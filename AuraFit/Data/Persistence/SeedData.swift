import Foundation
import SwiftData

/// Seeds default content (challenges, settings) on first launch.
@MainActor
enum SeedData {

    /// Ensures the singleton `AppSettings` exists and challenges are seeded. Idempotent.
    static func bootstrap(_ context: ModelContext) {
        ensureSettings(context)
        ensureChallenges(context)
        do {
            try context.save()
        } catch {
            AppLog.persistence.error("Seed save failed: \(error.localizedDescription)")
        }
    }

    static func ensureSettings(_ context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        let existing = (try? context.fetch(descriptor)) ?? []
        if existing.isEmpty {
            context.insert(AppSettings())
        }
    }

    static func ensureChallenges(_ context: ModelContext) {
        let descriptor = FetchDescriptor<Challenge>()
        let existing = (try? context.fetch(descriptor)) ?? []
        let existingByID = Dictionary(existing.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        for challenge in defaultChallenges() {
            guard let current = existingByID[challenge.id] else {
                context.insert(challenge)
                continue
            }
            // Refresh the presentation/rule fields on stores seeded by an older build so the
            // description a user reads always matches the rule the repository enforces.
            // Progress (`contributingSessionIDs`, `isCompleted`, `startDate`) is left untouched.
            current.title = challenge.title
            current.subtitle = challenge.subtitle
            current.details = challenge.details
            current.systemImage = challenge.systemImage
            current.accentHex = challenge.accentHex
            current.goalCount = challenge.goalCount
            current.minScore = challenge.minScore
            current.isFeatured = challenge.isFeatured
        }
    }

    /// The shipped challenge set.
    ///
    /// `details` is a contract: every rule described here is enforced by
    /// `SessionRepository.qualifies(session:for:)`, and nothing is enforced that isn't described.
    static func defaultChallenges() -> [Challenge] {
        [
            Challenge(
                id: "challenge.monochrome",
                title: "Monochrome Mastery",
                subtitle: "Five tonal fits",
                details: "Score 60+ on 5 fits whose colors stay in a single family. Show off your range within one palette.",
                systemImage: "circle.lefthalf.filled",
                accentHex: "8E73F5",
                goalCount: 5,
                minScore: 60,
                isFeatured: true
            ),
            Challenge(
                id: "challenge.streak7",
                title: "7-Day Glow Up",
                subtitle: "Seven different days",
                details: "Scan a fit on 7 different days and watch your average climb. Extra scans in a day don't count twice.",
                systemImage: "flame.fill",
                accentHex: "FB8B6B",
                goalCount: 7,
                minScore: 0
            ),
            Challenge(
                id: "challenge.mainchar",
                title: "Main Character Moment",
                subtitle: "Hit a 90+",
                details: "Land a single fit scoring 90 or above. Pure main character energy.",
                systemImage: "star.fill",
                accentHex: "5BD5F5",
                goalCount: 1,
                minScore: 90
            ),
            Challenge(
                id: "challenge.colorpop",
                title: "Color Pop",
                subtitle: "Three bold palettes",
                details: "Earn a Color Harmony score of 80+ on three different fits.",
                systemImage: "paintpalette.fill",
                accentHex: "57E08C",
                goalCount: 3,
                minScore: 0
            )
        ]
    }
}
