import Foundation
import SwiftData

/// Single-row persisted user settings & daily usage tracking for the freemium gate.
@Model
final class AppSettings {
    @Attribute(.unique) var id: String
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var saveOriginalsToPhotos: Bool
    var preferredPersonaRaw: String?
    var hasCompletedOnboarding: Bool

    /// Daily free-scan accounting.
    var scanCountToday: Int
    var scanCountDayStart: Date

    var createdAt: Date

    /// Stable identifier for the singleton settings row.
    static let singletonID = "app.settings.singleton"

    init(
        id: String = AppSettings.singletonID,
        hapticsEnabled: Bool = true,
        soundEnabled: Bool = true,
        saveOriginalsToPhotos: Bool = false,
        preferredPersonaRaw: String? = nil,
        hasCompletedOnboarding: Bool = false,
        scanCountToday: Int = 0,
        scanCountDayStart: Date = .now,
        createdAt: Date = .now
    ) {
        self.id = id
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.saveOriginalsToPhotos = saveOriginalsToPhotos
        self.preferredPersonaRaw = preferredPersonaRaw
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.scanCountToday = scanCountToday
        self.scanCountDayStart = scanCountDayStart
        self.createdAt = createdAt
    }

    /// Resets the daily counter if the stored day is not today. Returns the current count.
    @discardableResult
    func rolloverIfNeeded(now: Date = .now) -> Int {
        if !scanCountDayStart.isSameDay(as: now) {
            scanCountToday = 0
            scanCountDayStart = now
        }
        return scanCountToday
    }
}
