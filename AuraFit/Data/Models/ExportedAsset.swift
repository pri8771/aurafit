import Foundation
import SwiftData

/// A generated, exportable artifact (scorecard image or reveal video) tied to a session.
@Model
final class ExportedAsset {
    @Attribute(.unique) var id: UUID
    var sessionID: UUID
    var kindRaw: String
    var filePath: String
    var createdAt: Date
    var hasWatermark: Bool

    init(
        id: UUID = UUID(),
        sessionID: UUID,
        kind: ExportedAssetKind,
        filePath: String,
        createdAt: Date = .now,
        hasWatermark: Bool
    ) {
        self.id = id
        self.sessionID = sessionID
        self.kindRaw = kind.rawValue
        self.filePath = filePath
        self.createdAt = createdAt
        self.hasWatermark = hasWatermark
    }

    var kind: ExportedAssetKind { ExportedAssetKind(rawValue: kindRaw) ?? .scorecard }
}
