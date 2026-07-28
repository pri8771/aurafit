# Project Status

## Lifecycle status

`mvp_development`

## Current objective

Prove one trustworthy outfit-analysis loop from camera or import through analysis,
result explanation, persistence, and shareable export before expanding premium scope.

## Verified

- The simulator test suite passed 50 tests during the 2026-07-23 audit.
- Onboarding, home, scan entry, privacy framing, and import fallback launch.
- Core scoring, persistence, entitlement, and export components exist.

## Verification pending

- Deterministic simulator scan-to-export smoke.
- Physical camera, Photos, permissions, low-quality input, and export QA.
- Analysis-claim review while the bundled classifier is absent.
- StoreKit sandbox, privacy manifest, App Store metadata, and device matrix.

## Blockers

- The full user-facing scan/import-to-export loop has not been verified.
- The current build uses a heuristic classifier fallback.
- No `PrivacyInfo.xcprivacy` was found during the audit.

## Next action

Complete `AURA-CORE-001`: create or identify a deterministic QA image route and
exercise import, analysis, results, history, and export without a camera dependency.
