import CoreImage
import CoreImage.CIFilterBuiltins
#if canImport(UIKit)
import UIKit
#endif

/// Estimates lighting & image-quality signals using Core Image area-statistics filters.
/// Falls back to neutral signals if the image cannot be processed.
struct ImageQualityService: @unchecked Sendable {

    private let context: CIContext

    init(context: CIContext = CIContext(options: [.cacheIntermediates: false])) {
        self.context = context
    }

    #if canImport(UIKit)
    func analyze(_ image: UIImage) -> QualitySignals {
        guard let ciImage = CIImage(image: image.normalizedOrientation()) else {
            return .neutral
        }
        return analyze(ciImage)
    }
    #endif

    func analyze(_ ciImage: CIImage) -> QualitySignals {
        let extent = ciImage.extent
        guard !extent.isInfinite, extent.width > 1, extent.height > 1 else {
            return .neutral
        }

        let avg = averageColor(ciImage, extent: extent)
        let brightness = luminance(avg)

        // Contrast: compare luminance of darkened-stretched min/max regions via histogram proxy.
        let contrast = estimateContrast(ciImage, extent: extent, meanLuma: brightness)
        let sharpness = estimateSharpness(ciImage, extent: extent)
        let exposureBalance = exposureBalanceScore(brightness: brightness)

        return QualitySignals(
            brightness: brightness.clamped(to: 0...1),
            contrast: contrast.clamped(to: 0...1),
            sharpness: sharpness.clamped(to: 0...1),
            exposureBalance: exposureBalance.clamped(to: 0...1)
        )
    }

    // MARK: - Primitives

    private func averageColor(_ image: CIImage, extent: CGRect) -> (r: Double, g: Double, b: Double) {
        let filter = CIFilter.areaAverage()
        filter.inputImage = image
        filter.extent = extent
        guard let output = filter.outputImage else { return (0.5, 0.5, 0.5) }
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        return (Double(bitmap[0]) / 255, Double(bitmap[1]) / 255, Double(bitmap[2]) / 255)
    }

    private func luminance(_ c: (r: Double, g: Double, b: Double)) -> Double {
        0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b
    }

    /// Estimates contrast by sampling average luminance of two halves and the global min/max
    /// approximation. Uses areaMinMax for a robust dynamic-range read.
    private func estimateContrast(_ image: CIImage, extent: CGRect, meanLuma: Double) -> Double {
        let filter = CIFilter.areaMinMaxRed()
        // areaMinMax operates per-channel; convert to grayscale first for a luminance read.
        let mono = CIFilter.colorControls()
        mono.inputImage = image
        mono.saturation = 0
        guard let grayImage = mono.outputImage else {
            return 0.5
        }
        let mm = CIFilter.areaMinMax()
        mm.inputImage = grayImage
        mm.extent = extent
        guard let output = mm.outputImage else { _ = filter; return 0.5 }
        var bitmap = [UInt8](repeating: 0, count: 8) // 2 pixels: min row, max row
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 8,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 2),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        let minV = Double(bitmap[0]) / 255
        let maxV = Double(bitmap[4]) / 255
        return (maxV - minV).clamped(to: 0...1)
    }

    /// Estimates sharpness via the variance of a Laplacian-like high-pass (Sobel) response.
    private func estimateSharpness(_ image: CIImage, extent: CGRect) -> Double {
        let edges = CIFilter.edges()
        edges.inputImage = image
        edges.intensity = 1.0
        guard let edgeImage = edges.outputImage else { return 0.5 }

        let avg = CIFilter.areaAverage()
        avg.inputImage = edgeImage
        avg.extent = extent
        guard let output = avg.outputImage else { return 0.5 }
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(output,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: CGColorSpaceCreateDeviceRGB())
        let edgeEnergy = (Double(bitmap[0]) + Double(bitmap[1]) + Double(bitmap[2])) / (3 * 255)
        // Map edge energy through a curve: very low => blurry, moderate => sharp.
        return (edgeEnergy * 4.5).clamped(to: 0...1)
    }

    /// Penalizes both under- and over-exposure; ideal luminance ~0.5.
    private func exposureBalanceScore(brightness: Double) -> Double {
        let distance = abs(brightness - 0.52)
        return (1 - distance * 1.7).clamped(to: 0...1)
    }
}
