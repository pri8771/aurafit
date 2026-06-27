import SwiftUI
import UIKit

/// A compact card summarizing a `FitSession`, used in carousels and lists.
///
/// Pass an explicit `width` for fixed-size carousels; pass `nil` to fill the available
/// width (e.g. inside a `LazyVGrid`). The photo keeps a portrait aspect ratio either way.
struct FitCardView: View {
    let session: FitSession
    var width: CGFloat? = 160
    let image: UIImage?

    private let aspect: CGFloat = 0.77   // ~ portrait fit photo

    var body: some View {
        VStack(alignment: .leading, spacing: AFSpacing.xs) {
            ZStack(alignment: .topTrailing) {
                photo
                scoreBadge
                    .padding(AFSpacing.xs)
            }

            Text(session.label.rawValue)
                .font(AFTypography.subheadline(.semibold))
                .foregroundStyle(AFColors.textPrimary)
                .lineLimit(1)

            HStack(spacing: AFSpacing.xxs) {
                Image(systemName: session.stylePersona.systemImage)
                    .font(.caption2)
                Text(session.stylePersona.rawValue)
                    .font(AFTypography.caption())
                    .lineLimit(1)
            }
            .foregroundStyle(AFColors.textSecondary)

            Text(session.createdAt.relativeShortString)
                .font(AFTypography.caption())
                .foregroundStyle(AFColors.textTertiary)
        }
        .frame(width: width)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.label.rawValue) fit, score \(session.overallScore), \(session.stylePersona.rawValue), \(session.createdAt.shortDateString)")
    }

    @ViewBuilder
    private var photo: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    AFColors.surfaceElevated
                    Image(systemName: session.stylePersona.systemImage)
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(AFColors.brandGradient)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(aspect, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: AFRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AFRadius.md, style: .continuous)
                .strokeBorder(AFColors.stroke, lineWidth: 1)
        )
    }

    private var scoreBadge: some View {
        Text("\(session.overallScore)")
            .font(AFTypography.headline(.heavy).monospacedDigit())
            .foregroundStyle(.white)
            .padding(.horizontal, AFSpacing.sm)
            .padding(.vertical, AFSpacing.xxs)
            .background(AFColors.scoreColor(for: session.overallScore), in: Capsule())
            .overlay(Capsule().strokeBorder(.white.opacity(0.4), lineWidth: 1))
            .shadow(radius: 4)
    }
}
