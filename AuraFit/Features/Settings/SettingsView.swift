import SwiftUI
import SwiftData

/// The Settings tab: subscription status, preferences, privacy info, and data management.
struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL

    @Query private var settingsRows: [AppSettings]
    @Query private var sessions: [FitSession]

    @State private var showResetConfirm = false
    @State private var isRestoringPurchases = false
    @State private var restoreResultMessage: String?

    private var settings: AppSettings? { settingsRows.first }
    private var entitlements: EntitlementManager { environment.entitlements }

    var body: some View {
        NavigationStack {
            Form {
                membershipSection
                preferencesSection
                privacySection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .afScreenBackground()
            .navigationTitle("Settings")
            .alert("Restore Purchases", isPresented: Binding(
                get: { restoreResultMessage != nil },
                set: { if !$0 { restoreResultMessage = nil } }
            )) {
                Button("OK") { restoreResultMessage = nil }
            } message: {
                Text(restoreResultMessage ?? "")
            }
        }
    }

    // MARK: - Sections

    private var membershipSection: some View {
        Section {
            if entitlements.isPro {
                HStack {
                    Label("AuraFit Pro", systemImage: "sparkles")
                        .foregroundStyle(AFColors.textPrimary)
                    Spacer()
                    Text("Active").foregroundStyle(AFColors.success).font(AFTypography.subheadline(.semibold))
                }
                Button {
                    if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                        openURL(url)
                    }
                } label: {
                    Label("Manage Subscription", systemImage: "creditcard")
                }
            } else {
                Button {
                    router.presentPaywall(.general)
                } label: {
                    HStack {
                        Label("Upgrade to Pro", systemImage: "sparkles")
                        Spacer()
                        Image(systemName: "chevron.right").foregroundStyle(AFColors.textTertiary)
                    }
                }
                .foregroundStyle(AFColors.accent)
            }
            Button {
                Task {
                    isRestoringPurchases = true
                    let synced = await entitlements.restore()
                    isRestoringPurchases = false
                    if entitlements.isPro {
                        restoreResultMessage = "Your Pro subscription has been restored."
                    } else if !synced {
                        restoreResultMessage = "Couldn't connect to the App Store. Check your connection and try again."
                    } else {
                        restoreResultMessage = "No purchases found to restore."
                    }
                }
            } label: {
                HStack {
                    Text("Restore Purchases")
                    if isRestoringPurchases {
                        Spacer()
                        ProgressView()
                    }
                }
            }
            .foregroundStyle(AFColors.accent)
            .disabled(isRestoringPurchases)
        } header: {
            Text("Membership")
        } footer: {
            if !entitlements.isPro {
                Text("Free plan: \(ProductCatalog.freeDailyScanLimit) scans/day with watermarked exports.")
            }
        }
        .listRowBackground(AFColors.surface)
    }

    @ViewBuilder
    private var preferencesSection: some View {
        if let settings {
            Section("Preferences") {
                Toggle(isOn: Binding(
                    get: { settings.hapticsEnabled },
                    set: { newValue in
                        settings.hapticsEnabled = newValue
                        HapticsManager.shared.isEnabled = newValue
                        save()
                        if newValue { HapticsManager.shared.impact(.light) }
                    }
                )) {
                    Label("Haptics", systemImage: "iphone.radiowaves.left.and.right")
                }

                Toggle(isOn: Binding(
                    get: { settings.soundEnabled },
                    set: { settings.soundEnabled = $0; save() }
                )) {
                    Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                }

                Toggle(isOn: Binding(
                    get: { settings.saveOriginalsToPhotos },
                    set: { settings.saveOriginalsToPhotos = $0; save() }
                )) {
                    Label("Auto-save exports to Photos", systemImage: "photo.badge.arrow.down")
                }
            }
            .listRowBackground(AFColors.surface)
        }
    }

    private var privacySection: some View {
        Section {
            HStack(spacing: AFSpacing.md) {
                Image(systemName: "lock.shield.fill")
                    .font(.title2)
                    .foregroundStyle(AFColors.success)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your data stays on-device")
                        .font(AFTypography.subheadline(.semibold))
                        .foregroundStyle(AFColors.textPrimary)
                    Text("All analysis runs locally. AuraFit makes no network calls except to the App Store for purchases.")
                        .font(AFTypography.caption())
                        .foregroundStyle(AFColors.textSecondary)
                }
            }
            .padding(.vertical, AFSpacing.xxs)
        } header: {
            Text("Privacy")
        }
        .listRowBackground(AFColors.surface)
    }

    private var dataSection: some View {
        Section {
            HStack {
                Label("Saved Fits", systemImage: "square.stack.3d.up")
                Spacer()
                Text("\(sessions.count)").foregroundStyle(AFColors.textSecondary)
            }
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Delete All Fits", systemImage: "trash")
            }
        } header: {
            Text("Data")
        }
        .listRowBackground(AFColors.surface)
        .confirmationDialog("Delete all fits?",
                            isPresented: $showResetConfirm,
                            titleVisibility: .visible) {
            Button("Delete Everything", role: .destructive) { deleteAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This permanently removes all \(sessions.count) saved fits and their images.")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(AppInfo.version).foregroundStyle(AFColors.textSecondary)
            }
            Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                Label("Terms of Use", systemImage: "doc.text.fill")
            }
        }
        .listRowBackground(AFColors.surface)
    }

    // MARK: - Actions

    private func save() {
        do { try modelContext.save() }
        catch { AppLog.persistence.error("Settings save failed: \(error.localizedDescription)") }
    }

    private func deleteAll() {
        let repo = SessionRepository(context: modelContext, imageStore: environment.imageStore)
        for session in sessions { repo.delete(session) }
        HapticsManager.shared.impact(.rigid)
    }
}

#Preview {
    SettingsView()
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .modelContainer(SwiftDataContainer.makeInMemory())
}
