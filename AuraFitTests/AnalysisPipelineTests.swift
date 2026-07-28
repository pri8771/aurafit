import XCTest
import SwiftData
import UIKit
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

    // MARK: - Cancellation (AURA-ENG-008)

    /// A tiny solid-color image: enough for the pipeline to run, cheap enough for a unit test.
    /// Vision pose/segmentation don't produce results in the simulator, which is irrelevant here —
    /// these tests only care that the run stops and persists nothing.
    private func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 64, height: 96)).image { ctx in
            UIColor.systemIndigo.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 64, height: 96))
        }
    }

    func testCancellingBeforeFirstStageThrowsCancellationError() async {
        let pipeline = AnalysisPipeline()
        let image = testImage()

        let task = Task { () -> FitAnalysisResult in
            try await pipeline.analyze(image: image, stepDelay: .milliseconds(50))
        }
        // The task body can't start before this synchronous scope suspends, so the first
        // checkpoint is guaranteed to observe the cancellation.
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected the cancelled analysis to throw")
        } catch is CancellationError {
            // Expected.
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }
    }

    func testCancellingMidRunStopsThePipeline() async throws {
        let pipeline = AnalysisPipeline()
        let image = testImage()

        // Long step delays leave a wide window to cancel inside the run.
        let task = Task { () -> FitAnalysisResult in
            try await pipeline.analyze(image: image, stepDelay: .milliseconds(400))
        }
        try await Task.sleep(for: .milliseconds(120))
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected the cancelled analysis to throw")
        } catch is CancellationError {
            // Expected.
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }
    }

    /// The scan flow's contract: a cancelled analysis never reaches `createSession` (which is what
    /// `ScanView` gates the scan-quota increment on), so the store is left exactly as it was.
    @MainActor
    func testCancelledScanPersistsNoSession() async throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext
        SeedData.bootstrap(context)
        let repository = SessionRepository(context: context)
        let service = FitAnalysisService()
        let image = testImage()

        let task = Task { @MainActor in
            // Mirrors `ScanView.runAnalysis`: nothing is written until analysis returns a result.
            let result = try await service.analyze(image, stepDelay: .milliseconds(400))
            _ = try repository.createSession(result: result, originalImagePath: nil)
        }
        task.cancel()
        let outcome = await task.result
        if case .success = outcome { XCTFail("Expected the cancelled scan to abort") }

        XCTAssertEqual(try context.fetch(FetchDescriptor<FitSession>()).count, 0)

        // The service is reusable for the next attempt once reset.
        service.reset()
        XCTAssertFalse(service.isAnalyzing)
        XCTAssertEqual(service.currentStep, .normalizing)
        XCTAssertTrue(service.completedSteps.isEmpty)
    }

    func testColorNameMapping() {
        XCTAssertEqual(OutfitClassifierService.colorName(for: RGBColor(0, 0, 0)), "Black")
        XCTAssertEqual(OutfitClassifierService.colorName(for: RGBColor(1, 1, 1)), "White")
        XCTAssertEqual(OutfitClassifierService.colorName(for: RGBColor(0.05, 0.3, 0.9)), "Blue")
    }
}
