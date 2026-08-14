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
    /// Bounding box of confident joints in normalized image coordinates
    /// (origin top-left, like UIKit), nil when no person was found.
    var boundingBox: CGRect?

    static let unavailable = PoseSignals(
        detected: false, confidence: 0, fullBodyVisible: false,
        verticalCoverage: 0, horizontalCentering: 0.5, posture: 0.5,
        boundingBox: nil
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

/// Decides whether the photo contains enough trustworthy visual signal to score.
///
/// This gate intentionally runs before product-facing scoring. Outfit/color heuristics can
/// produce plausible-looking values for almost any image, so they must never turn an unusable
/// photo into an 80+ result.
struct PhotoQualityGate: Sendable {
    struct Assessment: Sendable, Equatable {
        enum Rejection: Sendable, Equatable {
            case noReliablePerson
            case croppedBody
            case subjectTooSmall
            case subjectTooLarge
            case tooDark
            case overexposed
            case blurry
            case lowDetail

            var message: String {
                switch self {
                case .noReliablePerson:
                    return "We couldn't get a reliable full-body read. Make sure one person is clearly visible from head to shoes."
                case .croppedBody:
                    return "Your full outfit isn't visible. Step back and keep your head and shoes inside the frame."
                case .subjectTooSmall:
                    return "You're too far from the camera for a reliable outfit score. Move closer while keeping your full body visible."
                case .subjectTooLarge:
                    return "You're too close to the camera for a reliable outfit score. Step back so your full silhouette fits."
                case .tooDark:
                    return "This photo is too dark to score reliably. Face a window or brighter light and try again."
                case .overexposed:
                    return "This photo is too washed out to score reliably. Move out of direct glare and try again."
                case .blurry:
                    return "This photo is too blurry to score reliably. Steady the phone or use a timer and retake it."
                case .lowDetail:
                    return "There isn't enough visible detail to score this photo reliably. Use clearer light and a less obstructed view."
                }
            }
        }

        var rejection: Rejection?
        /// Borderline-but-usable photos can be scored, but cannot receive a misleadingly high
        /// overall result. A hard rejection uses a ceiling as defense in depth.
        var scoreCeiling: Int?

        var isAcceptable: Bool { rejection == nil }
    }

    func assess(_ signals: AnalysisSignals) -> Assessment {
        let pose = signals.pose
        let segmentation = signals.segmentation
        let quality = signals.quality

        guard pose.detected, pose.confidence >= 0.35 else {
            return Assessment(rejection: .noReliablePerson, scoreCeiling: 49)
        }
        guard pose.fullBodyVisible else {
            return Assessment(rejection: .croppedBody, scoreCeiling: 49)
        }
        guard pose.verticalCoverage >= 0.34 else {
            return Assessment(rejection: .subjectTooSmall, scoreCeiling: 49)
        }
        guard pose.verticalCoverage <= 0.94 else {
            return Assessment(rejection: .subjectTooLarge, scoreCeiling: 49)
        }

        if segmentation.available {
            guard segmentation.subjectFraction >= 0.14 else {
                return Assessment(rejection: .subjectTooSmall, scoreCeiling: 49)
            }
            guard segmentation.subjectFraction <= 0.78 else {
                return Assessment(rejection: .subjectTooLarge, scoreCeiling: 49)
            }
        }

        if quality.brightness < 0.18 || (quality.exposureBalance < 0.30 && quality.brightness < 0.5) {
            return Assessment(rejection: .tooDark, scoreCeiling: 49)
        }
        if quality.brightness > 0.82 || (quality.exposureBalance < 0.30 && quality.brightness >= 0.5) {
            return Assessment(rejection: .overexposed, scoreCeiling: 49)
        }
        guard quality.sharpness >= 0.22 else {
            return Assessment(rejection: .blurry, scoreCeiling: 49)
        }
        guard quality.contrast >= 0.12 else {
            return Assessment(rejection: .lowDetail, scoreCeiling: 49)
        }

        var ceiling: Int?
        if quality.sharpness < 0.38 || quality.exposureBalance < 0.50 || quality.contrast < 0.22 {
            ceiling = 69
        }
        if pose.confidence < 0.55
            || pose.verticalCoverage < 0.45
            || pose.verticalCoverage > 0.86
            || pose.horizontalCentering < 0.55 {
            ceiling = min(ceiling ?? 74, 74)
        }
        if segmentation.available
            && (segmentation.subjectFraction < 0.25 || segmentation.subjectFraction > 0.65) {
            ceiling = min(ceiling ?? 74, 74)
        }

        return Assessment(rejection: nil, scoreCeiling: ceiling)
    }
}

/// The final result returned by the pipeline, ready to persist & display.
struct FitAnalysisResult: Sendable {
    var score: FitScore
    var persona: StylePersona
    var tips: [String]
    var outfitTags: [OutfitTag]
    var palette: [RGBColor]
    /// Photo-technique guidance ("how to take a better picture"), empty when the shot is fine.
    var photoTips: [String] = []
    /// Specific user-facing reason when the photo is refused; nil = use the generic message.
    var rejectionDetail: String? = nil
    /// Diagnostics about which subsystems produced real data.
    var diagnostics: Diagnostics

    struct Diagnostics: Sendable, Equatable {
        var poseDetected: Bool
        var segmentationAvailable: Bool
        var usedOutfitModel: Bool
        var photoQualityPassed: Bool = true

        /// A score is untrustworthy when the subject cannot be found or the deterministic
        /// photo-quality gate rejects the input.
        var isLowConfidence: Bool {
            !photoQualityPassed || (!poseDetected && !segmentationAvailable)
        }
    }
}
