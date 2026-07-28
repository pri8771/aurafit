// macOS CLI: inspects MobileCLIP CoreML models and precomputes label text embeddings.
// Usage: swift cliptool.swift <image.mlpackage> <text.mlpackage> <tokens.json> <out.json>
import CoreML
import Foundation

struct TokenFile: Codable {
    struct Entry: Codable { let group: String; let label: String; let prompt: String; let tokens: [Int] }
    let context_length: Int
    let labels: [Entry]
}

func describe(_ model: MLModel, name: String) {
    print("=== \(name) ===")
    for (k, v) in model.modelDescription.inputDescriptionsByName {
        print("  input \(k): \(v)")
    }
    for (k, v) in model.modelDescription.outputDescriptionsByName {
        print("  output \(k): \(v)")
    }
}

let args = CommandLine.arguments
guard args.count == 5 else { fatalError("usage: cliptool <image.mlpackage> <text.mlpackage> <tokens.json> <out.json>") }

let config = MLModelConfiguration()
config.computeUnits = .cpuOnly

let imageURL = try MLModel.compileModel(at: URL(fileURLWithPath: args[1]))
let imageModel = try MLModel(contentsOf: imageURL, configuration: config)
describe(imageModel, name: "image encoder")

let textURL = try MLModel.compileModel(at: URL(fileURLWithPath: args[2]))
let textModel = try MLModel(contentsOf: textURL, configuration: config)
describe(textModel, name: "text encoder")

let tokenData = try Data(contentsOf: URL(fileURLWithPath: args[3]))
let tokenFile = try JSONDecoder().decode(TokenFile.self, from: tokenData)

guard let inputName = textModel.modelDescription.inputDescriptionsByName.keys.first,
      let outputName = textModel.modelDescription.outputDescriptionsByName.keys.first else {
    fatalError("text encoder has no i/o")
}

// Run every prompt, L2-normalize each embedding, then average per (group, label) and re-normalize.
var sums: [String: [Double]] = [:]
var counts: [String: Int] = [:]
var order: [String] = []
var meta: [String: (group: String, label: String)] = [:]

for entry in tokenFile.labels {
    let arr = try MLMultiArray(shape: [1, NSNumber(value: tokenFile.context_length)], dataType: .int32)
    for (i, t) in entry.tokens.enumerated() { arr[i] = NSNumber(value: t) }
    let input = try MLDictionaryFeatureProvider(dictionary: [inputName: MLFeatureValue(multiArray: arr)])
    let result = try textModel.prediction(from: input)
    guard let emb = result.featureValue(for: outputName)?.multiArrayValue else { fatalError("no embedding") }
    var vec = (0..<emb.count).map { emb[$0].doubleValue }
    let norm = vec.reduce(0) { $0 + $1 * $1 }.squareRoot()
    vec = vec.map { $0 / norm }
    let key = "\(entry.group)|\(entry.label)"
    if sums[key] == nil { sums[key] = [Double](repeating: 0, count: vec.count); order.append(key); meta[key] = (entry.group, entry.label) }
    for i in 0..<vec.count { sums[key]![i] += vec[i] }
    counts[key, default: 0] += 1
}

struct OutLabel: Codable { let group: String; let label: String; let embedding: [Double] }
struct OutFile: Codable { let modelName: String; let dimension: Int; let labels: [OutLabel] }

var outLabels: [OutLabel] = []
for key in order {
    var avg = sums[key]!.map { $0 / Double(counts[key]!) }
    let norm = avg.reduce(0) { $0 + $1 * $1 }.squareRoot()
    avg = avg.map { $0 / norm }
    // Round to keep the JSON compact; 1e-5 precision is far below similarity noise.
    avg = avg.map { ($0 * 100000).rounded() / 100000 }
    let m = meta[key]!
    outLabels.append(OutLabel(group: m.group, label: m.label, embedding: avg))
}

let out = OutFile(modelName: "MobileCLIP-S0", dimension: outLabels.first?.embedding.count ?? 0, labels: outLabels)
let enc = JSONEncoder()
let data = try enc.encode(out)
try data.write(to: URL(fileURLWithPath: args[4]))
print("Wrote \(outLabels.count) label embeddings (dim \(out.dimension)) to \(args[4])")
