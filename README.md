# AuraFit

AuraFit is a fully local, on-device outfit and camera coach for iOS. Take or import a full-body
photo and AuraFit analyzes outfit signals, posture, color harmony, lighting, framing, and
"main character energy" — then generates a shareable **Fit Score** card and an optional 5-second
reveal clip. **No backend. No cloud inference. No analytics. No network calls. Nothing to buy —
every feature is free (DEC-006).**

> Built with SwiftUI, SwiftData, Vision, Core Image, and AVFoundation.
> iOS 18+ · iPhone portrait-first · dark-first design.

## Getting started

1. Open `AuraFit.xcodeproj` in Xcode 26.6 or a newer Apple-supported upload toolchain.
2. Select the **AuraFit** scheme and an iOS 18+ simulator or device.
3. Press **⌘B** to build, **⌘R** to run, **⌘U** to run tests.

The project uses Xcode's file-system–synchronized groups, so new files dropped into the
`AuraFit/` folder are picked up automatically — no `.pbxproj` edits required.

## Architecture

```
AuraFit/
├── App/              App entry, environment container, router, root tab view
├── Core/
│   ├── DesignSystem/ Colors, typography, spacing, reusable components
│   ├── Extensions/   Date/Color/UIImage/View helpers
│   └── Utilities/    Logger, haptics, share, permissions, statistics
├── Data/
│   ├── Models/       SwiftData @Model types + value types & enums
│   └── Persistence/  ModelContainer, file store, seed data, repository
├── Services/
│   ├── Camera/       AVFoundation capture, preview, photo picker
│   ├── Analysis/     Vision/Core Image/Core ML pipeline + scoring engine
│   ├── Export/       1080×1920 scorecard renderer, AVFoundation reveal video
└── Features/         Onboarding, Home, Scan, Results, History, Challenges, Settings
```

### Analysis pipeline

`AnalysisPipeline` is an `actor` that accepts a `UIImage` and returns a `FitAnalysisResult`:

1. **Normalize** — orientation + downscale.
2. **Pose** — `VNDetectHumanBodyPoseRequest` → posture, framing, full-body coverage.
3. **Segmentation** — `VNGeneratePersonSegmentationRequest` → subject fraction, background cleanliness.
4. **Quality** — Core Image area statistics → brightness, contrast, sharpness, exposure.
5. **Color** — palette extraction + color-theory harmony/cohesion scoring.
6. **Outfit** — `OutfitClassifierService` (drop-in Core ML wrapper with a heuristic fallback).
7. **Score** — `ScoreEngine` weighted blend:
   Outfit Cohesion 25% · Color Harmony 20% · Pose 15% · Lighting 15% · Framing 15% · Background 10%
   (Confidence Energy is a derived 7th metric shown but not weighted into the 100-point total).

Every subsystem degrades gracefully: if Vision/Core ML/camera are unavailable (e.g. Simulator),
the app falls back to neutral signals and heuristic classification, so it always compiles and runs.

### Dropping in real Core ML models

Add a compiled `OutfitClassifier.mlmodelc` to the app bundle. `OutfitClassifierService` loads it
automatically via `VNCoreMLModel` and maps its labels to `StylePersona`; until then it uses the
deterministic heuristic. No other code changes required.

## Pricing

AuraFit 1.0 is one full, free product: unlimited scans, all three scorecard styles, reveal
clips, and clean exports for everyone. There is no paywall, no StoreKit code, and no scan
quota; `FullFreeProductTests` and `scripts/release_candidate_check.sh` fail if any of that
vocabulary reappears in the app target. Monetization is deferred to a future version
(`docs/DECISIONS.md`, DEC-006).

## Privacy

All photos and analysis stay on-device. The app makes no network calls of its own. Generated
images/videos are written to the app's documents directory.

## Tests

`AuraFitTests` contains 93 unit/integration checks covering the score engine, color-harmony
math, file storage, analysis scoring (with mocked Vision signals), release configuration, the
full-free-product guard, statistics, and SwiftData. `AuraFitUITests` adds a deterministic
clean-install/import-to-result simulator smoke (94 tests total). Physical camera,
accessibility, signing, and App Store Connect checks remain manual release gates.

## TestFlight readiness

Start with `docs/TESTFLIGHT_READINESS.md` for the canonical 26-task execution backlog and
`docs/RELEASE_CHECKLIST.md` for sign-off. The repository is the source of truth; the Jira and
Notion import copy is `docs/mirrors/TESTFLIGHT_BACKLOG.csv`.
