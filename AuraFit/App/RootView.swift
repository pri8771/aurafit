import SwiftUI
import SwiftData

/// Root container: shows onboarding until completed, then the main `TabView`.
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
            environment.bindSettings(settings)
            // Housekeeping runs last and off the main thread: sweeping stranded capture files
            // must never delay first paint (AURA-ENG-035).
            let repo = SessionRepository(context: modelContext, imageStore: environment.imageStore)
            await repo.reconcileOrphanedAssets()
        }
        // The `@Query` row can materialize after this view first appears. Re-bind whenever it
        // changes so preferences are never left unbound.
        .onChange(of: settings?.persistentModelID) {
            environment.bindSettings(settings)
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
                            .accessibilityIdentifier("aurafit.tab.\(tab.title.lowercased()).button")
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
