import SwiftUI
import UIKit

/// A compact card summarizing a `FitSession`, used in carousels and lists.
///
/// Pass an explicit `width` for fixed-size carousels; pass `nil` to fill the available
/// width (e.g. inside a `LazyVGrid`). The photo keeps a portrait aspect ratio either way.
///
/// The card loads its own photo as a **downsampled thumbnail** on a background task. Cards
/// appear in lazy grids and carousels, so a synchronous full-resolution decode in `body` would
/// stall the main thread once per cell per re-evaluation.
struct FitCardView: View {
    let session: FitSession
    var width: CGFloat? = 160
    let imageStore: ImageFileStore

    @Environment(\.displayScale) private var displayScale
    @State private var phase: PhotoPhase = .loading

    private let aspect: CGFloat = 0.77   // ~ portrait fit photo

    /// The tallest a card photo ever renders. A card is at most half the screen wide (~200pt
    /// in the two-column grid) and taller than it is wide, so one budget covers the grid and
    /// the carousel — and lets them share cache entries.
    private static let maxPhotoPointHeight: CGFloat = 260

    private enum PhotoPhase {
        case loading
        case loaded(UIImage)
        case unavailable
    }

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
        .task(id: session.originalImagePath) { await loadPhoto() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(session.label.rawValue) fit, score \(session.overallScore), \(session.stylePersona.rawValue), \(session.createdAt.shortDateString)")
    }

    // MARK: - Photo loading

    /// Longest-edge pixel budget for this card's photo on the current display.
    private var thumbnailMaxPixelSize: CGFloat {
        (Self.maxPhotoPointHeight * max(displayScale, 1)).rounded()
    }

    /// Resolves the card photo without ever decoding on the main thread.
    ///
    /// `.task(id:)` cancels and restarts this whenever the card is handed a different photo,
    /// and the path is re-checked after the await so a slow load can never overwrite a newer
    /// one.
    private func loadPhoto() async {
        guard let path = session.originalImagePath else {
            phase = .unavailable
            return
        }

        // Cache hit: adopt it immediately, unanimated, so scrolling back over a card does not
        // flash a placeholder.
        if let cached = imageStore.cachedThumbnail(relativePath: path, maxPixelSize: thumbnailMaxPixelSize) {
            phase = .loaded(cached)
            return
        }

        phase = .loading
        let image = await imageStore.thumbnail(relativePath: path, maxPixelSize: thumbnailMaxPixelSize)
        guard !Task.isCancelled, session.originalImagePath == path else { return }

        withAnimation(.easeOut(duration: 0.18)) {
            phase = image.map(PhotoPhase.loaded) ?? .unavailable
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var photo: some View {
        Group {
            switch phase {
            case .loaded(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            case .loading:
                AFColors.surfaceElevated
            case .unavailable:
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
