import SwiftUI
import SwiftData

/// Root container: shows onboarding until completed, then the main `TabView`.
/// Also hosts the globally-presented paywall sheet.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @Query private var settingsRows: [AppSettings]

    private var settings: AppSettings? { settingsRows.first }

    var body: some View {
        @Bindable var router = router

        Group {
            if let settings, settings.hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView()
            }
        }
        .task {
            await environment.bootstrap(settings: settings)
        }
        .sheet(item: $router.paywallContext) { context in
            PaywallView(context: context)
                .environment(environment)
                .environment(router)
        }
        .alert("Storage Unavailable", isPresented: .constant(SwiftDataContainer.isUsingFallbackStorage)) {
            Button("OK") {}
        } message: {
            Text("AuraFit couldn't access on-device storage, so nothing you do this session will be saved after you close the app. Try restarting your device.")
        }
    }

    private var mainTabs: some View {
        @Bindable var router = router

        return TabView(selection: $router.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tabContent(tab)
                    .tag(tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.systemImage)
                    }
            }
        }
    }

    @ViewBuilder
    private func tabContent(_ tab: AppTab) -> some View {
        switch tab {
        case .home: HomeView()
        case .scan: ScanView()
        case .history: HistoryView()
        case .challenges: ChallengesView()
        case .settings: SettingsView()
        }
    }
}

#Preview {
    RootView()
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .modelContainer(SwiftDataContainer.makeInMemory())
}
