import Foundation

/// Turns analysis signals (plus CLIP's photo-issue read, when available) into concrete
/// "take a better picture next time" guidance. Distinct from `TipsGenerator`, which coaches
/// the *outfit* — this coaches the *photograph*.
struct PhotoCoach: Sendable {

    /// Photo-technique tips, strongest problems first, at most `limit`.
    func tips(
        signals: AnalysisSignals,
        issues: CLIPZeroShotClassifier.PhotoIssueAssessment?,
        limit: Int = 3
    ) -> [String] {
        var tips: [String] = []

        func issueProbability(_ label: String) -> Double {
            issues?.issues[label] ?? 0
        }

        // Framing problems first — they cost the most score.
        if signals.pose.detected && !signals.pose.fullBodyVisible {
            tips.append("Frame head to shoes — prop the phone farther back or tilt it down so nothing gets cropped.")
        } else if issueProbability("face only") > 0.35 {
            tips.append("This reads as a close-up — step back so your whole outfit is in the shot.")
        }

        if signals.quality.brightness < 0.38 || issueProbability("too dark") > 0.35 {
            tips.append("Face your light source — a window or lamp in front of you, never behind you.")
        } else if signals.quality.brightness > 0.72 || issueProbability("overexposed") > 0.35 {
            tips.append("Step out of harsh direct light, or tap your face in the camera to pull exposure down.")
        }

        if signals.quality.sharpness < 0.35 || issueProbability("blurry") > 0.35 {
            tips.append("It's a little soft — lean the phone on something steady and use a timer instead of hand-holding.")
        }

        if signals.segmentation.available {
            if signals.segmentation.subjectFraction < 0.28 {
                tips.append("Come closer — you should fill roughly half the frame for the best read on your fit.")
            } else if signals.segmentation.subjectFraction > 0.65 {
                tips.append("Add breathing room — a step back keeps the whole silhouette and shoes in play.")
            }
        }

        if signals.pose.detected && signals.pose.horizontalCentering < 0.72 {
            tips.append("Shift toward the middle of the frame — centered shots score higher on composition.")
        }

        if signals.segmentation.available && signals.segmentation.backgroundComplexity > 0.7 {
            tips.append("Try a plainer backdrop — a clean wall keeps the attention on the outfit.")
        }

        return Array(tips.prefix(limit))
    }

    /// A specific, user-facing reason for refusing to score a photo, derived from CLIP's
    /// dominant issue. nil means "no specific story beyond the generic message".
    func rejectionDetail(issues: CLIPZeroShotClassifier.PhotoIssueAssessment?) -> String? {
        switch issues?.dominantIssue {
        case "no person":
            return "We couldn't find a person in this photo. Stand fully in frame and try again."
        case "face only":
            return "That looks like a close-up. Step back so your full outfit — head to shoes — is visible."
        case "blurry":
            return "The photo is too blurry to read. Steady the phone (or use a timer) and retake it."
        case "too dark":
            return "It's too dark to see your outfit. Find more light — facing a window works best."
        case "overexposed":
            return "The photo is washed out. Move out of direct glare and retake it."
        default:
            return nil
        }
    }
}
