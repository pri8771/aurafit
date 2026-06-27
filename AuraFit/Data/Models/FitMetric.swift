import SwiftUI

/// A single scored dimension of a fit. Stored inline (Codable) within a `FitSession`.
struct FitMetric: Codable, Identifiable, Hashable, Sendable {
    var kind: FitMetricKind
    /// Score 0...100.
    var value: Int
    /// Optional improvement tip specific to this metric.
    var tip: String?

    var id: String { kind.rawValue }

    init(kind: FitMetricKind, value: Int, tip: String? = nil) {
        self.kind = kind
        self.value = value.clampedScore
        self.tip = tip
    }

    var title: String { kind.title }
    var systemImage: String { kind.systemImage }
}

/// A detected outfit attribute (e.g. dominant color name, garment guess). Stored inline.
struct OutfitTag: Codable, Identifiable, Hashable, Sendable {
    var id: UUID
    var label: String
    /// Confidence 0...1.
    var confidence: Double
    /// Optional hex color associated with the tag (for palette chips).
    var hex: String?

    init(id: UUID = UUID(), label: String, confidence: Double, hex: String? = nil) {
        self.id = id
        self.label = label
        self.confidence = confidence.clamped(to: 0...1)
        self.hex = hex
    }
}
