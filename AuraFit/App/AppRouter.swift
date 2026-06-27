import SwiftUI

/// Top-level tabs of the app.
enum AppTab: Int, Hashable, CaseIterable, Identifiable {
    case home, scan, history, challenges, settings
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .scan: return "Scan"
        case .history: return "History"
        case .challenges: return "Challenges"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .scan: return "camera.viewfinder"
        case .history: return "clock.arrow.circlepath"
        case .challenges: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

/// Centralized navigation state: selected tab and globally-presented sheets.
@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home

    /// Presents the paywall modally from anywhere.
    var paywallContext: PaywallContext?

    /// Triggers the scan flow (used by Home's CTA jumping to the Scan tab).
    func startScan() {
        selectedTab = .scan
    }

    func presentPaywall(_ context: PaywallContext = .general) {
        paywallContext = context
    }

    func dismissPaywall() {
        paywallContext = nil
    }
}

/// Why the paywall was shown — tailors the headline/CTA.
enum PaywallContext: Identifiable, Equatable {
    case general
    case dailyLimitReached
    case revealVideo
    case removeWatermark
    case template(StylePersona)

    var id: String {
        switch self {
        case .general: return "general"
        case .dailyLimitReached: return "dailyLimit"
        case .revealVideo: return "reveal"
        case .removeWatermark: return "watermark"
        case .template(let p): return "template-\(p.rawValue)"
        }
    }

    var headline: String {
        switch self {
        case .general: return "Unlock AuraFit Pro"
        case .dailyLimitReached: return "You're on a roll"
        case .revealVideo: return "Generate Reveal Clips"
        case .removeWatermark: return "Export Watermark-Free"
        case .template: return "Unlock This Template"
        }
    }

    var subheadline: String {
        switch self {
        case .general: return "Everything you need to perfect every fit."
        case .dailyLimitReached: return "You've used your free scans for today. Go Pro for unlimited."
        case .revealVideo: return "Turn your score into a shareable 5-second reveal."
        case .removeWatermark: return "Share clean, professional scorecards."
        case .template(let p): return "Get the \(p.rawValue) scorecard style and more."
        }
    }
}
