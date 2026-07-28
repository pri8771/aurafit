import SwiftUI
import SwiftData

/// First-run onboarding: a short paged intro ending in a "Get Started" CTA that flips the
/// persisted `hasCompletedOnboarding` flag.
struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settingsRows: [AppSettings]

    @State private var page = 0

    private let pages: [OnboardingPage] = [
        .init(systemImage: "camera.viewfinder",
              title: "Scan Your Fit",
              message: "Snap or import a full-body photo. Everything is analyzed right on your device — nothing ever leaves your phone."),
        .init(systemImage: "wand.and.stars",
              title: "On-Device AI Coach",
              message: "An image model reads your outfit and Apple's Vision framework reads your pose, both on your iPhone. You get notes on the clothes and on the photograph: color, lighting, framing, and background."),
        .init(systemImage: "square.and.arrow.up",
              title: "Share Your Score",
              message: "Get a Fit Score card and an optional 5-second reveal clip to share anywhere. Scores rate the outfit and the shot, never the person in it.")
    ]

    var body: some View {
        ZStack {
            AFBackground()

            VStack(spacing: AFSpacing.lg) {
                Spacer()

                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                        OnboardingPageView(page: item)
                            .tag(index)
                            .padding(.horizontal, AFSpacing.lg)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 460)

                pageIndicator

                Spacer()

                VStack(spacing: AFSpacing.sm) {
                    AFPrimaryButton(
                        title: page == pages.count - 1 ? "Get Started" : "Continue",
                        systemImage: page == pages.count - 1 ? "sparkles" : nil
                    ) {
                        advance()
                    }
                    if page < pages.count - 1 {
                        Button("Skip") { complete() }
                            .font(AFTypography.subheadline(.medium))
                            .foregroundStyle(AFColors.textSecondary)
                    }
                }
                .padding(.horizontal, AFSpacing.lg)
                .padding(.bottom, AFSpacing.xl)
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: AFSpacing.xs) {
            ForEach(0..<pages.count, id: \.self) { i in
                Capsule()
                    .fill(i == page ? AFColors.accent : AFColors.textTertiary)
                    .frame(width: i == page ? 22 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: page)
            }
        }
        .accessibilityHidden(true)
    }

    private func advance() {
        HapticsManager.shared.selection()
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            complete()
        }
    }

    private func complete() {
        HapticsManager.shared.impact(.medium)
        let settings = settingsRows.first ?? {
            let new = AppSettings()
            modelContext.insert(new)
            return new
        }()
        settings.hasCompletedOnboarding = true
        do {
            try modelContext.save()
        } catch {
            AppLog.persistence.error("Onboarding completion save failed: \(error.localizedDescription)")
        }
    }
}

private struct OnboardingPage {
    let systemImage: String
    let title: String
    let message: String
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AFSpacing.lg) {
            ZStack {
                Circle()
                    .fill(AFColors.brandGradient)
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .opacity(0.5)
                Image(systemName: page.systemImage)
                    .font(.system(size: 72, weight: .light))
                    .foregroundStyle(AFColors.brandGradient)
            }
            .frame(height: 180)

            Text(page.title)
                .font(AFTypography.title())
                .foregroundStyle(AFColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(page.message)
                .font(AFTypography.body())
                .foregroundStyle(AFColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OnboardingView()
        .modelContainer(SwiftDataContainer.makeInMemory())
}
