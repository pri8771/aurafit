import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Stores and retrieves image/video binaries in the app's documents directory.
///
/// Persisted models store *relative* paths (e.g. `originals/<uuid>.jpg`) so the store keeps
/// working across app container relocations. All file I/O is performed off the main actor.
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

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
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
    /// Loads a UIImage from a stored relative path, or nil if missing/unreadable.
    func loadImage(relativePath: String?) -> UIImage? {
        guard let relativePath else { return nil }
        let url = absoluteURL(for: relativePath)
        guard fileManager.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
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
