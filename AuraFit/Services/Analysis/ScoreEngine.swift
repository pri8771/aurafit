import Foundation

/// Converts normalized `AnalysisSignals` into a `FitScore`, improvement tips, and palette.
///
/// Pure and deterministic — no I/O, no Vision, no UIKit — so it is fully unit-testable.
/// Weighting (sums to 1.0 across the six weighted metrics):
///  Outfit Cohesion 25%, Color Harmony 20%, Pose 15%, Lighting 15%, Framing 15%, Background 10%.
///  Confidence Energy is displayed but derived from the others (not part of the 100-point sum).
struct ScoreEngine: Sendable {

    func score(from signals: AnalysisSignals) -> FitScore {
        let metrics = metricValues(from: signals)
        let rawOverall = weightedOverall(metrics)
        let assessment = PhotoQualityGate().assess(signals)
        let overall = min(rawOverall, assessment.scoreCeiling ?? 100)
        return FitScore(overall: overall, metrics: metrics)
    }

    // MARK: - Per-metric scoring

    func metricValues(from s: AnalysisSignals) -> [FitMetric] {
        let cohesion = outfitCohesionScore(s)
        let color = colorHarmonyScore(s)
        let pose = poseScore(s)
        let lighting = lightingScore(s)
        let framing = framingScore(s)
        let background = backgroundScore(s)
        let confidence = confidenceScore(pose: pose, framing: framing, lighting: lighting, cohesion: cohesion)

        return [
            FitMetric(kind: .outfitCohesion, value: cohesion),
            FitMetric(kind: .colorHarmony, value: color),
            FitMetric(kind: .posePosture, value: pose),
            FitMetric(kind: .lighting, value: lighting),
            FitMetric(kind: .framing, value: framing),
            FitMetric(kind: .backgroundCleanliness, value: background),
            FitMetric(kind: .confidenceEnergy, value: confidence)
        ]
    }

    private func outfitCohesionScore(_ s: AnalysisSignals) -> Int {
        // Blend classifier cohesion with color cohesion.
        let v = s.outfit.cohesion * 0.65 + s.color.cohesion * 0.35
        return scaled(v, floor: 30)
    }

    private func colorHarmonyScore(_ s: AnalysisSignals) -> Int {
        scaled(s.color.harmony, floor: 28)
    }

    private func poseScore(_ s: AnalysisSignals) -> Int {
        guard s.pose.detected else { return 52 }  // neutral when no pose found
        let coverage = s.pose.fullBodyVisible ? 1.0 : s.pose.verticalCoverage
        let v = s.pose.posture * 0.55 + coverage * 0.25 + s.pose.confidence * 0.20
        return scaled(v, floor: 30)
    }

    private func lightingScore(_ s: AnalysisSignals) -> Int {
        let q = s.quality
        let v = q.exposureBalance * 0.5 + q.contrast * 0.25 + q.sharpness * 0.25
        return scaled(v, floor: 25)
    }

    private func framingScore(_ s: AnalysisSignals) -> Int {
        // Combine pose centering & coverage with subject fraction from segmentation.
        let centering = s.pose.detected ? s.pose.horizontalCentering : 0.6
        let coverage = s.pose.detected ? s.pose.verticalCoverage : 0.6
        let subject = s.segmentation.available ? idealSubjectFraction(s.segmentation.subjectFraction) : 0.6
        let v = centering * 0.4 + coverage * 0.3 + subject * 0.3
        return scaled(v, floor: 28)
    }

    private func backgroundScore(_ s: AnalysisSignals) -> Int {
        guard s.segmentation.available else { return 58 }
        // Less complexity => cleaner background.
        let v = 1 - s.segmentation.backgroundComplexity
        return scaled(v, floor: 25)
    }

    /// "Confidence/main character energy" — a holistic blend of the strongest dimensions.
    private func confidenceScore(pose: Int, framing: Int, lighting: Int, cohesion: Int) -> Int {
        let avg = Double(pose + framing + lighting + cohesion) / 4.0
        // Reward strong pose + framing a little extra (presence).
        let presenceBonus = Double(max(0, pose - 70)) * 0.15 + Double(max(0, framing - 70)) * 0.1
        return Int(avg + presenceBonus).clampedScore
    }

    // MARK: - Overall

    func weightedOverall(_ metrics: [FitMetric]) -> Int {
        var sum = 0.0
        var weightTotal = 0.0
        for metric in metrics {
            let w = metric.kind.weight
            guard w > 0 else { continue }
            sum += Double(metric.value) * w
            weightTotal += w
        }
        guard weightTotal > 0 else { return 0 }
        return Int((sum / weightTotal).rounded()).clampedScore
    }

    // MARK: - Helpers

    /// Maps a 0...1 signal onto a score with a sensible floor so results never feel punishing.
    private func scaled(_ value: Double, floor: Int) -> Int {
        let v = value.clamped(to: 0...1)
        return (floor + Int((Double(100 - floor) * v).rounded())).clampedScore
    }

    /// Subject fraction quality: ~0.35–0.6 of the frame is ideal for a full-body fit photo.
    private func idealSubjectFraction(_ fraction: Double) -> Double {
        let ideal = 0.45
        let distance = abs(fraction - ideal)
        return (1 - distance * 1.8).clamped(to: 0...1)
    }
}
