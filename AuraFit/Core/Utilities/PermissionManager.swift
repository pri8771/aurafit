import Foundation
import AVFoundation
import Photos

/// Encapsulates runtime permission queries/requests for camera and photo library.
/// All methods are async and safe to call from the main actor.
struct PermissionManager {

    enum Status: Equatable {
        case notDetermined
        case authorized
        case limited
        case denied
        case restricted
    }

    // MARK: - Camera

    static var cameraStatus: Status {
        map(AVCaptureDevice.authorizationStatus(for: .video))
    }

    static func requestCamera() async -> Status {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .authorized : .denied
    }

    private static func map(_ status: AVAuthorizationStatus) -> Status {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    // MARK: - Photo Library (add only, for saving exports)

    static var photoAddStatus: Status {
        map(PHPhotoLibrary.authorizationStatus(for: .addOnly))
    }

    static func requestPhotoAdd() async -> Status {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return map(status)
    }

    private static func map(_ status: PHAuthorizationStatus) -> Status {
        switch status {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .limited: return .limited
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }
}
