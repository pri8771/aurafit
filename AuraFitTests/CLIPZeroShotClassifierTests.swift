import XCTest
import UIKit
@testable import AuraFit

/// The zero-shot classifier is retained in the codebase but ships with **no bundled encoder**:
/// MobileCLIP's licence permits research use only (see `docs/DECISIONS.md` DEC-004), so the
/// weights were removed before release. A permissively-licensed encoder is planned for Phase 1
/// (`AURA-ENG-038`).
///
/// These tests therefore assert the *absence* contract — that the app degrades cleanly to the
/// heuristic path rather than crashing or silently producing model-shaped output — plus the
/// encoder-agnostic helpers that survive the removal.
final class CLIPZeroShotClassifierTests: XCTestCase {

    /// Guards the removal: if an encoder is ever re-bundled, this fails and forces a
    /// deliberate revisit of the licence decision and of the tests below.
    func testNoEncoderIsBundled() {
        XCTAssertNil(
            Bundle.main.url(forResource: CLIPZeroShotClassifier.modelResourceName, withExtension: "mlmodelc"),
            "An encoder is bundled again — re-check licensing (DEC-004) before shipping."
        )
        XCTAssertNil(CLIPZeroShotClassifier(), "Classifier must not initialize without a bundled encoder.")
    }

    /// The service must fall through to the heuristic instead of failing.
    func testServiceFallsBackToHeuristicWithoutAnEncoder() {
        let service = OutfitClassifierService()
        XCTAssertNil(service.zeroShotClassifier)

        let colors = ColorSignals(palette: [RGBColor(0.1, 0.1, 0.12)], harmony: 0.7, cohesion: 0.8)
        let signals = service.classify(image: Self.silhouetteImage(), colors: colors, pose: .unavailable)

        XCTAssertFalse(signals.usedModel, "Without an encoder the result must be marked heuristic.")
        XCTAssertFalse(signals.tags.isEmpty)
    }

    /// Heuristic tags must not carry a fabricated confidence (AURA-ENG-005).
    func testHeuristicTagsCarryNoFabricatedConfidence() {
        let colors = ColorSignals(palette: [RGBColor(0.1, 0.1, 0.12)], harmony: 0.7, cohesion: 0.8)
        let signals = OutfitClassifierService().classify(
            image: Self.silhouetteImage(), colors: colors, pose: .unavailable
        )
        for tag in signals.tags {
            XCTAssertEqual(tag.confidence, OutfitClassifierService.noModelConfidence,
                           "Heuristic tag \(tag.label) must use the documented sentinel, not a made-up value.")
        }
    }

    /// PhotoCoach must still produce guidance with no CLIP issue assessment available.
    func testPhotoCoachWorksWithoutIssueAssessment() {
        let signals = AnalysisSignals(
            pose: PoseSignals(detected: true, confidence: 0.8, fullBodyVisible: false,
                              verticalCoverage: 0.7, horizontalCentering: 0.9,
                              posture: 0.8, boundingBox: nil),
            segmentation: .unavailable,
            quality: QualitySignals(brightness: 0.2, contrast: 0.5, sharpness: 0.6, exposureBalance: 0.4),
            color: .neutral,
            outfit: .neutral
        )
        let tips = PhotoCoach().tips(signals: signals, issues: nil)
        XCTAssertFalse(tips.isEmpty, "Signal-derived tips must survive without CLIP issue labels.")
        XCTAssertNil(PhotoCoach().rejectionDetail(issues: nil))
    }

    /// Encoder-agnostic geometry helper, still used by whatever encoder lands next.
    func testCenterCropProducesRequestedSize() throws {
        let buffer = try XCTUnwrap(
            CLIPZeroShotClassifier.centerCroppedPixelBuffer(from: Self.silhouetteImage(), side: 256)
        )
        XCTAssertEqual(CVPixelBufferGetWidth(buffer), 256)
        XCTAssertEqual(CVPixelBufferGetHeight(buffer), 256)
    }

    func testPersonCropFallsBackWithoutABox() {
        let image = Self.silhouetteImage()
        XCTAssertEqual(CLIPZeroShotClassifier.personCrop(from: image, boundingBox: nil).size, image.size)
    }

    // MARK: - Fixture

    private static func silhouetteImage() -> UIImage {
        let size = CGSize(width: 512, height: 768)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor(white: 0.93, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor(white: 0.12, alpha: 1).setFill()
            ctx.cgContext.fillEllipse(in: CGRect(x: 216, y: 60, width: 80, height: 80))
            ctx.fill(CGRect(x: 196, y: 150, width: 120, height: 240))
            ctx.fill(CGRect(x: 200, y: 395, width: 48, height: 280))
            ctx.fill(CGRect(x: 264, y: 395, width: 48, height: 280))
        }
    }
}
