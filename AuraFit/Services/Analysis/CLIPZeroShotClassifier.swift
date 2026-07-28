import CoreML
import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Zero-shot outfit classification using a bundled MobileCLIP-S0 image encoder
/// (Apple, `apple/coreml-mobileclip`) and precomputed text-label embeddings.
///
/// The image is embedded on device; persona and garment labels were embedded
/// offline with the matching MobileCLIP-S0 text encoder and ship as
/// `CLIPLabelEmbeddings.json`. Classification is cosine similarity in the shared
/// embedding space, so confidences are real model outputs — unlike the heuristic
/// fallback, which cannot see garments at all.
struct CLIPZeroShotClassifier {

    static let modelResourceName = "MobileCLIPImageEncoder"
    static let embeddingsResourceName = "CLIPLabelEmbeddings"
    /// MobileCLIP-S0 input resolution.
    private static let inputSide = 256
    /// CLIP-style softmax temperature (the standard learned logit scale ~100).
    private static let logitScale = 100.0

    struct LabelEmbedding: Decodable {
        let group: String
        let label: String
        let embedding: [Double]
    }

    private struct EmbeddingsFile: Decodable {
        let modelName: String
        let dimension: Int
        let labels: [LabelEmbedding]
    }

    private let model: MLModel
    private let personaLabels: [LabelEmbedding]
    private let garmentLabels: [LabelEmbedding]
    private let issueLabels: [LabelEmbedding]

    /// Fails (returns nil) when the encoder or embeddings are not bundled, so the
    /// caller can fall back to other classification paths.
    init?(bundle: Bundle = .main) {
        guard let modelURL = bundle.url(forResource: Self.modelResourceName, withExtension: "mlmodelc"),
              let embeddingsURL = bundle.url(forResource: Self.embeddingsResourceName, withExtension: "json") else {
            AppLog.analysis.info("MobileCLIP encoder or label embeddings not bundled; zero-shot classifier unavailable.")
            return nil
        }
        do {
            let configuration = MLModelConfiguration()
            self.model = try MLModel(contentsOf: modelURL, configuration: configuration)
            let file = try JSONDecoder().decode(EmbeddingsFile.self, from: Data(contentsOf: embeddingsURL))
            self.personaLabels = file.labels.filter { $0.group == "persona" }
            self.garmentLabels = file.labels.filter { $0.group == "garment" }
            self.issueLabels = file.labels.filter { $0.group == "photoIssue" }
            guard !personaLabels.isEmpty else { return nil }
            AppLog.analysis.info("Loaded MobileCLIP zero-shot classifier (\(file.modelName), \(file.labels.count) labels).")
        } catch {
            AppLog.analysis.error("Failed to load MobileCLIP classifier: \(error.localizedDescription)")
            return nil
        }
    }

    /// CLIP's read on whether the photo itself has a capture problem. Probabilities are a
    /// softmax across all photo-issue labels (including the "good photo" anchor), so a high
    /// value means the issue dominates the other interpretations of the shot.
    struct PhotoIssueAssessment: Sendable, Equatable {
        /// Probability that the best description is "a well-lit sharp full-body outfit photo".
        var goodPhoto: Double
        /// Issue label → probability, sorted handling left to callers.
        var issues: [String: Double]

        /// The single most likely issue when it beats the good-photo anchor decisively.
        var dominantIssue: String? {
            guard let top = issues.max(by: { $0.value < $1.value }) else { return nil }
            return top.value > goodPhoto && top.value > 0.4 ? top.key : nil
        }
    }

    #if canImport(UIKit)
    /// Returns outfit signals for the image, or nil if encoding fails.
    /// When pose found a person, classification uses a padded crop around them so the
    /// outfit — not the background — dominates the embedding.
    func classify(image: UIImage, colors: ColorSignals, pose: PoseSignals = .unavailable) -> OutfitSignals? {
        let outfitRegion = Self.personCrop(from: image, boundingBox: pose.detected ? pose.boundingBox : nil)
        guard let embedding = imageEmbedding(for: outfitRegion) else { return nil }

        let personaRanking = ranked(labels: personaLabels, against: embedding)
        let garmentRanking = ranked(labels: garmentLabels, against: embedding)
        guard let topPersona = personaRanking.first else { return nil }

        let persona = StylePersona(rawValue: topPersona.label) ?? OutfitClassifierService.persona(fromLabel: topPersona.label)

        var tags: [OutfitTag] = [OutfitTag(label: topPersona.label, confidence: topPersona.probability)]
        for garment in garmentRanking.prefix(3) where garment.probability > 0.05 {
            tags.append(OutfitTag(label: garment.label, confidence: garment.probability))
        }

        // CLIP judges style identity, not palette discipline — cohesion stays with
        // the color analysis, matching the other classification paths.
        let cohesion = (colors.cohesion * 0.7 + colors.harmony * 0.3).clamped(to: 0...1)

        return OutfitSignals(cohesion: cohesion, persona: persona, tags: tags, usedModel: true)
    }

    /// Evaluates the photo-issue label group against the FULL frame (issues like "no person"
    /// or "too dark" are frame-level judgments, so no person crop here). Returns nil when the
    /// embeddings asset predates the photoIssue group or encoding fails.
    func assessPhotoIssues(image: UIImage) -> PhotoIssueAssessment? {
        guard !issueLabels.isEmpty, let embedding = imageEmbedding(for: image) else { return nil }
        let ranking = ranked(labels: issueLabels, against: embedding)
        var good = 0.0
        var issues: [String: Double] = [:]
        for entry in ranking {
            if entry.label == Self.goodPhotoLabel {
                good = entry.probability
            } else {
                issues[entry.label] = entry.probability
            }
        }
        return PhotoIssueAssessment(goodPhoto: good, issues: issues)
    }

    /// Label name of the positive anchor in the photoIssue group.
    static let goodPhotoLabel = "good photo"

    /// Crops to a padded person box (15% horizontal, 8% vertical padding) or center-square
    /// falls through when there is no usable box.
    static func personCrop(from image: UIImage, boundingBox: CGRect?) -> UIImage {
        guard let box = boundingBox, box.width > 0.05, box.height > 0.1,
              let cg = image.normalizedOrientation().cgImage else {
            return image
        }
        let width = Double(cg.width)
        let height = Double(cg.height)
        let padX = box.width * 0.15
        let padY = box.height * 0.08
        let padded = CGRect(
            x: ((box.minX - padX) * width).rounded(.down),
            y: ((box.minY - padY) * height).rounded(.down),
            width: ((box.width + padX * 2) * width).rounded(.up),
            height: ((box.height + padY * 2) * height).rounded(.up)
        ).intersection(CGRect(x: 0, y: 0, width: width, height: height))
        guard padded.width > 32, padded.height > 32, let cropped = cg.cropping(to: padded) else {
            return image
        }
        return UIImage(cgImage: cropped)
    }

    // MARK: - Encoding

    private func imageEmbedding(for image: UIImage) -> [Double]? {
        guard let pixelBuffer = Self.centerCroppedPixelBuffer(from: image, side: Self.inputSide) else {
            AppLog.analysis.error("MobileCLIP: could not prepare pixel buffer.")
            return nil
        }
        do {
            let input = try MLDictionaryFeatureProvider(
                dictionary: ["image": MLFeatureValue(pixelBuffer: pixelBuffer)]
            )
            let output = try model.prediction(from: input)
            guard let array = output.featureValue(for: "final_emb_1")?.multiArrayValue else { return nil }
            var vector = (0..<array.count).map { array[$0].doubleValue }
            let norm = vector.reduce(0) { $0 + $1 * $1 }.squareRoot()
            guard norm > 0 else { return nil }
            vector = vector.map { $0 / norm }
            return vector
        } catch {
            AppLog.analysis.error("MobileCLIP inference failed: \(error.localizedDescription)")
            return nil
        }
    }

    private struct RankedLabel {
        let label: String
        let similarity: Double
        let probability: Double
    }

    /// Cosine similarity against each label, softmaxed into probabilities.
    private func ranked(labels: [LabelEmbedding], against embedding: [Double]) -> [RankedLabel] {
        let similarities = labels.map { label in
            (label.label, zip(embedding, label.embedding).reduce(0) { $0 + $1.0 * $1.1 })
        }
        guard let maxSim = similarities.map(\.1).max() else { return [] }
        // Subtract the max before exponentiating for numeric stability.
        let exps = similarities.map { exp(($0.1 - maxSim) * Self.logitScale) }
        let total = exps.reduce(0, +)
        return zip(similarities, exps)
            .map { RankedLabel(label: $0.0, similarity: $0.1, probability: $1 / total) }
            .sorted { $0.probability > $1.probability }
    }

    /// Center-crops to a square and scales to `side` x `side` in a BGRA pixel buffer.
    static func centerCroppedPixelBuffer(from image: UIImage, side: Int) -> CVPixelBuffer? {
        guard let cg = image.normalizedOrientation().cgImage else { return nil }
        let width = cg.width
        let height = cg.height
        let edge = min(width, height)
        let cropRect = CGRect(x: (width - edge) / 2, y: (height - edge) / 2, width: edge, height: edge)
        guard let cropped = cg.cropping(to: cropRect) else { return nil }

        var buffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: true,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: true] as CFDictionary
        CVPixelBufferCreate(nil, side, side, kCVPixelFormatType_32BGRA, attrs, &buffer)
        guard let pixelBuffer = buffer else { return nil }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: side,
            height: side,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        ) else { return nil }
        context.interpolationQuality = .high
        context.draw(cropped, in: CGRect(x: 0, y: 0, width: side, height: side))
        return pixelBuffer
    }
    #endif
}
