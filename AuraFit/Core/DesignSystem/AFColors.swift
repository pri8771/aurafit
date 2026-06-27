import SwiftUI

/// Central color palette for AuraFit. Dark-first aesthetic with neon accent gradients.
///
/// All colors are defined programmatically so the app does not depend on asset-catalog
/// color sets beyond `AccentColor`. This keeps the design system self-contained and testable.
enum AFColors {

    // MARK: - Brand

    static let accent = Color(red: 0.557, green: 0.451, blue: 0.961)      // electric violet
    static let accentSecondary = Color(red: 0.357, green: 0.835, blue: 0.96) // cyan
    static let accentWarm = Color(red: 0.98, green: 0.55, blue: 0.42)     // coral

    // MARK: - Surfaces

    static let background = Color(red: 0.05, green: 0.05, blue: 0.08)
    static let surface = Color(red: 0.10, green: 0.10, blue: 0.14)
    static let surfaceElevated = Color(red: 0.14, green: 0.14, blue: 0.19)
    static let stroke = Color.white.opacity(0.08)

    // MARK: - Text

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.68)
    static let textTertiary = Color.white.opacity(0.42)

    // MARK: - Semantic

    static let success = Color(red: 0.30, green: 0.85, blue: 0.55)
    static let warning = Color(red: 0.98, green: 0.78, blue: 0.30)
    static let danger = Color(red: 0.96, green: 0.36, blue: 0.42)

    // MARK: - Gradients

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [accent, accentSecondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var warmGradient: LinearGradient {
        LinearGradient(
            colors: [accentWarm, accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var auraGradient: RadialGradient {
        RadialGradient(
            colors: [accent.opacity(0.45), accentSecondary.opacity(0.10), .clear],
            center: .center,
            startRadius: 4,
            endRadius: 320
        )
    }

    /// Returns a score-driven gradient: red → amber → green as the score rises.
    static func scoreGradient(for score: Int) -> LinearGradient {
        let colors: [Color]
        switch score {
        case 85...:  colors = [success, accentSecondary]
        case 70..<85: colors = [accent, accentSecondary]
        case 55..<70: colors = [warning, accentWarm]
        case 40..<55: colors = [accentWarm, warning]
        default:      colors = [danger, accentWarm]
        }
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func scoreColor(for score: Int) -> Color {
        switch score {
        case 85...:   return success
        case 70..<85: return accentSecondary
        case 55..<70: return warning
        case 40..<55: return accentWarm
        default:      return danger
        }
    }
}
