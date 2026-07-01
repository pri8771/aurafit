import Foundation
import StoreKit

/// Abstraction over the purchasing backend so entitlement logic can be unit-tested with mocks.
@MainActor
protocol PurchaseProviding: AnyObject {
    var products: [Product] { get }
    var purchasedProductIDs: Set<String> { get }
    var loadState: StoreKitService.LoadState { get }

    func loadProducts() async
    func purchase(_ product: Product) async throws -> StoreKitService.PurchaseOutcome
    func restorePurchases() async -> Bool
    func product(for id: String) -> Product?
}

/// StoreKit 2 wrapper: loads products, performs purchases, listens for transaction updates,
/// and maintains the set of currently-entitled product IDs.
@MainActor
@Observable
final class StoreKitService: PurchaseProviding {

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    enum PurchaseOutcome: Equatable {
        case success
        case pending
        case cancelled
    }

    enum StoreError: LocalizedError {
        case failedVerification
        case productUnavailable

        var errorDescription: String? {
            switch self {
            case .failedVerification: return "Could not verify the purchase with the App Store."
            case .productUnavailable: return "This product is currently unavailable."
            }
        }
    }

    private(set) var products: [Product] = []
    private(set) var purchasedProductIDs: Set<String> = []
    private(set) var loadState: LoadState = .idle

    nonisolated(unsafe) private var updatesTask: Task<Void, Never>?

    init() {
        // Begin listening for transaction updates immediately (renewals, refunds, Ask-to-Buy).
        updatesTask = listenForTransactions()
    }

    deinit {
        updatesTask?.cancel()
    }

    // MARK: - Loading

    func loadProducts() async {
        loadState = .loading
        // Runs concurrently with (not gated behind) the network-bound product fetch below:
        // Transaction.currentEntitlements reads locally-cached, on-device StoreKit data and
        // works offline, so a subscriber's entitlement shouldn't wait on App Store connectivity.
        async let entitlementsRefresh: Void = refreshEntitlements()
        do {
            let storeProducts = try await Product.products(for: ProductCatalog.allProductIDs)
            // Stable ordering: subscriptions first (yearly, monthly), then templates.
            products = storeProducts.sorted { lhs, rhs in
                rank(lhs.id) < rank(rhs.id)
            }
            loadState = .loaded
        } catch {
            AppLog.store.error("Product load failed: \(error.localizedDescription)")
            loadState = .failed(error.localizedDescription)
        }
        await entitlementsRefresh
    }

    private func rank(_ id: String) -> Int {
        switch id {
        case ProductCatalog.proYearly: return 0
        case ProductCatalog.proMonthly: return 1
        case ProductCatalog.templateStreetwear: return 2
        case ProductCatalog.templateSoftLuxury: return 3
        default: return 99
        }
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    // MARK: - Purchasing

    func purchase(_ product: Product) async throws -> PurchaseOutcome {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await refreshEntitlements()
            await transaction.finish()
            return .success
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    /// Returns whether the App Store sync itself succeeded (independent of whether it
    /// yields any active entitlements) so callers can distinguish a network/auth failure
    /// from a genuine "no purchases to restore".
    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
        } catch {
            AppLog.store.error("Restore (AppStore.sync) failed: \(error.localizedDescription)")
            return false
        }
        await refreshEntitlements()
        return true
    }

    // MARK: - Entitlements

    /// Recomputes `purchasedProductIDs` from `Transaction.currentEntitlements`.
    func refreshEntitlements() async {
        var active: Set<String> = []
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.revocationDate == nil {
                // For subscriptions, currentEntitlements only yields active ones.
                active.insert(transaction.productID)
            }
        }
        purchasedProductIDs = active
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { [weak self] in
            for await update in Transaction.updates {
                guard let self else { continue }
                if let transaction = try? Self.staticCheckVerified(update) {
                    await self.refreshEntitlements()
                    await transaction.finish()
                }
            }
        }
    }

    // MARK: - Verification

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let safe): return safe
        }
    }

    nonisolated private static func staticCheckVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let safe): return safe
        }
    }
}
