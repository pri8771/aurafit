import SwiftUI
import SwiftData

/// Container for app-wide services, injected through the SwiftUI environment.
/// Constructed once at launch (or with substitutes for previews/tests).
@MainActor
@Observable
final class AppEnvironment {
    let imageStore: ImageFileStore
    let analysisService: FitAnalysisService

    /// The persisted settings row, bound by `RootView` once its `@Query` materializes it.
    /// Read by flows that need a preference outside a view's own `@Query` (e.g. auto-save).
    private(set) var settings: AppSettings?

    init(
        imageStore: ImageFileStore? = nil,
        analysisService: FitAnalysisService? = nil
    ) {
        self.imageStore = imageStore ?? ImageFileStore()
        self.analysisService = analysisService ?? AppEnvironment.makeAnalysisService()
    }

    #if DEBUG

    /// Builds the analysis facade, substituting the Vision stubs when the UI test asked for them
    /// (AURA-QA-001). Vision's pose and segmentation requests cannot run on the Simulator, so
    /// without this the smoke test can never reach the result screen. `UITestVisionStub` — and
    /// with it the launch-argument string — is compiled out of Release entirely.
    private static func makeAnalysisService() -> FitAnalysisService {
        guard UITestVisionStub.isEnabled else { return FitAnalysisService() }
        AppLog.app.notice("UI test Vision stub active: pose and segmentation are synthetic.")
        return FitAnalysisService(
            pipeline: AnalysisPipeline(pose: StubPoseService(), segmentation: StubSegmentationService())
        )
    }

    #else

    private static func makeAnalysisService() -> FitAnalysisService {
        FitAnalysisService()
    }

    #endif

    /// Binds the persisted settings row to the services that depend on it.
    ///
    /// Safe to call repeatedly — `RootView` re-invokes it whenever its `@Query` result changes,
    /// so a row that materializes after first appearance still gets bound. A `nil` row is logged
    /// and *ignored* rather than clearing an existing binding.
    func bindSettings(_ settings: AppSettings?) {
        guard let settings else {
            AppLog.app.error("AppSettings row unavailable at bind time; preferences use defaults until it materializes.")
            return
        }
        self.settings = settings
        HapticsManager.shared.isEnabled = settings.hapticsEnabled
    }

    /// A preview/test environment with an unsaved settings row bound.
    static func preview() -> AppEnvironment {
        let env = AppEnvironment()
        env.bindSettings(AppSettings())
        return env
    }
}
