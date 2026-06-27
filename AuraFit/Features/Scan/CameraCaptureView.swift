import SwiftUI
import UIKit

/// Full-screen camera capture with a full-body alignment guide overlay.
/// Falls back gracefully when the camera is unavailable (e.g. Simulator).
struct CameraCaptureView: View {
    let onCapture: (UIImage) -> Void
    let onUseLibrary: () -> Void
    let onCancel: () -> Void

    @State private var camera = CameraService()
    @State private var isCapturing = false
    @State private var errorMessage: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch camera.state {
            case .running:
                CameraPreviewView(session: camera.session)
                    .ignoresSafeArea()
                alignmentGuide
                controls
            case .unavailable(let reason), .failed(let reason):
                unavailableView(reason: reason)
            default:
                loadingView
            }
        }
        .task {
            await camera.start()
        }
        .onDisappear { camera.stop() }
        .alert("Capture Failed", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Overlays

    private var alignmentGuide: some View {
        GeometryReader { geo in
            let guideWidth = geo.size.width * 0.5
            let guideHeight = geo.size.height * 0.78
            ZStack {
                RoundedRectangle(cornerRadius: AFRadius.xl, style: .continuous)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2.5, dash: [12, 8])
                    )
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(width: guideWidth, height: guideHeight)

                Image(systemName: "figure.stand")
                    .font(.system(size: guideHeight * 0.5, weight: .ultraLight))
                    .foregroundStyle(.white.opacity(0.18))
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .allowsHitTesting(false)
        .overlay(alignment: .top) {
            Text("Fit your whole body inside the frame")
                .font(AFTypography.subheadline(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, AFSpacing.md)
                .padding(.vertical, AFSpacing.xs)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.top, 60)
                .accessibilityAddTraits(.isStaticText)
        }
    }

    private var controls: some View {
        VStack {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(AFSpacing.sm)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Cancel")
                Spacer()
            }
            .padding(AFSpacing.md)

            Spacer()

            HStack(alignment: .center) {
                Button(action: onUseLibrary) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(AFSpacing.md)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .accessibilityLabel("Import from library")

                Spacer()

                Button(action: capture) {
                    ZStack {
                        Circle().strokeBorder(.white, lineWidth: 4).frame(width: 78, height: 78)
                        Circle().fill(.white).frame(width: 62, height: 62)
                        if isCapturing {
                            ProgressView().tint(.black)
                        }
                    }
                }
                .disabled(isCapturing)
                .scaleEffect(isCapturing && !reduceMotion ? 0.92 : 1)
                .animation(.spring(response: 0.3), value: isCapturing)
                .accessibilityLabel("Capture photo")

                Spacer()

                Color.clear.frame(width: 56, height: 56)
            }
            .padding(.horizontal, AFSpacing.xl)
            .padding(.bottom, AFSpacing.xxl)
        }
    }

    private func unavailableView(reason: String) -> some View {
        VStack(spacing: AFSpacing.lg) {
            Spacer()
            Image(systemName: "camera.metering.unknown")
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(AFColors.brandGradient)
            Text("Camera Unavailable")
                .font(AFTypography.title2())
                .foregroundStyle(.white)
            Text(reason)
                .font(AFTypography.subheadline())
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
            AFPrimaryButton(title: "Import from Library", systemImage: "photo.on.rectangle", action: onUseLibrary)
            AFSecondaryButton(title: "Cancel", action: onCancel)
        }
        .padding(AFSpacing.lg)
    }

    private var loadingView: some View {
        VStack(spacing: AFSpacing.md) {
            ProgressView().tint(.white)
            Text("Starting camera…")
                .font(AFTypography.subheadline())
                .foregroundStyle(.white.opacity(0.7))
        }
    }

    private func capture() {
        guard !isCapturing else { return }
        isCapturing = true
        HapticsManager.shared.impact(.medium)
        Task {
            defer { isCapturing = false }
            do {
                let image = try await camera.capturePhoto()
                onCapture(image)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
