import SwiftUI
import SwiftData

/// Root container: shows onboarding until completed, then the main `TabView`.
/// Also hosts the globally-presented paywall sheet.
struct RootView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    @Query private var settingsRows: [AppSettings]

    /// Drives the fallback-storage alert. A real `@State` (rather than `.constant(...)`) is
    /// required: SwiftUI writes `false` back through the binding on dismissal, and a constant
    /// binding makes that write a no-op, so the alert re-presents on the next view update and
    /// traps the user in a loop — in exactly the failure case the alert exists to report.
    @State private var isShowingStorageWarning = false

    /// Ensures the alert is presented at most once per session even if `body` re-evaluates.
    @State private var hasPresentedStorageWarning = false

    private var settings: AppSettings? { settingsRows.first }

    private var isUsingFallbackStorage: Bool { SwiftDataContainer.isUsingFallbackStorage }

    var body: some View {
        @Bindable var router = router

        VStack(spacing: 0) {
            if isUsingFallbackStorage {
                storageWarningBanner
            }

            Group {
                if let settings, settings.hasCompletedOnboarding {
                    mainTabs
                } else {
                    OnboardingView()
                }
            }
        }
        .task {
            presentStorageWarningIfNeeded()
            await environment.bootstrap(settings: settings)
        }
        // The `@Query` row can materialize after this view first appears. Re-bind whenever it
        // changes so the free-scan quota is never left unenforced (AURA-ENG-011).
        .onChange(of: settings?.persistentModelID) {
            environment.bindSettings(settings)
        }
        .sheet(item: $router.paywallContext) { context in
            PaywallView(context: context)
                .environment(environment)
                .environment(router)
        }
        .alert("Storage Unavailable", isPresented: $isShowingStorageWarning) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("AuraFit couldn't access on-device storage, so nothing you do this session will be saved after you close the app. Try restarting your device.")
        }
    }

    /// Persistent, non-blocking reminder that stays after the alert is dismissed, so the user
    /// keeps being told their data isn't being saved without being trapped in an alert loop.
    private var storageWarningBanner: some View {
        Button {
            isShowingStorageWarning = true
        } label: {
            HStack(spacing: AFSpacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("Not saving — storage unavailable")
                    .fontWeight(.medium)
            }
            .font(.footnote)
            .foregroundStyle(AFColors.background)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AFSpacing.xs)
            .background(AFColors.warning)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("storageUnavailableBanner")
        .accessibilityHint("Shows details about the storage problem.")
    }

    private func presentStorageWarningIfNeeded() {
        guard isUsingFallbackStorage, !hasPresentedStorageWarning else { return }
        hasPresentedStorageWarning = true
        isShowingStorageWarning = true
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
