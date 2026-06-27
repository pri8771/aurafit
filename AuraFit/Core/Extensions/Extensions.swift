import SwiftUI
import CoreImage
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Date

extension Date {
    /// Whether this date falls on the same calendar day as `other`.
    func isSameDay(as other: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: other)
    }

    var relativeShortString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }

    var shortDateString: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }
}

// MARK: - Int score helpers

extension Int {
    /// Clamps an integer into the 0...100 score range.
    var clampedScore: Int { Swift.max(0, Swift.min(100, self)) }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

// MARK: - Color <-> components

extension Color {
    /// Creates a Color from RGB components in 0...1.
    init(rgb r: Double, _ g: Double, _ b: Double) {
        self.init(red: r, green: g, blue: b)
    }

    #if canImport(UIKit)
    /// Extracts approximate RGBA components (0...1). Returns nil if not convertible.
    var rgbaComponents: (r: Double, g: Double, b: Double, a: Double)? {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return (Double(r), Double(g), Double(b), Double(a))
    }
    #endif
}

// MARK: - UIImage helpers

#if canImport(UIKit)
extension UIImage {
    /// Returns an image redrawn with orientation baked in (orientation == .up).
    func normalizedOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    /// Resizes so the longest edge equals `maxDimension`, preserving aspect ratio.
    func resized(maxDimension: CGFloat) -> UIImage {
        let longest = Swift.max(size.width, size.height)
        guard longest > maxDimension, longest > 0 else { return self }
        let scaleFactor = maxDimension / longest
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
#endif

// MARK: - View helpers

extension View {
    /// Conditionally applies a transform.
    @ViewBuilder
    func `if`<Transformed: View>(_ condition: Bool, transform: (Self) -> Transformed) -> some View {
        if condition { transform(self) } else { self }
    }

    /// Hides the view based on a condition while keeping layout when `remove` is false.
    @ViewBuilder
    func hidden(_ shouldHide: Bool, remove: Bool = false) -> some View {
        if shouldHide {
            if remove { EmptyView() } else { self.hidden() }
        } else {
            self
        }
    }
}
