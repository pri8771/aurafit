import SwiftUI
import SwiftData

/// Detail screen for a single challenge: progress, rules, and contributing fits.
struct ChallengeDetailView: View {
    let challenge: Challenge

    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Query private var allSessions: [FitSession]

    private var accent: Color {
        RGBColor.fromHex(challenge.accentHex)?.color ?? AFColors.accent
    }

    private var contributing: [FitSession] {
        let ids = Set(challenge.contributingSessionIDs)
        return allSessions.filter { ids.contains($0.id.uuidString) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: AFSpacing.lg) {
                hero
                progressCard
                rulesCard
                contributingSection
                if !challenge.isCompleted {
                    AFPrimaryButton(title: "Scan a Fit", systemImage: "camera.fill") {
                        router.startScan()
                    }
                }
            }
            .padding(AFSpacing.md)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(challenge.title)
        .navigationBarTitleDisplayMode(.inline)
        .afScreenBackground()
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var hero: some View {
        VStack(spacing: AFSpacing.sm) {
            ZStack {
                Circle().fill(accent.opacity(0.18)).frame(width: 96, height: 96)
                Image(systemName: challenge.systemImage)
                    .font(.system(size: 44))
                    .foregroundStyle(accent)
            }
            Text(challenge.subtitle)
                .font(AFTypography.subheadline(.medium))
                .foregroundStyle(AFColors.textSecondary)
            if challenge.isCompleted {
                AFTagChip(text: "Completed", systemImage: "checkmark.seal.fill", tint: AFColors.success)
            }
        }
        .padding(.top, AFSpacing.sm)
    }

    private var progressCard: some View {
        AFGlassCard {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                HStack {
                    Text("Progress").font(AFTypography.headline()).foregroundStyle(AFColors.textPrimary)
                    Spacer()
                    Text("\(challenge.completedCount)/\(challenge.goalCount)")
                        .font(AFTypography.headline(.bold).monospacedDigit())
                        .foregroundStyle(accent)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(AFColors.surfaceElevated)
                        Capsule().fill(accent)
                            .frame(width: max(8, geo.size.width * min(1, challenge.progress)))
                    }
                }
                .frame(height: 12)
            }
        }
    }

    private var rulesCard: some View {
        AFGlassCard {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                Label("How it works", systemImage: "info.circle.fill")
                    .font(AFTypography.headline())
                    .foregroundStyle(AFColors.textPrimary)
                Text(challenge.details)
                    .font(AFTypography.subheadline())
                    .foregroundStyle(AFColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                if challenge.minScore > 0 {
                    AFTagChip(text: "Min score \(challenge.minScore)", systemImage: "target", tint: accent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var contributingSection: some View {
        if !contributing.isEmpty {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                AFSectionHeader(title: "Your Fits")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AFSpacing.md) {
                        ForEach(contributing) { session in
                            NavigationLink {
                                FitDetailView(session: session)
                            } label: {
                                FitCardView(session: session,
                                            image: environment.imageStore.loadImage(relativePath: session.originalImagePath))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}
