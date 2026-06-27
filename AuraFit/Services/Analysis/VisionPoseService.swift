import Vision
#if canImport(UIKit)
import UIKit
#endif

/// Detects human body pose with Vision and derives normalized posture/framing signals.
/// Returns `.unavailable` on any failure so the pipeline degrades gracefully.
struct VisionPoseService: Sendable {

    #if canImport(UIKit)
    func analyze(_ image: UIImage) -> PoseSignals {
        guard let cg = image.normalizedOrientation().cgImage else { return .unavailable }
        return analyze(cgImage: cg)
    }
    #endif

    func analyze(cgImage: CGImage) -> PoseSignals {
        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            AppLog.analysis.error("Pose request failed: \(error.localizedDescription)")
            return .unavailable
        }

        guard let observation = (request.results)?.first else {
            return .unavailable
        }

        let points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]
        do {
            points = try observation.recognizedPoints(.all)
        } catch {
            return .unavailable
        }

        // Collect confident joints (Vision coordinates: origin bottom-left, normalized 0...1).
        let confident = points.values.filter { $0.confidence > 0.1 }
        guard confident.count >= 4 else {
            return PoseSignals(detected: true, confidence: Double(observation.confidence),
                               fullBodyVisible: false, verticalCoverage: 0.3,
                               horizontalCentering: 0.5, posture: 0.5)
        }

        let ys = confident.map { Double($0.location.y) }
        let xs = confident.map { Double($0.location.x) }
        let minY = ys.min() ?? 0, maxY = ys.max() ?? 1
        let verticalCoverage = (maxY - minY).clamped(to: 0...1)

        // Center of mass horizontal position; centering = 1 when near 0.5.
        let avgX = xs.reduce(0, +) / Double(xs.count)
        let horizontalCentering = (1 - abs(avgX - 0.5) * 2).clamped(to: 0...1)

        // Full body if we see both ankles (or feet) with some confidence.
        let leftAnkle = points[.leftAnkle]?.confidence ?? 0
        let rightAnkle = points[.rightAnkle]?.confidence ?? 0
        let nose = points[.nose]?.confidence ?? 0
        let fullBody = (leftAnkle > 0.05 || rightAnkle > 0.05) && nose > 0.05 && verticalCoverage > 0.55

        let posture = estimatePosture(points)

        return PoseSignals(
            detected: true,
            confidence: Double(observation.confidence),
            fullBodyVisible: fullBody,
            verticalCoverage: verticalCoverage,
            horizontalCentering: horizontalCentering,
            posture: posture
        )
    }

    /// Posture score from shoulder/hip levelness and spine verticality.
    private func estimatePosture(_ points: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> Double {
        func pt(_ name: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
            guard let p = points[name], p.confidence > 0.1 else { return nil }
            return p.location
        }

        var components: [Double] = []

        // Shoulder levelness.
        if let ls = pt(.leftShoulder), let rs = pt(.rightShoulder) {
            let tilt = abs(Double(ls.y - rs.y))
            components.append((1 - tilt * 4).clamped(to: 0...1))
        }
        // Hip levelness.
        if let lh = pt(.leftHip), let rh = pt(.rightHip) {
            let tilt = abs(Double(lh.y - rh.y))
            components.append((1 - tilt * 4).clamped(to: 0...1))
        }
        // Spine verticality (neck above root, horizontally aligned).
        if let neck = pt(.neck), let root = pt(.root) {
            let lateral = abs(Double(neck.x - root.x))
            components.append((1 - lateral * 3).clamped(to: 0...1))
        }

        guard !components.isEmpty else { return 0.6 }
        return components.reduce(0, +) / Double(components.count)
    }
}
