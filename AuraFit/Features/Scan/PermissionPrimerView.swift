import SwiftUI

/// A friendly pre-permission primer shown before the system camera prompt, explaining the
/// privacy-first value ("everything stays on your device").
struct PermissionPrimerView: View {
    let onContinue: () -> Void
    let onUseLibrary: () -> Void
    var onCancel: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AFSpacing.lg) {
            Spacer()
            ZStack {
                Circle().fill(AFColors.brandGradient).frame(width: 120, height: 120).blur(radius: 26).opacity(0.5)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 64, weight: .light))
                    .foregroundStyle(AFColors.brandGradient)
            }

            Text("100% On-Device")
                .font(AFTypography.title())
                .foregroundStyle(AFColors.textPrimary)

            Text("AuraFit analyzes your fit photo entirely on your iPhone. Your photos are never uploaded, shared, or sent to any server.")
                .font(AFTypography.body())
                .foregroundStyle(AFColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                PrimerBullet(icon: "camera.fill", text: "Capture a quick full-body photo")
                PrimerBullet(icon: "cpu", text: "On-device models score the outfit and the shot")
                PrimerBullet(icon: "hand.raised.fill", text: "Nothing ever leaves your device")
            }
            .padding(.vertical, AFSpacing.sm)

            Spacer()

            VStack(spacing: AFSpacing.sm) {
                AFPrimaryButton(title: "Enable Camera", systemImage: "camera.fill", action: onContinue)
                    .accessibilityIdentifier("permissionPrimer.enableCameraButton")
                AFSecondaryButton(title: "Import from Library", systemImage: "photo.on.rectangle", action: onUseLibrary)
                    .accessibilityIdentifier("permissionPrimer.importFromLibraryButton")
            }
        }
        .padding(AFSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .afScreenBackground()
        .overlay(alignment: .topTrailing) {
            if let onCancel {
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AFColors.textTertiary)
                }
                .padding(AFSpacing.md)
                .accessibilityLabel("Close")
            }
        }
    }
}

private struct PrimerBullet: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: AFSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(AFColors.accent)
                .frame(width: 28)
            Text(text)
                .font(AFTypography.subheadline())
                .foregroundStyle(AFColors.textSecondary)
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PermissionPrimerView(onContinue: {}, onUseLibrary: {})
}
