import Foundation

/// Pure, testable computations over fit history (averages, streaks, trends).
enum FitStatistics {

    /// Average overall score across the last `days` days (inclusive of today).
    static func weeklyAverage(_ sessions: [FitSession], days: Int = 7, now: Date = .now, calendar: Calendar = .current) -> Int? {
        guard let cutoff = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: now)) else { return nil }
        let recent = sessions.filter { $0.createdAt >= cutoff }
        guard !recent.isEmpty else { return nil }
        let total = recent.reduce(0) { $0 + $1.overallScore }
        return Int((Double(total) / Double(recent.count)).rounded())
    }

    /// Current consecutive-day streak ending today (or yesterday if nothing today yet).
    static func currentStreak(_ sessions: [FitSession], now: Date = .now, calendar: Calendar = .current) -> Int {
        guard !sessions.isEmpty else { return 0 }
        // Unique scan days (start-of-day), sorted descending.
        let days = Set(sessions.map { calendar.startOfDay(for: $0.createdAt) }).sorted(by: >)
        guard let mostRecent = days.first else { return 0 }

        let today = calendar.startOfDay(for: now)
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }

        // Streak only counts if the most recent scan is today or yesterday.
        guard mostRecent == today || mostRecent == yesterday else { return 0 }

        var streak = 0
        var expected = mostRecent
        for day in days {
            if day == expected {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: expected) else { break }
                expected = prev
            } else if day < expected {
                break
            }
        }
        return streak
    }

    /// The most recent session, if any.
    static func latest(_ sessions: [FitSession]) -> FitSession? {
        sessions.max { $0.createdAt < $1.createdAt }
    }

    /// All-time best overall score.
    static func bestScore(_ sessions: [FitSession]) -> Int? {
        sessions.map(\.overallScore).max()
    }

    /// Trend (delta) between the latest score and the average of the prior `window` sessions.
    static func trend(_ sessions: [FitSession], window: Int = 5) -> Int? {
        let sorted = sessions.sorted { $0.createdAt > $1.createdAt }
        guard let latest = sorted.first else { return nil }
        let prior = Array(sorted.dropFirst().prefix(window))
        guard !prior.isEmpty else { return nil }
        let priorAvg = Double(prior.reduce(0) { $0 + $1.overallScore }) / Double(prior.count)
        return latest.overallScore - Int(priorAvg.rounded())
    }
}
