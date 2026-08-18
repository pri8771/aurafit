import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A selectable visual style for the exported scorecard. Every style is available to everyone.
enum ScorecardTheme: String, CaseIterable, Identifiable, Sendable {
    case classic
    case streetwear
    case softLuxury

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .streetwear: return "Streetwear"
        case .softLuxury: return "Soft Luxury"
        }
    }

    /// Base card background color.
    var baseColor: Color {
        switch self {
        case .classic: return Color(red: 0.05, green: 0.05, blue: 0.08)
        case .streetwear: return Color(red: 0.06, green: 0.04, blue: 0.05)
        case .softLuxury: return Color(red: 0.09, green: 0.075, blue: 0.11)
        }
    }

    /// Ambient radial-gradient stops layered behind the card content (top-anchored).
    var ambientColors: [Color] {
        switch self {
        case .classic:
            return [Color(red: 0.557, green: 0.451, blue: 0.961).opacity(0.40),
                    Color(red: 0.357, green: 0.835, blue: 0.96).opacity(0.12), .clear]
        case .streetwear:
            return [Color(red: 0.98, green: 0.33, blue: 0.28).opacity(0.55),
                    Color(red: 0.98, green: 0.78, blue: 0.22).opacity(0.20), .clear]
        case .softLuxury:
            return [Color(red: 0.83, green: 0.69, blue: 0.45).opacity(0.42),
                    Color(red: 0.42, green: 0.28, blue: 0.48).opacity(0.22), .clear]
        }
    }

    /// Accent used for the brand mark and persona chip.
    var accent: Color {
        switch self {
        case .classic: return Color(red: 0.557, green: 0.451, blue: 0.961)
        case .streetwear: return Color(red: 0.98, green: 0.55, blue: 0.42)
        case .softLuxury: return Color(red: 0.86, green: 0.74, blue: 0.52)
        }
    }
}

/// Immutable data needed to render a shareable scorecard / reveal clip.
struct ScorecardModel {
    var score: FitScore
    var persona: StylePersona
    var paletteHex: [String]
    var dateString: String
    var theme: ScorecardTheme

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
        theme: ScorecardTheme = .classic
    ) {
        self.score = score
        self.persona = persona
        self.paletteHex = paletteHex
        self.dateString = dateString
        self.theme = theme
    }
}
