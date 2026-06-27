import XCTest
@testable import AuraFit

/// Exercises the scoring path of the pipeline with synthetic (mocked) Vision signals,
/// avoiding any dependency on real image analysis.
final class AnalysisPipelineTests: XCTestCase {

    private func strongSignals() -> AnalysisSignals {
        AnalysisSignals(
            pose: PoseSignals(detected: true, confidence: 0.9, fullBodyVisible: true,
                              verticalCoverage: 0.85, horizontalCentering: 0.95, posture: 0.92),
            segmentation: SegmentationSignals(available: true, subjectFraction: 0.45, backgroundComplexity: 0.08),
            quality: QualitySignals(brightness: 0.52, contrast: 0.7, sharpness: 0.7, exposureBalance: 0.95),
            color: ColorSignals(palette: [RGBColor(0.1, 0.1, 0.1), RGBColor(0.2, 0.2, 0.6)], harmony: 0.9, cohesion: 0.9),
            outfit: OutfitSignals(cohesion: 0.9, persona: .streetwear, tags: [OutfitTag(label: "Streetwear", confidence: 0.8)], usedModel: false)
        )
    }

    func testScoreForSignalsReturnsResult() async {
        let pipeline = AnalysisPipeline()
        let result = await pipeline.score(for: strongSignals())
        XCTAssertGreaterThan(result.score.overall, 70)
        XCTAssertEqual(result.persona, .streetwear)
        XCTAssertFalse(result.tips.isEmpty)
        XCTAssertEqual(result.diagnostics.poseDetected, true)
        XCTAssertEqual(result.diagnostics.segmentationAvailable, true)
    }

    func testTipsAreBoundedThreeToFive() async {
        let pipeline = AnalysisPipeline()
        let result = await pipeline.score(for: strongSignals())
        XCTAssertGreaterThanOrEqual(result.tips.count, 3)
        XCTAssertLessThanOrEqual(result.tips.count, 5)
    }

    func testWeakSignalsProduceLowerScoreAndMoreTips() async {
        let pipeline = AnalysisPipeline()
        var weak = strongSignals()
        weak.pose = PoseSignals(detected: true, confidence: 0.3, fullBodyVisible: false,
                                verticalCoverage: 0.3, horizontalCentering: 0.3, posture: 0.3)
        weak.quality = QualitySignals(brightness: 0.2, contrast: 0.2, sharpness: 0.2, exposureBalance: 0.3)
        weak.color = ColorSignals(palette: [], harmony: 0.2, cohesion: 0.2)
        weak.outfit = OutfitSignals(cohesion: 0.2, persona: .undetermined, tags: [], usedModel: false)
        weak.segmentation = SegmentationSignals(available: true, subjectFraction: 0.9, backgroundComplexity: 0.9)

        let strong = await pipeline.score(for: strongSignals())
        let weakResult = await pipeline.score(for: weak)
        XCTAssertLessThan(weakResult.score.overall, strong.score.overall)
    }

    func testHeuristicClassifierInfersPersona() {
        let classifier = OutfitClassifierService()
        // Dark, low-saturation palette → streetwear.
        let dark = ColorSignals(palette: [RGBColor(0.05, 0.05, 0.05), RGBColor(0.1, 0.1, 0.12)],
                                harmony: 0.7, cohesion: 0.8)
        let pose = PoseSignals(detected: true, confidence: 0.6, fullBodyVisible: true,
                               verticalCoverage: 0.6, horizontalCentering: 0.6, posture: 0.6)
        let result = classifier.heuristicClassification(colors: dark, pose: pose)
        XCTAssertEqual(result.persona, .streetwear)
        XCTAssertFalse(result.usedModel)
    }

    func testColorNameMapping() {
        XCTAssertEqual(OutfitClassifierService.colorName(for: RGBColor(0, 0, 0)), "Black")
        XCTAssertEqual(OutfitClassifierService.colorName(for: RGBColor(1, 1, 1)), "White")
        XCTAssertEqual(OutfitClassifierService.colorName(for: RGBColor(0.05, 0.3, 0.9)), "Blue")
    }
}
