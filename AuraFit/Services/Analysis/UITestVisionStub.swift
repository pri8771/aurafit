#if DEBUG

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Debug-only Vision stub for the UI smoke test (AURA-QA-001).
///
/// `VNDetectHumanBodyPoseRequest` and `VNGeneratePersonSegmentationRequest` do not run on the
/// iOS Simulator — the request handler fails with "Unable to setup request" / "E5RT is not
/// supported", so both services return `.unavailable`, `FitAnalysisResult.Diagnostics
/// .isLowConfidence` is true, and `ScanView` refuses the photo before a result screen ever
/// appears. That makes the core-loop UI contract (navigation → analysis → persistence →
/// results → export) untestable in CI, which is the *only* thing the UI test is meant to assert;
/// model quality is validated on device (`AURA-QA-002`, `docs/PLAN.md` §5.2).
///
/// Activation is deliberately narrow and unreachable in a shipped build:
/// * the whole file is `#if DEBUG`, so neither the stubs nor the launch-argument string are
///   compiled into a Release binary (verified with `strings` on the Release .app);
/// * even in Debug it stays inert unless the host process was launched with `-UITestStubVision`,
///   which only `AuraFitUITests` passes.
enum UITestVisionStub {

    /// Launch argument that swaps the Vision services for deterministic stubs.
    static let launchArgument = "-UITestStubVision"

    /// True only when the current process was launched by the UI test with the flag above.
    static var isEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(launchArgument)
    }
}

/// Fixed, plausible full-body pose signals: a centered, upright subject filling most of the
/// frame. Values sit comfortably inside the "good photo" bands `ScoreEngine` and `PhotoCoach`
/// expect, so the pipeline produces a real score instead of a rejection.
struct StubPoseService: PoseAnalyzing {

    #if canImport(UIKit)
    func analyze(_ image: UIImage) -> PoseSignals {
        PoseSignals(
            detected: true,
            confidence: 0.86,
            fullBodyVisible: true,
            verticalCoverage: 0.82,
            horizontalCentering: 0.92,
            posture: 0.78,
            boundingBox: CGRect(x: 0.30, y: 0.08, width: 0.40, height: 0.84)
        )
    }
    #endif
}

/// Fixed, plausible segmentation signals: subject occupies a well-framed share of the shot
/// against an uncluttered background.
struct StubSegmentationService: SegmentationAnalyzing {

    #if canImport(UIKit)
    func analyze(_ image: UIImage) -> SegmentationSignals {
        SegmentationSignals(
            available: true,
            subjectFraction: 0.42,
            backgroundComplexity: 0.30
        )
    }
    #endif
}

#endif
