import SwiftUI
import SwiftData

@main
struct AuraFitApp: App {
    /// The shared SwiftData container for the running app.
    private let modelContainer: ModelContainer

    @State private var environment: AppEnvironment
    @State private var router = AppRouter()

    init() {
        // UI tests pass this to force a clean in-memory store so every test run starts from
        // deterministic first-launch state (see `SwiftDataContainer.makeShared(forceInMemory:)`).
        let forceInMemory = ProcessInfo.processInfo.arguments.contains("-UITestInMemoryStore")
        let container = SwiftDataContainer.makeShared(forceInMemory: forceInMemory)
        self.modelContainer = container
        _environment = State(initialValue: AppEnvironment())

        // Seed default content on the main context.
        let context = container.mainContext
        SeedData.bootstrap(context)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(environment)
                .environment(router)
                .tint(AFColors.accent)
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
