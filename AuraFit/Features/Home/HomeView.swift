import SwiftUI
import SwiftData

/// The Home tab: greeting + scan CTA, latest score, weekly stats, recent fits carousel,
/// and a featured challenge.
struct HomeView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router

    @Query(sort: \FitSession.createdAt, order: .reverse) private var sessions: [FitSession]
    @Query(filter: #Predicate<Challenge> { $0.isFeatured }) private var featuredChallenges: [Challenge]

    private var latest: FitSession? { sessions.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AFSpacing.lg) {
                    header
                    scanCTA
                    if let latest {
                        latestSummary(latest)
                        statsRow
                        recentCarousel
                    } else {
                        emptyState
                    }
                    if let challenge = featuredChallenges.first {
                        featuredChallengeCard(challenge)
                    }
                }
                .padding(AFSpacing.md)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("AuraFit")
            .navigationBarTitleDisplayMode(.inline)
            .afScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AFSpacing.xxs) {
            Text(greeting)
                .font(AFTypography.subheadline(.medium))
                .foregroundStyle(AFColors.textSecondary)
            Text("Ready to rate today's fit?")
                .font(AFTypography.title(.bold))
                .foregroundStyle(AFColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("aurafit.home.root.container")
    }

    private var scanCTA: some View {
        Button {
            HapticsManager.shared.impact(.medium)
            router.startScan()
        } label: {
            HStack(spacing: AFSpacing.md) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 30, weight: .semibold))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scan Today's Fit")
                        .font(AFTypography.title3(.bold))
                    Text(scanSubtitle)
                        .font(AFTypography.caption())
                        .opacity(0.9)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
            }
            .foregroundStyle(.white)
            .padding(AFSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(AFColors.brandGradient, in: RoundedRectangle(cornerRadius: AFRadius.lg, style: .continuous))
            .shadow(color: AFColors.accent.opacity(0.4), radius: 18, y: 10)
        }
        .buttonStyle(AFPressStyle())
        .accessibilityIdentifier("aurafit.home.scan.button")
        .accessibilityHint("Opens the scan flow")
    }

    private func latestSummary(_ session: FitSession) -> some View {
        NavigationLink {
            FitDetailView(session: session)
        } label: {
            AFGlassCard {
                HStack(spacing: AFSpacing.md) {
                    ScoreRingView(score: session.overallScore, size: 92, lineWidth: 9, animated: false)
                    VStack(alignment: .leading, spacing: AFSpacing.xxs) {
                        Text("Last Fit Score")
                            .font(AFTypography.caption(.semibold))
                            .foregroundStyle(AFColors.textTertiary)
                        Text(session.label.rawValue)
                            .font(AFTypography.title3(.bold))
                            .foregroundStyle(AFColors.textPrimary)
                        AFTagChip(text: session.stylePersona.rawValue, systemImage: session.stylePersona.systemImage)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AFColors.textTertiary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var statsRow: some View {
        HStack(spacing: AFSpacing.sm) {
            StatTile(
                title: "Weekly Avg",
                value: FitStatistics.weeklyAverage(sessions).map(String.init) ?? "—",
                systemImage: "chart.line.uptrend.xyaxis",
                tint: AFColors.accentSecondary
            )
            StatTile(
                title: "Streak",
                value: "\(FitStatistics.currentStreak(sessions))d",
                systemImage: "flame.fill",
                tint: AFColors.accentWarm
            )
            StatTile(
                title: "Best",
                value: FitStatistics.bestScore(sessions).map(String.init) ?? "—",
                systemImage: "star.fill",
                tint: AFColors.warning
            )
        }
    }

    private var recentCarousel: some View {
        VStack(alignment: .leading, spacing: AFSpacing.sm) {
            AFSectionHeader(title: "Recent Fits", actionTitle: "See all") {
                router.selectedTab = .history
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AFSpacing.md) {
                    ForEach(Array(sessions.prefix(8))) { session in
                        NavigationLink {
                            FitDetailView(session: session)
                        } label: {
                            FitCardView(session: session, imageStore: environment.imageStore)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, AFSpacing.xxs)
            }
        }
    }

    private func featuredChallengeCard(_ challenge: Challenge) -> some View {
        VStack(alignment: .leading, spacing: AFSpacing.sm) {
            AFSectionHeader(title: "Featured Challenge", actionTitle: "All") {
                router.selectedTab = .challenges
            }
            NavigationLink {
                ChallengeDetailView(challenge: challenge)
            } label: {
                ChallengeRowView(challenge: challenge)
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyState: some View {
        AFGlassCard {
            AFEmptyState(
                systemImage: "sparkles",
                title: "No fits yet",
                message: "Scan your first fit to see your score, stats, and style persona.",
                actionTitle: "Scan a Fit"
            ) {
                router.startScan()
            }
        }
    }

    // MARK: - Helpers

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning ☀️"
        case 12..<17: return "Good afternoon 👋"
        case 17..<22: return "Good evening 🌙"
        default: return "Late night fit check 🌌"
        }
    }

    private var scanSubtitle: String { "Analyzed privately on your iPhone" }
}

/// Small stat tile used in the Home stats row.
private struct StatTile: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        AFGlassCard(padding: AFSpacing.sm) {
            VStack(alignment: .leading, spacing: AFSpacing.xs) {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
                Text(value)
                    .font(AFTypography.title3(.bold).monospacedDigit())
                    .foregroundStyle(AFColors.textPrimary)
                Text(title)
                    .font(AFTypography.caption())
                    .foregroundStyle(AFColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

#Preview {
    HomeView()
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .modelContainer(SwiftDataContainer.makeInMemory())
}
