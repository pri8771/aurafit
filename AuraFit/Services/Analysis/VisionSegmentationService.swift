import Vision
import CoreImage
#if canImport(UIKit)
import UIKit
#endif

/// Seam for person-segmentation analysis so `AnalysisPipeline` can be driven by a stub.
/// Mirrors `OutfitClassifying`: the real implementation is `VisionSegmentationService`.
protocol SegmentationAnalyzing: Sendable {
    #if canImport(UIKit)
    func analyze(_ image: UIImage) -> SegmentationSignals
    #endif
}

/// Generates a person segmentation mask and derives subject-coverage & background-complexity
/// signals. Degrades to neutral signals if segmentation is unavailable.
struct VisionSegmentationService: SegmentationAnalyzing, @unchecked Sendable {

    private let context: CIContext

    init(context: CIContext = CIContext(options: [.cacheIntermediates: false])) {
        self.context = context
    }

    #if canImport(UIKit)
    func analyze(_ image: UIImage) -> SegmentationSignals {
        let normalized = image.normalizedOrientation()
        guard let cg = normalized.cgImage else { return .unavailable }
        return analyze(cgImage: cg)
    }
    #endif

    func analyze(cgImage: CGImage) -> SegmentationSignals {
        let request = VNGeneratePersonSegmentationRequest()
        request.qualityLevel = .balanced
        request.outputPixelFormat = kCVPixelFormatType_OneComponent8

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            AppLog.analysis.error("Segmentation failed: \(error.localizedDescription)")
            return .unavailable
        }

        guard let mask = request.results?.first?.pixelBuffer else {
            return .unavailable
        }

        let subjectFraction = foregroundFraction(mask)
        let backgroundComplexity = estimateBackgroundComplexity(cgImage: cgImage)

        return SegmentationSignals(
            available: true,
            subjectFraction: subjectFraction.clamped(to: 0...1),
            backgroundComplexity: backgroundComplexity.clamped(to: 0...1)
        )
    }

    /// Fraction of mask pixels considered foreground (subject).
    private func foregroundFraction(_ pixelBuffer: CVPixelBuffer) -> Double {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        guard let base = CVPixelBufferGetBaseAddress(pixelBuffer), width > 0, height > 0 else {
            return 0.4
        }
        let ptr = base.assumingMemoryBound(to: UInt8.self)

        var foreground = 0
        var total = 0
        // Subsample for performance.
        let step = max(1, min(width, height) / 96)
        var y = 0
        while y < height {
            var x = 0
            let row = ptr.advanced(by: y * bytesPerRow)
            while x < width {
                if row[x] > 128 { foreground += 1 }
                total += 1
                x += step
            }
            y += step
        }
        guard total > 0 else { return 0.4 }
        return Double(foreground) / Double(total)
    }

    /// Background complexity proxy: overall edge energy of the full image.
    /// (A clean studio background yields low edge energy.)
    private func estimateBackgroundComplexity(cgImage: CGImage) -> Double {
        let ciImage = CIImage(cgImage: cgImage)
        let edges = CIFilter(name: "CIEdges", parameters: [kCIInputImageKey: ciImage, "inputIntensity": 1.0])
        guard let edgeImage = edges?.outputImage else { return 0.5 }
        let avg = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: edgeImage,
            kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
        ])
        guard let output = avg?.outputImage else { return 0.5 }
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        let energy = (Double(bitmap[0]) + Double(bitmap[1]) + Double(bitmap[2])) / (3 * 255)
        return (energy * 5).clamped(to: 0...1)
    }
}
