import SwiftUI
import SwiftData
import StoreKit

/// Derives user entitlements (Pro status, unlocked templates) from a `PurchaseProviding` source
/// and enforces the freemium daily-scan gate against persisted `AppSettings`.
@MainActor
@Observable
final class EntitlementManager {

    private let store: any PurchaseProviding

    /// Set by the app on launch so the manager can read/update daily scan accounting.
    var settings: AppSettings?

    #if DEBUG
    /// Debug-only override so Pro features can be exercised on-device without a real purchase.
    /// Compiled out entirely in Release builds — cannot ship or reach TestFlight/App Store.
    /// Flip to `false` to test the real StoreKit purchase/entitlement flow instead.
    static var forceProForTesting = true
    #endif

    init(store: any PurchaseProviding) {
        self.store = store
    }

    // MARK: - Derived entitlements

    var isPro: Bool {
        #if DEBUG
        if Self.forceProForTesting { return true }
        #endif
        return !store.purchasedProductIDs.isDisjoint(with: ProductCatalog.proSubscriptionIDs)
    }

    var tier: EntitlementTier { isPro ? .pro : .free }

    func isTemplateUnlocked(_ productID: String) -> Bool {
        if isPro { return true }   // Pro unlocks all templates.
        return store.purchasedProductIDs.contains(productID)
    }

    func isPersonaTemplateUnlocked(_ persona: StylePersona) -> Bool {
        switch persona {
        case .streetwear: return isTemplateUnlocked(ProductCatalog.templateStreetwear)
        case .softLuxury: return isTemplateUnlocked(ProductCatalog.templateSoftLuxury)
        default: return true   // Built-in personas are always available.
        }
    }

    /// Exports are watermarked for free users.
    var exportsWatermarked: Bool { !isPro }

    /// Reveal videos are a Pro feature.
    var canGenerateRevealVideo: Bool { isPro }

    // MARK: - Daily scan gate

    /// Remaining free scans today (large sentinel when Pro).
    var remainingFreeScansToday: Int {
        guard !isPro else { return .max }
        guard let settings else { return ProductCatalog.freeDailyScanLimit }
        let used = settings.rolloverIfNeeded()
        return max(0, ProductCatalog.freeDailyScanLimit - used)
    }

    var canScan: Bool { isPro || remainingFreeScansToday > 0 }

    /// Records a scan against the daily quota (no-op for Pro). Caller must save the context.
    func registerScan() {
        guard !isPro, let settings else { return }
        settings.rolloverIfNeeded()
        settings.scanCountToday += 1
    }

    // MARK: - Pass-through

    var products: [Product] { store.products }
    var loadState: StoreKitService.LoadState { store.loadState }

    func loadProducts() async { await store.loadProducts() }
    func restore() async -> Bool { await store.restorePurchases() }
    func purchase(_ product: Product) async throws -> StoreKitService.PurchaseOutcome {
        try await store.purchase(product)
    }
    func product(for id: String) -> Product? { store.product(for: id) }
}
