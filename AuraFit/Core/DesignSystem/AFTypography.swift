import SwiftUI

/// Typographic scale for AuraFit. All fonts use the system font with rounded design for a
/// friendly, modern feel and honor Dynamic Type via relative text styles.
enum AFTypography {

    static func display(_ weight: Font.Weight = .bold) -> Font {
        .system(.largeTitle, design: .rounded, weight: weight)
    }

    static func title(_ weight: Font.Weight = .bold) -> Font {
        .system(.title, design: .rounded, weight: weight)
    }

    static func title2(_ weight: Font.Weight = .semibold) -> Font {
        .system(.title2, design: .rounded, weight: weight)
    }

    static func title3(_ weight: Font.Weight = .semibold) -> Font {
        .system(.title3, design: .rounded, weight: weight)
    }

    static func headline(_ weight: Font.Weight = .semibold) -> Font {
        .system(.headline, design: .rounded, weight: weight)
    }

    static func body(_ weight: Font.Weight = .regular) -> Font {
        .system(.body, design: .rounded, weight: weight)
    }

    static func callout(_ weight: Font.Weight = .regular) -> Font {
        .system(.callout, design: .rounded, weight: weight)
    }

    static func subheadline(_ weight: Font.Weight = .regular) -> Font {
        .system(.subheadline, design: .rounded, weight: weight)
    }

    static func footnote(_ weight: Font.Weight = .regular) -> Font {
        .system(.footnote, design: .rounded, weight: weight)
    }

    static func caption(_ weight: Font.Weight = .regular) -> Font {
        .system(.caption, design: .rounded, weight: weight)
    }

    /// Monospaced numeric style used for big score readouts.
    static func scoreNumber(size: CGFloat) -> Font {
        .system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }
}

extension Text {
    /// Convenience for applying a typography style and primary color in one call.
    func afStyle(_ font: Font, color: Color = AFColors.textPrimary) -> some View {
        self.font(font).foregroundStyle(color)
    }
}
