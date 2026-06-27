import SwiftUI

// MARK: - Glass Card

/// A glassmorphism container using system materials with a subtle gradient stroke.
struct AFGlassCard<Content: View>: View {
    var padding: CGFloat = AFSpacing.md
    var cornerRadius: CGFloat = AFRadius.lg
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(AFColors.surface.opacity(0.35))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.18), .white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: AFShadow.card.color, radius: AFShadow.card.radius, x: AFShadow.card.x, y: AFShadow.card.y)
    }
}

// MARK: - Primary Button

struct AFPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            HStack(spacing: AFSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(AFTypography.headline())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AFSpacing.md)
            .foregroundStyle(.white)
            .background(AFColors.brandGradient, in: Capsule())
            .opacity(isEnabled ? 1 : 0.5)
            .shadow(color: AFColors.accent.opacity(reduceMotion ? 0 : 0.4), radius: 16, y: 6)
        }
        .buttonStyle(AFPressStyle())
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
    }
}

struct AFSecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AFSpacing.xs) {
                if let systemImage { Image(systemName: systemImage) }
                Text(title).font(AFTypography.headline())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AFSpacing.md)
            .foregroundStyle(AFColors.textPrimary)
            .background(AFColors.surfaceElevated, in: Capsule())
            .overlay(Capsule().strokeBorder(AFColors.stroke, lineWidth: 1))
        }
        .buttonStyle(AFPressStyle())
        .accessibilityLabel(Text(title))
    }
}

/// Subtle scale-on-press style; respects Reduce Motion.
struct AFPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Section Header

struct AFSectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AFTypography.title3())
                .foregroundStyle(AFColors.textPrimary)
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(AFTypography.subheadline(.semibold))
                    .foregroundStyle(AFColors.accent)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Metric Bar

struct AFMetricBar: View {
    let label: String
    let value: Int          // 0...100
    var systemImage: String? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animatedWidth: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: AFSpacing.xs) {
            HStack(spacing: AFSpacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(AFColors.accent)
                        .font(.footnote)
                }
                Text(label)
                    .font(AFTypography.subheadline(.medium))
                    .foregroundStyle(AFColors.textSecondary)
                Spacer()
                Text("\(value)")
                    .font(AFTypography.subheadline(.bold).monospacedDigit())
                    .foregroundStyle(AFColors.scoreColor(for: value))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(AFColors.surfaceElevated)
                    Capsule()
                        .fill(AFColors.scoreGradient(for: value))
                        .frame(width: max(6, animatedWidth * geo.size.width))
                }
                .onAppear {
                    let target = CGFloat(value) / 100.0
                    if reduceMotion {
                        animatedWidth = target
                    } else {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.85)) {
                            animatedWidth = target
                        }
                    }
                }
            }
            .frame(height: 10)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text("\(value) out of 100"))
    }
}

// MARK: - Palette Chip

struct AFPaletteChip: View {
    let color: Color
    var size: CGFloat = 28

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1))
            .accessibilityHidden(true)
    }
}

// MARK: - Tag Chip

struct AFTagChip: View {
    let text: String
    var systemImage: String? = nil
    var tint: Color = AFColors.accent

    var body: some View {
        HStack(spacing: AFSpacing.xxs) {
            if let systemImage { Image(systemName: systemImage).font(.caption2) }
            Text(text).font(AFTypography.caption(.semibold))
        }
        .padding(.horizontal, AFSpacing.sm)
        .padding(.vertical, AFSpacing.xxs + 2)
        .foregroundStyle(tint)
        .background(tint.opacity(0.16), in: Capsule())
        .overlay(Capsule().strokeBorder(tint.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Empty State

struct AFEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AFSpacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(AFColors.brandGradient)
            Text(title)
                .font(AFTypography.title3())
                .foregroundStyle(AFColors.textPrimary)
                .multilineTextAlignment(.center)
            Text(message)
                .font(AFTypography.subheadline())
                .foregroundStyle(AFColors.textSecondary)
                .multilineTextAlignment(.center)
            if let actionTitle, let action {
                AFPrimaryButton(title: actionTitle, action: action)
                    .padding(.top, AFSpacing.xs)
                    .frame(maxWidth: 260)
            }
        }
        .padding(AFSpacing.xl)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Background

/// Standard app background: deep gradient with a soft aura glow.
struct AFBackground: View {
    var body: some View {
        ZStack {
            AFColors.background.ignoresSafeArea()
            AFColors.auraGradient
                .ignoresSafeArea()
                .blendMode(.screen)
                .opacity(0.7)
        }
    }
}

extension View {
    /// Applies the standard AuraFit background behind the content.
    func afScreenBackground() -> some View {
        background(AFBackground())
    }
}
