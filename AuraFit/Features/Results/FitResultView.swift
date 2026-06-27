import SwiftUI
import SwiftData
import UIKit

/// The result screen for a scan (and the detail screen for history). Shows the score, label,
/// persona, metric breakdown, tips, palette, and export/share CTAs.
struct FitResultView: View {
    let session: FitSession
    var result: FitAnalysisResult?
    var providedImage: UIImage?
    var isFreshScan: Bool

    init(session: FitSession,
         result: FitAnalysisResult? = nil,
         image: UIImage? = nil,
         isFreshScan: Bool = false) {
        self.session = session
        self.result = result
        self.providedImage = image
        self.isFreshScan = isFreshScan
    }

    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var fitImage: UIImage?
    @State private var exportState: ExportState = .idle
    @State private var shareItems: [Any]?
    @State private var toast: String?

    private enum ExportState: Equatable {
        case idle, renderingCard, renderingVideo
        var isBusy: Bool { self != .idle }
    }

    private var entitlements: EntitlementManager { environment.entitlements }
    private var metrics: [FitMetric] { session.metrics }

    var body: some View {
        ScrollView {
            VStack(spacing: AFSpacing.lg) {
                scoreHeader
                personaCard
                metricsCard
                if !session.tips.isEmpty { tipsCard }
                paletteCard
                actionButtons
                if isFreshScan { tryAgainButton }
            }
            .padding(AFSpacing.md)
        }
        .scrollIndicators(.hidden)
        .navigationTitle(isFreshScan ? "Your Fit Score" : session.createdAt.shortDateString)
        .navigationBarTitleDisplayMode(.inline)
        .afScreenBackground()
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticsManager.shared.impact(.light)
                    let repo = SessionRepository(context: modelContext, imageStore: environment.imageStore)
                    repo.setFavorite(session, !session.isFavorite)
                } label: {
                    Image(systemName: session.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(session.isFavorite ? AFColors.danger : AFColors.textSecondary)
                }
                .accessibilityLabel(session.isFavorite ? "Remove from favorites" : "Add to favorites")
            }
        }
        .task { await loadImage() }
        .sheet(isPresented: Binding(get: { shareItems != nil }, set: { if !$0 { shareItems = nil } })) {
            if let shareItems {
                ShareSheet(items: shareItems)
            }
        }
        .overlay(alignment: .bottom) { toastView }
    }

    // MARK: - Sections

    private var scoreHeader: some View {
        VStack(spacing: AFSpacing.sm) {
            ScoreRingView(score: session.overallScore, size: 230, animated: isFreshScan)
            Text(session.label.emoji + " " + session.label.rawValue)
                .font(AFTypography.title(.bold))
                .foregroundStyle(AFColors.textPrimary)
            Text(session.label.blurb)
                .font(AFTypography.subheadline())
                .foregroundStyle(AFColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AFSpacing.sm)
    }

    private var personaCard: some View {
        AFGlassCard {
            HStack(spacing: AFSpacing.md) {
                ZStack {
                    Circle().fill(AFColors.accent.opacity(0.18)).frame(width: 54, height: 54)
                    Image(systemName: session.stylePersona.systemImage)
                        .font(.title2)
                        .foregroundStyle(AFColors.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Style Persona")
                        .font(AFTypography.caption(.semibold))
                        .foregroundStyle(AFColors.textTertiary)
                    Text(session.stylePersona.rawValue)
                        .font(AFTypography.title3(.bold))
                        .foregroundStyle(AFColors.textPrimary)
                    Text(session.stylePersona.tagline)
                        .font(AFTypography.caption())
                        .foregroundStyle(AFColors.textSecondary)
                }
                Spacer()
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var metricsCard: some View {
        AFGlassCard {
            VStack(alignment: .leading, spacing: AFSpacing.md) {
                Text("Breakdown")
                    .font(AFTypography.title3(.bold))
                    .foregroundStyle(AFColors.textPrimary)
                ForEach(metrics) { metric in
                    AFMetricBar(label: metric.title, value: metric.value, systemImage: metric.systemImage)
                }
            }
        }
    }

    private var tipsCard: some View {
        AFGlassCard {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                Label("Glow-Up Tips", systemImage: "wand.and.stars")
                    .font(AFTypography.title3(.bold))
                    .foregroundStyle(AFColors.textPrimary)
                ForEach(Array(session.tips.enumerated()), id: \.offset) { index, tip in
                    HStack(alignment: .top, spacing: AFSpacing.sm) {
                        Text("\(index + 1)")
                            .font(AFTypography.caption(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(AFColors.brandGradient, in: Circle())
                        Text(tip)
                            .font(AFTypography.subheadline())
                            .foregroundStyle(AFColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var paletteCard: some View {
        if !session.paletteHex.isEmpty {
            AFGlassCard {
                VStack(alignment: .leading, spacing: AFSpacing.sm) {
                    Text("Palette")
                        .font(AFTypography.title3(.bold))
                        .foregroundStyle(AFColors.textPrimary)
                    HStack(spacing: AFSpacing.sm) {
                        ForEach(Array(session.paletteHex.prefix(5).enumerated()), id: \.offset) { _, hex in
                            if let rgb = RGBColor.fromHex(hex) {
                                VStack(spacing: AFSpacing.xxs) {
                                    AFPaletteChip(color: rgb.color, size: 40)
                                    Text("#\(hex)")
                                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                                        .foregroundStyle(AFColors.textTertiary)
                                }
                            }
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: AFSpacing.sm) {
            AFPrimaryButton(
                title: "Share Scorecard",
                systemImage: "square.and.arrow.up",
                isLoading: exportState == .renderingCard
            ) {
                Task { await shareScorecard() }
            }

            HStack(spacing: AFSpacing.sm) {
                AFSecondaryButton(title: "Save", systemImage: "square.and.arrow.down") {
                    Task { await saveScorecardToPhotos() }
                }
                AFSecondaryButton(
                    title: entitlements.canGenerateRevealVideo ? "Reveal Clip" : "Reveal Clip",
                    systemImage: entitlements.canGenerateRevealVideo ? "play.rectangle.fill" : "lock.fill"
                ) {
                    Task { await generateReveal() }
                }
            }
            .overlay {
                if exportState == .renderingVideo {
                    HStack(spacing: AFSpacing.xs) {
                        ProgressView().tint(AFColors.accent)
                        Text("Rendering reveal…").font(AFTypography.caption()).foregroundStyle(AFColors.textSecondary)
                    }
                    .padding(.horizontal, AFSpacing.md)
                    .padding(.vertical, AFSpacing.xs)
                    .background(.ultraThinMaterial, in: Capsule())
                }
            }
        }
        .disabled(exportState.isBusy)
    }

    private var tryAgainButton: some View {
        Button {
            HapticsManager.shared.selection()
            dismiss()
        } label: {
            Label("Scan Another Fit", systemImage: "arrow.counterclockwise")
                .font(AFTypography.headline())
                .foregroundStyle(AFColors.accent)
        }
        .padding(.top, AFSpacing.xs)
    }

    @ViewBuilder
    private var toastView: some View {
        if let toast {
            Text(toast)
                .font(AFTypography.subheadline(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, AFSpacing.md)
                .padding(.vertical, AFSpacing.sm)
                .background(.ultraThinMaterial, in: Capsule())
                .overlay(Capsule().strokeBorder(AFColors.stroke))
                .padding(.bottom, AFSpacing.xl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Export

    private func scorecardModel() -> ScorecardModel {
        var model = ScorecardModel(
            score: session.fitScore,
            persona: session.stylePersona,
            paletteHex: session.paletteHex,
            dateString: session.createdAt.shortDateString,
            includeWatermark: entitlements.exportsWatermarked
        )
        model.photo = fitImage
        return model
    }

    /// Renders (and caches) the scorecard image, returning a file URL.
    private func renderScorecardURL() async -> URL? {
        // Re-render when watermark state may have changed or no cached card exists.
        if let path = session.scorecardImagePath,
           environment.imageStore.fileExists(relativePath: path),
           !needsWatermarkRerender(path: path) {
            return environment.imageStore.absoluteURL(for: path)
        }
        exportState = .renderingCard
        defer { exportState = .idle }
        do {
            let renderer = ScorecardRenderer()
            let path = try renderer.renderAndStore(model: scorecardModel(),
                                                   store: environment.imageStore,
                                                   name: session.id.uuidString)
            let repo = SessionRepository(context: modelContext, imageStore: environment.imageStore)
            repo.attachScorecard(path, to: session)
            return environment.imageStore.absoluteURL(for: path)
        } catch {
            showToast("Couldn't render scorecard")
            AppLog.export.error("Scorecard render failed: \(error.localizedDescription)")
            return nil
        }
    }

    /// Always re-render for Pro users if the cached card might still have a watermark.
    private func needsWatermarkRerender(path: String) -> Bool {
        // Simple heuristic: Pro users get a fresh, watermark-free render once.
        entitlements.isPro
    }

    private func shareScorecard() async {
        guard let url = await renderScorecardURL() else { return }
        shareItems = [url]
        HapticsManager.shared.impact(.light)
    }

    private func saveScorecardToPhotos() async {
        guard let url = await renderScorecardURL() else { return }
        let ok = await ShareManager.saveImageToPhotos(url)
        showToast(ok ? "Saved to Photos" : "Couldn't save — check Photos access")
        if ok { HapticsManager.shared.notify(.success) }
    }

    private func generateReveal() async {
        guard entitlements.canGenerateRevealVideo else {
            router.presentPaywall(.revealVideo)
            return
        }
        exportState = .renderingVideo
        defer { exportState = .idle }
        do {
            let renderer = RevealVideoRenderer()
            let path = try await renderer.renderAndStore(model: scorecardModel(),
                                                         store: environment.imageStore,
                                                         name: session.id.uuidString)
            let repo = SessionRepository(context: modelContext, imageStore: environment.imageStore)
            repo.attachRevealVideo(path, to: session)
            let url = environment.imageStore.absoluteURL(for: path)
            HapticsManager.shared.notify(.success)
            shareItems = [url]
        } catch {
            showToast("Couldn't render reveal clip")
            AppLog.export.error("Reveal render failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func loadImage() async {
        if let providedImage {
            fitImage = providedImage
        } else {
            fitImage = environment.imageStore.loadImage(relativePath: session.originalImagePath)
        }
    }

    private func showToast(_ message: String) {
        withAnimation { toast = message }
        Task {
            try? await Task.sleep(for: .seconds(2.2))
            withAnimation { toast = nil }
        }
    }
}

#Preview {
    NavigationStack {
        FitResultView(
            session: FitSession(
                overallScore: 88,
                label: .sharp,
                stylePersona: .streetwear,
                metrics: FitMetricKind.allCases.map { FitMetric(kind: $0, value: Int.random(in: 60...95)) },
                tips: ["Square your shoulders for a confident stance.", "Drop to 2–3 main tones for a cleaner story."],
                paletteHex: ["1A1A1A", "8E73F5", "5BD5F5"]
            ),
            isFreshScan: true
        )
    }
    .environment(AppEnvironment.preview())
    .environment(AppRouter())
    .modelContainer(SwiftDataContainer.makeInMemory())
}
