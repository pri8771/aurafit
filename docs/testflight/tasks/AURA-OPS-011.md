---
id: AURA-OPS-011
title: Freeze release identity and beta scope
gate: TF-G1
status: done
ownerBoundary: Owner + agent
dependsOn: [AURA-OPS-010]
evidence: quality/evidence/testflight/AURA-OPS-011/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-011 — Freeze release identity and beta scope

## Task description

This task fixes one release tuple and one beta scope so all later testing, archive, and upload evidence refers to the same binary. We query Apple for used builds, select an unused build, verify Xcode Release settings, and prohibit feature additions because Apple rejects reused build strings and changing scope invalidates evidence. The expected result is a documented `com.pchordia.aurafit`/version/build/commit candidate shared by build settings and `docs/STATUS.md`.

## Preconditions and inputs

- AURA-OPS-010 evidence confirms the correct App Store Connect record.
- App Store Connect access to inspect version `1.0` builds.
- `OWNER_REQUIRED_BETA_VERSION_CHANGE` only if marketing version should not remain `1.0`.

## Subtasks

### AURA-OPS-011-ST-01 — Query existing version 1.0 builds

Query App Store Connect before choosing a build because every build Apple has received is permanently unavailable for reuse. In App Store Connect → Apps → AuraFit → TestFlight → iOS Builds, list the highest build associated with version `1.0`. Expected result: evidence names the highest used integer or explicitly records no uploaded builds.

**Execution**

1. Open the exact AuraFit app record → TestFlight → iOS Builds; filter/version-search `1.0`.
2. Record build numbers and states, then identify the maximum positive integer; do not infer from local project files.

**Expected result and evidence:** Apple query time, version, observed build list, and highest build are recorded.

**Failure handling:** Cannot query is `blocked_external`; do not select a build number.

### AURA-OPS-011-ST-02 — Select the next unused build number

Select `CURRENT_PROJECT_VERSION` as the next unused positive integer to create a unique candidate. Build `1` is allowed only when ST-01 proves Apple never received `1.0 (1)`. Expected result: a single owner/agent-approved candidate build is recorded.

**Execution**

1. Set proposed build to highest observed build + 1, or `1` only for an empty Apple history.
2. Recheck that proposed tuple is absent in App Store Connect and record `OWNER_REQUIRED_RELEASE_BUILD` if an owner needs to select a different unused integer.

**Expected result and evidence:** Proposed and verified-unused build number are documented.

**Failure handling:** Existing tuple is `blocked_external`; return to ST-01 and choose another verified-unused integer.

### AURA-OPS-011-ST-03 — Confirm marketing version

Keep `MARKETING_VERSION=1.0` unless the owner deliberately changes beta version, avoiding accidental version-line fragmentation. Expected result: Release settings and evidence show `1.0` or an explicit owner-approved alternative.

**Execution**

1. Require `OWNER_REQUIRED_BETA_VERSION_CHANGE` before using any value other than `1.0`.
2. From repository root run `xcodebuild -showBuildSettings -project AuraFit.xcodeproj -scheme AuraFit -configuration Release > /tmp/AURA-OPS-011-settings.txt`; require exit 0; record `MARKETING_VERSION`.

**Expected result and evidence:** Version value and settings artifact path are recorded.

**Failure handling:** Missing/incorrect value is `source_failure` until project settings are changed under the approved candidate decision.

### AURA-OPS-011-ST-04 — Record the release tuple

Record all immutable candidate details so downstream evidence can be compared exactly. Expected result: bundle ID, version, build, commit SHA, branch, Xcode version, minimum OS, device family, and intended `TF-G2`/`TF-G3` gates are in the evidence index.

**Execution**

1. Run from repository root: `git rev-parse HEAD`, `git branch --show-current`, and `xcodebuild -version`; all must exit 0.
2. Read required settings from `/tmp/AURA-OPS-011-settings.txt`, then create/update the task evidence with date/time zone and operator role.

**Expected result and evidence:** One release tuple is present and internally consistent.

**Failure handling:** Unknown/contradictory value is `verification_pending`; do not archive.

### AURA-OPS-011-ST-05 — Freeze beta feature scope

Freeze feature scope to ensure the tested candidate cannot silently acquire new behavior. Expected result: the release note states that only release blockers and required-QA fixes may change the candidate; all feature requests are deferred.

**Execution**

1. Record scope rule and intended gates in task evidence and candidate status note.
2. For each proposed change after freeze, classify it as required release-blocker fix or deferred feature; require owner approval for exceptions.

**Expected result and evidence:** Scope decision and any exception are recorded.

**Failure handling:** Undecided new feature is `human_review_required`; stop its inclusion in the candidate.

### AURA-OPS-011-ST-06 — Align project, tests, and status after a build change

When the build changes, update every asserted release identity so release evidence does not disagree with the binary. Expected result: Release settings, version/build tests, evidence, and `docs/STATUS.md` agree; test-target bundle IDs remain untouched.

**Execution**

1. If build changes, update only approved project version/build fields and tests that assert them; do not alter test-target bundle IDs.
2. Rerun the Release settings command, update task evidence and `docs/STATUS.md`, then compare all tuple fields.

**Expected result and evidence:** Matching tuple values and changed-file list are recorded.

**Failure handling:** Any mismatch is `source_failure`; stop later gates until aligned.

## Acceptance criteria

- [ ] Build number is verified unused in App Store Connect.
- [ ] Release tuple is documented under the evidence path.
- [ ] Release build settings report expected tuple.
- [ ] `docs/STATUS.md` names the same candidate.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-011/README.md`.

## Stop and reverification conditions

Stop if App Store Connect cannot be queried or the tuple is used. Any version/build, commit, scope, deployment target, or device-family change invalidates later candidate evidence.
