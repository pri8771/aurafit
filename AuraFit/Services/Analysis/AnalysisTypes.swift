import SwiftUI

/// A simple RGB color value (components 0...1) used throughout the analysis pipeline.
/// Decoupled from `UIColor`/`Color` so the scoring logic stays platform-agnostic and testable.
struct RGBColor: Codable, Hashable, Sendable {
    var r: Double
    var g: Double
    var b: Double

    init(_ r: Double, _ g: Double, _ b: Double) {
        self.r = r.clamped(to: 0...1)
        self.g = g.clamped(to: 0...1)
        self.b = b.clamped(to: 0...1)
    }

    var color: Color { Color(red: r, green: g, blue: b) }

    var hexString: String {
        String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    /// Hue, saturation, brightness (each 0...1).
    var hsb: (h: Double, s: Double, b: Double) {
        let maxV = max(r, g, b)
        let minV = min(r, g, b)
        let delta = maxV - minV
        var h = 0.0
        if delta != 0 {
            if maxV == r {
                h = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
            } else if maxV == g {
                h = ((b - r) / delta) + 2
            } else {
                h = ((r - g) / delta) + 4
            }
            h /= 6
            if h < 0 { h += 1 }
        }
        let s = maxV == 0 ? 0 : delta / maxV
        return (h, s, maxV)
    }

    static func fromHex(_ hex: String) -> RGBColor? {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255
        let g = Double((value >> 8) & 0xFF) / 255
        let b = Double(value & 0xFF) / 255
        return RGBColor(r, g, b)
    }
}

// MARK: - Signal bundles

/// Normalized signals from body-pose detection. All confidences/ratios are 0...1.
struct PoseSignals: Sendable, Equatable {
    var detected: Bool
    var confidence: Double
    var fullBodyVisible: Bool
    /// Fraction of the frame's height the body spans.
    var verticalCoverage: Double
    /// How centered the body is horizontally (1 = perfectly centered).
    var horizontalCentering: Double
    /// Postural uprightness/openness (1 = upright & balanced).
    var posture: Double

    static let unavailable = PoseSignals(
        detected: false, confidence: 0, fullBodyVisible: false,
        verticalCoverage: 0, horizontalCentering: 0.5, posture: 0.5
    )
}

/// Normalized signals from person segmentation.
struct SegmentationSignals: Sendable, Equatable {
    var available: Bool
    /// Fraction of frame occupied by the subject.
    var subjectFraction: Double
    /// Background visual complexity (1 = busy/cluttered).
    var backgroundComplexity: Double

    static let unavailable = SegmentationSignals(available: false, subjectFraction: 0.4, backgroundComplexity: 0.5)
}

/// Normalized signals from Core Image quality analysis.
struct QualitySignals: Sendable, Equatable {
    /// Average luminance 0...1.
    var brightness: Double
    /// Global contrast 0...1.
    var contrast: Double
    /// Sharpness/detail estimate 0...1.
    var sharpness: Double
    /// 1 = well-exposed (not clipped), 0 = heavily over/under-exposed.
    var exposureBalance: Double

    static let neutral = QualitySignals(brightness: 0.5, contrast: 0.5, sharpness: 0.5, exposureBalance: 0.7)
}

/// Normalized color signals.
struct ColorSignals: Sendable, Equatable {
    var palette: [RGBColor]
    /// 0...1 — how harmonious the palette is.
    var harmony: Double
    /// 0...1 — how cohesive/balanced the outfit colors are (not too chaotic).
    var cohesion: Double

    static let neutral = ColorSignals(palette: [], harmony: 0.6, cohesion: 0.6)
}

/// Outfit classification output (heuristic or Core ML).
struct OutfitSignals: Sendable, Equatable {
    var cohesion: Double
    var persona: StylePersona
    var tags: [OutfitTag]
    /// Whether a real Core ML model produced this (vs heuristic fallback).
    var usedModel: Bool

    static let neutral = OutfitSignals(cohesion: 0.65, persona: .undetermined, tags: [], usedModel: false)
}

/// The full normalized signal set fed to `ScoreEngine`.
struct AnalysisSignals: Sendable, Equatable {
    var pose: PoseSignals
    var segmentation: SegmentationSignals
    var quality: QualitySignals
    var color: ColorSignals
    var outfit: OutfitSignals
}

/// The final result returned by the pipeline, ready to persist & display.
struct FitAnalysisResult: Sendable {
    var score: FitScore
    var persona: StylePersona
    var tips: [String]
    var outfitTags: [OutfitTag]
    var palette: [RGBColor]
    /// Diagnostics about which subsystems produced real data.
    var diagnostics: Diagnostics

    struct Diagnostics: Sendable, Equatable {
        var poseDetected: Bool
        var segmentationAvailable: Bool
        var usedOutfitModel: Bool
    }
}
