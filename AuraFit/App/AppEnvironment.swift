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
        store: any PurchaseProviding = StoreKitService(),
        imageStore: ImageFileStore = ImageFileStore(),
        analysisService: FitAnalysisService = FitAnalysisService()
    ) {
        self.store = store
        self.imageStore = imageStore
        self.analysisService = analysisService
        self.entitlements = EntitlementManager(store: store)
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
