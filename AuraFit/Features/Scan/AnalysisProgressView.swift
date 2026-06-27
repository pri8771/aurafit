import SwiftUI
import UIKit

/// Animated 5-step progress shown while the pipeline runs. Driven by `FitAnalysisService`.
struct AnalysisProgressView: View {
    let image: UIImage?
    let currentStep: AnalysisStep
    let completedSteps: Set<AnalysisStep>

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    /// Steps shown to the user (the internal "normalizing" step is folded into the first row).
    private var displayedSteps: [AnalysisStep] {
        [.detectingPose, .readingColors, .checkingLighting, .scoringComposition, .buildingScorecard]
    }

    var body: some View {
        VStack(spacing: AFSpacing.xl) {
            Spacer()
            previewThumb
            VStack(alignment: .leading, spacing: AFSpacing.md) {
                ForEach(displayedSteps) { step in
                    stepRow(step)
                }
            }
            .padding(AFSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AFRadius.lg, style: .continuous))
            Spacer()
            Text("Analyzing on-device…")
                .font(AFTypography.footnote())
                .foregroundStyle(AFColors.textTertiary)
        }
        .padding(AFSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .afScreenBackground()
        .onAppear { pulse = true }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Analyzing your fit. Current step: \(currentStep.title)")
    }

    private var previewThumb: some View {
        ZStack {
            Circle()
                .fill(AFColors.brandGradient)
                .frame(width: 180, height: 180)
                .blur(radius: 40)
                .opacity(reduceMotion ? 0.4 : (pulse ? 0.7 : 0.35))
                .animation(reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)

            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 60, weight: .light))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: 150, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: AFRadius.lg, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: AFRadius.lg, style: .continuous).strokeBorder(.white.opacity(0.2)))
        }
    }

    private func stepRow(_ step: AnalysisStep) -> some View {
        let isDone = completedSteps.contains(step) || step.rawValue < currentStep.rawValue
        let isActive = step == currentStep

        return HStack(spacing: AFSpacing.md) {
            ZStack {
                Circle()
                    .fill(isDone ? AFColors.success.opacity(0.2) : (isActive ? AFColors.accent.opacity(0.2) : AFColors.surfaceElevated))
                    .frame(width: 36, height: 36)
                if isDone {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AFColors.success)
                } else if isActive {
                    ProgressView().tint(AFColors.accent).scaleEffect(0.8)
                } else {
                    Image(systemName: step.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(AFColors.textTertiary)
                }
            }
            Text(step.title)
                .font(AFTypography.body(isActive ? .semibold : .regular))
                .foregroundStyle(isDone || isActive ? AFColors.textPrimary : AFColors.textSecondary)
            Spacer()
        }
        .animation(.easeInOut, value: isDone)
        .animation(.easeInOut, value: isActive)
    }
}

#Preview {
    AnalysisProgressView(image: nil, currentStep: .checkingLighting, completedSteps: [.detectingPose, .readingColors])
}
