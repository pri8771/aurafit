import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

/// Helpers for loading images chosen via SwiftUI's `PhotosPicker`.
enum PhotoPickerService {

    enum PickerError: LocalizedError {
        case loadFailed
        case decodeFailed

        var errorDescription: String? {
            switch self {
            case .loadFailed: return "Could not load the selected photo."
            case .decodeFailed: return "That file isn't a supported image."
            }
        }
    }

    #if canImport(UIKit)
    /// Loads a `UIImage` from a `PhotosPickerItem`, normalizing orientation.
    static func loadImage(from item: PhotosPickerItem) async throws -> UIImage {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw PickerError.loadFailed
        }
        guard let image = UIImage(data: data) else {
            throw PickerError.decodeFailed
        }
        return image.normalizedOrientation()
    }
    #endif
}
