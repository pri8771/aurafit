import XCTest
@testable import AuraFit

final class FitStatisticsTests: XCTestCase {

    private let cal = Calendar.current

    private func session(score: Int, daysAgo: Int) -> FitSession {
        let date = cal.date(byAdding: .day, value: -daysAgo, to: .now)!
        return FitSession(createdAt: date, overallScore: score, label: .from(score: score),
                          stylePersona: .classic, metrics: [])
    }

    func testWeeklyAverageOnlyCountsLastSevenDays() {
        let sessions = [
            session(score: 90, daysAgo: 0),
            session(score: 80, daysAgo: 3),
            session(score: 40, daysAgo: 10)   // outside window
        ]
        let avg = FitStatistics.weeklyAverage(sessions)
        XCTAssertEqual(avg, 85)
    }

    func testWeeklyAverageNilWhenEmpty() {
        XCTAssertNil(FitStatistics.weeklyAverage([]))
    }

    func testCurrentStreakConsecutiveDays() {
        let sessions = [
            session(score: 70, daysAgo: 0),
            session(score: 70, daysAgo: 1),
            session(score: 70, daysAgo: 2)
        ]
        XCTAssertEqual(FitStatistics.currentStreak(sessions), 3)
    }

    func testStreakBreaksWithGap() {
        let sessions = [
            session(score: 70, daysAgo: 0),
            session(score: 70, daysAgo: 1),
            session(score: 70, daysAgo: 4)   // gap
        ]
        XCTAssertEqual(FitStatistics.currentStreak(sessions), 2)
    }

    func testStreakZeroWhenLatestIsOld() {
        let sessions = [session(score: 70, daysAgo: 3)]
        XCTAssertEqual(FitStatistics.currentStreak(sessions), 0)
    }

    func testStreakCountsFromYesterday() {
        let sessions = [
            session(score: 70, daysAgo: 1),
            session(score: 70, daysAgo: 2)
        ]
        XCTAssertEqual(FitStatistics.currentStreak(sessions), 2)
    }

    func testMultipleScansSameDayCountAsOne() {
        let sessions = [
            session(score: 70, daysAgo: 0),
            session(score: 80, daysAgo: 0),
            session(score: 90, daysAgo: 1)
        ]
        XCTAssertEqual(FitStatistics.currentStreak(sessions), 2)
    }

    func testBestScoreAndLatest() {
        let sessions = [
            session(score: 60, daysAgo: 2),
            session(score: 95, daysAgo: 1),
            session(score: 70, daysAgo: 0)
        ]
        XCTAssertEqual(FitStatistics.bestScore(sessions), 95)
        XCTAssertEqual(FitStatistics.latest(sessions)?.overallScore, 70)
    }

    func testTrendComputesDelta() {
        let sessions = [
            session(score: 90, daysAgo: 0),   // latest
            session(score: 70, daysAgo: 1),
            session(score: 70, daysAgo: 2)
        ]
        // prior avg = 70, latest = 90 → +20
        XCTAssertEqual(FitStatistics.trend(sessions), 20)
    }
}
