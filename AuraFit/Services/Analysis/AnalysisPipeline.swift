import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Discrete, observable steps of the analysis pipeline (drives the progress UI).
enum AnalysisStep: Int, CaseIterable, Sendable, Identifiable {
    case normalizing
    case detectingPose
    case readingColors
    case checkingLighting
    case scoringComposition
    case buildingScorecard

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .normalizing: return "Preparing your photo"
        case .detectingPose: return "Detecting pose"
        case .readingColors: return "Reading outfit colors"
        case .checkingLighting: return "Checking lighting"
        case .scoringComposition: return "Scoring composition"
        case .buildingScorecard: return "Building scorecard"
        }
    }

    var systemImage: String {
        switch self {
        case .normalizing: return "wand.and.stars"
        case .detectingPose: return "figure.stand"
        case .readingColors: return "paintpalette"
        case .checkingLighting: return "sun.max"
        case .scoringComposition: return "viewfinder"
        case .buildingScorecard: return "rectangle.portrait.badge.plus"
        }
    }
}

/// The core analysis engine. An `actor` so heavy Vision/Core Image work runs off the main thread
/// and is isolated for Swift 6 concurrency safety. Accepts a `UIImage`, emits step progress, and
/// returns a `FitAnalysisResult`.
actor AnalysisPipeline {

    // Injected collaborators (value types / Sendable) for testability.
    private let pose: VisionPoseService
    private let segmentation: VisionSegmentationService
    private let quality: ImageQualityService
    private let colorHarmony: ColorHarmonyService
    private let classifier: any OutfitClassifying
    private let scoreEngine: ScoreEngine
    private let tipsGenerator: TipsGenerator
    private let photoCoach: PhotoCoach

    init(
        pose: VisionPoseService = VisionPoseService(),
        segmentation: VisionSegmentationService = VisionSegmentationService(),
        quality: ImageQualityService = ImageQualityService(),
        colorHarmony: ColorHarmonyService = ColorHarmonyService(),
        classifier: (any OutfitClassifying)? = nil,
        scoreEngine: ScoreEngine = ScoreEngine(),
        tipsGenerator: TipsGenerator = TipsGenerator(),
        photoCoach: PhotoCoach = PhotoCoach()
    ) {
        self.pose = pose
        self.segmentation = segmentation
        self.quality = quality
        self.colorHarmony = colorHarmony
        self.classifier = classifier ?? OutfitClassifierService()
        self.scoreEngine = scoreEngine
        self.tipsGenerator = tipsGenerator
        self.photoCoach = photoCoach
    }

    #if canImport(UIKit)
    /// Runs the full pipeline. `onStep` is invoked (on the main actor) as each step begins.
    /// A small artificial delay per step makes the animated progress legible without blocking.
    func analyze(
        image: UIImage,
        stepDelay: Duration = .milliseconds(420),
        onStep: (@MainActor @Sendable (AnalysisStep) -> Void)? = nil
    ) async -> FitAnalysisResult {

        // (A) Normalize
        await emit(.normalizing, onStep, delay: stepDelay)
        let working = image.normalizedOrientation().resized(maxDimension: 1280)

        // (B) Pose
        await emit(.detectingPose, onStep, delay: stepDelay)
        let poseSignals = pose.analyze(working)

        // (C) Segmentation (grouped under pose/composition visually) + (E) color
        await emit(.readingColors, onStep, delay: stepDelay)
        let colorSignals = colorHarmony.analyze(working)
        let segmentationSignals = segmentation.analyze(working)

        // (D) Lighting / quality
        await emit(.checkingLighting, onStep, delay: stepDelay)
        let qualitySignals = quality.analyze(working)

        // (F) Outfit classification + (G) scoring
        await emit(.scoringComposition, onStep, delay: stepDelay)
        let outfitSignals = classifier.classify(image: working, colors: colorSignals, pose: poseSignals)

        let signals = AnalysisSignals(
            pose: poseSignals,
            segmentation: segmentationSignals,
            quality: qualitySignals,
            color: colorSignals,
            outfit: outfitSignals
        )
        let score = scoreEngine.score(from: signals)
        let tips = tipsGenerator.tips(for: score, signals: signals, persona: outfitSignals.persona)

        // Photo coaching: CLIP's frame-level issue read (when bundled) + signal heuristics.
        let issues = (classifier as? OutfitClassifierService)?
            .zeroShotClassifier?
            .assessPhotoIssues(image: working)
        let photoTips = photoCoach.tips(signals: signals, issues: issues)
        let rejectionDetail = photoCoach.rejectionDetail(issues: issues)

        // (Build scorecard step — actual rendering happens later in the Results layer)
        await emit(.buildingScorecard, onStep, delay: stepDelay)

        return FitAnalysisResult(
            score: score,
            persona: outfitSignals.persona,
            tips: tips,
            outfitTags: outfitSignals.tags,
            palette: colorSignals.palette,
            photoTips: photoTips,
            rejectionDetail: rejectionDetail,
            diagnostics: .init(
                poseDetected: poseSignals.detected,
                segmentationAvailable: segmentationSignals.available,
                usedOutfitModel: outfitSignals.usedModel
            )
        )
    }
    #endif

    /// Analyze raw signals only (used by tests / advanced callers).
    func score(for signals: AnalysisSignals) -> FitAnalysisResult {
        let score = scoreEngine.score(from: signals)
        let tips = tipsGenerator.tips(for: score, signals: signals, persona: signals.outfit.persona)
        return FitAnalysisResult(
            score: score,
            persona: signals.outfit.persona,
            tips: tips,
            outfitTags: signals.outfit.tags,
            palette: signals.color.palette,
            diagnostics: .init(
                poseDetected: signals.pose.detected,
                segmentationAvailable: signals.segmentation.available,
                usedOutfitModel: signals.outfit.usedModel
            )
        )
    }

    private func emit(
        _ step: AnalysisStep,
        _ onStep: (@MainActor @Sendable (AnalysisStep) -> Void)?,
        delay: Duration
    ) async {
        if let onStep {
            await MainActor.run { onStep(step) }
        }
        if delay > .zero {
            try? await Task.sleep(for: delay)
        }
    }
}
