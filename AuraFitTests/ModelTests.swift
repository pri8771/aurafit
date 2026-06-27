import XCTest
import SwiftData
@testable import AuraFit

final class ModelTests: XCTestCase {

    func testScoreLabelThresholds() {
        XCTAssertEqual(ScoreLabel.from(score: 95), .mainCharacter)
        XCTAssertEqual(ScoreLabel.from(score: 85), .sharp)
        XCTAssertEqual(ScoreLabel.from(score: 70), .clean)
        XCTAssertEqual(ScoreLabel.from(score: 50), .almostThere)
        XCTAssertEqual(ScoreLabel.from(score: 20), .needsGlowUp)
    }

    func testFitMetricClampsValue() {
        XCTAssertEqual(FitMetric(kind: .lighting, value: 150).value, 100)
        XCTAssertEqual(FitMetric(kind: .lighting, value: -20).value, 0)
    }

    func testClampedScoreExtension() {
        XCTAssertEqual(250.clampedScore, 100)
        XCTAssertEqual((-5).clampedScore, 0)
        XCTAssertEqual(73.clampedScore, 73)
    }

    func testFitScoreDerivesLabel() {
        let score = FitScore(overall: 91, metrics: [])
        XCTAssertEqual(score.label, .mainCharacter)
    }

    @MainActor
    func testSwiftDataInsertAndFetch() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext

        let session = FitSession(overallScore: 88, label: .sharp, stylePersona: .streetwear,
                                 metrics: FitMetricKind.allCases.map { FitMetric(kind: $0, value: 80) })
        context.insert(session)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<FitSession>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.overallScore, 88)
        XCTAssertEqual(fetched.first?.stylePersona, .streetwear)
        XCTAssertEqual(fetched.first?.metrics.count, 7)
    }

    @MainActor
    func testSeedDataIsIdempotent() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext

        SeedData.bootstrap(context)
        let firstCount = try context.fetch(FetchDescriptor<Challenge>()).count
        XCTAssertGreaterThan(firstCount, 0)

        SeedData.bootstrap(context)
        let secondCount = try context.fetch(FetchDescriptor<Challenge>()).count
        XCTAssertEqual(firstCount, secondCount)

        let settings = try context.fetch(FetchDescriptor<AppSettings>())
        XCTAssertEqual(settings.count, 1)
    }

    @MainActor
    func testSessionRepositoryCreateAndDelete() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext
        SeedData.bootstrap(context)
        let repo = SessionRepository(context: context)

        let result = FitAnalysisResult(
            score: FitScore(overall: 92, metrics: FitMetricKind.allCases.map { FitMetric(kind: $0, value: 92) }),
            persona: .softLuxury,
            tips: ["Tip one", "Tip two", "Tip three"],
            outfitTags: [],
            palette: [RGBColor(0.5, 0.5, 0.5)],
            diagnostics: .init(poseDetected: true, segmentationAvailable: true, usedOutfitModel: false)
        )
        let session = repo.createSession(result: result, originalImagePath: nil)
        XCTAssertEqual(try context.fetch(FetchDescriptor<FitSession>()).count, 1)

        // A 92 score should satisfy the "Main Character Moment" (90+) challenge.
        let challenges = try context.fetch(FetchDescriptor<Challenge>())
        let mainChar = challenges.first { $0.id == "challenge.mainchar" }
        XCTAssertEqual(mainChar?.contributingSessionIDs.contains(session.id.uuidString), true)

        repo.delete(session)
        XCTAssertEqual(try context.fetch(FetchDescriptor<FitSession>()).count, 0)
    }

    func testRolloverResetsCountOnNewDay() {
        let settings = AppSettings()
        settings.scanCountToday = 3
        settings.scanCountDayStart = Calendar.current.date(byAdding: .day, value: -2, to: .now)!
        let count = settings.rolloverIfNeeded()
        XCTAssertEqual(count, 0)
        XCTAssertEqual(settings.scanCountToday, 0)
    }
}
