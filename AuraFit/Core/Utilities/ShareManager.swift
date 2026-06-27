import SwiftUI
import Photos
#if canImport(UIKit)
import UIKit
#endif

/// Helpers for sharing/saving generated assets.
enum ShareManager {

    /// Saves an image to the user's photo library. Requests permission if needed.
    /// - Returns: `true` on success.
    @discardableResult
    static func saveImageToPhotos(_ url: URL) async -> Bool {
        let status = await ensurePhotoPermission()
        guard status == .authorized || status == .limited else { return false }
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            } completionHandler: { success, error in
                if let error { AppLog.export.error("Save image failed: \(error.localizedDescription)") }
                continuation.resume(returning: success)
            }
        }
    }

    /// Saves a video to the user's photo library.
    @discardableResult
    static func saveVideoToPhotos(_ url: URL) async -> Bool {
        let status = await ensurePhotoPermission()
        guard status == .authorized || status == .limited else { return false }
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, error in
                if let error { AppLog.export.error("Save video failed: \(error.localizedDescription)") }
                continuation.resume(returning: success)
            }
        }
    }

    private static func ensurePhotoPermission() async -> PermissionManager.Status {
        let current = PermissionManager.photoAddStatus
        if current == .notDetermined {
            return await PermissionManager.requestPhotoAdd()
        }
        return current
    }
}

/// A `UIViewControllerRepresentable` wrapper around `UIActivityViewController`
/// for SwiftUI `.sheet` presentation of share content.
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
