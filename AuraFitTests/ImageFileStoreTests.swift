import XCTest
import UIKit
@testable import AuraFit

final class ImageFileStoreTests: XCTestCase {

    private var store: ImageFileStore!

    override func setUp() {
        super.setUp()
        store = ImageFileStore()
    }

    private func makeImage(_ color: UIColor = .red, size: CGSize = CGSize(width: 40, height: 40)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
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
}
