import SwiftUI
import CoreImage
#if canImport(UIKit)
import UIKit
#endif

/// Extracts a dominant color palette and evaluates color harmony & cohesion.
///
/// The harmony model is a lightweight approximation of classic color-theory relationships
/// (monochromatic, analogous, complementary, triadic). It is fully deterministic and unit-tested.
struct ColorHarmonyService: @unchecked Sendable {

    private let context: CIContext

    init(context: CIContext = CIContext(options: [.cacheIntermediates: false])) {
        self.context = context
    }

    // MARK: - Public API

    #if canImport(UIKit)
    /// Analyzes an image, returning palette + harmony signals.
    func analyze(_ image: UIImage, maxColors: Int = 5) -> ColorSignals {
        let palette = extractPalette(image, maxColors: maxColors)
        return evaluate(palette: palette)
    }

    /// Extracts up to `maxColors` representative colors by quantizing into a small grid and
    /// counting bucket populations. Pure CPU, no Core ML required.
    func extractPalette(_ image: UIImage, maxColors: Int = 5) -> [RGBColor] {
        guard let cg = image.normalizedOrientation().cgImage else { return [] }
        let width = 48
        let height = 48
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        guard let colorSpace = cg.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB),
              let ctx = CGContext(
                data: &pixels,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              )
        else {
            _ = colorSpace
            return []
        }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Quantize into 4 levels per channel (64 buckets) and accumulate average color.
        struct Bucket { var count = 0; var r = 0.0; var g = 0.0; var b = 0.0 }
        var buckets: [Int: Bucket] = [:]
        let levels = 4
        for i in stride(from: 0, to: pixels.count, by: bytesPerPixel) {
            let a = Double(pixels[i + 3]) / 255
            if a < 0.4 { continue }
            let r = Double(pixels[i]) / 255
            let g = Double(pixels[i + 1]) / 255
            let b = Double(pixels[i + 2]) / 255
            // Skip near-pure background extremes lightly to bias toward garment colors.
            let key = (Int(r * Double(levels - 1)) * levels * levels)
                + (Int(g * Double(levels - 1)) * levels)
                + Int(b * Double(levels - 1))
            var bucket = buckets[key] ?? Bucket()
            bucket.count += 1
            bucket.r += r; bucket.g += g; bucket.b += b
            buckets[key] = bucket
        }

        let sorted = buckets.values.sorted { $0.count > $1.count }
        return sorted.prefix(maxColors).map { bucket in
            RGBColor(bucket.r / Double(bucket.count),
                     bucket.g / Double(bucket.count),
                     bucket.b / Double(bucket.count))
        }
    }
    #endif

    // MARK: - Harmony evaluation (pure, testable)

    /// Evaluates harmony & cohesion of a palette. Returns neutral values for empty palettes.
    func evaluate(palette: [RGBColor]) -> ColorSignals {
        guard palette.count >= 2 else {
            return ColorSignals(palette: palette, harmony: 0.6, cohesion: 0.7)
        }

        let hsbs = palette.map { $0.hsb }
        let saturated = hsbs.filter { $0.s > 0.15 }   // ignore near-grays for hue relationships

        let harmony = harmonyScore(hsbs: hsbs, saturated: saturated)
        let cohesion = cohesionScore(hsbs: hsbs)

        return ColorSignals(palette: palette, harmony: harmony, cohesion: cohesion)
    }

    /// Harmony: rewards palettes whose hues fall into recognized relationships and whose
    /// neutrals (low saturation) anchor the look.
    func harmonyScore(hsbs: [(h: Double, s: Double, b: Double)], saturated: [(h: Double, s: Double, b: Double)]) -> Double {
        // Neutral-heavy palettes (mostly grays/black/white) read as harmonious.
        let neutralFraction = Double(hsbs.count - saturated.count) / Double(hsbs.count)
        if saturated.count <= 1 {
            return (0.78 + 0.2 * neutralFraction).clamped(to: 0...1)
        }

        // Compute pairwise hue distances on the color wheel.
        var relationshipBonus = 0.0
        var comparisons = 0
        for i in 0..<saturated.count {
            for j in (i + 1)..<saturated.count {
                let d = hueDistance(saturated[i].h, saturated[j].h)  // 0...0.5
                comparisons += 1
                relationshipBonus += relationshipReward(forHueDistance: d)
            }
        }
        let avgRelationship = comparisons > 0 ? relationshipBonus / Double(comparisons) : 0.6

        // Penalize too many strongly saturated competing hues.
        let strongHues = saturated.filter { $0.s > 0.45 }.count
        let overloadPenalty = strongHues > 3 ? Double(strongHues - 3) * 0.08 : 0

        let score = avgRelationship + 0.12 * neutralFraction - overloadPenalty
        return score.clamped(to: 0...1)
    }

    /// Cohesion: rewards consistent saturation/brightness (a deliberate tonal story).
    func cohesionScore(hsbs: [(h: Double, s: Double, b: Double)]) -> Double {
        let sats = hsbs.map(\.s)
        let brts = hsbs.map(\.b)
        let satSpread = standardDeviation(sats)
        let brtSpread = standardDeviation(brts)
        // Lower spread => higher cohesion.
        let score = 1.0 - (satSpread * 0.6 + brtSpread * 0.6)
        return score.clamped(to: 0...1)
    }

    // MARK: - Helpers

    /// Reward curve for a hue distance (0 = identical, 0.5 = opposite).
    private func relationshipReward(forHueDistance d: Double) -> Double {
        // Targets: monochromatic/analogous (~0...0.12), triadic (~0.33), complementary (~0.5).
        let targets: [(center: Double, reward: Double, width: Double)] = [
            (0.02, 0.95, 0.06),  // monochromatic
            (0.09, 0.90, 0.07),  // analogous
            (0.33, 0.85, 0.07),  // triadic
            (0.50, 0.88, 0.07)   // complementary
        ]
        var best = 0.45  // baseline for "no clean relationship"
        for t in targets {
            let proximity = max(0, 1 - abs(d - t.center) / t.width)
            best = max(best, t.reward * proximity + 0.45 * (1 - proximity))
        }
        return best
    }

    /// Shortest distance between two hues on the [0,1) wheel, range 0...0.5.
    func hueDistance(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b).truncatingRemainder(dividingBy: 1.0)
        return min(diff, 1 - diff)
    }

    func standardDeviation(_ values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let variance = values.reduce(0) { $0 + ($1 - mean) * ($1 - mean) } / Double(values.count)
        return variance.squareRoot()
    }
}
