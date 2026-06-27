import Foundation

/// Canonical product identifiers and metadata for AuraFit's IAP catalog.
enum ProductCatalog {

    // MARK: - Identifiers

    static let proMonthly = "com.aurafit.pro.monthly"
    static let proYearly = "com.aurafit.pro.yearly"
    static let templateStreetwear = "com.aurafit.template.streetwear"
    static let templateSoftLuxury = "com.aurafit.template.softluxury"

    /// All product IDs to request from StoreKit.
    static let allProductIDs: [String] = [
        proMonthly, proYearly, templateStreetwear, templateSoftLuxury
    ]

    /// Subscription product IDs that grant full Pro access.
    static let proSubscriptionIDs: Set<String> = [proMonthly, proYearly]

    /// Non-consumable template unlocks.
    static let templateIDs: Set<String> = [templateStreetwear, templateSoftLuxury]

    // MARK: - Freemium configuration

    /// Free users may run this many scans per day.
    static let freeDailyScanLimit = 3

    static func isProSubscription(_ id: String) -> Bool { proSubscriptionIDs.contains(id) }
    static func isTemplate(_ id: String) -> Bool { templateIDs.contains(id) }

    /// Maps a template product to the persona it unlocks.
    static func persona(forTemplate id: String) -> StylePersona? {
        switch id {
        case templateStreetwear: return .streetwear
        case templateSoftLuxury: return .softLuxury
        default: return nil
        }
    }
}
