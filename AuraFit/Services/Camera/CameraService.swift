import AVFoundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Manages an `AVCaptureSession` for full-body photo capture.
///
/// Configuration and capture run on a dedicated session queue; published state is updated on the
/// main actor. On the simulator (or any device without a camera) `isAvailable` is `false` and the
/// UI shows a graceful fallback that routes the user to the photo library.
@MainActor
@Observable
final class CameraService: NSObject {

    enum CameraState: Equatable {
        case idle
        case configuring
        case running
        case unavailable(reason: String)
        case failed(reason: String)
    }

    private(set) var state: CameraState = .idle
    private(set) var isAvailable: Bool = false
    /// Live framing suggestion for the viewfinder overlay (nil until the first stable read).
    private(set) var coachHint: CoachHint?

    /// The underlying session, exposed for the preview layer.
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.aurafit.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "com.aurafit.camera.frames", qos: .utility)
    /// Touched only on `videoQueue`.
    private let frameAnalyzer = LiveFrameAnalyzer()
    private var photoContinuation: CheckedContinuation<UIImage, Error>?
    private var isConfigured = false

    enum CameraError: LocalizedError, Sendable {
        case noDevice
        case cannotAddInput
        case cannotAddOutput
        case captureFailed(String)
        case dataConversionFailed

        var errorDescription: String? {
            switch self {
            case .noDevice: return "No camera is available on this device."
            case .cannotAddInput: return "Unable to access the camera input."
            case .cannotAddOutput: return "Unable to configure photo capture."
            case .captureFailed(let m): return "Capture failed: \(m)"
            case .dataConversionFailed: return "Could not process the captured photo."
            }
        }
    }

    // MARK: - Lifecycle

    /// Requests permission (if needed), configures, and starts the session.
    func start() async {
        let permission = PermissionManager.cameraStatus
        let granted: Bool
        switch permission {
        case .authorized: granted = true
        case .notDetermined: granted = (await PermissionManager.requestCamera()) == .authorized
        default: granted = false
        }

        guard granted else {
            state = .unavailable(reason: "Camera access is off. Enable it in Settings to scan a live fit.")
            isAvailable = false
            return
        }

        #if targetEnvironment(simulator)
        state = .unavailable(reason: "The camera isn't available in the Simulator. Import a photo instead.")
        isAvailable = false
        return
        #else
        state = .configuring
        let success = await configureIfNeeded()
        guard success else { return }
        await startRunning()
        isAvailable = true
        state = .running
        #endif
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
    }

    // MARK: - Configuration

    private func configureIfNeeded() async -> Bool {
        guard !isConfigured else { return true }
        let outcome = await withCheckedContinuation { (continuation: CheckedContinuation<Result<Void, CameraError>, Never>) in
            sessionQueue.async { [weak self] in
                guard let self else { continuation.resume(returning: .failure(.noDevice)); return }
                continuation.resume(returning: self.configureSession())
            }
        }
        switch outcome {
        case .success:
            isConfigured = true
            return true
        case .failure(let error):
            fail(error)
            return false
        }
    }

    /// Runs on the session queue. Pure — no actor hops, no side effects beyond session configuration.
    nonisolated private func configureSession() -> Result<Void, CameraError> {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            ?? AVCaptureDevice.default(for: .video) else {
            session.commitConfiguration()
            return .failure(.noDevice)
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input) else {
                session.commitConfiguration()
                return .failure(.cannotAddInput)
            }
            session.addInput(input)
        } catch {
            session.commitConfiguration()
            return .failure(.cannotAddInput)
        }

        guard session.canAddOutput(photoOutput) else {
            session.commitConfiguration()
            return .failure(.cannotAddOutput)
        }
        session.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = .quality

        // Live-coach frame tap. Optional: capture still works if the session refuses it.
        if session.canAddOutput(videoOutput) {
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
            session.addOutput(videoOutput)
        }

        session.commitConfiguration()
        return .success(())
    }

    private func startRunning() async {
        await withCheckedContinuation { continuation in
            sessionQueue.async { [session] in
                if !session.isRunning { session.startRunning() }
                continuation.resume()
            }
        }
    }

    private func fail(_ error: CameraError) {
        AppLog.camera.error("\(error.localizedDescription)")
        state = .failed(reason: error.localizedDescription)
        isAvailable = false
    }

    // MARK: - Capture

    /// Captures a single photo and returns a normalized `UIImage`.
    func capturePhoto() async throws -> UIImage {
        guard isAvailable else { throw CameraError.captureFailed("Camera not available.") }
        guard photoContinuation == nil else {
            throw CameraError.captureFailed("A capture is already in progress.")
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.photoContinuation = continuation
            let settings = AVCapturePhotoSettings()
            settings.photoQualityPrioritization = .quality
            sessionQueue.async { [photoOutput] in
                photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate (live coach)

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // Buffers arrive sensor-landscape; .right maps them upright for the portrait UI.
        guard let hint = frameAnalyzer.process(pixelBuffer, orientation: .right) else { return }
        Task { @MainActor in
            guard self.state == .running else { return }
            self.coachHint = hint
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        Task { @MainActor in
            defer { self.photoContinuation = nil }
            if let error {
                self.photoContinuation?.resume(throwing: CameraError.captureFailed(error.localizedDescription))
                return
            }
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                self.photoContinuation?.resume(throwing: CameraError.dataConversionFailed)
                return
            }
            self.photoContinuation?.resume(returning: image.normalizedOrientation())
        }
    }
}
