import Foundation
import SwiftData

/// Builds the app's `ModelContainer`. Provides an in-memory variant for tests/previews.
enum SwiftDataContainer {

    static let schema = Schema([
        FitSession.self,
        Challenge.self,
        AppSettings.self
    ])

    /// Set to true if `makeShared()` had to fall back to an in-memory store. The UI warns
    /// the user that nothing will persist across app restarts when this is true.
    private(set) static var isUsingFallbackStorage = false

    /// The shared, on-disk container for the running app.
    ///
    /// Pass `forceInMemory: true` (wired to the `-UITestInMemoryStore` launch argument in
    /// `AuraFitApp`) to force a clean, in-memory container regardless of any on-disk state left
    /// over from a previous run. This exists purely so `AuraFitUITests` can start every test from
    /// deterministic first-launch state (onboarding not completed, no prior scans) without
    /// resorting to fake data in the production path — the app only ever takes this branch when
    /// the UI test host explicitly passes the argument.
    static func makeShared(forceInMemory: Bool = false) -> ModelContainer {
        if forceInMemory {
            return makeInMemory()
        }
        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            AppLog.persistence.error("Persistent container failed: \(error.localizedDescription). Falling back to in-memory.")
            isUsingFallbackStorage = true
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
