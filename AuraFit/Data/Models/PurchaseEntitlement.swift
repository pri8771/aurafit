import Foundation
import SwiftData

/// A locally cached snapshot of a purchase/entitlement. The source of truth is StoreKit's
/// `Transaction.currentEntitlements`; this model lets the UI render instantly offline and
/// persists non-consumable template unlocks.
@Model
final class PurchaseEntitlement {
    @Attribute(.unique) var productID: String
    var purchaseDate: Date
    var expirationDate: Date?
    var isActive: Bool
    /// Original transaction ID for de-duplication/auditing.
    var originalTransactionID: String?

    init(
        productID: String,
        purchaseDate: Date = .now,
        expirationDate: Date? = nil,
        isActive: Bool = true,
        originalTransactionID: String? = nil
    ) {
        self.productID = productID
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.isActive = isActive
        self.originalTransactionID = originalTransactionID
    }
}
