import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Centralized haptic feedback. Safe to call on simulator / unsupported devices (no-ops).
@MainActor
final class HapticsManager {
    static let shared = HapticsManager()

    /// Set to `false` to globally disable haptics (mirrors `AppSettings.hapticsEnabled`).
    var isEnabled: Bool = true

    private init() {}

    func impact(_ style: ImpactStyle = .medium) {
        guard isEnabled else { return }
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style.uiStyle)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }

    func selection() {
        guard isEnabled else { return }
        #if canImport(UIKit)
        UISelectionFeedbackGenerator().selectionChanged()
        #endif
    }

    func notify(_ type: NotificationType) {
        guard isEnabled else { return }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(type.uiType)
        #endif
    }

    /// A celebratory escalating pattern used on score reveal.
    func celebrate() {
        guard isEnabled else { return }
        impact(.light)
        Task {
            try? await Task.sleep(for: .milliseconds(120))
            impact(.medium)
            try? await Task.sleep(for: .milliseconds(120))
            impact(.heavy)
            try? await Task.sleep(for: .milliseconds(140))
            notify(.success)
        }
    }

    enum ImpactStyle {
        case light, medium, heavy, soft, rigid
        #if canImport(UIKit)
        var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            case .soft: return .soft
            case .rigid: return .rigid
            }
        }
        #endif
    }

    enum NotificationType {
        case success, warning, error
        #if canImport(UIKit)
        var uiType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            }
        }
        #endif
    }
}
