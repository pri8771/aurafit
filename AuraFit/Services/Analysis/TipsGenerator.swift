import Foundation

/// Produces 3–5 actionable, friendly improvement tips ranked by the weakest metrics.
struct TipsGenerator: Sendable {

    func tips(for score: FitScore, signals: AnalysisSignals, persona: StylePersona) -> [String] {
        // Rank weighted metrics ascending (weakest first) for targeted advice.
        let ranked = score.metrics
            .filter { $0.kind.weight > 0 }
            .sorted { $0.value < $1.value }

        var tips: [String] = []
        for metric in ranked where tips.count < 4 {
            if metric.value >= 82 { continue }  // already strong — skip
            tips.append(tip(for: metric.kind, value: metric.value, signals: signals))
        }

        // Always include one persona-flavored, positive closer.
        tips.append(personaTip(persona))

        // Guarantee at least 3 tips even on a near-perfect fit.
        if tips.count < 3 {
            tips.append("Lock in this setup — same lighting and framing — to keep your scores high.")
        }
        return Array(tips.prefix(5))
    }

    private func tip(for kind: FitMetricKind, value: Int, signals: AnalysisSignals) -> String {
        switch kind {
        case .outfitCohesion:
            return "Tie the look together with one repeated element — a shared color, texture, or accessory across pieces."
        case .colorHarmony:
            if signals.color.palette.count > 4 {
                return "You're juggling a lot of colors. Drop to 2–3 main tones and let one be a neutral anchor."
            }
            return "Lean into a clear color story — analogous tones or one bold complementary pop reads as intentional."
        case .posePosture:
            return "Square your shoulders, lengthen your spine, and shift weight to one leg for a relaxed, confident stance."
        case .lighting:
            if signals.quality.brightness < 0.4 {
                return "It's a bit dark — face a window or add soft front light to bring out fabric detail."
            }
            if signals.quality.brightness > 0.7 {
                return "The shot's blown out — step out of direct light or lower exposure to recover detail."
            }
            return "Aim for soft, even light from the front to flatter both you and the fabric."
        case .framing:
            if !signals.pose.fullBodyVisible {
                return "Back up so your full body fits head-to-toe with a little breathing room around the edges."
            }
            return "Center yourself in the frame and leave even margins top and bottom for a balanced composition."
        case .backgroundCleanliness:
            return "Simplify the background — a clean wall or uncluttered space keeps the focus on your fit."
        case .confidenceEnergy:
            return "Own it — chin up, relaxed expression, and a stance that says the photo is about you."
        }
    }

    private func personaTip(_ persona: StylePersona) -> String {
        switch persona {
        case .streetwear: return "Streetwear edge: play with proportions — an oversized top over slim bottoms reads effortless."
        case .softLuxury: return "Soft luxury: let texture do the talking — knits, silk, and tonal layers elevate instantly."
        case .minimalist: return "Minimalist win: keep it clean, but add one quiet detail — a watch or a fold — for intention."
        case .sporty: return "Sporty energy: fresh sneakers and clean lines keep this look sharp and intentional."
        case .classic: return "Classic move: tailoring is everything — make sure shoulders and hems hit just right."
        case .bold: return "Bold & expressive: you've got the color — anchor it with one neutral so it pops, not clashes."
        case .cozy: return "Cozy done right: balance the relaxed fit with one structured piece to stay polished."
        case .undetermined: return "Your style is eclectic — pick one hero piece each fit and build the rest around it."
        }
    }
}
