import XCTest
import SwiftData
@testable import AuraFit

/// Guards DEC-006 (2026-08-18): AuraFit 1.0 is one full, free product. There is no paywall,
/// no purchase surface, no locked scorecard style, and no scan quota — and nothing in the app
/// target may reintroduce that vocabulary without failing here first.
final class FullFreeProductTests: XCTestCase {

    // MARK: - Repository layout

    /// The test file's own path anchors the repository root; the test bundle runs on the
    /// Simulator but can read the host file system, which is what makes a source-level guard
    /// possible without a build script.
    private static let repositoryRoot: URL = {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()   // AuraFitTests/
            .deletingLastPathComponent()   // repo root
    }()

    private static let appTargetRoot = repositoryRoot.appendingPathComponent("AuraFit", isDirectory: true)

    private var repositoryLooksIntact: Bool {
        FileManager.default.fileExists(atPath: Self.appTargetRoot.appendingPathComponent("App/AuraFitApp.swift").path)
    }

    // MARK: - No purchase surface in the project

    func testStoreAndPaywallSourcesAreGone() throws {
        try XCTSkipUnless(repositoryLooksIntact, "Repository sources are not reachable from this test host.")
        let forbiddenPaths = [
            "AuraFit/Features/Paywall",
            "AuraFit/Services/Store",
            "AuraFit/Resources/AuraFit.storekit"
        ]
        for relative in forbiddenPaths {
            let path = Self.repositoryRoot.appendingPathComponent(relative).path
            XCTAssertFalse(FileManager.default.fileExists(atPath: path), "\(relative) must not exist in a full-free build.")
        }
    }

    func testProjectDeclaresNoStoreKitConfiguration() throws {
        try XCTSkipUnless(repositoryLooksIntact, "Repository sources are not reachable from this test host.")
        let project = Self.repositoryRoot.appendingPathComponent("AuraFit.xcodeproj/project.pbxproj")
        let scheme = Self.repositoryRoot.appendingPathComponent("AuraFit.xcodeproj/xcshareddata/xcschemes/AuraFit.xcscheme")
        for file in [project, scheme] {
            let text = try String(contentsOf: file, encoding: .utf8)
            XCTAssertFalse(text.localizedCaseInsensitiveContains("storekit"), "\(file.lastPathComponent) still references StoreKit.")
        }
        let projectText = try String(contentsOf: project, encoding: .utf8)
        XCTAssertFalse(projectText.contains("CURRENT_PROJECT_VERSION = 1;"), "Build number must be bumped past the consumed builds.")
        XCTAssertFalse(projectText.contains("CURRENT_PROJECT_VERSION = 2;"), "Build number must be bumped past the consumed builds.")
        XCTAssertTrue(projectText.contains("CURRENT_PROJECT_VERSION = 3;"))
        XCTAssertTrue(projectText.contains("MARKETING_VERSION = 1.0;"))
    }

    /// Source-level guard: none of the tier vocabulary may appear anywhere in the app target
    /// (Swift sources, privacy manifest, assets) or the project/scheme files. Case-insensitive
    /// except for the bare word "Pro", which is matched as a whole word so that "Product",
    /// "Progress", "process" and friends stay legal.
    func testAppTargetContainsNoTierVocabulary() throws {
        try XCTSkipUnless(repositoryLooksIntact, "Repository sources are not reachable from this test host.")

        let caseInsensitiveWords = [
            "paywall", "premium", "upgrade", "subscription", "subscribe", "purchase",
            "entitlement", "quota", "storekit", "freemium", "watermark", "free plan",
            "free scan", "in-app purchase", "unlock all", "go pro", "restore purchases"
        ]
        let allowlist: [String] = [
            "LastUpgradeCheck",       // Xcode project metadata, not product copy
            "LastUpgradeVersion"      // Xcode scheme metadata, not product copy
        ]
        let proWord = try NSRegularExpression(pattern: #"\bPro\b"#)

        var files: [URL] = []
        let enumerator = FileManager.default.enumerator(at: Self.appTargetRoot, includingPropertiesForKeys: [.isRegularFileKey])
        while let url = enumerator?.nextObject() as? URL {
            let ext = url.pathExtension.lowercased()
            if ["swift", "xcprivacy", "json", "plist", "strings", "xcstrings"].contains(ext) {
                files.append(url)
            }
        }
        files.append(Self.repositoryRoot.appendingPathComponent("AuraFit.xcodeproj/project.pbxproj"))
        files.append(Self.repositoryRoot.appendingPathComponent("AuraFit.xcodeproj/xcshareddata/xcschemes/AuraFit.xcscheme"))
        XCTAssertGreaterThan(files.count, 40, "Expected to scan the whole app target.")

        var violations: [String] = []
        for file in files {
            guard let raw = try? String(contentsOf: file, encoding: .utf8) else { continue }
            let relative = file.path.replacingOccurrences(of: Self.repositoryRoot.path + "/", with: "")
            for (index, rawLine) in raw.components(separatedBy: .newlines).enumerated() {
                var line = rawLine
                for allowed in allowlist { line = line.replacingOccurrences(of: allowed, with: "") }
                let lower = line.lowercased()
                for word in caseInsensitiveWords where lower.contains(word) {
                    violations.append("\(relative):\(index + 1): '\(word)' — \(rawLine.trimmingCharacters(in: .whitespaces))")
                }
                let range = NSRange(line.startIndex..., in: line)
                if proWord.firstMatch(in: line, range: range) != nil {
                    violations.append("\(relative):\(index + 1): 'Pro' — \(rawLine.trimmingCharacters(in: .whitespaces))")
                }
            }
        }
        XCTAssertTrue(violations.isEmpty, "Tier vocabulary found in the app target:\n" + violations.joined(separator: "\n"))
    }

    // MARK: - Everything is available to everyone

    /// Every scorecard style renders for any user: there is no product ID, lock, or ownership
    /// check between the theme list and the renderer.
    @MainActor
    func testEveryScorecardStyleRendersWithoutAnyOwnershipCheck() throws {
        XCTAssertEqual(ScorecardTheme.allCases.count, 3)
        for theme in ScorecardTheme.allCases {
            let model = ScorecardModel(
                score: .placeholder,
                persona: .streetwear,
                paletteHex: ["1A1A1A", "8E73F5", "5BD5F5"],
                dateString: "18 Aug 2026",
                theme: theme
            )
            let image = try ScorecardRenderer().renderImage(model: model)
            XCTAssertEqual(image.size.width * image.scale, ScorecardRenderer.exportSize.width, accuracy: 1, "\(theme) did not render at export size")
        }
    }

    /// Scans are unlimited: nothing in the persistence layer counts, caps, or refuses a scan.
    /// Twenty sessions in a row is well past any daily figure the product ever shipped with.
    @MainActor
    func testScansAreUnlimited() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext
        SeedData.bootstrap(context)
        let repo = SessionRepository(context: context)

        for index in 0..<20 {
            let metrics = FitMetricKind.allCases.map { FitMetric(kind: $0, value: 70) }
            let result = FitAnalysisResult(
                score: FitScore(overall: 70, metrics: metrics),
                persona: .classic,
                tips: ["Tip"],
                outfitTags: [],
                palette: [],
                diagnostics: .init(poseDetected: true, segmentationAvailable: true, usedOutfitModel: false)
            )
            XCTAssertNoThrow(try repo.createSession(result: result, originalImagePath: nil), "Scan \(index + 1) was refused.")
        }
        XCTAssertEqual(try context.fetch(FetchDescriptor<FitSession>()).count, 20)

        // The settings row carries preferences only — no usage accounting to reset or exhaust.
        let settings = try XCTUnwrap(try context.fetch(FetchDescriptor<AppSettings>()).first)
        let storedProperties = Mirror(reflecting: settings).children.compactMap(\.label)
        XCTAssertFalse(storedProperties.contains { $0.lowercased().contains("scancount") }, "AppSettings still tracks scan usage: \(storedProperties)")
    }
}
