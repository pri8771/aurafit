import SwiftUI
import SwiftData

/// The Settings tab: preferences, privacy info, data management, and about.
struct SettingsView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(\.modelContext) private var modelContext

    @Query private var settingsRows: [AppSettings]
    @Query private var sessions: [FitSession]

    @State private var showResetConfirm = false

    private var settings: AppSettings? { settingsRows.first }

    var body: some View {
        NavigationStack {
            Form {
                preferencesSection
                privacySection
                dataSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .afScreenBackground()
            .navigationTitle("Settings")
        }
        .accessibilityIdentifier("aurafit.settings.root.container")
    }

    // MARK: - Sections

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
                    Text("All analysis runs locally. AuraFit makes no network calls of its own.")
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
            // AuraFit's own policy, not Apple's: App Review 5.1.1(i) requires a policy for
            // this app, and it must stay reachable even before a hosted URL exists.
            NavigationLink {
                PrivacyPolicyView()
            } label: {
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
