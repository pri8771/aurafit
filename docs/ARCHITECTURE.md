# Architecture

## Current architecture

AuraFit is a native SwiftUI/SwiftData application. Feature views call an
`AnalysisPipeline` actor that normalizes images and coordinates Vision, Core
Image, optional Core ML classification, and the score engine. Results and settings
persist locally. Export services produce scorecards and reveal media. There is no
store, entitlement, or quota layer: every capability is available to every user
(DEC-006).

## Data flow

```text
Camera or Photos -> image normalization -> Vision/Core Image/Core ML signals
-> score engine -> explainable result -> SwiftData/history -> image/video export
```

## Persistence

- SwiftData stores app models and settings; generated media uses local files.
- Photos remain on-device unless the user invokes the system share flow.
- Deletion, relaunch restoration, and migration require release evidence.

## External dependencies

- Apple Vision, Core ML, Core Image, AVFoundation, and SwiftData.
- No required backend or third-party runtime package.
- The intended production classifier model is not currently bundled.

## Known architectural risks

- Heuristic fallback can be mistaken for learned outfit classification.
- Camera and media workflows have significant physical-device-only behavior.
- Large media generation and interrupted export require recovery testing.
