import AVFoundation
import CoreVideo
import Foundation
import Vision

/// A single live suggestion shown over the viewfinder while the user lines up a shot.
enum CoachHint: Equatable, Sendable {
    case moreLight
    case stepIntoFrame
    case stepBack
    case comeCloser
    case centerYourself
    case perfect

    var message: String {
        switch self {
        case .moreLight: return "Too dark — face a light"
        case .stepIntoFrame: return "Step into the frame"
        case .stepBack: return "Step back — head to toe"
        case .comeCloser: return "Come a little closer"
        case .centerYourself: return "Center yourself"
        case .perfect: return "Perfect — hold that!"
        }
    }

    var systemImage: String {
        switch self {
        case .moreLight: return "sun.max"
        case .stepIntoFrame: return "figure.stand"
        case .stepBack: return "arrow.up.left.and.arrow.down.right"
        case .comeCloser: return "arrow.down.right.and.arrow.up.left"
        case .centerYourself: return "align.horizontal.center"
        case .perfect: return "checkmark.circle.fill"
        }
    }

    var isPositive: Bool { self == .perfect }
}

/// Pure decision logic mapping one frame's measurements to a hint. Deterministic and
/// unit-testable; thresholds mirror what `ScoreEngine` later rewards, so following the
/// live coach genuinely raises the eventual score.
struct CoachHintEngine: Sendable {

    struct FrameReading: Sendable {
        /// Mean luminance 0...1.
        var brightness: Double
        var personDetected: Bool
        var fullBodyVisible: Bool
        /// Fraction of frame height the joints span (0 when no person).
        var verticalCoverage: Double
        /// Horizontal center of mass of the joints, 0...1 (0.5 = centered).
        var horizontalCenter: Double
    }

    func hint(for reading: FrameReading) -> CoachHint {
        if reading.brightness < 0.22 { return .moreLight }
        guard reading.personDetected else { return .stepIntoFrame }
        if !reading.fullBodyVisible && reading.verticalCoverage > 0.6 { return .stepBack }
        if reading.verticalCoverage < 0.45 { return .comeCloser }
        if abs(reading.horizontalCenter - 0.5) > 0.16 { return .centerYourself }
        if reading.brightness < 0.32 { return .moreLight }
        return .perfect
    }
}

/// Analyzes live camera frames at a throttled rate on the caller's (serial) video queue.
/// Not thread-safe by itself — all calls must come from that one queue.
final class LiveFrameAnalyzer {

    private let engine = CoachHintEngine()
    /// Minimum seconds between analyzed frames (~3 Hz keeps ANE/CPU cost negligible).
    private let interval: TimeInterval = 0.35
    private var lastAnalysis: TimeInterval = 0

    // Hysteresis: a hint must win twice in a row before we surface it, so the chip
    // doesn't flicker at threshold boundaries.
    private var candidate: CoachHint?
    private var published: CoachHint?

    /// Returns a newly stabilized hint, or nil when nothing should change yet.
    /// (Wall clock is fine for throttling — a clock jump costs at most one extra frame,
    /// and it avoids required-reason timebase APIs the privacy manifest doesn't declare.)
    func process(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> CoachHint? {
        let now = Date().timeIntervalSinceReferenceDate
        guard now - lastAnalysis >= interval else { return nil }
        lastAnalysis = now

        let reading = read(pixelBuffer, orientation: orientation)
        let next = engine.hint(for: reading)

        if next == published { candidate = nil; return nil }
        if next == candidate {
            candidate = nil
            published = next
            return next
        }
        candidate = next
        return nil
    }

    // MARK: - Frame measurement

    private func read(_ pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> CoachHintEngine.FrameReading {
        let brightness = Self.meanLuminance(pixelBuffer)

        let request = VNDetectHumanBodyPoseRequest()
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return .init(brightness: brightness, personDetected: false, fullBodyVisible: false,
                         verticalCoverage: 0, horizontalCenter: 0.5)
        }

        guard let observation = request.results?.first,
              let points = try? observation.recognizedPoints(.all) else {
            return .init(brightness: brightness, personDetected: false, fullBodyVisible: false,
                         verticalCoverage: 0, horizontalCenter: 0.5)
        }

        let confident = points.values.filter { $0.confidence > 0.1 }
        guard confident.count >= 4 else {
            return .init(brightness: brightness, personDetected: false, fullBodyVisible: false,
                         verticalCoverage: 0, horizontalCenter: 0.5)
        }

        let ys = confident.map { Double($0.location.y) }
        let xs = confident.map { Double($0.location.x) }
        let coverage = ((ys.max() ?? 0) - (ys.min() ?? 0)).clamped(to: 0...1)
        let centerX = xs.reduce(0, +) / Double(xs.count)

        let leftAnkle = points[.leftAnkle]?.confidence ?? 0
        let rightAnkle = points[.rightAnkle]?.confidence ?? 0
        let nose = points[.nose]?.confidence ?? 0
        let fullBody = (leftAnkle > 0.05 || rightAnkle > 0.05) && nose > 0.05 && coverage > 0.55

        return .init(
            brightness: brightness,
            personDetected: true,
            fullBodyVisible: fullBody,
            verticalCoverage: coverage,
            horizontalCenter: centerX
        )
    }

    /// Cheap mean luminance over a sparse BGRA pixel grid (no Core Image, no allocation).
    static func meanLuminance(_ pixelBuffer: CVPixelBuffer) -> Double {
        guard CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA else { return 0.5 }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer) else { return 0.5 }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let buffer = base.assumingMemoryBound(to: UInt8.self)

        let step = max(1, min(width, height) / 32)  // ~32x32 sample grid
        var total = 0.0
        var count = 0
        var y = 0
        while y < height {
            var x = 0
            while x < width {
                let offset = y * bytesPerRow + x * 4
                let b = Double(buffer[offset])
                let g = Double(buffer[offset + 1])
                let r = Double(buffer[offset + 2])
                total += (0.0722 * b + 0.7152 * g + 0.2126 * r) / 255
                count += 1
                x += step
            }
            y += step
        }
        return count > 0 ? total / Double(count) : 0.5
    }
}
