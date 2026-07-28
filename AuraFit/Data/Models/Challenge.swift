import Foundation
import SwiftData

/// A style challenge the user can participate in (e.g. "Monochrome Week").
///
/// `goalCount` and `minScore` cover the rules every challenge shares; anything more specific
/// (distinct days, palette shape, a per-metric floor) lives in
/// `SessionRepository.qualifies(session:for:)`, keyed by `id` and kept in step with `details`.
@Model
final class Challenge {
    @Attribute(.unique) var id: String
    var title: String
    var subtitle: String
    var details: String
    var systemImage: String
    var accentHex: String

    /// Target number of qualifying scans to complete the challenge.
    var goalCount: Int
    /// Minimum overall score for a scan to count toward the challenge (0 = any).
    var minScore: Int

    var startDate: Date
    var endDate: Date?

    /// IDs of `FitSession`s that count toward this challenge.
    var contributingSessionIDs: [String]
    var isFeatured: Bool
    var isCompleted: Bool

    init(
        id: String,
        title: String,
        subtitle: String,
        details: String,
        systemImage: String,
        accentHex: String,
        goalCount: Int,
        minScore: Int = 0,
        startDate: Date = .now,
        endDate: Date? = nil,
        contributingSessionIDs: [String] = [],
        isFeatured: Bool = false,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.details = details
        self.systemImage = systemImage
        self.accentHex = accentHex
        self.goalCount = goalCount
        self.minScore = minScore
        self.startDate = startDate
        self.endDate = endDate
        self.contributingSessionIDs = contributingSessionIDs
        self.isFeatured = isFeatured
        self.isCompleted = isCompleted
    }

    var progress: Double {
        guard goalCount > 0 else { return 0 }
        return Double(contributingSessionIDs.count) / Double(goalCount)
    }

    var completedCount: Int { contributingSessionIDs.count }
}
