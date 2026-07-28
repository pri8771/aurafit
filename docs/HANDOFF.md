# Handoff

## What the project is

AuraFit is a local-first iPhone outfit and camera coach that analyzes a full-body
photo, explains the result, and creates a shareable scorecard.

## Current state

The app and test foundation are substantial, but the user-facing core loop remains
`verification_pending`. It is not production-ready.

## Build and run

```bash
xcodebuild test \
  -project AuraFit.xcodeproj \
  -scheme AuraFit \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  -derivedDataPath /tmp/AuraFit-DerivedData \
  CODE_SIGNING_ALLOWED=NO
```

## Important constraints

- Preserve local photo processing and explicit user-initiated sharing.
- Do not present heuristic fallback as a capability of an absent model.
- Preserve existing uncommitted scan, result, export, and entitlement changes.
- Do not expand monetization before the first-result loop is verified.

## Known issues

See `docs/BUGS.md` and `docs/RISKS.md`.

## Next recommended task

`AURA-CORE-001`: establish a deterministic simulator fixture and report the exact
first complete import-to-export behavior before making broader changes.
