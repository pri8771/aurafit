import XCTest

/// Covers AuraFit's core loop end to end in the simulator:
/// launch -> onboarding -> Scan tab -> camera permission primer -> library import fallback
/// -> analysis -> Fit Score result screen.
///
/// The simulator has no camera and no bundled Core ML model (see `docs/BUGS.md` / DEC-003), so
/// this test deliberately routes through the "Import from Library" path exposed by the
/// permission primer rather than driving the real camera. That exercises the exact same
/// `AnalysisPipeline` the camera path would, including the heuristic outfit-classifier fallback,
/// without depending on hardware the simulator cannot provide.
///
/// Setup requirement: the run must seed at least one photo into the target simulator's Photos
/// library before this test executes, e.g.:
///   xcrun simctl addmedia <device-udid> AuraFitUITests/Fixtures/QAFitPhoto.jpg
/// The CI workflow (`.github/workflows/ci.yml`) does this automatically. `QAFitPhoto.jpg` is a
/// generated, synthetic full-body silhouette fixture — not a real photo — checked in for
/// deterministic QA per `docs/STATUS.md` (AURA-CORE-001).
///
/// What this test asserts is the **UI contract** — navigation, analysis completion, persistence
/// and the result screen — not model quality. Vision's pose and person-segmentation requests do
/// not run on the Simulator at all ("Unable to setup request" / "E5RT is not supported"), so the
/// app is launched with `-UITestStubVision`, which swaps those two services for the deterministic
/// stubs in `AuraFit/Services/Analysis/UITestVisionStub.swift` (AURA-QA-001). Everything else in
/// the pipeline — colour, quality, the heuristic outfit classifier, scoring, tips, persistence,
/// export — is the real code path. Model quality is validated on a physical device instead
/// (AURA-QA-002, `docs/PLAN.md` §5.2).
final class ScanCoreLoopUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchOnboardingScanImportReachesFitScore() throws {
        let app = XCUIApplication()
        // `-UITestInMemoryStore` forces a clean in-memory SwiftData store so the run always
        // starts at onboarding, regardless of state left over from a previous run on this
        // simulator. `-UITestStubVision` substitutes deterministic full-body pose and
        // segmentation signals for the Vision requests the Simulator cannot execute. Both are
        // `#if DEBUG`-only escape hatches and are absent from a Release build (AURA-ENG-014,
        // AURA-QA-001).
        app.launchArguments += ["-UITestInMemoryStore", "-UITestStubVision"]
        app.launch()

        // MARK: Onboarding
        // `OnboardingView` shows a "Skip" button on every page except the last; tapping it
        // completes onboarding immediately (see AuraFit/Features/Onboarding/OnboardingView.swift).
        let skipButton = app.buttons["aurafit.onboarding.skip.button"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 10), "Onboarding did not appear on first launch.")
        skipButton.tap()

        // MARK: Scan tab
        let scanTab = app.tabBars.buttons["Scan"]
        XCTAssertTrue(scanTab.waitForExistence(timeout: 10), "Main tab bar did not appear after onboarding.")
        scanTab.tap()

        let openCameraButton = app.buttons["aurafit.scan.camera.button"]
        XCTAssertTrue(openCameraButton.waitForExistence(timeout: 10), "Scan start screen did not appear.")
        openCameraButton.tap()

        // MARK: Permission primer
        // Camera authorization is `.notDetermined` on a fresh simulator, so tapping "Open Camera"
        // shows `PermissionPrimerView` instead of the camera itself
        // (see AuraFit/Features/Scan/ScanView.swift `beginCameraFlow()`).
        let primerImportButton = app.buttons["permissionPrimer.importFromLibraryButton"]
        XCTAssertTrue(primerImportButton.waitForExistence(timeout: 10), "Camera permission primer did not appear.")
        primerImportButton.tap()

        // MARK: Pick a photo from the system picker
        // SwiftUI's `.photosPicker` (PHPickerViewController) requires no photo-library
        // permission prompt and, in default single-selection mode, dismisses itself as soon as
        // an item is tapped.
        //
        // The very first time an app presents this picker, the system overlays a one-time
        // "Private Access to Photos" explainer banner (with a "Close" button) on top of the
        // photo grid. Dismiss it first if present so the subsequent tap lands on an actual
        // photo rather than the banner's decorative icon. The banner can take a few seconds to
        // animate in, so wait generously for it.
        let onboardingCloseButton = app.buttons["Close"]
        if onboardingCloseButton.waitForExistence(timeout: 8) {
            onboardingCloseButton.tap()
            // The banner's dismiss animation briefly leaves the grid beneath it un-hittable;
            // give it a moment to finish before interacting with the grid. There is no XCUITest
            // hook for "wait for this specific system-owned dismiss animation to finish", so a
            // short fixed pause is the pragmatic option here.
            Thread.sleep(forTimeInterval: 1.5)
        }

        // Target the picker's actual grid thumbnails specifically (accessibility identifier
        // "PXGGridLayout-Info", labeled "Photo, <date>"). The picker toolbar also exposes other
        // `Image`/icon elements (e.g. the one-time banner's icon, "Sort and Filter"), so a
        // generic "first Image on screen" query is not reliable — it can land on those instead
        // of an actual photo and open the wrong control.
        let gridPhoto = app.images.matching(identifier: "PXGGridLayout-Info").firstMatch
        if gridPhoto.waitForExistence(timeout: 15) {
            tapWhenHittable(gridPhoto)
        } else {
            // Fall back to any image whose label indicates it's a photo, in case the
            // internal identifier above changes in a future iOS version.
            let labeledPhoto = app.images.matching(
                NSPredicate(format: "label BEGINSWITH 'Photo,'")
            ).firstMatch
            if labeledPhoto.waitForExistence(timeout: 5) {
                tapWhenHittable(labeledPhoto)
            } else {
                let firstCell = app.collectionViews.cells.firstMatch
                XCTAssertTrue(firstCell.waitForExistence(timeout: 5),
                              "System photo picker did not present any selectable photo. Was " +
                              "the simulator seeded via `xcrun simctl addmedia`?")
                tapWhenHittable(firstCell)
            }
        }

        // MARK: Analysis -> Fit Score result
        // With the stubbed pose/segmentation signals the pipeline yields a scoreable result
        // rather than the "we couldn't detect a person" refusal `ScanView` raises when
        // `FitAnalysisResult.Diagnostics.isLowConfidence` is true. The outfit classifier runs its
        // heuristic fallback because no `OutfitClassifier.mlmodelc` is bundled (confirmed absent;
        // see docs/BUGS.md and docs/ARCHITECTURE.md).
        let resultScreen = app.otherElements["aurafit.result.root.container"]
        XCTAssertTrue(resultScreen.waitForExistence(timeout: 60),
                      "Did not reach the Fit Score result screen after picking a photo.")

        let breakdown = app.staticTexts["aurafit.result.breakdown.heading"]
        XCTAssertTrue(breakdown.waitForExistence(timeout: 10), "Result screen is missing the metric breakdown card.")
    }

    /// Taps `element` via its normalized coordinate rather than `XCUIElement.tap()`.
    /// `.tap()` first asserts the element is "hittable", which can spuriously fail for a moment
    /// while a system overlay (e.g. the Photos picker's one-time "Private Access to Photos"
    /// banner) is mid-dismiss-animation directly over it, even though the element itself already
    /// exists. A coordinate tap performs the tap without that check, since the caller has already
    /// confirmed the element exists via `waitForExistence`.
    private func tapWhenHittable(_ element: XCUIElement) {
        element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
    }
}
