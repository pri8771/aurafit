import SwiftUI
import SwiftData
import PhotosUI
import UIKit

/// The Scan tab coordinator. Manages the full flow:
/// chooser → (permission primer / camera) or library → analysis progress → result.
struct ScanView: View {
    @Environment(AppEnvironment.self) private var environment
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    private enum Sheet: Identifiable {
        case camera, analyzing
        var id: Int { hashValue }
    }

    private enum CameraPermissionPrompt: Equatable { case primer, deniedSettings }

    @State private var activeSheet: Sheet?
    @State private var cameraPermissionPrompt: CameraPermissionPrompt?
    @State private var isProcessingScan = false
    @State private var photoItem: PhotosPickerItem?
    @State private var capturedImage: UIImage?
    @State private var analysisResult: FitAnalysisResult?
    @State private var resultSession: FitSession?
    @State private var errorMessage: String?
    /// The in-flight analysis, retained so the Cancel button can stop it.
    @State private var analysisTask: Task<Void, Never>?

    private var entitlements: EntitlementManager { environment.entitlements }

    var body: some View {
        NavigationStack {
            startScreen
                .navigationTitle("Scan")
                .navigationBarTitleDisplayMode(.inline)
                .afScreenBackground()
                .toolbarBackground(.hidden, for: .navigationBar)
                .navigationDestination(item: $resultSession) { session in
                    FitResultView(session: session,
                                  result: analysisResult,
                                  image: capturedImage,
                                  isFreshScan: true)
                }
        }
        // Camera / analyzing presented as full-screen covers.
        .fullScreenCover(item: $activeSheet) { sheet in
            switch sheet {
            case .camera:
                CameraCaptureView(
                    onCapture: { image in
                        activeSheet = nil
                        handleImage(image)
                    },
                    onUseLibrary: { activeSheet = nil; showLibraryPickerFlag = true },
                    onCancel: { activeSheet = nil }
                )
            case .analyzing:
                AnalysisProgressView(
                    image: capturedImage,
                    currentStep: environment.analysisService.currentStep,
                    completedSteps: environment.analysisService.completedSteps,
                    onCancel: cancelAnalysis
                )
                // Swipe-to-dismiss stays off so the cover can't be dismissed while the task keeps
                // running; Cancel is the one exit, and it stops the work as well as the screen.
                .interactiveDismissDisabled()
            }
        }
        .sheet(isPresented: Binding(
            get: { cameraPermissionPrompt == .primer },
            set: { if !$0 { cameraPermissionPrompt = nil } }
        )) {
            PermissionPrimerView(
                onContinue: { cameraPermissionPrompt = nil; openCamera() },
                onUseLibrary: { cameraPermissionPrompt = nil; showLibraryPickerFlag = true },
                onCancel: { cameraPermissionPrompt = nil }
            )
        }
        .alert("Camera Access Needed", isPresented: Binding(
            get: { cameraPermissionPrompt == .deniedSettings },
            set: { if !$0 { cameraPermissionPrompt = nil } }
        )) {
            Button("Open Settings") { PermissionManager.openAppSettings(); cameraPermissionPrompt = nil }
            Button("Use Library") { cameraPermissionPrompt = nil; showLibraryPickerFlag = true }
            Button("Cancel", role: .cancel) { cameraPermissionPrompt = nil }
        } message: {
            Text("Camera access is off. Enable it in Settings, or import a photo from your library instead.")
        }
        .photosPicker(isPresented: $showLibraryPickerFlag, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }
            Task { await loadLibraryImage(newItem) }
        }
        .alert("Something went wrong", isPresented: .constant(errorMessage != nil)) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    @State private var showLibraryPickerFlag = false

    // MARK: - Start screen

    private var startScreen: some View {
        ScrollView {
            VStack(spacing: AFSpacing.lg) {
                heroIllustration

                VStack(spacing: AFSpacing.xs) {
                    Text("Capture your fit")
                        .font(AFTypography.title(.bold))
                        .foregroundStyle(AFColors.textPrimary)
                    Text("Stand full-body in good light. We'll handle the rest — all on your device.")
                        .font(AFTypography.subheadline())
                        .foregroundStyle(AFColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)

                quotaBanner

                VStack(spacing: AFSpacing.sm) {
                    AFPrimaryButton(title: "Open Camera", systemImage: "camera.fill") {
                        beginCameraFlow()
                    }
                    AFSecondaryButton(title: "Import from Library", systemImage: "photo.on.rectangle") {
                        beginLibraryFlow()
                    }
                    .accessibilityIdentifier("scanView.importFromLibraryButton")
                }
                .padding(.horizontal)

                tips
            }
            .padding(AFSpacing.md)
        }
        .scrollIndicators(.hidden)
    }

    private var heroIllustration: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AFRadius.xl, style: .continuous)
                .fill(AFColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: AFRadius.xl, style: .continuous)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10, 7]))
                        .foregroundStyle(AFColors.accent.opacity(0.5))
                )
            Image(systemName: "figure.stand")
                .font(.system(size: 120, weight: .ultraLight))
                .foregroundStyle(AFColors.brandGradient)
        }
        .frame(height: 280)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var quotaBanner: some View {
        if !entitlements.isPro {
            let remaining = entitlements.remainingFreeScansToday
            HStack(spacing: AFSpacing.sm) {
                Image(systemName: remaining > 0 ? "bolt.fill" : "lock.fill")
                    .foregroundStyle(remaining > 0 ? AFColors.accent : AFColors.warning)
                Text(remaining > 0
                     ? "\(remaining) free scan\(remaining == 1 ? "" : "s") left today"
                     : "Daily free scans used — go Pro for unlimited")
                    .font(AFTypography.footnote(.medium))
                    .foregroundStyle(AFColors.textSecondary)
                Spacer()
                Button("Go Pro") { router.presentPaywall(.general) }
                    .font(AFTypography.footnote(.semibold))
                    .foregroundStyle(AFColors.accent)
            }
            .padding(AFSpacing.sm)
            .background(AFColors.surface, in: RoundedRectangle(cornerRadius: AFRadius.md, style: .continuous))
            .padding(.horizontal)
        }
    }

    private var tips: some View {
        AFGlassCard {
            VStack(alignment: .leading, spacing: AFSpacing.sm) {
                Label("Tips for a great scan", systemImage: "lightbulb.fill")
                    .font(AFTypography.headline())
                    .foregroundStyle(AFColors.textPrimary)
                tipRow("Use even, front-facing light")
                tipRow("Keep the background simple")
                tipRow("Fit your whole body in the frame")
                tipRow("Stand tall with a relaxed pose")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func tipRow(_ text: String) -> some View {
        HStack(spacing: AFSpacing.sm) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(AFColors.success)
            Text(text).font(AFTypography.subheadline()).foregroundStyle(AFColors.textSecondary)
        }
    }

    // MARK: - Flow

    private func beginCameraFlow() {
        guard ensureCanScan() else { return }
        switch PermissionManager.cameraStatus {
        case .authorized: openCamera()
        case .notDetermined: cameraPermissionPrompt = .primer
        case .denied, .restricted, .limited: cameraPermissionPrompt = .deniedSettings
        }
    }

    private func beginLibraryFlow() {
        guard ensureCanScan() else { return }
        showLibraryPickerFlag = true
    }

    private func openCamera() {
        activeSheet = .camera
    }

    /// Returns true if the user can scan; otherwise presents the paywall.
    private func ensureCanScan() -> Bool {
        if entitlements.canScan { return true }
        router.presentPaywall(.dailyLimitReached)
        return false
    }

    private func loadLibraryImage(_ item: PhotosPickerItem) async {
        do {
            let image = try await PhotoPickerService.loadImage(from: item)
            photoItem = nil
            handleImage(image)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func handleImage(_ image: UIImage) {
        guard !isProcessingScan else { return }
        guard ensureCanScan() else { return }
        isProcessingScan = true
        capturedImage = image
        activeSheet = .analyzing
        analysisTask = Task {
            await runAnalysis(on: image)
            isProcessingScan = false
            analysisTask = nil
        }
    }

    /// Stops an in-flight analysis. The progress cover is dismissed immediately so the user is
    /// never stuck waiting for a stalled Vision request to notice; `runAnalysis` does the rest of
    /// the cleanup (deleting the staged photo, resetting the step indicator) as it unwinds.
    private func cancelAnalysis() {
        guard let analysisTask else { return }
        analysisTask.cancel()
        activeSheet = nil
    }

    private func runAnalysis(on image: UIImage) async {
        // Stage the capture on disk *before* analysis. A camera capture is unrepeatable, so it must
        // survive a crash or a hang in the pipeline rather than living only in memory until a
        // result exists. Cleaned up below on every path that doesn't produce a session.
        let originalPath = await stageOriginal(image)

        let result: FitAnalysisResult
        do {
            result = try await environment.analysisService.analyze(image)
        } catch is CancellationError {
            discardStagedOriginal(originalPath)
            environment.analysisService.reset()
            activeSheet = nil
            return
        } catch {
            discardStagedOriginal(originalPath)
            environment.analysisService.reset()
            activeSheet = nil
            errorMessage = error.localizedDescription
            return
        }

        // The task can be cancelled between the last checkpoint and here; honor it before any
        // state is committed, so cancelling never persists a session or spends a scan.
        guard !Task.isCancelled else {
            discardStagedOriginal(originalPath)
            environment.analysisService.reset()
            activeSheet = nil
            return
        }

        guard !result.diagnostics.isLowConfidence else {
            // No session references the staged file on this path, so remove it rather than leaving
            // an orphan; `capturedImage` still holds the photo for the rest of this session.
            discardStagedOriginal(originalPath)
            activeSheet = nil
            errorMessage = result.rejectionDetail
                ?? "We couldn't detect a person in this photo. Make sure you're fully visible in good light, then try again."
            return
        }

        analysisResult = result

        // Persist the session, reusing the JPEG staged above rather than encoding a second copy.
        let repository = SessionRepository(context: modelContext, imageStore: environment.imageStore)
        let session: FitSession
        do {
            session = try repository.createSession(result: result, originalImagePath: originalPath)
        } catch {
            // A silent failure here would show a result screen for a scan that disappears on
            // relaunch. Tell the user instead, and don't charge them a scan for it.
            discardStagedOriginal(originalPath)
            analysisResult = nil
            activeSheet = nil
            errorMessage = error.localizedDescription
            return
        }
        entitlements.registerScan()

        // Honor the "Save originals to Photos" setting by copying the captured photo to the library.
        if let originalPath, entitlements.settings?.saveOriginalsToPhotos == true {
            let url = environment.imageStore.absoluteURL(for: originalPath)
            Task { await ShareManager.saveImageToPhotos(url) }
        }

        HapticsManager.shared.celebrate()

        // Dismiss the analyzing cover and navigate to results.
        activeSheet = nil
        resultSession = session
    }

    /// Writes the capture to the originals folder off the main actor. Returns nil (and logs) if
    /// the write fails — a storage problem shouldn't stop the user from seeing their score.
    private func stageOriginal(_ image: UIImage) async -> String? {
        let store = environment.imageStore
        return await Task.detached(priority: .userInitiated) { () -> String? in
            do {
                return try store.saveJPEG(image, folder: .originals)
            } catch {
                AppLog.persistence.error("Failed to save original: \(error.localizedDescription)")
                return nil
            }
        }.value
    }

    /// Removes a staged capture that no session will ever point at.
    private func discardStagedOriginal(_ path: String?) {
        guard let path else { return }
        let store = environment.imageStore
        Task.detached(priority: .utility) { store.delete(relativePath: path) }
    }
}

#Preview {
    ScanView()
        .environment(AppEnvironment.preview())
        .environment(AppRouter())
        .modelContainer(SwiftDataContainer.makeInMemory())
}
