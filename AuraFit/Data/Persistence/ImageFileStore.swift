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

    enum Folder: String, CaseIterable {
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
    /// Overrides the container the managed folders live in. Production always leaves this nil;
    /// tests point it at a scratch directory so a reconcile pass can't reach real files.
    private let rootDirectory: URL?

    init(fileManager: FileManager = .default,
         thumbnailCache: ImageThumbnailCache = .shared,
         rootDirectory: URL? = nil) {
        self.fileManager = fileManager
        self.thumbnailCache = thumbnailCache
        self.rootDirectory = rootDirectory
    }

    // MARK: - Directory resolution

    private var documentsURL: URL {
        if let rootDirectory { return rootDirectory }
        // `.documentDirectory` is guaranteed to exist for an app sandbox.
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
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

    // MARK: - Reconciling orphans

    /// How long a file is protected from the sweep purely by being new.
    ///
    /// A capture is written to `originals/` *before* analysis runs (AURA-ENG-008), so between the
    /// write and the `FitSession` that adopts it there is a window where a perfectly live file has
    /// no referrer at all. The grace period only has to outlast that window — analysis plus the
    /// user reading the reveal, seconds to a couple of minutes — and fifteen minutes buys a wide
    /// margin at the cost of one extra launch before a true orphan is collected.
    static let orphanGracePeriod: TimeInterval = 15 * 60

    /// Tally of a single `reconcileOrphans` pass. `scanned` is the sum of the other four.
    struct ReconcileReport: Sendable, Equatable {
        var scanned = 0
        var deleted = 0
        var keptReferenced = 0
        var keptRecent = 0
        var failed = 0
    }

    /// Deletes files in the managed folders that no persisted model points at.
    ///
    /// A crash or force-quit between staging a capture and saving its session strands the file:
    /// nothing references it, and none of the cancel/error/rejection cleanup paths ever run, so
    /// without a sweep `originals/` grows without bound.
    ///
    /// Scope is deliberately narrow. Only direct children of `originals/`, `scorecards/` and
    /// `reveals/` are considered; sub-directories and anything whose parent isn't the folder being
    /// enumerated are skipped, so nothing outside the app's own managed folders can be removed.
    /// Files younger than `minimumAge` are left alone — see `orphanGracePeriod` — which is what
    /// makes the pass safe to run while a scan is in flight.
    ///
    /// Blocking disk I/O, like the rest of this type: call it from a background context.
    ///
    /// - Parameters:
    ///   - referencedRelativePaths: *every* path persisted models still point at. Anything absent
    ///     is treated as garbage, so callers must never pass a partial set (a failed fetch has to
    ///     abort the sweep, not run it with an empty set).
    ///   - minimumAge: files modified within this interval of `now` are kept regardless.
    ///   - now: injectable clock for tests.
    @discardableResult
    func reconcileOrphans(referencedRelativePaths: Set<String>,
                          minimumAge: TimeInterval = ImageFileStore.orphanGracePeriod,
                          now: Date = .now) -> ReconcileReport {
        let root = documentsURL.standardizedFileURL
        // Compare on absolute standardized paths so a stored path that picked up a `./` or a
        // redundant separator still matches the file it names.
        let referenced = Set(referencedRelativePaths.map {
            root.appendingPathComponent($0).standardizedFileURL.path
        })
        let keys: [URLResourceKey] = [.isRegularFileKey, .contentModificationDateKey, .creationDateKey]
        var report = ReconcileReport()

        for folder in Folder.allCases {
            let folderURL = root.appendingPathComponent(folder.rawValue, isDirectory: true).standardizedFileURL
            // Missing folder simply means nothing has been written there yet; don't create it.
            guard fileManager.fileExists(atPath: folderURL.path) else { continue }

            let contents: [URL]
            do {
                contents = try fileManager.contentsOfDirectory(
                    at: folderURL,
                    includingPropertiesForKeys: keys,
                    options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
                )
            } catch {
                report.failed += 1
                AppLog.persistence.error("Asset reconcile could not read \(folder.rawValue): \(error.localizedDescription)")
                continue
            }

            for candidate in contents {
                let url = candidate.standardizedFileURL
                // Re-derive the parent rather than trusting the enumeration: only a direct child
                // of this managed folder is ever a deletion candidate.
                guard url.deletingLastPathComponent().path == folderURL.path else { continue }
                let values = try? url.resourceValues(forKeys: Set(keys))
                guard values?.isRegularFile == true else { continue }

                report.scanned += 1
                if referenced.contains(url.path) {
                    report.keptReferenced += 1
                    continue
                }
                // A file whose timestamp can't be read is assumed brand new. If it really is
                // garbage the next launch gets another chance; deleting a live capture doesn't.
                let stamp = values?.contentModificationDate ?? values?.creationDate
                guard let stamp, now.timeIntervalSince(stamp) >= minimumAge else {
                    report.keptRecent += 1
                    continue
                }

                do {
                    // No cache eviction needed: an orphan is by definition unreferenced, so no
                    // live view can be holding a thumbnail of it.
                    try fileManager.removeItem(at: url)
                    report.deleted += 1
                } catch {
                    report.failed += 1
                    AppLog.persistence.error("Asset reconcile could not delete a file in \(folder.rawValue): \(error.localizedDescription)")
                }
            }
        }

        if report.deleted > 0 || report.failed > 0 {
            AppLog.persistence.info("Asset reconcile: scanned \(report.scanned), deleted \(report.deleted), kept \(report.keptReferenced) referenced and \(report.keptRecent) recent, \(report.failed) failed.")
        } else {
            AppLog.persistence.debug("Asset reconcile: scanned \(report.scanned), nothing to collect.")
        }
        return report
    }
}
