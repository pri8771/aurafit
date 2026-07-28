import XCTest
import UIKit
@testable import AuraFit

/// Exercises the bundled MobileCLIP zero-shot classifier end to end: asset presence,
/// deterministic embedding + ranking, and integration through `OutfitClassifierService`.
final class CLIPZeroShotClassifierTests: XCTestCase {

    /// The encoder and label embeddings must ship in the app bundle. This test is the
    /// canary for the "model silently missing from the bundle" failure mode.
    func testClassifierLoadsFromAppBundle() {
        XCTAssertNotNil(
            CLIPZeroShotClassifier(),
            "MobileCLIPImageEncoder.mlmodelc / CLIPLabelEmbeddings.json missing from app bundle."
        )
    }

    func testClassifyProducesModelBackedSignals() throws {
        let classifier = try XCTUnwrap(CLIPZeroShotClassifier())
        let colors = ColorSignals(palette: [], harmony: 0.6, cohesion: 0.7)
        let signals = try XCTUnwrap(classifier.classify(image: Self.silhouetteImage(), colors: colors))

        XCTAssertTrue(signals.usedModel)
        XCTAssertNotEqual(signals.persona, .undetermined)
        XCTAssertFalse(signals.tags.isEmpty)
        for tag in signals.tags {
            XCTAssertGreaterThan(tag.confidence, 0)
            XCTAssertLessThanOrEqual(tag.confidence, 1)
        }
        // The persona tag's confidence is a real softmax probability, not a constant.
        XCTAssertNotEqual(signals.tags[0].confidence, 0.6, accuracy: 0.0001)
    }

    func testClassificationIsDeterministic() throws {
        let classifier = try XCTUnwrap(CLIPZeroShotClassifier())
        let colors = ColorSignals(palette: [], harmony: 0.5, cohesion: 0.5)
        let image = Self.silhouetteImage()
        let first = try XCTUnwrap(classifier.classify(image: image, colors: colors))
        let second = try XCTUnwrap(classifier.classify(image: image, colors: colors))

        XCTAssertEqual(first.persona, second.persona)
        XCTAssertEqual(first.tags.map(\.label), second.tags.map(\.label))
        for (a, b) in zip(first.tags, second.tags) {
            XCTAssertEqual(a.confidence, b.confidence, accuracy: 0.001)
        }
    }

    func testServicePrefersClipOverHeuristic() {
        let service = OutfitClassifierService()
        let colors = ColorSignals(palette: [RGBColor(0.1, 0.1, 0.12)], harmony: 0.7, cohesion: 0.8)
        let signals = service.classify(image: Self.silhouetteImage(), colors: colors, pose: .unavailable)
        XCTAssertTrue(signals.usedModel, "Service should route through the bundled MobileCLIP classifier.")
    }

    func testCenterCropProducesRequestedSize() throws {
        let buffer = try XCTUnwrap(
            CLIPZeroShotClassifier.centerCroppedPixelBuffer(from: Self.silhouetteImage(), side: 256)
        )
        XCTAssertEqual(CVPixelBufferGetWidth(buffer), 256)
        XCTAssertEqual(CVPixelBufferGetHeight(buffer), 256)
    }

    // MARK: - Fixture

    /// Draws a simple dark full-body silhouette on a light background — the same shape
    /// family as the UI-test QA fixture, generated in code so the unit target needs no asset.
    private static func silhouetteImage() -> UIImage {
        let size = CGSize(width: 512, height: 768)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            UIColor(white: 0.93, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            UIColor(white: 0.12, alpha: 1).setFill()
            // Head.
            ctx.cgContext.fillEllipse(in: CGRect(x: 216, y: 60, width: 80, height: 80))
            // Torso.
            ctx.fill(CGRect(x: 196, y: 150, width: 120, height: 240))
            // Arms.
            ctx.fill(CGRect(x: 156, y: 160, width: 36, height: 200))
            ctx.fill(CGRect(x: 320, y: 160, width: 36, height: 200))
            // Legs.
            ctx.fill(CGRect(x: 200, y: 395, width: 48, height: 280))
            ctx.fill(CGRect(x: 264, y: 395, width: 48, height: 280))
        }
    }
}
