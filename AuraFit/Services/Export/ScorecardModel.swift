import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Immutable data needed to render a shareable scorecard / reveal clip.
struct ScorecardModel {
    var score: FitScore
    var persona: StylePersona
    var paletteHex: [String]
    var dateString: String
    var includeWatermark: Bool

    var palette: [RGBColor] { paletteHex.compactMap { RGBColor.fromHex($0) } }

    #if canImport(UIKit)
    /// The user's original fit photo (not Sendable across actors; kept for main-actor rendering).
    var photo: UIImage?
    #endif

    init(
        score: FitScore,
        persona: StylePersona,
        paletteHex: [String],
        dateString: String,
        includeWatermark: Bool
    ) {
        self.score = score
        self.persona = persona
        self.paletteHex = paletteHex
        self.dateString = dateString
        self.includeWatermark = includeWatermark
    }
}
