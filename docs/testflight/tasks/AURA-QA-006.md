---
id: AURA-QA-006
title: Internal TestFlight distribution and smoke
gate: TF-G2
status: blocked_external
ownerBoundary: Owner + internal tester
dependsOn: [AURA-OPS-013]
evidence: quality/evidence/testflight/AURA-QA-006/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-006 — Internal TestFlight distribution and smoke

## Task description

This task verifies the App Store-processed and thinned TestFlight build on a real iPhone, rather than treating a local archive as distribution proof. It is necessary because processing, StoreKit sandbox, and installed artifact behavior can differ from development. After `AURA-OPS-013` clears processing, distribute to an eligible internal tester, run the seven steps in order, and record redacted group/build/tester-role/device/version/expected/actual/crash evidence; the expected change is a passed internal smoke and `TF-G2` advancement, or a precise external blocker/defect.

## Preconditions and inputs

- `AURA-OPS-013` evidence identifies a processed build with no action-required status.
- Authorized App Store Connect role; at least one account user with app access; a physical iPhone with TestFlight.
- `OWNER_REQUIRED_WHAT_TO_TEST_COPY` is approved; evidence lives in `quality/evidence/testflight/AURA-QA-006/README.md`.
- Never commit tester names/emails, TestFlight links, receipts, or account data.

## Subtasks

### AURA-QA-006-ST-01 — Create or confirm the internal group

This establishes the controlled distribution group required for internal testing and later external-group prerequisites. In App Store Connect → Apps → AuraFit → TestFlight → Internal Testing, create `AuraFit Internal` unless an owner-approved group already exists. Expect one approved internal group and a redacted group identifier/name in evidence; do not duplicate an existing approved group.

**Execution**

1. Use an authorized App Store Connect role and navigate to the TestFlight Internal Testing area.
2. Search for an owner-approved group; otherwise create exactly `AuraFit Internal` and record group settings without member personal data.

**Expected result and evidence:** One usable internal group is recorded.

**Failure handling:** Missing App Store Connect role is `blocked_external`; stop before creating substitute groups.

### AURA-QA-006-ST-02 — Add an eligible internal tester

This confirms testing is performed by a genuine internal App Store Connect user, not an external person incorrectly added as internal. Verify the selected person is an account user with AuraFit app access, add them to the group, and record only tester role/count and invitation state. Expect at least one eligible tester; do not expose identity in repository evidence.

**Execution**

1. In Users and Access, confirm `OWNER_REQUIRED_INTERNAL_TESTER` has required account/app access.
2. Add the eligible account user to AuraFit Internal and record redacted role, count, and invite state.

**Expected result and evidence:** At least one eligible internal tester belongs to the group.

**Failure handling:** If no eligible account user exists, record exact owner request and remain `blocked_external`.

### AURA-QA-006-ST-03 — Assign processed build and What to Test

This binds the tested build to clear instructions, ensuring the internal smoke is reproducible. In the internal group, add the exact processed build from `AURA-OPS-013` and enter only approved `What to Test` copy. Expect the build is available to the group with build-specific instructions; record version/build and text source path, not a fabricated summary.

**Execution**

1. Select the processed candidate version/build in TestFlight Internal Testing.
2. Assign it to AuraFit Internal, paste `OWNER_REQUIRED_WHAT_TO_TEST_COPY`, save, and verify availability state.

**Expected result and evidence:** Correct build/instructions appear for internal testing.

**Failure handling:** Build unavailable/action-required or copy unapproved is `blocked_external`; do not substitute another build/copy.

### AURA-QA-006-ST-04 — Install cleanly through TestFlight

This proves the tester receives Apple's distributed app rather than a local development build. On a physical iPhone, delete any development AuraFit build, open TestFlight, install the assigned candidate, and launch it. Expect installation source is TestFlight and no debug/local test data controls appear; record device and installation source.

**Execution**

1. Delete the existing AuraFit app from the tester iPhone and confirm TestFlight is installed/signed in.
2. Install the assigned build from TestFlight, launch, and capture redacted build/source evidence.

**Expected result and evidence:** Candidate installs and launches as a TestFlight build on physical hardware.

**Failure handling:** Installation/launch crash is P0/P1; create bug and stop smoke.

### AURA-QA-006-ST-05 — Verify TestFlight identity and expiration

This verifies the installed artifact is the intended candidate and remains inside TestFlight's distribution window. In TestFlight and AuraFit where visible, record version, build number, and 90-day expiration status. Expect all match `AURA-OPS-013` release tuple; mismatches invalidate the run.

**Execution**

1. Open the TestFlight app details for AuraFit and capture version/build/expiration information.
2. Compare to `AURA-OPS-013` evidence and record exact match/mismatch.

**Expected result and evidence:** Version/build match candidate and 90-day expiration is shown.

**Failure handling:** Any mismatch is P1/release-identity failure; stop and investigate upload assignment.

### AURA-QA-006-ST-06 — Run the processed-build short smoke

This validates core functionality, StoreKit, and public links in the exact distributed artifact. On the TestFlight build execute launch/onboarding; camera and import result; save/share; relaunch/history; product loading and one sandbox purchase/restore; privacy and terms links; then verify no debug controls/test data. Expect every path works with real catalog/sandbox behavior and public pages; record preconditions, fixture, actions, expected/actual, and defects.

**Execution**

1. Use licensed/synthetic fixture and complete the listed smoke paths in sequence on physical hardware.
2. For StoreKit, use a dedicated sandbox account and no local `.storekit`; verify public links open without workspace authentication.

**Expected result and evidence:** Every named smoke check passes with no P0/P1; StoreKit uses TestFlight sandbox/real products.

**Failure handling:** Any launch crash or P0/P1 creates a bug and blocks `TF-G2`; StoreKit failure is also recorded in `AURA-QA-010`.

### AURA-QA-006-ST-07 — Inspect TestFlight sessions, crashes, and feedback

This detects post-run telemetry and tester feedback that a manual path may miss. After the smoke, review App Store Connect → AuraFit → TestFlight metrics/feedback for the exact build, record zero findings or redacted counts/identifiers, and link defects. Expect no unexplained launch crash/session anomaly or untriaged feedback.

**Execution**

1. Navigate to the candidate build's TestFlight sessions/crashes/feedback views with authorized role.
2. Record check time, build, aggregate counts, redacted report references, and any linked bug IDs.

**Expected result and evidence:** Post-run telemetry review is documented.

**Failure handling:** Crash/P0/P1 feedback blocks G2; missing portal access is `blocked_external`.

## Acceptance criteria

- [ ] At least one internal tester installs the processed build.
- [ ] Short smoke passes with zero launch crash and zero P0/P1 defect.
- [ ] StoreKit uses TestFlight’s sandbox and real App Store Connect products.
- [ ] Status advances to `TF-G2`.

## Completion and evidence

Record all redacted group, build, device, smoke, and telemetry evidence in `quality/evidence/testflight/AURA-QA-006/README.md`.

## Stop and reverification conditions

Stop for unprocessed build, no eligible tester, no TestFlight install, wrong build, or P0/P1. Any new archive/upload/build, product/catalog change, or core-flow change requires a fresh internal TestFlight smoke.
