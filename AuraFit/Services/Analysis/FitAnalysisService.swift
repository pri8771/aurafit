import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Observable facade that drives the analysis pipeline for the UI: it exposes the current
/// step and analyzing state, and returns the result. Owned by the Scan feature.
@MainActor
@Observable
final class FitAnalysisService {

    private(set) var currentStep: AnalysisStep = .normalizing
    private(set) var isAnalyzing: Bool = false
    private(set) var completedSteps: Set<AnalysisStep> = []

    private let pipeline: AnalysisPipeline

    init(pipeline: AnalysisPipeline = AnalysisPipeline()) {
        self.pipeline = pipeline
    }

    #if canImport(UIKit)
    /// Runs analysis end-to-end, updating `currentStep`/`completedSteps` for the progress UI.
    ///
    /// Throws `CancellationError` if the calling task is cancelled (the user tapped Cancel on the
    /// progress screen). Callers should `reset()` afterwards so a later run starts from step one.
    func analyze(_ image: UIImage, stepDelay: Duration = .milliseconds(420)) async throws -> FitAnalysisResult {
        isAnalyzing = true
        completedSteps = []
        currentStep = .normalizing
        defer { isAnalyzing = false }

        let result = try await pipeline.analyze(image: image, stepDelay: stepDelay) { [weak self] step in
            guard let self else { return }
            // Mark the previous step complete as we advance.
            if let previous = AnalysisStep(rawValue: step.rawValue - 1) {
                self.completedSteps.insert(previous)
            }
            self.currentStep = step
        }
        // Mark all complete.
        completedSteps = Set(AnalysisStep.allCases)
        return result
    }
    #endif

    func reset() {
        currentStep = .normalizing
        completedSteps = []
        isAnalyzing = false
    }
}
