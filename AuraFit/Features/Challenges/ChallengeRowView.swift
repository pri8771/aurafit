import SwiftUI

/// A row/card summarizing a challenge with progress, used in Home and the Challenges list.
struct ChallengeRowView: View {
    let challenge: Challenge

    private var accent: Color {
        RGBColor.fromHex(challenge.accentHex)?.color ?? AFColors.accent
    }

    var body: some View {
        AFGlassCard {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                HStack(spacing: AFSpacing.md) {
                    ZStack {
                        Circle().fill(accent.opacity(0.18)).frame(width: 48, height: 48)
                        Image(systemName: challenge.systemImage)
                            .font(.title3)
                            .foregroundStyle(accent)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(challenge.title)
                            .font(AFTypography.headline())
                            .foregroundStyle(AFColors.textPrimary)
                        Text(challenge.subtitle)
                            .font(AFTypography.caption())
                            .foregroundStyle(AFColors.textSecondary)
                    }
                    Spacer()
                    if challenge.isCompleted {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(AFColors.success)
                            .font(.title3)
                    }
                }

                progressBar

                Text("\(challenge.completedCount)/\(challenge.goalCount) complete")
                    .font(AFTypography.caption(.medium))
                    .foregroundStyle(AFColors.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(challenge.title), \(challenge.completedCount) of \(challenge.goalCount) complete")
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(AFColors.surfaceElevated)
                Capsule()
                    .fill(LinearGradient(colors: [accent, accent.opacity(0.6)],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: max(8, geo.size.width * min(1, challenge.progress)))
            }
        }
        .frame(height: 10)
    }
}
