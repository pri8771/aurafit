import SwiftUI

/// An animated circular score gauge used on the result and home screens.
struct ScoreRingView: View {
    let score: Int
    var size: CGFloat = 220
    var lineWidth: CGFloat = 18
    var showsLabel: Bool = true
    /// When false, the ring renders at full value without animating (for snapshots).
    var animated: Bool = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var progress: CGFloat = 0
    @State private var displayedScore: Int = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(AFColors.surfaceElevated, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AFColors.scoreGradient(for: score),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: AFColors.scoreColor(for: score).opacity(reduceMotion ? 0 : 0.5), radius: 12)

            if showsLabel {
                VStack(spacing: 0) {
                    Text("\(displayedScore)")
                        .font(AFTypography.scoreNumber(size: size * 0.32))
                        .foregroundStyle(AFColors.textPrimary)
                        .contentTransition(.numericText())
                    Text("/ 100")
                        .font(AFTypography.subheadline(.medium))
                        .foregroundStyle(AFColors.textTertiary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear { animate() }
        .onChange(of: score) { _, _ in animate() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Fit score")
        .accessibilityValue("\(score) out of 100")
    }

    private func animate() {
        let target = CGFloat(score.clampedScore) / 100
        if !animated || reduceMotion {
            progress = target
            displayedScore = score.clampedScore
            return
        }
        progress = 0
        displayedScore = 0
        withAnimation(.easeOut(duration: 1.1)) {
            progress = target
        }
        // Count-up the number.
        Task { @MainActor in
            let steps = 24
            for i in 0...steps {
                displayedScore = Int(Double(score.clampedScore) * Double(i) / Double(steps))
                try? await Task.sleep(for: .milliseconds(40))
            }
            displayedScore = score.clampedScore
        }
    }
}

#Preview {
    ScoreRingView(score: 87)
        .padding()
        .afScreenBackground()
}
