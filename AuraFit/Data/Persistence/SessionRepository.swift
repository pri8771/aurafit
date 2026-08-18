import Foundation
import SwiftData

/// A `ModelContext.save()` that failed. Surfaced (rather than swallowed) so the UI can tell the
/// user their scan was not stored instead of showing a result that vanishes on relaunch.
enum PersistenceError: LocalizedError {
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let detail):
            return "Your scan couldn't be saved to this device. \(detail)"
        }
    }
}

/// Centralizes create/update/delete of `FitSession`s plus associated file cleanup and
/// challenge progress updates. Operates on a `ModelContext` (main-actor bound).
@MainActor
struct SessionRepository {
    let context: ModelContext
    let imageStore: ImageFileStore
    /// Injectable so day-boundary logic can be tested deterministically.
    let calendar: Calendar

    init(context: ModelContext,
         imageStore: ImageFileStore = ImageFileStore(),
         calendar: Calendar = .current) {
        self.context = context
        self.imageStore = imageStore
        self.calendar = calendar
    }

    // MARK: - Create

    /// Creates and persists a session. Throws `PersistenceError.saveFailed` if the store rejects
    /// the write; in that case the half-built session (and any challenge progress it earned) is
    /// rolled back so the app never shows a scan that isn't actually stored.
    @discardableResult
    func createSession(
        result: FitAnalysisResult,
        originalImagePath: String?,
        createdAt: Date = .now
    ) throws -> FitSession {
        let session = FitSession(
            createdAt: createdAt,
            overallScore: result.score.overall,
            label: result.score.label,
            stylePersona: result.persona,
            metrics: result.score.metrics,
            tips: result.tips,
            photoTips: result.photoTips,
            outfitTags: result.outfitTags,
            paletteHex: result.palette.map(\.hexString),
            originalImagePath: originalImagePath
        )
        context.insert(session)
        updateChallengeProgress(for: session)
        do {
            try saveOrThrow()
        } catch {
            context.rollback()
            throw error
        }
        return session
    }

    // MARK: - Update

    func setFavorite(_ session: FitSession, _ isFavorite: Bool) {
        session.isFavorite = isFavorite
        save()
    }

    func attachScorecard(_ path: String, to session: FitSession) {
        guard session.modelContext != nil else { return }
        session.scorecardImagePath = path
        save()
    }

    func attachRevealVideo(_ path: String, to session: FitSession) {
        guard session.modelContext != nil else { return }
        session.revealVideoPath = path
        save()
    }

    // MARK: - Delete

    func delete(_ session: FitSession) {
        imageStore.deleteAssets(for: session)
        // Remove from any challenges.
        let id = session.id.uuidString
        let descriptor = FetchDescriptor<Challenge>()
        if let challenges = try? context.fetch(descriptor) {
            for challenge in challenges where challenge.contributingSessionIDs.contains(id) {
                challenge.contributingSessionIDs.removeAll { $0 == id }
                challenge.isCompleted = challenge.contributingSessionIDs.count >= challenge.goalCount
            }
        }
        context.delete(session)
        save()
    }

    // MARK: - Orphaned assets

    /// Guards the launch sweep so it runs at most once per process, even if the view that kicks it
    /// off re-appears or its task re-fires. Main-actor isolated along with the rest of the type.
    private static var hasReconciledAssets = false

    /// Every asset path the persisted sessions still point at.
    ///
    /// Throws instead of degrading to an empty set: "no paths are referenced" is precisely the
    /// instruction to delete everything, so a failed fetch has to abort the sweep, not drive it.
    func referencedAssetPaths() throws -> Set<String> {
        let sessions = try context.fetch(FetchDescriptor<FitSession>())
        var paths = Set<String>()
        for session in sessions {
            paths.formUnion([
                session.originalImagePath,
                session.scorecardImagePath,
                session.revealVideoPath
            ].compactMap { $0 })
        }
        return paths
    }

    /// Collects staged files that no session ever claimed (AURA-ENG-035).
    ///
    /// A capture is written to disk before analysis runs, so a crash mid-pipeline leaves a file
    /// nothing references and nothing deletes. This is the launch-time sweep for those.
    ///
    /// Runs at most once per launch. The fetch happens here on the main actor — a personal scan
    /// history stays small — and the disk work is handed to a detached background task, so the
    /// caller only ever awaits a suspension. `ImageFileStore` additionally spares any file younger
    /// than its grace period, which is what keeps a scan that is *currently* in flight safe.
    ///
    /// Every failure is logged and swallowed: this is housekeeping, and it must never be able to
    /// hold up launch.
    func reconcileOrphanedAssets(minimumAge: TimeInterval = ImageFileStore.orphanGracePeriod) async {
        guard !Self.hasReconciledAssets else { return }
        Self.hasReconciledAssets = true

        let referenced: Set<String>
        do {
            referenced = try referencedAssetPaths()
        } catch {
            AppLog.persistence.error("Asset reconcile skipped; session fetch failed: \(error.localizedDescription)")
            return
        }

        let store = imageStore
        _ = await Task.detached(priority: .utility) {
            store.reconcileOrphans(referencedRelativePaths: referenced, minimumAge: minimumAge)
        }.value
    }

    // MARK: - Challenges

    /// Updates challenge progress when a new qualifying session is created.
    func updateChallengeProgress(for session: FitSession) {
        let descriptor = FetchDescriptor<Challenge>()
        guard let challenges = try? context.fetch(descriptor) else { return }
        let id = session.id.uuidString
        var contributed: [String] = []

        for challenge in challenges where !challenge.isCompleted {
            guard !challenge.contributingSessionIDs.contains(id) else { continue }
            guard qualifies(session: session, for: challenge) else { continue }
            challenge.contributingSessionIDs.append(id)
            if challenge.contributingSessionIDs.count >= challenge.goalCount {
                challenge.isCompleted = true
            }
            contributed.append(challenge.id)
        }
        if !contributed.isEmpty {
            session.challengeIDs = contributed
        }
    }

    /// Whether `session` counts toward `challenge`.
    ///
    /// Each branch must match the challenge's user-facing `details` copy — a challenge that
    /// completes on rules the user was never told is worse than no challenge at all.
    func qualifies(session: FitSession, for challenge: Challenge) -> Bool {
        // Every challenge honors its own score floor first (0 = any score).
        guard session.overallScore >= challenge.minScore else { return false }

        switch challenge.id {
        case "challenge.colorpop":
            // "Earn a Color Harmony score of 80+ on three different fits."
            return (session.metrics.first { $0.kind == .colorHarmony }?.value ?? 0) >= 80

        case "challenge.monochrome":
            // "Score 5 fits built around a single color family" — the palette itself has to be
            // tonal, not merely a 60+ scan.
            return Self.isMonochromatic(paletteHex: session.paletteHex)

        case "challenge.streak7":
            // "Scan a fit on 7 different days" — a day that already contributed can't count twice,
            // otherwise seven scans in one afternoon would complete the challenge.
            let day = calendar.startOfDay(for: session.createdAt)
            return !contributingDays(of: challenge).contains(day)

        default:
            // "challenge.mainchar" and any future score-only challenge: the score floor above is
            // the whole rule.
            return true
        }
    }

    /// Start-of-day dates of the sessions already counted toward `challenge`.
    private func contributingDays(of challenge: Challenge) -> Set<Date> {
        guard !challenge.contributingSessionIDs.isEmpty else { return [] }
        let wanted = Set(challenge.contributingSessionIDs)
        // Fetched unfiltered and matched in memory: SwiftData predicates can't test membership in
        // a Swift `Set` of UUID strings, and a personal scan history stays small.
        guard let sessions = try? context.fetch(FetchDescriptor<FitSession>()) else { return [] }
        return Set(
            sessions
                .filter { wanted.contains($0.id.uuidString) }
                .map { calendar.startOfDay(for: $0.createdAt) }
        )
    }

    /// True when a stored palette reads as a single color family.
    ///
    /// Only the `dominant` leading entries are judged — `ColorHarmonyService` orders the palette by
    /// pixel population, and the trailing buckets are mostly background noise that would disqualify
    /// otherwise tonal fits. Near-neutral entries (black/white/grey) are ignored too: they anchor a
    /// tonal look rather than introducing a hue, so an all-neutral palette counts as its own
    /// (achromatic) family. What remains must sit inside a narrow arc of the color wheel.
    ///
    /// The arc and dominance window are heuristics tuned against synthetic palettes; they still
    /// need confirmation against real captures on device.
    nonisolated static func isMonochromatic(
        paletteHex: [String],
        dominant: Int = 3,
        maxHueSpread: Double = 0.10
    ) -> Bool {
        let colors = paletteHex.prefix(dominant).compactMap(RGBColor.fromHex)
        guard !colors.isEmpty else { return false }

        // Same saturation floor `ColorHarmonyService` uses to separate hues from neutrals.
        let hues = colors.map(\.hsb).filter { $0.s > 0.15 }.map(\.h)
        guard hues.count > 1 else { return true }

        for i in 0..<(hues.count - 1) {
            for j in (i + 1)..<hues.count where hueDistance(hues[i], hues[j]) > maxHueSpread {
                return false
            }
        }
        return true
    }

    /// Shortest distance between two hues on the [0,1) wheel, range 0...0.5.
    nonisolated private static func hueDistance(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 1.0)
        return min(diff, 1 - diff)
    }

    // MARK: - Save

    /// Saves pending changes, throwing `PersistenceError.saveFailed` on failure.
    func saveOrThrow() throws {
        do {
            try context.save()
        } catch {
            AppLog.persistence.error("Save failed: \(error.localizedDescription)")
            throw PersistenceError.saveFailed(error.localizedDescription)
        }
    }

    /// Save variant for secondary mutations (favorites, attachment paths, deletes) where there is
    /// no meaningful recovery beyond retrying the gesture. Returns `false` — and logs — instead of
    /// throwing, so callers can react without every call site becoming a `do/catch`.
    @discardableResult
    func save() -> Bool {
        do {
            try saveOrThrow()
            return true
        } catch {
            return false
        }
    }
}
