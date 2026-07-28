import XCTest
import UIKit
@testable import AuraFit

final class ImageFileStoreTests: XCTestCase {

    private var store: ImageFileStore!

    override func setUp() {
        super.setUp()
        store = ImageFileStore()
    }

    /// Renders at scale 1 so `size` is also the pixel size — thumbnail assertions are in pixels.
    private func makeImage(_ color: UIColor = .red, size: CGSize = CGSize(width: 40, height: 40)) -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }

    func testSaveAndLoadJPEGRoundTrip() throws {
        let image = makeImage()
        let path = try store.saveJPEG(image, folder: .originals, name: "test-\(UUID().uuidString)")
        XCTAssertTrue(path.hasPrefix("originals/"))
        XCTAssertTrue(store.fileExists(relativePath: path))

        let loaded = store.loadImage(relativePath: path)
        XCTAssertNotNil(loaded)

        store.delete(relativePath: path)
        XCTAssertFalse(store.fileExists(relativePath: path))
    }

    func testSavePNGRoundTrip() throws {
        let image = makeImage(.green)
        let path = try store.savePNG(image, folder: .scorecards, name: "card-\(UUID().uuidString)")
        XCTAssertTrue(path.hasPrefix("scorecards/"))
        XCTAssertNotNil(store.loadImage(relativePath: path))
        store.delete(relativePath: path)
    }

    func testLoadMissingReturnsNil() {
        XCTAssertNil(store.loadImage(relativePath: "originals/does-not-exist.jpg"))
        XCTAssertNil(store.loadImage(relativePath: nil))
        XCTAssertFalse(store.fileExists(relativePath: nil))
    }

    func testSaveDataAndAdoptFile() throws {
        let data = Data("hello aura".utf8)
        let path = try store.saveData(data, folder: .reveals, fileName: "blob-\(UUID().uuidString).bin")
        XCTAssertTrue(store.fileExists(relativePath: path))

        // Adopt a temp file.
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("adopt-\(UUID().uuidString).bin")
        try data.write(to: tmp)
        let adopted = try store.adoptFile(at: tmp, folder: .reveals)
        XCTAssertTrue(store.fileExists(relativePath: adopted))

        store.delete(relativePath: path)
        store.delete(relativePath: adopted)
    }

    func testAbsoluteURLContainsRelativePath() {
        let url = store.absoluteURL(for: "originals/x.jpg")
        XCTAssertTrue(url.path.hasSuffix("originals/x.jpg"))
    }

    // MARK: - Thumbnails

    /// A store with a private cache so thumbnail tests never see each other's entries.
    private func makeIsolatedStore() -> ImageFileStore {
        ImageFileStore(thumbnailCache: ImageThumbnailCache())
    }

    func testThumbnailIsBoundedByRequestedPixelSize() throws {
        let store = makeIsolatedStore()
        let large = makeImage(.blue, size: CGSize(width: 900, height: 600))
        let path = try store.saveJPEG(large, folder: .originals, name: "thumb-\(UUID().uuidString)")
        defer { store.delete(relativePath: path) }

        let thumb = try XCTUnwrap(store.loadThumbnail(relativePath: path, maxPixelSize: 64))
        let pixelWidth = thumb.size.width * thumb.scale
        let pixelHeight = thumb.size.height * thumb.scale
        XCTAssertLessThanOrEqual(max(pixelWidth, pixelHeight), 64)
        // Aspect ratio is preserved, so the long edge should actually be used.
        XCTAssertGreaterThan(max(pixelWidth, pixelHeight), 32)

        // The full-size load still returns the original resolution.
        let full = try XCTUnwrap(store.loadImage(relativePath: path))
        XCTAssertEqual(full.size.width * full.scale, 900, accuracy: 1)
    }

    func testThumbnailRespectsLargerBudgetWithoutUpscaling() throws {
        let store = makeIsolatedStore()
        let source = makeImage(.orange, size: CGSize(width: 120, height: 200))
        let path = try store.saveJPEG(source, folder: .originals, name: "thumb-\(UUID().uuidString)")
        defer { store.delete(relativePath: path) }

        let thumb = try XCTUnwrap(store.loadThumbnail(relativePath: path, maxPixelSize: 1000))
        XCTAssertEqual(thumb.size.width * thumb.scale, 120, accuracy: 1)
        XCTAssertEqual(thumb.size.height * thumb.scale, 200, accuracy: 1)
    }

    func testSecondThumbnailLoadHitsTheCache() throws {
        let store = makeIsolatedStore()
        let image = makeImage(.purple, size: CGSize(width: 400, height: 300))
        let path = try store.saveJPEG(image, folder: .originals, name: "cache-\(UUID().uuidString)")

        XCTAssertNil(store.cachedThumbnail(relativePath: path, maxPixelSize: 80), "Cold cache should miss")
        let first = try XCTUnwrap(store.loadThumbnail(relativePath: path, maxPixelSize: 80))
        let cached = try XCTUnwrap(store.cachedThumbnail(relativePath: path, maxPixelSize: 80))
        XCTAssertTrue(first === cached, "The cache should hand back the identical instance")

        // Deleting the file proves the second load never touched the disk.
        store.delete(relativePath: path)
        XCTAssertFalse(store.fileExists(relativePath: path))
        let second = try XCTUnwrap(store.loadThumbnail(relativePath: path, maxPixelSize: 80))
        XCTAssertTrue(first === second)
    }

    func testCacheKeysAreSizeSpecific() throws {
        let store = makeIsolatedStore()
        let image = makeImage(.yellow, size: CGSize(width: 400, height: 400))
        let path = try store.saveJPEG(image, folder: .originals, name: "sizes-\(UUID().uuidString)")
        defer { store.delete(relativePath: path) }

        let small = try XCTUnwrap(store.loadThumbnail(relativePath: path, maxPixelSize: 50))
        XCTAssertNil(store.cachedThumbnail(relativePath: path, maxPixelSize: 150),
                     "A different pixel budget must not reuse the smaller entry")
        let big = try XCTUnwrap(store.loadThumbnail(relativePath: path, maxPixelSize: 150))
        XCTAssertFalse(small === big)
        XCTAssertLessThanOrEqual(max(small.size.width, small.size.height), 50)
        XCTAssertLessThanOrEqual(max(big.size.width, big.size.height), 150)
    }

    func testThumbnailOfMissingOrInvalidInputReturnsNil() {
        let store = makeIsolatedStore()
        XCTAssertNil(store.loadThumbnail(relativePath: nil, maxPixelSize: 100))
        XCTAssertNil(store.loadThumbnail(relativePath: "originals/does-not-exist.jpg", maxPixelSize: 100))
        XCTAssertNil(store.cachedThumbnail(relativePath: nil, maxPixelSize: 100))
        XCTAssertNil(store.loadThumbnail(relativePath: "originals/x.jpg", maxPixelSize: 0))
    }

    func testThumbnailOfNonImageDataReturnsNil() throws {
        let store = makeIsolatedStore()
        let path = try store.saveData(Data("not an image".utf8), folder: .originals, fileName: "junk-\(UUID().uuidString).jpg")
        defer { store.delete(relativePath: path) }
        XCTAssertNil(store.loadThumbnail(relativePath: path, maxPixelSize: 100))
    }

    func testAsyncThumbnailLoadsAndPopulatesCache() async throws {
        let store = makeIsolatedStore()
        let image = makeImage(.cyan, size: CGSize(width: 640, height: 480))
        let path = try store.saveJPEG(image, folder: .originals, name: "async-\(UUID().uuidString)")
        defer { store.delete(relativePath: path) }

        let asyncResult = await store.thumbnail(relativePath: path, maxPixelSize: 100)
        let loaded = try XCTUnwrap(asyncResult)
        XCTAssertLessThanOrEqual(max(loaded.size.width * loaded.scale, loaded.size.height * loaded.scale), 100)

        let cached = try XCTUnwrap(store.cachedThumbnail(relativePath: path, maxPixelSize: 100))
        XCTAssertTrue(loaded === cached)

        let secondResult = await store.thumbnail(relativePath: path, maxPixelSize: 100)
        XCTAssertTrue(loaded === secondResult)

        let nilResult = await store.thumbnail(relativePath: nil, maxPixelSize: 100)
        XCTAssertNil(nilResult)
    }

    func testCacheRemoveAllClearsEntries() throws {
        let cache = ImageThumbnailCache()
        let store = ImageFileStore(thumbnailCache: cache)
        let image = makeImage(.magenta, size: CGSize(width: 200, height: 200))
        let path = try store.saveJPEG(image, folder: .originals, name: "purge-\(UUID().uuidString)")
        defer { store.delete(relativePath: path) }

        XCTAssertNotNil(store.loadThumbnail(relativePath: path, maxPixelSize: 60))
        XCTAssertNotNil(store.cachedThumbnail(relativePath: path, maxPixelSize: 60))
        cache.removeAll()
        XCTAssertNil(store.cachedThumbnail(relativePath: path, maxPixelSize: 60))
    }
}
