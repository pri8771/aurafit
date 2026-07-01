import Foundation
import StoreKit

/// A lightweight `PurchaseProviding` mock for SwiftUI previews and unit tests.
///
/// It cannot fabricate real `Product` values (StoreKit forbids it), so `products` is empty;
/// entitlement logic is driven entirely by `purchasedProductIDs`, which is what the tests exercise.
@MainActor
final class MockPurchaseProvider: PurchaseProviding {
    var products: [Product] = []
    var purchasedProductIDs: Set<String>
    var loadState: StoreKitService.LoadState = .loaded

    /// Records the most recent purchase attempt for test assertions.
    private(set) var lastPurchasedID: String?
    var restoreCallCount = 0

    init(isPro: Bool = false, purchased: Set<String> = []) {
        var ids = purchased
        if isPro { ids.insert(ProductCatalog.proMonthly) }
        self.purchasedProductIDs = ids
    }

    func loadProducts() async { loadState = .loaded }

    func purchase(_ product: Product) async throws -> StoreKitService.PurchaseOutcome {
        lastPurchasedID = product.id
        purchasedProductIDs.insert(product.id)
        return .success
    }

    /// Test-only helper to simulate a purchase by product ID (since real `Product` can't be built).
    func simulatePurchase(_ id: String) {
        lastPurchasedID = id
        purchasedProductIDs.insert(id)
    }

    func restorePurchases() async -> Bool { restoreCallCount += 1; return true }

    func product(for id: String) -> Product? { nil }
}
