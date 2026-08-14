import Foundation
import CoreML
import Vision
#if canImport(UIKit)
import UIKit
#endif

/// Abstraction over an outfit-classification model so an alternative Core ML model can be
/// dropped in without touching the pipeline.
protocol OutfitClassifying {
    /// Returns persona + cohesion + tags for an image, given already-computed color signals.
    #if canImport(UIKit)
    func classify(image: UIImage, colors: ColorSignals, pose: PoseSignals) -> OutfitSignals
    #endif
}

/// Default classifier. Tries, in order:
/// 1. Optional, separately licensed MobileCLIP resources, if a future build bundles them.
/// 2. An optional dedicated Core ML model named `OutfitClassifier`, if ever bundled.
/// 3. A deterministic heuristic based on color & pose signals, so the app always runs.
struct OutfitClassifierService: OutfitClassifying {

    /// Name of the optional compiled Core ML model resource (`OutfitClassifier.mlmodelc`).
    static let modelResourceName = "OutfitClassifier"

    private let clip: CLIPZeroShotClassifier?
    private let model: VNCoreMLModel?

    init() {
        self.clip = CLIPZeroShotClassifier()
        self.model = Self.loadModelIfAvailable()
    }

    /// Loads the Vision-wrapped Core ML model if it exists in the bundle; otherwise nil.
    private static func loadModelIfAvailable() -> VNCoreMLModel? {
        guard let url = Bundle.main.url(forResource: modelResourceName, withExtension: "mlmodelc") else {
            AppLog.analysis.info("No OutfitClassifier model bundled; using heuristic fallback.")
            return nil
        }
        do {
            let mlModel = try MLModel(contentsOf: url)
            let vnModel = try VNCoreMLModel(for: mlModel)
            AppLog.analysis.info("Loaded OutfitClassifier Core ML model.")
            return vnModel
        } catch {
            AppLog.analysis.error("Failed to load OutfitClassifier: \(error.localizedDescription)")
            return nil
        }
    }

    #if canImport(UIKit)
    /// The zero-shot classifier, exposed so the pipeline can reuse it for photo-issue checks.
    var zeroShotClassifier: CLIPZeroShotClassifier? { clip }

    func classify(image: UIImage, colors: ColorSignals, pose: PoseSignals) -> OutfitSignals {
        if let clip, let clipResult = clip.classify(image: image, colors: colors, pose: pose) {
            return clipResult
        }
        if let model, let cg = image.normalizedOrientation().cgImage {
            if let modelResult = runModel(model, cgImage: cg, colors: colors) {
                return modelResult
            }
        }
        return heuristicClassification(colors: colors, pose: pose)
    }

    /// Runs the Core ML classifier and maps its top label to a `StylePersona`.
    private func runModel(_ model: VNCoreMLModel, cgImage: CGImage, colors: ColorSignals) -> OutfitSignals? {
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
        do {
            try handler.perform([request])
        } catch {
            AppLog.analysis.error("OutfitClassifier inference failed: \(error.localizedDescription)")
            return nil
        }
        guard let results = request.results as? [VNClassificationObservation],
              let top = results.first else {
            return nil
        }
        let persona = Self.persona(fromLabel: top.identifier)
        let tags = results.prefix(3).map {
            OutfitTag(label: $0.identifier, confidence: Double($0.confidence))
        }
        // Cohesion still benefits from color analysis even with a model present.
        return OutfitSignals(
            cohesion: colors.cohesion,
            persona: persona,
            tags: tags,
            usedModel: true
        )
    }
    #endif

    /// Maps a raw model label to a known persona (best-effort, case-insensitive).
    static func persona(fromLabel label: String) -> StylePersona {
        let normalized = label.lowercased()
        if normalized.contains("street") { return .streetwear }
        if normalized.contains("lux") || normalized.contains("elegant") { return .softLuxury }
        if normalized.contains("minim") { return .minimalist }
        if normalized.contains("sport") || normalized.contains("athl") { return .sporty }
        if normalized.contains("classic") || normalized.contains("formal") { return .classic }
        if normalized.contains("bold") || normalized.contains("color") { return .bold }
        if normalized.contains("cozy") || normalized.contains("casual") { return .cozy }
        return .undetermined
    }

    // MARK: - Heuristic fallback (deterministic, testable)

    /// Infers persona & cohesion from palette characteristics and pose energy.
    func heuristicClassification(colors: ColorSignals, pose: PoseSignals) -> OutfitSignals {
        let persona = Self.inferPersona(colors: colors, pose: pose)
        let tags = Self.makeTags(colors: colors, persona: persona)
        // Cohesion blends color cohesion with a mild boost for harmonious palettes.
        let cohesion = (colors.cohesion * 0.7 + colors.harmony * 0.3).clamped(to: 0...1)
        return OutfitSignals(cohesion: cohesion, persona: persona, tags: tags, usedModel: false)
    }

    static func inferPersona(colors: ColorSignals, pose: PoseSignals) -> StylePersona {
        let hsbs = colors.palette.map { $0.hsb }
        guard !hsbs.isEmpty else { return .undetermined }

        let avgSat = hsbs.map(\.s).reduce(0, +) / Double(hsbs.count)
        let avgBright = hsbs.map(\.b).reduce(0, +) / Double(hsbs.count)
        let saturatedCount = hsbs.filter { $0.s > 0.5 }.count
        let darkCount = hsbs.filter { $0.b < 0.3 }.count

        // High-energy pose + high saturation => sporty/bold.
        if saturatedCount >= 3 && avgSat > 0.55 { return .bold }
        if pose.verticalCoverage > 0.7 && avgSat > 0.4 && avgBright > 0.5 { return .sporty }

        // Mostly dark, low saturation => streetwear.
        if darkCount >= 2 && avgSat < 0.3 { return .streetwear }

        // Soft, bright, low-mid saturation => soft luxury.
        if avgBright > 0.6 && avgSat < 0.35 { return .softLuxury }

        // Very low saturation overall => minimalist.
        if avgSat < 0.18 { return .minimalist }

        // Warm, mid brightness => cozy.
        if avgBright > 0.4 && avgBright < 0.7 && avgSat < 0.45 { return .cozy }

        return .classic
    }

    /// Sentinel confidence for tags that did not come from a model.
    ///
    /// The heuristic path is a deterministic rule over the palette, not a probabilistic
    /// classifier, so it has no probability to report. Earlier versions stored invented
    /// constants (0.6 for the persona, 0.5 for colors) that were indistinguishable from
    /// real model output once persisted. `OutfitTag.confidence` is non-optional and shared
    /// with call sites outside this file, so the honest value is this documented zero:
    /// UI must treat it as "no confidence available" and never render it as a percentage.
    static let noModelConfidence: Double = 0

    static func makeTags(colors: ColorSignals, persona: StylePersona) -> [OutfitTag] {
        var tags: [OutfitTag] = [OutfitTag(label: persona.rawValue, confidence: noModelConfidence)]
        for color in colors.palette.prefix(3) {
            tags.append(OutfitTag(label: Self.colorName(for: color),
                                  confidence: noModelConfidence,
                                  hex: color.hexString))
        }
        return tags
    }

    /// Approximate human-readable color name from hue/sat/brightness.
    static func colorName(for color: RGBColor) -> String {
        let (h, s, b) = color.hsb
        if b < 0.12 { return "Black" }
        if b > 0.9 && s < 0.1 { return "White" }
        if s < 0.12 { return b < 0.5 ? "Charcoal" : "Gray" }
        switch h {
        case 0..<0.04, 0.96...1: return "Red"
        case 0.04..<0.10: return "Orange"
        case 0.10..<0.17: return "Yellow"
        case 0.17..<0.42: return "Green"
        case 0.42..<0.55: return "Teal"
        case 0.55..<0.70: return "Blue"
        case 0.70..<0.83: return "Purple"
        case 0.83..<0.96: return "Pink"
        default: return "Neutral"
        }
    }
}
