import SwiftUI
import UIKit

/// The visual layout used to render a 1080×1920 shareable scorecard (and reveal-clip frames).
///
/// Designed at a logical 360×640 canvas and rendered at scale 3 → 1080×1920. A `revealProgress`
/// (0...1) animates the score count-up and content fade for the reveal video.
struct ScorecardView: View {
    let model: ScorecardModel
    var revealProgress: Double = 1.0

    /// Logical design size; the renderer applies a scale to reach export resolution.
    static let canvasSize = CGSize(width: 360, height: 640)

    private var displayedScore: Int {
        Int((Double(model.score.overall) * revealProgress).rounded())
    }

    private var contentOpacity: Double {
        // Fade supporting content in during the back half of the reveal.
        ((revealProgress - 0.35) / 0.5).clamped(to: 0...1)
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 14) {
                header
                photoBlock
                scoreBlock
                metricsBlock
                    .opacity(contentOpacity)
                paletteBlock
                    .opacity(contentOpacity)
                Spacer(minLength: 0)
                footer
            }
            .padding(20)
        }
        .frame(width: Self.canvasSize.width, height: Self.canvasSize.height)
        .background(model.theme.baseColor)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }

    // MARK: - Sections

    private var background: some View {
        ZStack {
            model.theme.baseColor
            RadialGradient(
                colors: model.theme.ambientColors,
                center: .top,
                startRadius: 10,
                endRadius: 520
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(model.theme.accent)
                Text("AuraFit")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Text(model.dateString)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    @ViewBuilder
    private var photoBlock: some View {
        Group {
            #if canImport(UIKit)
            if let photo = model.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholderPhoto
            }
            #else
            placeholderPhoto
            #endif
        }
        .frame(height: 250)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 1)
        )
    }

    private var placeholderPhoto: some View {
        ZStack {
            AFColors.surfaceElevated
            Image(systemName: model.persona.systemImage)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AFColors.brandGradient)
        }
    }

    private var scoreBlock: some View {
        VStack(spacing: 2) {
            Text("\(displayedScore)")
                .font(.system(size: 76, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(AFColors.scoreGradient(for: model.score.overall))
            Text(model.score.label.rawValue.uppercased())
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(.white)
            HStack(spacing: 5) {
                Image(systemName: model.persona.systemImage)
                Text(model.persona.rawValue)
            }
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundStyle(AFColors.accent)
            .opacity(contentOpacity)
        }
    }

    private var metricsBlock: some View {
        VStack(spacing: 7) {
            ForEach(model.score.metrics.filter { $0.kind.weight > 0 }) { metric in
                HStack(spacing: 8) {
                    Text(metric.title)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(width: 110, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(.white.opacity(0.12))
                            Capsule()
                                .fill(AFColors.scoreGradient(for: metric.value))
                                .frame(width: geo.size.width * CGFloat(metric.value) / 100)
                        }
                    }
                    .frame(height: 7)
                    Text("\(metric.value)")
                        .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white)
                        .frame(width: 22, alignment: .trailing)
                }
            }
        }
    }

    private var paletteBlock: some View {
        HStack(spacing: 8) {
            ForEach(Array(model.palette.prefix(5).enumerated()), id: \.offset) { _, color in
                Circle()
                    .fill(color.color)
                    .frame(width: 22, height: 22)
                    .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
            }
        }
    }

    private var footer: some View {
        HStack {
            Text(model.score.label.emoji + " " + model.score.label.blurb)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(2)
            Spacer()
        }
    }
}

#Preview {
    ScorecardView(
        model: ScorecardModel(
            score: .placeholder,
            persona: .streetwear,
            paletteHex: ["1A1A1A", "8E73F5", "5BD5F5", "FB8B6B"],
            dateString: "Jun 27, 2026"
        )
    )
}
