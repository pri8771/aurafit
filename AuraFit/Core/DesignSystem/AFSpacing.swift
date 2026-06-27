import SwiftUI

/// Spacing, radius, and shadow tokens for a consistent layout rhythm.
enum AFSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum AFRadius {
    static let sm: CGFloat = 10
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let pill: CGFloat = 999
}

enum AFShadow {
    static let card = (color: Color.black.opacity(0.35), radius: CGFloat(18), x: CGFloat(0), y: CGFloat(10))
    static let glow = (color: AFColors.accent.opacity(0.45), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(0))
}
