# AuraFit

AuraFit is a fully local, on-device AI outfit & camera coach for iOS. Take or import a full-body
photo and AuraFit analyzes outfit quality, posture, color harmony, lighting, framing, and
"main character energy" — then generates a shareable **Fit Score** card and an optional 5-second
reveal clip. **No backend. No cloud inference. No analytics. No network calls except StoreKit.**

> Built with SwiftUI, SwiftData, Vision, Core ML, Core Image, AVFoundation, and StoreKit 2.
> iOS 18+ · iPhone portrait-first · dark-first design.

## Getting started

1. Open `AuraFit.xcodeproj` in Xcode 16 (current stable).
2. Select the **AuraFit** scheme and an iOS 18+ simulator or device.
3. Press **⌘B** to build, **⌘R** to run, **⌘U** to run tests.

The project uses Xcode's file-system–synchronized groups, so new files dropped into the
`AuraFit/` folder are picked up automatically — no `.pbxproj` edits required.

StoreKit testing is pre-wired: the scheme references `AuraFit/Resources/AuraFit.storekit`, so
purchases work in the simulator without an App Store Connect setup.

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
│   └── Store/        StoreKit 2 service, entitlements, product catalog
└── Features/         Onboarding, Home, Scan, Results, History, Challenges, Paywall, Settings
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

## Monetization

- **Free:** 3 scans/day, watermarked exports.
- **Pro** (`com.aurafit.pro.monthly` / `com.aurafit.pro.yearly`): unlimited scans, no watermark,
  reveal videos, all templates.
- **Template packs** (`com.aurafit.template.streetwear` / `...softluxury`): one-time unlocks.

Entitlements are derived from `Transaction.currentEntitlements` (StoreKit 2) via
`EntitlementManager`, which also enforces the daily free-scan gate against persisted `AppSettings`.

## Privacy

All photos and analysis stay on-device. The app makes no network calls other than the StoreKit /
App Store purchase flow. Generated images/videos are written to the app's documents directory.

## Tests

`AuraFitTests` covers the score engine, color-harmony math, file storage, StoreKit entitlement
logic (with mocks), the analysis scoring path (with mocked Vision signals), statistics, and the
SwiftData models/repository.
