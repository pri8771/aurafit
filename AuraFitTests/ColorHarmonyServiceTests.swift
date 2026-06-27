import XCTest
@testable import AuraFit

final class ColorHarmonyServiceTests: XCTestCase {

    private let service = ColorHarmonyService()

    func testHueDistanceWrapsAround() {
        XCTAssertEqual(service.hueDistance(0.95, 0.05), 0.10, accuracy: 0.0001)
        XCTAssertEqual(service.hueDistance(0.1, 0.4), 0.30, accuracy: 0.0001)
        XCTAssertEqual(service.hueDistance(0.0, 0.5), 0.50, accuracy: 0.0001)
    }

    func testStandardDeviationOfConstantIsZero() {
        XCTAssertEqual(service.standardDeviation([0.5, 0.5, 0.5]), 0, accuracy: 0.0001)
    }

    func testMonochromaticPaletteScoresHighHarmony() {
        // Three shades of blue (same hue, varying brightness).
        let palette = [
            RGBColor(0.1, 0.2, 0.6),
            RGBColor(0.2, 0.3, 0.7),
            RGBColor(0.15, 0.25, 0.65)
        ]
        let result = service.evaluate(palette: palette)
        XCTAssertGreaterThan(result.harmony, 0.7)
    }

    func testNeutralPaletteIsHarmonious() {
        let palette = [
            RGBColor(0.05, 0.05, 0.05),
            RGBColor(0.5, 0.5, 0.5),
            RGBColor(0.9, 0.9, 0.9)
        ]
        let result = service.evaluate(palette: palette)
        XCTAssertGreaterThan(result.harmony, 0.7)
        XCTAssertGreaterThan(result.cohesion, 0.0)
    }

    func testEmptyPaletteReturnsNeutralDefaults() {
        let result = service.evaluate(palette: [])
        XCTAssertEqual(result.harmony, 0.6, accuracy: 0.0001)
    }

    func testHarmonyAndCohesionAreClamped() {
        let palette = [
            RGBColor(1, 0, 0), RGBColor(0, 1, 0), RGBColor(0, 0, 1),
            RGBColor(1, 1, 0), RGBColor(1, 0, 1)
        ]
        let result = service.evaluate(palette: palette)
        XCTAssertTrue((0...1).contains(result.harmony))
        XCTAssertTrue((0...1).contains(result.cohesion))
    }

    func testCohesionHigherForConsistentTones() {
        let consistent = service.cohesionScore(hsbs: [
            (0.6, 0.4, 0.5), (0.6, 0.42, 0.52), (0.6, 0.38, 0.48)
        ])
        let chaotic = service.cohesionScore(hsbs: [
            (0.6, 0.1, 0.9), (0.1, 0.9, 0.2), (0.3, 0.5, 0.6)
        ])
        XCTAssertGreaterThan(consistent, chaotic)
    }

    func testRGBHexRoundTrip() {
        let color = RGBColor(0.557, 0.451, 0.961)
        let hex = color.hexString
        let parsed = RGBColor.fromHex(hex)
        XCTAssertNotNil(parsed)
        XCTAssertEqual(parsed!.r, color.r, accuracy: 0.01)
        XCTAssertEqual(parsed!.g, color.g, accuracy: 0.01)
        XCTAssertEqual(parsed!.b, color.b, accuracy: 0.01)
    }

    func testHexParsingRejectsInvalid() {
        XCTAssertNil(RGBColor.fromHex("ZZZ"))
        XCTAssertNil(RGBColor.fromHex("12345"))
        XCTAssertNotNil(RGBColor.fromHex("#FFAA00"))
    }
}
