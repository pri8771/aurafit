# AURA-OPS-011 evidence — release identity freeze runbook

- **2026-08-18 (later) update:** `1.0 (3)` was uploaded and submitted for App Review the same
  day; the tuple is now consumed. Builds 1 and 2 remain in App Store Connect unused. Next build
  must be `≥ 4`. Record: `quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md`.

- **2026-08-18 update:** builds `1` and `2` are consumed in App Store Connect; the owner's
  DEC-006 decision (one full, free product) fixed the next candidate at `1.0 (3)` and
  `CURRENT_PROJECT_VERSION` was bumped to `3` in both configurations. Beta scope for build 3:
  no in-app purchases. See `quality/evidence/release/1.0-3-full-free/README.md`.

- Status: `blocked_external`; App Store Connect build history is required before a build can be frozen.
- Current local, unapproved values: bundle `com.pchordia.aurafit`, marketing version `1.0`, build `1`, min OS `18.0`, iPhone family `1`; HEAD observed during runbook preparation: `0f48aa22ea1cea7d8a33ba5bceea0926c055e120` on `claude/phase0-production-readiness`. These facts are not a frozen candidate.
- Owner input: `OWNER_REQUIRED_BETA_VERSION_CHANGE` only if version differs from 1.0; `OWNER_REQUIRED_RELEASE_BUILD` only if owner selects a different verified-unused integer.

## Subtask checklist

- [ ] `AURA-OPS-011-ST-01` — ASC → Apps → AuraFit → TestFlight → iOS Builds, filter `1.0`; record query time, every observed integer/state, and highest positive integer (or explicit no-uploaded-builds). Local project value is never evidence of Apple availability.
- [ ] `AURA-OPS-011-ST-02` — Propose highest + 1; use `1` only when ST-01 proves empty history. Recheck exact version/build absence in ASC and record it. Existing tuple: return to ST-01; do not reuse it.
- [ ] `AURA-OPS-011-ST-03` — Unless owner provides a version-change decision, require `MARKETING_VERSION=1.0`. Run from root: `xcodebuild -showBuildSettings -project AuraFit.xcodeproj -scheme AuraFit -configuration Release > /tmp/AURA-OPS-011-settings.txt`; record exit and MARKETING_VERSION. Incorrect setting: source failure.
- [ ] `AURA-OPS-011-ST-04` — After ST-02/03, record one tuple: bundle/version/build/commit/branch/Xcode/min-OS/device-family/intended TF-G2 and TF-G3 gates. Obtain `git rev-parse HEAD`, `git branch --show-current`, `xcodebuild -version`, and settings output. Contradiction: `verification_pending`; do not archive.
- [ ] `AURA-OPS-011-ST-05` — Owner records freeze rule: only release blockers/required-QA fixes may change this candidate; all new features defer. Each exception needs owner approval and must be listed.
- [ ] `AURA-OPS-011-ST-06` — If version/build changes, update approved project fields and identity tests only (never test-target bundle IDs), rerun settings, then have the shared-status owner update STATUS. Any tuple mismatch blocks later gates.

```text
ASC query time / observed builds / highest:
verified-unused proposed version/build:
approved version-change decision:
commit / branch / Xcode:
min OS / device family / intended gates:
scope rule and exceptions:
changed files and post-change settings path:
```

Any version, build, commit, scope, deployment-target, or device-family change invalidates this record and later archive/upload evidence.
