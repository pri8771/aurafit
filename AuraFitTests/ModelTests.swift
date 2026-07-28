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
        let session = try repo.createSession(result: result, originalImagePath: nil)
        XCTAssertEqual(try context.fetch(FetchDescriptor<FitSession>()).count, 1)

        // A 92 score should satisfy the "Main Character Moment" (90+) challenge.
        let challenges = try context.fetch(FetchDescriptor<Challenge>())
        let mainChar = challenges.first { $0.id == "challenge.mainchar" }
        XCTAssertEqual(mainChar?.contributingSessionIDs.contains(session.id.uuidString), true)

        repo.delete(session)
        XCTAssertEqual(try context.fetch(FetchDescriptor<FitSession>()).count, 0)
    }

    // MARK: - Challenge qualification (AURA-ENG-009)

    /// A result with a chosen score and palette; everything else is neutral filler.
    private func result(score: Int, palette: [RGBColor] = [], colorHarmony: Int? = nil) -> FitAnalysisResult {
        let metrics = FitMetricKind.allCases.map { kind in
            FitMetric(kind: kind, value: kind == .colorHarmony ? (colorHarmony ?? score) : score)
        }
        return FitAnalysisResult(
            score: FitScore(overall: score, metrics: metrics),
            persona: .softLuxury,
            tips: ["Tip one", "Tip two", "Tip three"],
            outfitTags: [],
            palette: palette,
            diagnostics: .init(poseDetected: true, segmentationAvailable: true, usedOutfitModel: false)
        )
    }

    private func challenge(_ id: String, in context: ModelContext) throws -> Challenge {
        let match = try context.fetch(FetchDescriptor<Challenge>()).first { $0.id == id }
        return try XCTUnwrap(match)
    }

    /// A palette in one hue family, one spanning opposite sides of the wheel.
    private var tonalBluePalette: [RGBColor] { [RGBColor(0.1, 0.2, 0.8), RGBColor(0.15, 0.3, 0.9)] }
    private var clashingPalette: [RGBColor] { [RGBColor(0.1, 0.2, 0.8), RGBColor(0.9, 0.5, 0.1)] }

    @MainActor
    func testSevenDayChallengeCountsDistinctCalendarDaysOnly() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext
        SeedData.bootstrap(context)
        let repo = SessionRepository(context: context)

        let calendar = Calendar.current
        let day0 = calendar.startOfDay(for: .now).addingTimeInterval(9 * 3600)

        // Three scans in one afternoon must advance the streak exactly once.
        for hour in 0..<3 {
            try repo.createSession(result: result(score: 70, palette: clashingPalette),
                                   originalImagePath: nil,
                                   createdAt: day0.addingTimeInterval(Double(hour) * 3600))
        }
        var streak = try challenge("challenge.streak7", in: context)
        XCTAssertEqual(streak.contributingSessionIDs.count, 1)
        XCTAssertFalse(streak.isCompleted)

        // Six more days completes it.
        for dayOffset in 1...6 {
            let date = try XCTUnwrap(calendar.date(byAdding: .day, value: -dayOffset, to: day0))
            try repo.createSession(result: result(score: 70, palette: clashingPalette),
                                   originalImagePath: nil,
                                   createdAt: date)
        }
        streak = try challenge("challenge.streak7", in: context)
        XCTAssertEqual(streak.contributingSessionIDs.count, 7)
        XCTAssertTrue(streak.isCompleted)
    }

    func testMonochromeDetection() {
        // Two shades of the same blue.
        XCTAssertTrue(SessionRepository.isMonochromatic(paletteHex: tonalBluePalette.map(\.hexString)))
        // Blue against orange is two families.
        XCTAssertFalse(SessionRepository.isMonochromatic(paletteHex: clashingPalette.map(\.hexString)))
        // Neutrals carry no hue, so an all-grey palette is its own tonal family.
        XCTAssertTrue(SessionRepository.isMonochromatic(
            paletteHex: [RGBColor(0.1, 0.1, 0.1), RGBColor(0.7, 0.7, 0.7)].map(\.hexString)))
        // A single hue plus neutrals still reads as one family.
        XCTAssertTrue(SessionRepository.isMonochromatic(
            paletteHex: [RGBColor(0.1, 0.2, 0.8), RGBColor(0.5, 0.5, 0.5)].map(\.hexString)))
        // Nothing to judge.
        XCTAssertFalse(SessionRepository.isMonochromatic(paletteHex: []))
        // Only the dominant leading entries are judged; a minor trailing bucket can't disqualify.
        let tonalPlusNoise = (tonalBluePalette + [RGBColor(0.1, 0.2, 0.8), RGBColor(0.9, 0.5, 0.1)])
            .map(\.hexString)
        XCTAssertTrue(SessionRepository.isMonochromatic(paletteHex: tonalPlusNoise))
        XCTAssertFalse(SessionRepository.isMonochromatic(paletteHex: tonalPlusNoise, dominant: 4))
    }

    @MainActor
    func testMonochromeChallengeRequiresATonalPalette() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext
        SeedData.bootstrap(context)
        let repo = SessionRepository(context: context)

        // Comfortably above the 60 floor, but two color families: must not count.
        try repo.createSession(result: result(score: 88, palette: clashingPalette), originalImagePath: nil)
        XCTAssertEqual(try challenge("challenge.monochrome", in: context).contributingSessionIDs.count, 0)

        // Tonal palette but below the stated 60 floor: must not count.
        try repo.createSession(result: result(score: 45, palette: tonalBluePalette), originalImagePath: nil)
        XCTAssertEqual(try challenge("challenge.monochrome", in: context).contributingSessionIDs.count, 0)

        // Tonal palette above the floor: counts.
        try repo.createSession(result: result(score: 72, palette: tonalBluePalette), originalImagePath: nil)
        XCTAssertEqual(try challenge("challenge.monochrome", in: context).contributingSessionIDs.count, 1)
    }

    @MainActor
    func testColorPopChallengeUsesColorHarmonyMetric() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext
        SeedData.bootstrap(context)
        let repo = SessionRepository(context: context)

        // High overall score, weak color harmony: the challenge's own rule must reject it.
        try repo.createSession(result: result(score: 88, palette: clashingPalette, colorHarmony: 40),
                               originalImagePath: nil)
        XCTAssertEqual(try challenge("challenge.colorpop", in: context).contributingSessionIDs.count, 0)

        try repo.createSession(result: result(score: 70, palette: clashingPalette, colorHarmony: 85),
                               originalImagePath: nil)
        XCTAssertEqual(try challenge("challenge.colorpop", in: context).contributingSessionIDs.count, 1)
    }

    @MainActor
    func testSeedRefreshesChallengeCopyOnExistingStores() throws {
        let container = SwiftDataContainer.makeInMemory()
        let context = container.mainContext
        SeedData.bootstrap(context)

        // Simulate a store seeded by an older build whose description didn't match the rule.
        let streak = try challenge("challenge.streak7", in: context)
        streak.details = "Scan a fit every day for 7 days."
        streak.contributingSessionIDs = ["kept"]
        try context.save()

        SeedData.bootstrap(context)
        let refreshed = try challenge("challenge.streak7", in: context)
        XCTAssertEqual(refreshed.details, SeedData.defaultChallenges().first { $0.id == "challenge.streak7" }?.details)
        XCTAssertEqual(refreshed.contributingSessionIDs, ["kept"])
    }

    func testPersistenceErrorHasUserFacingDescription() {
        let message = PersistenceError.saveFailed("Disk is full.").localizedDescription
        XCTAssertTrue(message.contains("couldn't be saved"))
        XCTAssertTrue(message.contains("Disk is full."))
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
