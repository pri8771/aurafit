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
        self.analysisService = analysisService ?? FitAnalysisService()
        self.entitlements = EntitlementManager(store: resolvedStore)
    }

    /// Loads products and entitlements; binds the persisted settings row.
    func bootstrap(settings: AppSettings?) async {
        entitlements.settings = settings
        if let settings {
            HapticsManager.shared.isEnabled = settings.hapticsEnabled
        }
        await entitlements.loadProducts()
    }

    /// A preview/test environment using a mock purchase provider.
    static func preview(isPro: Bool = false) -> AppEnvironment {
        let env = AppEnvironment(store: MockPurchaseProvider(isPro: isPro))
        env.entitlements.settings = AppSettings()
        return env
    }
}
