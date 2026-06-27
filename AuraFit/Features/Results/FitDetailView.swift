import SwiftUI

/// Detail screen for a saved fit (reuses `FitResultView` in non-fresh mode).
struct FitDetailView: View {
    let session: FitSession
    var body: some View {
        FitResultView(session: session, isFreshScan: false)
    }
}
