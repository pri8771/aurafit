# Test Plan

## Required suites

- Existing unit tests for scoring, color, persistence, entitlement logic, and export.
- Deterministic image fixtures spanning valid, dark, bright, cropped, no-person,
  multiple-person, and unsupported inputs.
- UI smoke from clean install through import, analysis, result, history, export,
  relaunch, and deletion.
- Physical camera and Photos permission grant/deny/revoke paths.
- Interrupted analysis/export, low storage, StoreKit offline/restore, and daily-limit cases.
- Supported phone sizes, Dynamic Type, VoiceOver, dark appearance, and long copy.

## Environment limitations

- Simulator cannot validate live camera quality.
- A passing heuristic test does not validate classifier product quality.
- App Store Connect purchases and privacy declarations require release configuration.
