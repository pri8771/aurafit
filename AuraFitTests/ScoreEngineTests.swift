import XCTest
@testable import AuraFit

final class ScoreEngineTests: XCTestCase {

    private let engine = ScoreEngine()

    private func signals(
        cohesion: Double = 0.7,
        harmony: Double = 0.7,
        posture: Double = 0.7,
        poseDetected: Bool = true,
        fullBody: Bool = true,
        coverage: Double = 0.8,
        centering: Double = 0.9,
        brightness: Double = 0.5,
        contrast: Double = 0.6,
        sharpness: Double = 0.6,
        exposure: Double = 0.9,
        bgComplexity: Double = 0.2,
        subjectFraction: Double = 0.45,
        segAvailable: Bool = true
    ) -> AnalysisSignals {
        AnalysisSignals(
            pose: PoseSignals(detected: poseDetected, confidence: 0.8, fullBodyVisible: fullBody,
                              verticalCoverage: coverage, horizontalCentering: centering, posture: posture),
            segmentation: SegmentationSignals(available: segAvailable, subjectFraction: subjectFraction, backgroundComplexity: bgComplexity),
            quality: QualitySignals(brightness: brightness, contrast: contrast, sharpness: sharpness, exposureBalance: exposure),
            color: ColorSignals(palette: [], harmony: harmony, cohesion: cohesion),
            outfit: OutfitSignals(cohesion: cohesion, persona: .classic, tags: [], usedModel: false)
        )
    }

    func testScoreInValidRange() {
        let score = engine.score(from: signals())
        XCTAssertGreaterThanOrEqual(score.overall, 0)
        XCTAssertLessThanOrEqual(score.overall, 100)
    }

    func testAllSevenMetricsPresent() {
        let score = engine.score(from: signals())
        XCTAssertEqual(Set(score.metrics.map(\.kind)), Set(FitMetricKind.allCases))
        XCTAssertEqual(score.metrics.count, 7)
    }

    func testHigherSignalsProduceHigherScore() {
        let low = engine.score(from: signals(cohesion: 0.1, harmony: 0.1, posture: 0.1,
                                             coverage: 0.2, centering: 0.2, brightness: 0.95,
                                             contrast: 0.1, sharpness: 0.1, exposure: 0.1,
                                             bgComplexity: 0.95, subjectFraction: 0.95))
        let high = engine.score(from: signals(cohesion: 0.95, harmony: 0.95, posture: 0.95,
                                              coverage: 0.85, centering: 0.95, brightness: 0.52,
                                              contrast: 0.7, sharpness: 0.7, exposure: 0.95,
                                              bgComplexity: 0.05, subjectFraction: 0.45))
        XCTAssertGreaterThan(high.overall, low.overall)
    }

    func testWeightsSumToOneAcrossWeightedMetrics() {
        let total = FitMetricKind.allCases.map(\.weight).reduce(0, +)
        XCTAssertEqual(total, 1.0, accuracy: 0.0001)
    }

    func testWeightedOverallMatchesManualComputation() {
        let metrics: [FitMetric] = [
            FitMetric(kind: .outfitCohesion, value: 80),
            FitMetric(kind: .colorHarmony, value: 60),
            FitMetric(kind: .posePosture, value: 70),
            FitMetric(kind: .lighting, value: 50),
            FitMetric(kind: .framing, value: 90),
            FitMetric(kind: .backgroundCleanliness, value: 40),
            FitMetric(kind: .confidenceEnergy, value: 100)  // weight 0, must not count
        ]
        let expected = 80 * 0.25 + 60 * 0.20 + 70 * 0.15 + 50 * 0.15 + 90 * 0.15 + 40 * 0.10
        let result = engine.weightedOverall(metrics)
        XCTAssertEqual(Double(result), expected.rounded(), accuracy: 1.0)
    }

    func testNoPoseFallsBackToNeutralPose() {
        let score = engine.score(from: signals(poseDetected: false))
        let pose = score.metric(.posePosture)?.value ?? 0
        XCTAssertEqual(pose, 52)
    }

    func testLabelMatchesScore() {
        let score = engine.score(from: signals(cohesion: 0.99, harmony: 0.99, posture: 0.99,
                                               coverage: 0.9, centering: 0.99, exposure: 0.99,
                                               contrast: 0.8, sharpness: 0.8, bgComplexity: 0.02))
        XCTAssertEqual(score.label, ScoreLabel.from(score: score.overall))
    }
}
