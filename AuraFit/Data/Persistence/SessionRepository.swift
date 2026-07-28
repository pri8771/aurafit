import Foundation
import SwiftData

/// Centralizes create/update/delete of `FitSession`s plus associated file cleanup and
/// challenge progress updates. Operates on a `ModelContext` (main-actor bound).
@MainActor
struct SessionRepository {
    let context: ModelContext
    let imageStore: ImageFileStore

    init(context: ModelContext, imageStore: ImageFileStore = ImageFileStore()) {
        self.context = context
        self.imageStore = imageStore
    }

    // MARK: - Create

    @discardableResult
    func createSession(
        result: FitAnalysisResult,
        originalImagePath: String?
    ) -> FitSession {
        let session = FitSession(
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
        save()
        return session
    }

    // MARK: - Update

    func setFavorite(_ session: FitSession, _ isFavorite: Bool) {
        session.isFavorite = isFavorite
        save()
    }

    func attachScorecard(_ path: String, includesWatermark: Bool, to session: FitSession) {
        guard session.modelContext != nil else { return }
        session.scorecardImagePath = path
        session.scorecardIncludesWatermark = includesWatermark
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

    // MARK: - Challenges

    /// Updates challenge progress when a new qualifying session is created.
    func updateChallengeProgress(for session: FitSession) {
        let descriptor = FetchDescriptor<Challenge>()
        guard let challenges = try? context.fetch(descriptor) else { return }
        let id = session.id.uuidString
        var contributed: [String] = []

        for challenge in challenges where !challenge.isCompleted {
            guard qualifies(session: session, for: challenge) else { continue }
            guard !challenge.contributingSessionIDs.contains(id) else { continue }
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

    private func qualifies(session: FitSession, for challenge: Challenge) -> Bool {
        switch challenge.id {
        case "challenge.colorpop":
            // Requires Color Harmony >= 80.
            return (session.metrics.first { $0.kind == .colorHarmony }?.value ?? 0) >= 80
        default:
            return session.overallScore >= challenge.minScore
        }
    }

    // MARK: - Save

    func save() {
        do {
            try context.save()
        } catch {
            AppLog.persistence.error("Save failed: \(error.localizedDescription)")
        }
    }
}
