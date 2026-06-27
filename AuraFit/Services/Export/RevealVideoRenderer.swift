import SwiftUI
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

/// Renders a ~5-second vertical "score reveal" video by animating `ScorecardView`'s
/// `revealProgress` and writing frames with `AVAssetWriter`.
@MainActor
struct RevealVideoRenderer {

    /// Output resolution (kept at 720×1280 to balance quality and render time).
    static let renderSize = CGSize(width: 720, height: 1280)
    static let duration: Double = 5.0
    static let fps: Int = 24

    enum RenderError: LocalizedError {
        case writerSetupFailed
        case frameRenderFailed
        case pixelBufferFailed
        case writeFailed(String)

        var errorDescription: String? {
            switch self {
            case .writerSetupFailed: return "Could not set up the video writer."
            case .frameRenderFailed: return "Could not render a video frame."
            case .pixelBufferFailed: return "Could not allocate video memory."
            case .writeFailed(let m): return "Video export failed: \(m)"
            }
        }
    }

    #if canImport(UIKit)
    /// Renders the reveal video and stores it, returning the relative documents path.
    func renderAndStore(model: ScorecardModel, store: ImageFileStore, name: String) async throws -> String {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("reveal-\(name).mp4")
        try? FileManager.default.removeItem(at: tempURL)

        try await render(model: model, to: tempURL)
        return try store.adoptFile(at: tempURL, folder: .reveals, fileName: "\(name).mp4")
    }

    /// Writes the animated reveal to `outputURL`.
    func render(model: ScorecardModel, to outputURL: URL) async throws {
        let size = Self.renderSize
        let writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        } catch {
            throw RenderError.writerSetupFailed
        }

        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(size.width),
            AVVideoHeightKey: Int(size.height)
        ]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        input.expectsMediaDataInRealTime = false

        let attrs: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
            kCVPixelBufferWidthKey as String: Int(size.width),
            kCVPixelBufferHeightKey as String: Int(size.height)
        ]
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: attrs)

        guard writer.canAdd(input) else { throw RenderError.writerSetupFailed }
        writer.add(input)

        guard writer.startWriting() else {
            throw RenderError.writeFailed(writer.error?.localizedDescription ?? "unknown")
        }
        writer.startSession(atSourceTime: .zero)

        let totalFrames = Int(Self.duration * Double(Self.fps))
        let timescale = CMTimeScale(Self.fps)

        for frame in 0..<totalFrames {
            let t = Double(frame) / Double(max(1, totalFrames - 1))
            let progress = Self.revealCurve(t)

            guard let pixelBuffer = try renderFrame(model: model, progress: progress, adaptor: adaptor, size: size) else {
                throw RenderError.frameRenderFailed
            }

            // Back-pressure: wait until the input is ready.
            while !input.isReadyForMoreMediaData {
                try await Task.sleep(for: .milliseconds(5))
            }
            let presentationTime = CMTime(value: CMTimeValue(frame), timescale: timescale)
            adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
        }

        input.markAsFinished()
        await writer.finishWriting()

        if writer.status == .failed {
            throw RenderError.writeFailed(writer.error?.localizedDescription ?? "unknown")
        }
    }

    /// Renders one SwiftUI frame to a pixel buffer.
    private func renderFrame(
        model: ScorecardModel,
        progress: Double,
        adaptor: AVAssetWriterInputPixelBufferAdaptor,
        size: CGSize
    ) throws -> CVPixelBuffer? {
        let view = ScorecardView(model: model, revealProgress: progress)
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = ProposedViewSize(ScorecardView.canvasSize)
        renderer.scale = size.width / ScorecardView.canvasSize.width
        guard let uiImage = renderer.uiImage, let cgImage = uiImage.cgImage else {
            throw RenderError.frameRenderFailed
        }

        guard let pool = adaptor.pixelBufferPool else { throw RenderError.pixelBufferFailed }
        var pixelBufferOut: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pixelBufferOut)
        guard status == kCVReturnSuccess, let pixelBuffer = pixelBufferOut else {
            throw RenderError.pixelBufferFailed
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            throw RenderError.pixelBufferFailed
        }

        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        return pixelBuffer
    }

    /// Easing curve: score counts up over the first ~70% then holds, with a gentle ease-out.
    static func revealCurve(_ t: Double) -> Double {
        let countUpEnd = 0.7
        if t >= countUpEnd { return 1.0 }
        let x = t / countUpEnd
        // ease-out cubic
        return 1 - pow(1 - x, 3)
    }
    #endif
}
