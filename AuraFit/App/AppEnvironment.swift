import SwiftUI
import SwiftData

/// Container for app-wide services, injected through the SwiftUI environment.
/// Constructed once at launch (or with mocks for previews/tests).
@MainActor
@Observable
final class AppEnvironment {
    let store: any PurchaseProviding
    let entitlements: EntitlementManager
    let imageStore: ImageFileStore
    let analysisService: FitAnalysisService

    init(
        store: (any PurchaseProviding)? = nil,
        imageStore: ImageFileStore? = nil,
        analysisService: FitAnalysisService? = nil
    ) {
        let resolvedStore = store ?? StoreKitService()
        self.store = resolvedStore
        self.imageStore = imageStore ?? ImageFileStore()
        self.analysisService = analysisService ?? AppEnvironment.makeAnalysisService()
        self.entitlements = EntitlementManager(store: resolvedStore)
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

    /// Loads products and entitlements; binds the persisted settings row.
    func bootstrap(settings: AppSettings?) async {
        bindSettings(settings)
        await entitlements.loadProducts()
    }

    /// Binds the persisted settings row to the services that depend on it.
    ///
    /// Safe to call repeatedly — `RootView` re-invokes it whenever its `@Query` result changes,
    /// so a row that materializes after first appearance still gets bound. A `nil` row is logged
    /// and *ignored* rather than clearing an existing binding: without it the free-scan quota has
    /// nothing to count against, and `EntitlementManager` deliberately fails closed (AURA-ENG-011).
    func bindSettings(_ settings: AppSettings?) {
        guard let settings else {
            AppLog.app.error("AppSettings row unavailable at bind time; daily scan quota fails closed until it materializes.")
            return
        }
        entitlements.settings = settings
        HapticsManager.shared.isEnabled = settings.hapticsEnabled
    }

    #if DEBUG

    /// A preview/test environment using a mock purchase provider.
    static func preview(isPro: Bool = false) -> AppEnvironment {
        let env = AppEnvironment(store: MockPurchaseProvider(isPro: isPro))
        env.entitlements.settings = AppSettings()
        return env
    }

    #else

    /// Release stub (AURA-ENG-014).
    ///
    /// `MockPurchaseProvider` is `#if DEBUG`-only so it is never linked into the shipped binary.
    /// This entry point still has to exist in Release because `#Preview` macro bodies *are*
    /// type-checked and compiled in Release builds — `ENABLE_PREVIEWS = NO` does not strip them —
    /// and seven `#Preview` blocks across the Features layer call `AppEnvironment.preview()`.
    /// Nothing invokes it at runtime: `PreviewRegistry` conformances are only ever driven by the
    /// Xcode preview host, which runs a Debug build.
    static func preview(isPro: Bool = false) -> AppEnvironment {
        AppEnvironment()
    }

    #endif
}
