import Foundation
import UIKit

/// Process-wide, memory-pressure-aware cache for downsampled thumbnails.
///
/// Keys combine the stored *relative* path with the requested pixel budget, so the same
/// original can be cached at several display sizes without collisions. `NSCache` evicts on
/// memory pressure, so a hit is never guaranteed — callers must always be able to re-decode.
///
/// Entries are not purged when a file is deleted. Stored paths are UUID-based and never
/// reused, so a stale entry can only waste memory until eviction, never show the wrong photo.
///
/// `@unchecked Sendable` is sound here: the only stored property is an `NSCache`, which Apple
/// documents as safe to access from any thread, and this wrapper adds no other mutable state.
final class ImageThumbnailCache: @unchecked Sendable {

    /// Shared instance used by `ImageFileStore`.
    static let shared = ImageThumbnailCache()

    private let cache = NSCache<NSString, UIImage>()

    /// - Parameters:
    ///   - countLimit: Maximum number of thumbnails retained (a few screens' worth of cards).
    ///   - totalCostLimit: Soft byte ceiling; cost is the thumbnail's decoded pixel footprint.
    init(countLimit: Int = 150, totalCostLimit: Int = 32 * 1024 * 1024) {
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }

    /// Builds the cache key for a path/size pair.
    static func key(relativePath: String, maxPixelSize: Int) -> NSString {
        "\(relativePath)@\(maxPixelSize)" as NSString
    }

    func image(relativePath: String, maxPixelSize: Int) -> UIImage? {
        cache.object(forKey: Self.key(relativePath: relativePath, maxPixelSize: maxPixelSize))
    }

    func insert(_ image: UIImage, relativePath: String, maxPixelSize: Int) {
        cache.setObject(image,
                        forKey: Self.key(relativePath: relativePath, maxPixelSize: maxPixelSize),
                        cost: Self.approximateBytes(of: image))
    }

    /// Drops every entry. Used by tests; the system handles eviction at runtime.
    func removeAll() {
        cache.removeAllObjects()
    }

    /// Decoded footprint of a bitmap, assuming 4 bytes per pixel.
    private static func approximateBytes(of image: UIImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
