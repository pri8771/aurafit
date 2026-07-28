import XCTest
@testable import AuraFit

/// Covers the live-coach decision engine and the post-capture PhotoCoach guidance.
final class CoachAndPhotoTipsTests: XCTestCase {

    // MARK: - CoachHintEngine

    private func reading(
        brightness: Double = 0.5,
        person: Bool = true,
        fullBody: Bool = true,
        coverage: Double = 0.7,
        centerX: Double = 0.5
    ) -> CoachHintEngine.FrameReading {
        .init(brightness: brightness, personDetected: person, fullBodyVisible: fullBody,
              verticalCoverage: coverage, horizontalCenter: centerX)
    }

    func testDarknessBeatsEverything() {
        let engine = CoachHintEngine()
        XCTAssertEqual(engine.hint(for: reading(brightness: 0.1, person: false)), .moreLight)
    }

    func testNoPersonAsksToStepIn() {
        XCTAssertEqual(CoachHintEngine().hint(for: reading(person: false)), .stepIntoFrame)
    }

    func testCroppedBodyAsksToStepBack() {
        // Big coverage but ankles/nose missing = body runs out of frame.
        XCTAssertEqual(CoachHintEngine().hint(for: reading(fullBody: false, coverage: 0.9)), .stepBack)
    }

    func testSmallSubjectAsksToComeCloser() {
        XCTAssertEqual(CoachHintEngine().hint(for: reading(coverage: 0.3)), .comeCloser)
    }

    func testOffCenterAsksToCenter() {
        XCTAssertEqual(CoachHintEngine().hint(for: reading(centerX: 0.2)), .centerYourself)
    }

    func testGoodFrameIsPerfect() {
        XCTAssertEqual(CoachHintEngine().hint(for: reading()), .perfect)
    }

    // MARK: - PhotoCoach

    private func signals(
        brightness: Double = 0.55,
        sharpness: Double = 0.6,
        fullBody: Bool = true,
        subjectFraction: Double = 0.45,
        centering: Double = 0.9,
        backgroundComplexity: Double = 0.3
    ) -> AnalysisSignals {
        AnalysisSignals(
            pose: PoseSignals(detected: true, confidence: 0.8, fullBodyVisible: fullBody,
                              verticalCoverage: 0.7, horizontalCentering: centering,
                              posture: 0.8, boundingBox: nil),
            segmentation: SegmentationSignals(available: true, subjectFraction: subjectFraction,
                                              backgroundComplexity: backgroundComplexity),
            quality: QualitySignals(brightness: brightness, contrast: 0.5,
                                    sharpness: sharpness, exposureBalance: 0.7),
            color: .neutral,
            outfit: .neutral
        )
    }

    func testCleanShotYieldsNoPhotoTips() {
        XCTAssertTrue(PhotoCoach().tips(signals: signals(), issues: nil).isEmpty)
    }

    func testDarkCroppedShotYieldsOrderedTips() {
        let tips = PhotoCoach().tips(signals: signals(brightness: 0.2, fullBody: false), issues: nil)
        XCTAssertEqual(tips.count, 2)
        XCTAssertTrue(tips[0].contains("head to shoes"), "framing tip should lead")
        XCTAssertTrue(tips[1].contains("light"))
    }

    func testTipsAreCapped() {
        let tips = PhotoCoach().tips(
            signals: signals(brightness: 0.2, sharpness: 0.1, fullBody: false,
                             subjectFraction: 0.1, centering: 0.3, backgroundComplexity: 0.9),
            issues: nil
        )
        XCTAssertEqual(tips.count, 3)
    }

    func testClipIssueTriggersTipWithoutSignalEvidence() {
        let issues = CLIPZeroShotClassifier.PhotoIssueAssessment(
            goodPhoto: 0.2, issues: ["blurry": 0.6]
        )
        let tips = PhotoCoach().tips(signals: signals(), issues: issues)
        XCTAssertTrue(tips.contains { $0.contains("soft") || $0.contains("steady") })
    }

    func testRejectionDetailForDominantIssue() {
        let coach = PhotoCoach()
        let noPerson = CLIPZeroShotClassifier.PhotoIssueAssessment(
            goodPhoto: 0.1, issues: ["no person": 0.8]
        )
        XCTAssertNotNil(coach.rejectionDetail(issues: noPerson))

        let fine = CLIPZeroShotClassifier.PhotoIssueAssessment(
            goodPhoto: 0.8, issues: ["blurry": 0.1]
        )
        XCTAssertNil(coach.rejectionDetail(issues: fine))
    }

    // MARK: - Person crop

    func testPersonCropShrinksToBox() throws {
        let size = CGSize(width: 400, height: 800)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            UIColor.white.setFill(); ctx.fill(CGRect(origin: .zero, size: size))
        }
        let box = CGRect(x: 0.25, y: 0.1, width: 0.5, height: 0.8)
        let cropped = CLIPZeroShotClassifier.personCrop(from: image, boundingBox: box)
        let croppedCG = try XCTUnwrap(cropped.cgImage)
        let originalCG = try XCTUnwrap(image.cgImage)
        XCTAssertLessThan(croppedCG.width, originalCG.width)
        XCTAssertLessThan(croppedCG.height, originalCG.height)
        // Padded box: width (0.5 + 2*0.075) * 400 = 260, height (0.8 + 2*0.064) * 800 ≈ 742.
        XCTAssertEqual(croppedCG.width, 260, accuracy: 2)
        XCTAssertEqual(croppedCG.height, 743, accuracy: 3)

        // Degenerate/missing boxes fall back to the original image.
        let untouched = CLIPZeroShotClassifier.personCrop(from: image, boundingBox: nil)
        XCTAssertEqual(untouched.size, size)
    }
}
