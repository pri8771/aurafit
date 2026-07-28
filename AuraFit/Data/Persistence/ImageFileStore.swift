import Foundation
import ImageIO
#if canImport(UIKit)
import UIKit
#endif

/// Stores and retrieves image/video binaries in the app's documents directory.
///
/// Persisted models store *relative* paths (e.g. `originals/<uuid>.jpg`) so the store keeps
/// working across app container relocations.
///
/// Every read and write here is **synchronous on the calling thread** — the type is `Sendable`
/// so callers can hop off the main actor themselves. Two rules follow from that:
///
/// - `loadImage(relativePath:)` decodes the original at full resolution (a 12MP JPEG is ~45MB
///   of bitmap). Call it only for detail/export paths, and only from a background context.
/// - List and carousel UI must use `thumbnail(relativePath:maxPixelSize:)`, which downsamples
///   with ImageIO on a background task and serves repeats from `ImageThumbnailCache`.
struct ImageFileStore: @unchecked Sendable {

    enum Folder: String {
        case originals
        case scorecards
        case reveals
    }

    enum StoreError: LocalizedError {
        case encodingFailed
        case writeFailed(String)
        case notFound(String)

        var errorDescription: String? {
            switch self {
            case .encodingFailed: return "Could not encode the image."
            case .writeFailed(let p): return "Could not write file at \(p)."
            case .notFound(let p): return "File not found at \(p)."
            }
        }
    }

    private let fileManager: FileManager
    private let thumbnailCache: ImageThumbnailCache

    init(fileManager: FileManager = .default,
         thumbnailCache: ImageThumbnailCache = .shared) {
        self.fileManager = fileManager
        self.thumbnailCache = thumbnailCache
    }

    // MARK: - Directory resolution

    private var documentsURL: URL {
        // `.documentDirectory` is guaranteed to exist for an app sandbox.
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
    }

    private func folderURL(_ folder: Folder) throws -> URL {
        let url = documentsURL.appendingPathComponent(folder.rawValue, isDirectory: true)
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }

    /// Resolves a stored relative path into an absolute URL.
    func absoluteURL(for relativePath: String) -> URL {
        documentsURL.appendingPathComponent(relativePath)
    }

    // MARK: - Writing

    #if canImport(UIKit)
    /// Saves a JPEG and returns the *relative* path to store in the model.
    func saveJPEG(_ image: UIImage, folder: Folder, quality: CGFloat = 0.9, name: String = UUID().uuidString) throws -> String {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw StoreError.encodingFailed
        }
        return try saveData(data, folder: folder, fileName: "\(name).jpg")
    }

    /// Saves a PNG and returns the relative path.
    func savePNG(_ image: UIImage, folder: Folder, name: String = UUID().uuidString) throws -> String {
        guard let data = image.pngData() else { throw StoreError.encodingFailed }
        return try saveData(data, folder: folder, fileName: "\(name).png")
    }
    #endif

    /// Saves raw data under `folder` and returns the relative path.
    func saveData(_ data: Data, folder: Folder, fileName: String) throws -> String {
        let dir = try folderURL(folder)
        let fileURL = dir.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw StoreError.writeFailed(fileURL.path)
        }
        return "\(folder.rawValue)/\(fileName)"
    }

    /// Moves an existing file (e.g. a rendered video in tmp) into a managed folder. Returns relative path.
    func adoptFile(at sourceURL: URL, folder: Folder, fileName: String? = nil) throws -> String {
        let dir = try folderURL(folder)
        let name = fileName ?? sourceURL.lastPathComponent
        let dest = dir.appendingPathComponent(name)
        if fileManager.fileExists(atPath: dest.path) {
            try? fileManager.removeItem(at: dest)
        }
        try fileManager.moveItem(at: sourceURL, to: dest)
        return "\(folder.rawValue)/\(name)"
    }

    // MARK: - Reading

    #if canImport(UIKit)
    /// Loads a UIImage at **full resolution** from a stored relative path, or nil if
    /// missing/unreadable.
    ///
    /// Decoding happens synchronously on the calling thread and costs roughly
    /// `width × height × 4` bytes. Reserve this for the detail and export paths that actually
    /// need every pixel; grids and carousels want `thumbnail(relativePath:maxPixelSize:)`.
    func loadImage(relativePath: String?) -> UIImage? {
        guard let relativePath else { return nil }
        let url = absoluteURL(for: relativePath)
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// Returns an already-cached thumbnail without touching the disk, or nil on a miss.
    ///
    /// Lets a view render a cached photo in its first frame instead of flashing a placeholder.
    func cachedThumbnail(relativePath: String?, maxPixelSize: CGFloat) -> UIImage? {
        guard let relativePath, let pixelSize = Self.normalizedPixelSize(maxPixelSize) else { return nil }
        return thumbnailCache.image(relativePath: relativePath, maxPixelSize: pixelSize)
    }

    /// Loads a thumbnail whose longest edge is at most `maxPixelSize`, off the main actor.
    ///
    /// A cache hit returns without suspending. A miss decodes on a background task — ImageIO
    /// downsamples straight from the file, so the full-resolution bitmap is never
    /// materialized. An in-flight decode cannot be interrupted, but a cancelled caller is
    /// handed `nil` rather than a stale image; the finished thumbnail still lands in the cache
    /// for whoever asks next.
    func thumbnail(relativePath: String?, maxPixelSize: CGFloat) async -> UIImage? {
        guard let relativePath else { return nil }
        if let cached = cachedThumbnail(relativePath: relativePath, maxPixelSize: maxPixelSize) {
            return cached
        }
        if Task.isCancelled { return nil }

        let store = self
        let image = await Task.detached(priority: .userInitiated) {
            store.loadThumbnail(relativePath: relativePath, maxPixelSize: maxPixelSize)
        }.value
        return Task.isCancelled ? nil : image
    }

    /// Synchronous downsampling primitive behind `thumbnail(relativePath:maxPixelSize:)`.
    ///
    /// Exposed for tests and for callers that are already on a background thread. Never call
    /// this from the main actor.
    func loadThumbnail(relativePath: String?, maxPixelSize: CGFloat) -> UIImage? {
        guard let relativePath, let pixelSize = Self.normalizedPixelSize(maxPixelSize) else { return nil }
        if let cached = thumbnailCache.image(relativePath: relativePath, maxPixelSize: pixelSize) {
            return cached
        }

        let url = absoluteURL(for: relativePath)
        guard fileManager.fileExists(atPath: url.path) else { return nil }

        // `kCGImageSourceShouldCache: false` keeps the *original* out of the decode cache; we
        // only ever want the downsampled copy resident.
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, sourceOptions) else { return nil }

        let thumbnailOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,   // honour EXIF orientation
            kCGImageSourceShouldCacheImmediately: true,         // decode here, not on first draw
            kCGImageSourceThumbnailMaxPixelSize: pixelSize
        ]
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
            return nil
        }

        let image = UIImage(cgImage: cgImage)
        thumbnailCache.insert(image, relativePath: relativePath, maxPixelSize: pixelSize)
        return image
    }

    /// Clamps a requested edge budget to a whole, positive pixel count.
    private static func normalizedPixelSize(_ maxPixelSize: CGFloat) -> Int? {
        guard maxPixelSize.isFinite, maxPixelSize >= 1 else { return nil }
        return Int(maxPixelSize.rounded())
    }
    #endif

    func fileExists(relativePath: String?) -> Bool {
        guard let relativePath else { return false }
        return fileManager.fileExists(atPath: absoluteURL(for: relativePath).path)
    }

    // MARK: - Deleting

    func delete(relativePath: String?) {
        guard let relativePath else { return }
        let url = absoluteURL(for: relativePath)
        try? fileManager.removeItem(at: url)
    }

    /// Removes all stored binaries for a session.
    func deleteAssets(for session: FitSession) {
        delete(relativePath: session.originalImagePath)
        delete(relativePath: session.scorecardImagePath)
        delete(relativePath: session.revealVideoPath)
    }
}
