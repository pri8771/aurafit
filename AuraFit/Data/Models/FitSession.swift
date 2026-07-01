import Foundation
import SwiftData

/// A persisted record of one fit scan and its results.
///
/// Image/video binaries are *not* stored in SwiftData; instead we persist relative file
/// paths (within the app's documents directory) and load lazily via `ImageFileStore`.
@Model
final class FitSession {
    @Attribute(.unique) var id: UUID
    var createdAt: Date

    /// Relative paths within the documents directory (resolved by `ImageFileStore`).
    var originalImagePath: String?
    var scorecardImagePath: String?
    var scorecardIncludesWatermark: Bool = false
    var revealVideoPath: String?

    var overallScore: Int
    /// Persisted as the raw value of `ScoreLabel`.
    var labelRaw: String
    /// Persisted as the raw value of `StylePersona`.
    var stylePersonaRaw: String

    var notes: String
    var isFavorite: Bool

    /// Stored inline as Codable arrays.
    var metrics: [FitMetric]
    var tips: [String]
    var outfitTags: [OutfitTag]
    /// Dominant palette as hex strings.
    var paletteHex: [String]

    /// IDs of challenges this scan contributed toward.
    var challengeIDs: [String]

    var appVersion: String

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        overallScore: Int,
        label: ScoreLabel,
        stylePersona: StylePersona,
        metrics: [FitMetric],
        tips: [String] = [],
        outfitTags: [OutfitTag] = [],
        paletteHex: [String] = [],
        originalImagePath: String? = nil,
        scorecardImagePath: String? = nil,
        scorecardIncludesWatermark: Bool = false,
        revealVideoPath: String? = nil,
        notes: String = "",
        isFavorite: Bool = false,
        challengeIDs: [String] = [],
        appVersion: String = AppInfo.version
    ) {
        self.id = id
        self.createdAt = createdAt
        self.overallScore = overallScore.clampedScore
        self.labelRaw = label.rawValue
        self.stylePersonaRaw = stylePersona.rawValue
        self.metrics = metrics
        self.tips = tips
        self.outfitTags = outfitTags
        self.paletteHex = paletteHex
        self.originalImagePath = originalImagePath
        self.scorecardImagePath = scorecardImagePath
        self.scorecardIncludesWatermark = scorecardIncludesWatermark
        self.revealVideoPath = revealVideoPath
        self.notes = notes
        self.isFavorite = isFavorite
        self.challengeIDs = challengeIDs
        self.appVersion = appVersion
    }

    // MARK: - Computed

    var label: ScoreLabel { ScoreLabel(rawValue: labelRaw) ?? .from(score: overallScore) }
    var stylePersona: StylePersona { StylePersona(rawValue: stylePersonaRaw) ?? .undetermined }

    var fitScore: FitScore { FitScore(overall: overallScore, metrics: metrics) }
}

/// App version helper used to stamp records.
enum AppInfo {
    static var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
