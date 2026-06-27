import SwiftUI
import SwiftData

@main
struct AuraFitApp: App {
    /// The shared SwiftData container for the running app.
    private let modelContainer: ModelContainer

    @State private var environment: AppEnvironment
    @State private var router = AppRouter()

    init() {
        let container = SwiftDataContainer.makeShared()
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
