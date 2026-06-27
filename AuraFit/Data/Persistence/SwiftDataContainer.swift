import Foundation
import SwiftData

/// Builds the app's `ModelContainer`. Provides an in-memory variant for tests/previews.
enum SwiftDataContainer {

    static let schema = Schema([
        FitSession.self,
        Challenge.self,
        ExportedAsset.self,
        PurchaseEntitlement.self,
        AppSettings.self
    ])

    /// The shared, on-disk container for the running app.
    static func makeShared() -> ModelContainer {
        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            AppLog.persistence.error("Persistent container failed: \(error.localizedDescription). Falling back to in-memory.")
            // Graceful fallback: never crash the app over storage init.
            return makeInMemory()
        }
    }

    /// An in-memory container for tests and SwiftUI previews.
    static func makeInMemory() -> ModelContainer {
        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("In-memory ModelContainer must succeed: \(error)")
        }
    }
}
