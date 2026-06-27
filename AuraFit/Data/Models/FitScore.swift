import SwiftUI

/// The computed scoring result for a fit: the weighted overall score, its label,
/// and the per-metric breakdown. A pure value type produced by `ScoreEngine`.
struct FitScore: Codable, Hashable, Sendable {
    var overall: Int
    var label: ScoreLabel
    var metrics: [FitMetric]

    init(overall: Int, metrics: [FitMetric]) {
        self.overall = overall.clampedScore
        self.metrics = metrics
        self.label = ScoreLabel.from(score: overall.clampedScore)
    }

    func metric(_ kind: FitMetricKind) -> FitMetric? {
        metrics.first { $0.kind == kind }
    }

    /// A neutral, placeholder score used for previews and error fallbacks.
    static var placeholder: FitScore {
        FitScore(
            overall: 72,
            metrics: FitMetricKind.allCases.map { FitMetric(kind: $0, value: 72) }
        )
    }
}
