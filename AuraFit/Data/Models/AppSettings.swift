import Foundation
import SwiftData

/// Single-row persisted user settings.
@Model
final class AppSettings {
    @Attribute(.unique) var id: String
    var hapticsEnabled: Bool
    var soundEnabled: Bool
    var saveOriginalsToPhotos: Bool
    var preferredPersonaRaw: String?
    var hasCompletedOnboarding: Bool
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
        createdAt: Date = .now
    ) {
        self.id = id
        self.hapticsEnabled = hapticsEnabled
        self.soundEnabled = soundEnabled
        self.saveOriginalsToPhotos = saveOriginalsToPhotos
        self.preferredPersonaRaw = preferredPersonaRaw
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
    }
}
