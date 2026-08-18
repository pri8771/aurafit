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

/// Centralized navigation state: the selected tab.
@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home

    /// Triggers the scan flow (used by Home's CTA jumping to the Scan tab).
    func startScan() {
        selectedTab = .scan
    }
}
