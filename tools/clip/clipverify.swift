// macOS CLI: encodes an image with the MobileCLIP image encoder and ranks label similarities.
// Usage: swift clipverify.swift <image.mlpackage> <LabelEmbeddings.json> <photo> [photo...]
import CoreML
import Foundation
import AppKit

struct OutLabel: Codable { let group: String; let label: String; let embedding: [Double] }
struct OutFile: Codable { let modelName: String; let dimension: Int; let labels: [OutLabel] }

let args = CommandLine.arguments
guard args.count >= 4 else { fatalError("usage: clipverify <image.mlpackage> <embeddings.json> <photo>...") }

let config = MLModelConfiguration()
config.computeUnits = .cpuOnly
let compiled = try MLModel.compileModel(at: URL(fileURLWithPath: args[1]))
let model = try MLModel(contentsOf: compiled, configuration: config)
let embFile = try JSONDecoder().decode(OutFile.self, from: Data(contentsOf: URL(fileURLWithPath: args[2])))

func pixelBuffer(from image: NSImage, side: Int) -> CVPixelBuffer {
    // Center-crop to square then scale to side x side.
    var rect = CGRect(origin: .zero, size: image.size)
    let cg = image.cgImage(forProposedRect: &rect, context: nil, hints: nil)!
    let w = cg.width, h = cg.height
    let edge = min(w, h)
    let cropped = cg.cropping(to: CGRect(x: (w - edge) / 2, y: (h - edge) / 2, width: edge, height: edge))!
    var pb: CVPixelBuffer?
    CVPixelBufferCreate(nil, side, side, kCVPixelFormatType_32BGRA, nil, &pb)
    let buf = pb!
    CVPixelBufferLockBaseAddress(buf, [])
    let ctx = CGContext(data: CVPixelBufferGetBaseAddress(buf), width: side, height: side,
                        bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buf),
                        space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)!
    ctx.interpolationQuality = .high
    ctx.draw(cropped, in: CGRect(x: 0, y: 0, width: side, height: side))
    CVPixelBufferUnlockBaseAddress(buf, [])
    return buf
}

for path in args.dropFirst(3) {
    guard let img = NSImage(contentsOfFile: path) else { print("cannot load \(path)"); continue }
    let pb = pixelBuffer(from: img, side: 256)
    let input = try MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(pixelBuffer: pb)])
    let out = try model.prediction(from: input)
    let emb = out.featureValue(for: "final_emb_1")!.multiArrayValue!
    var vec = (0..<emb.count).map { emb[$0].doubleValue }
    let norm = vec.reduce(0) { $0 + $1 * $1 }.squareRoot()
    vec = vec.map { $0 / norm }

    print("\n== \(path) ==")
    for group in ["persona", "garment"] {
        let labels = embFile.labels.filter { $0.group == group }
        let sims = labels.map { l in (l.label, zip(vec, l.embedding).reduce(0) { $0 + $1.0 * $1.1 }) }
        // Softmax with CLIP-style temperature 100 for readable probabilities.
        let exps = sims.map { exp($0.1 * 100) }
        let total = exps.reduce(0, +)
        let ranked = zip(sims, exps).map { ($0.0, $0.1, $1 / total) }.sorted { $0.2 > $1.2 }
        print("  [\(group)]")
        for (label, sim, prob) in ranked.prefix(5) {
            print(String(format: "    %-22@ sim=%.4f p=%.3f", label as NSString, sim, prob))
        }
    }
}
