import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Renders a `ScorecardModel` into a 1080×1920 PNG/JPEG using SwiftUI's `ImageRenderer`.
@MainActor
struct ScorecardRenderer {

    /// Target export resolution (vertical, share-friendly).
    static let exportSize = CGSize(width: 1080, height: 1920)

    enum RenderError: LocalizedError {
        case renderFailed
        var errorDescription: String? { "Could not render the scorecard image." }
    }

    #if canImport(UIKit)
    /// Renders the scorecard to a `UIImage` at export resolution.
    func renderImage(model: ScorecardModel) throws -> UIImage {
        let view = ScorecardView(model: model, revealProgress: 1.0)
        let renderer = ImageRenderer(content: view)
        // Scale the 360×640 logical canvas up to 1080×1920.
        renderer.proposedSize = ProposedViewSize(ScorecardView.canvasSize)
        renderer.scale = Self.exportSize.width / ScorecardView.canvasSize.width
        guard let image = renderer.uiImage else {
            throw RenderError.renderFailed
        }
        return image
    }

    /// Renders and persists a scorecard, returning the relative file path in the documents dir.
    func renderAndStore(model: ScorecardModel, store: ImageFileStore, name: String) throws -> String {
        let image = try renderImage(model: model)
        return try store.savePNG(image, folder: .scorecards, name: name)
    }
    #endif
}
