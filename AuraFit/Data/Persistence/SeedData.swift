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
        let existingIDs = Set(existing.map(\.id))
        for challenge in defaultChallenges() where !existingIDs.contains(challenge.id) {
            context.insert(challenge)
        }
    }

    static func defaultChallenges() -> [Challenge] {
        [
            Challenge(
                id: "challenge.monochrome",
                title: "Monochrome Mastery",
                subtitle: "Five tonal fits",
                details: "Score 5 fits built around a single color family. Show off your range within one palette.",
                systemImage: "circle.lefthalf.filled",
                accentHex: "8E73F5",
                goalCount: 5,
                minScore: 60,
                isFeatured: true
            ),
            Challenge(
                id: "challenge.streak7",
                title: "7-Day Glow Up",
                subtitle: "A week of fits",
                details: "Scan a fit every day for 7 days and watch your weekly average climb.",
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
