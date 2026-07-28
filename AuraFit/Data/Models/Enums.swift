import SwiftUI

// MARK: - Metric Kind

/// The seven scored dimensions of a fit. Raw values are stable identifiers used for persistence.
enum FitMetricKind: String, Codable, CaseIterable, Identifiable, Sendable {
    case outfitCohesion
    case colorHarmony
    case posePosture
    case lighting
    case framing
    case backgroundCleanliness
    case confidenceEnergy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .outfitCohesion: return "Outfit Cohesion"
        case .colorHarmony: return "Color Harmony"
        case .posePosture: return "Pose / Posture"
        case .lighting: return "Lighting"
        case .framing: return "Framing"
        case .backgroundCleanliness: return "Background"
        case .confidenceEnergy: return "Confidence Energy"
        }
    }

    var systemImage: String {
        switch self {
        case .outfitCohesion: return "tshirt.fill"
        case .colorHarmony: return "paintpalette.fill"
        case .posePosture: return "figure.stand"
        case .lighting: return "sun.max.fill"
        case .framing: return "viewfinder"
        case .backgroundCleanliness: return "square.on.square"
        case .confidenceEnergy: return "bolt.fill"
        }
    }

    /// Weight of this metric in the overall score (sums to 1.0).
    var weight: Double {
        switch self {
        case .outfitCohesion: return 0.25
        case .colorHarmony: return 0.20
        case .posePosture: return 0.15
        case .lighting: return 0.15
        case .framing: return 0.15
        case .backgroundCleanliness: return 0.10
        case .confidenceEnergy: return 0.0   // derived/secondary, displayed but not weighted into 100
        }
    }
}

// MARK: - Score Label

/// Qualitative tier derived from the overall numeric score.
enum ScoreLabel: String, Codable, CaseIterable, Sendable {
    case mainCharacter = "Main Character"
    case sharp = "Sharp"
    case clean = "Clean"
    case almostThere = "Almost There"
    case needsGlowUp = "Needs a Glow-Up"

    static func from(score: Int) -> ScoreLabel {
        switch score {
        case 90...100: return .mainCharacter
        case 78..<90:  return .sharp
        case 64..<78:  return .clean
        case 48..<64:  return .almostThere
        default:       return .needsGlowUp
        }
    }

    var emoji: String {
        switch self {
        case .mainCharacter: return "🌟"
        case .sharp: return "⚡️"
        case .clean: return "✨"
        case .almostThere: return "🔥"
        case .needsGlowUp: return "💪"
        }
    }

    var blurb: String {
        switch self {
        case .mainCharacter: return "This one's radiating main character energy."
        case .sharp: return "Crisp, intentional, and dialed in."
        case .clean: return "Solid look with a clean finish."
        case .almostThere: return "Strong base — a few tweaks away."
        case .needsGlowUp: return "Good start. Let's level it up."
        }
    }
}

// MARK: - Style Persona

/// The closest aesthetic archetype for a fit. This is the classifier's nearest match,
/// not a certainty — surface it with its confidence rather than as a detected fact.
enum StylePersona: String, Codable, CaseIterable, Identifiable, Sendable {
    case streetwear = "Streetwear"
    case softLuxury = "Soft Luxury"
    case minimalist = "Minimalist"
    case sporty = "Sporty"
    case classic = "Classic"
    case bold = "Bold & Expressive"
    case cozy = "Cozy"
    case undetermined = "Eclectic"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .streetwear: return "figure.walk.motion"
        case .softLuxury: return "sparkles"
        case .minimalist: return "circle.dashed"
        case .sporty: return "figure.run"
        case .classic: return "crown.fill"
        case .bold: return "flame.fill"
        case .cozy: return "cloud.fill"
        case .undetermined: return "wand.and.stars"
        }
    }

    var tagline: String {
        switch self {
        case .streetwear: return "Effortless, urban, statement-making."
        case .softLuxury: return "Refined textures and quiet confidence."
        case .minimalist: return "Less, but better."
        case .sporty: return "Athletic, energetic, ready to move."
        case .classic: return "Timeless and tailored."
        case .bold: return "Color, contrast, and personality."
        case .cozy: return "Warm, relaxed, and inviting."
        case .undetermined: return "A mix that's all your own."
        }
    }
}

// MARK: - Entitlement Tier

enum EntitlementTier: String, Codable, Sendable {
    case free
    case pro
}
