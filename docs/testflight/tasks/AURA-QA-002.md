---
id: AURA-QA-002
title: Execute physical-device core-loop and persistence matrix
gate: TF-G1
status: blocked_external
ownerBoundary: Owner + agent + iPhone
dependsOn: [AURA-OPS-012A]
evidence: quality/evidence/testflight/AURA-QA-002/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-002 — Physical-device core-loop and persistence matrix

## Task description

This task proves AuraFit's camera-to-result value loop, export, persistence, permissions, quota, and language on real iPhone hardware. It is required because Vision, camera, Photos, media export, and SwiftData behavior cannot be established by simulator or unit tests. Execute all twelve rows below on a Release build installed by `AURA-OPS-012A`, recording the same device/build/fixture/expected/actual evidence for each; the expected change is a complete hardware evidence matrix or a reproducible defect that blocks the final archive.

## Preconditions and inputs

- `AURA-OPS-012A` evidence shows a supported physical iPhone runs the signed Release build.
- Use a clean install where stated, a licensed/synthetic fixture set, and no personal photos in Git.
- Create `quality/evidence/testflight/AURA-QA-002/README.md` before testing. For each row record model, iOS, version/build, commit, fixture, preconditions, actions, expected/actual, pass/fail, redacted screenshot/video path, and defect ID.

## Subtasks

### AURA-QA-002-ST-01 — Test clean-install camera core loop

This verifies first-run camera capture through analysis and Result, because the primary real-camera path must work before beta. Delete AuraFit, install the signed Release build, complete onboarding, grant Camera access, capture a licensed/synthetic subject, start analysis, and open Result. Expect one credible result with no stuck progress or duplicate scan; log the complete evidence row and create a P0/P1 bug if it fails.

**Execution**

1. On the physical iPhone, delete AuraFit, install the `AURA-OPS-012A` Release build, and launch it.
2. Complete onboarding, choose Camera, allow permission, capture the fixture, wait for analysis, and open Result.

**Expected result and evidence:** Camera capture reaches one credible Result; record the row in the task evidence index.

**Failure handling:** Log a reproducible defect; data loss, false success, stuck progress, duplicate scan, or privacy mismatch is P0/P1 and blocks `AURA-OPS-012B`.

### AURA-QA-002-ST-02 — Test clean-install library-import core loop

This verifies the alternate import path so users without camera access can still receive a result. From a clean Release install, complete onboarding, choose library import, select the licensed/synthetic fixture, analyze it, and open Result. Expect the same credible completion as camera capture and record the row; file severity using ST-01 rules if import fails or misrepresents permission state.

**Execution**

1. Delete and reinstall AuraFit; complete onboarding and select library import.
2. Select the fixture, allow only the requested Photos access, analyze it, and open Result.

**Expected result and evidence:** Import reaches a credible Result with truthful permission UI; record fixture and actual output.

**Failure handling:** Record defect ID and block final archive for P0/P1 behavior.

### AURA-QA-002-ST-03 — Test scorecard export, Photos save, and share

This proves a completed scorecard can leave the app, which is required for the advertised sharing outcome. Starting from a known result, export the scorecard image, save it to Photos, then invoke the share sheet. Expect one valid exported image, a truthful save result, and an available share sheet; capture only redacted artifact paths and outcome.

**Execution**

1. Produce or open a result using a licensed fixture, choose scorecard export, and save it to Photos.
2. Open Share, verify the iOS share sheet appears, then cancel or use an approved non-personal destination.

**Expected result and evidence:** Image is saved once and sharing is available; log result, permission state, and redacted artifact location.

**Failure handling:** False save success, malformed export, or blocked core export is P1; create a bug and stop that affected path.

### AURA-QA-002-ST-04 — Test entitled reveal-video render and export

This verifies the premium reveal-video benefit on hardware because entitlement-gated media rendering must not be assumed from Debug. Use a real active entitlement permitted by the current build source, render a reveal video from a licensed fixture, and export it. Expect the render to complete once with usable media and no watermark/entitlement mismatch; record entitlement source without credentials.

**Execution**

1. Confirm an active entitlement in the evidence index; do not use local `.storekit` as StoreKit evidence.
2. From a completed result, choose reveal render, wait for completion, export, and inspect the exported media.

**Expected result and evidence:** Entitled user receives a usable reveal export; log build, entitlement state, render outcome, and artifact path.

**Failure handling:** Premium access or export failure is P1; log a defect and do not claim StoreKit validation.

### AURA-QA-002-ST-05 — Test relaunch, history, favorite, and deletion persistence

This verifies durable local history and managed-media cleanup, preventing silent data loss or privacy retention. Create at least one result, force-close and relaunch, inspect history/images, toggle favorite, delete the entry, and confirm its database row and managed media are removed. Expect each state change to persist exactly once; record before/after evidence without committing user media.

**Execution**

1. Create a result, force-quit AuraFit, relaunch, and open History.
2. Verify the image renders, toggle favorite and relaunch once, then delete the session and verify it is absent with its managed media removed.

**Expected result and evidence:** History/favorite survive relaunch and delete removes both record and managed media; record actual states.

**Failure handling:** Data loss, retained private media, or duplicate data is P0/P1; create bug and block archive.

### AURA-QA-002-ST-06 — Test Camera permission recovery and library fallback

This verifies users can recover after denying Camera rather than being trapped in a misleading flow. On clean installs test allow, deny, deny then Settings recovery, and library fallback. Expect truthful primer/system-state messaging, a working Settings recovery after enabling Camera, and usable library fallback; log each branch separately.

**Execution**

1. Run allow and deny branches on clean installs or reset app permissions in iOS Settings.
2. After denial, use the app's Settings route, enable Camera in iOS Settings, return, and retest; also choose library fallback.

**Expected result and evidence:** All four branches have truthful UI and a usable next action; record permission state and actual result.

**Failure handling:** A trapped or falsely successful permission flow is P1; file a defect.

### AURA-QA-002-ST-07 — Test add-only Photos permission recovery

This verifies export behavior under the least-privilege Photos state, avoiding false claims that content was saved. Test allow, deny, and retry after denial for add-only Photos access. Expect save only after authorization and a recoverable, truthful retry path after denial; log system permission state and visible app message.

**Execution**

1. Reset Photos permission, perform scorecard save, and allow add-only access.
2. Reset again, deny access, retry save, and observe the recovery path without changing unrelated permissions.

**Expected result and evidence:** Allow saves; deny never reports success and offers a truthful retry/recovery route.

**Failure handling:** False success is P1; record defect and stop the export claim.

### AURA-QA-002-ST-08 — Test input-quality and subject-coverage fixtures

This verifies analysis fails safely and honestly across expected input variation, protecting the product's credibility. Run valid, dark, bright, blurry, cropped, no-person, and multiple-person licensed/synthetic fixtures through the chosen camera/import path. Expect a credible result for valid input and truthful recoverable guidance or behavior for unsupported input; log fixture-to-result mapping.

**Execution**

1. Prepare the seven named fixtures outside Git or in an approved licensed fixture location.
2. Analyze each once, recording any score/result or error/guidance and retry availability.

**Expected result and evidence:** Every fixture has an expected/actual row and no misleading successful result.

**Failure handling:** Misleading identity/body claim, crash, or unusable error is P1; file defect.

### AURA-QA-002-ST-09 — Test interruption and immediate-retry behavior

This verifies active work recovers safely from ordinary iOS lifecycle events. During analysis, background AuraFit, cancel, start an immediate second scan, attempt rotation, and introduce an approved incoming interruption. Expect no stuck UI, duplicate scan, permanent camera lock, or corrupted history; record the action order and state transitions.

**Execution**

1. Begin analysis, send AuraFit to background, return, and observe completion/recovery.
2. Repeat with cancel then immediate scan, portrait rotation attempt, and a controlled call/notification interruption.

**Expected result and evidence:** Each operation recovers or reports a truthful cancel state; log exact sequence and result.

**Failure handling:** Crash, lock, corruption, duplicate work, or permanent progress is P0/P1.

### AURA-QA-002-ST-10 — Test airplane-mode free functionality

This verifies AuraFit's local-first free loop remains available without network, while StoreKit unavailability stays isolated. Enable Airplane Mode, launch or continue AuraFit, perform a free camera/import analysis, then visit product loading only to observe its recovery UI. Expect core analysis to work and StoreKit failure not to block free use; log connectivity state.

**Execution**

1. Enable Airplane Mode on the physical iPhone and confirm Wi-Fi/cellular are disabled.
2. Run one free analysis, then open the paywall/product view without attempting to fabricate product results.

**Expected result and evidence:** Free path completes; any StoreKit issue is truthful and recoverable, not blocking.

**Failure handling:** Offline free-loop blockage is P1; create a bug.

### AURA-QA-002-ST-11 — Test free quota and next-day rollover

This verifies the declared three-free-scans-per-day boundary and rollover without manipulating production clocks. Consume three free scans, attempt a fourth, then use an owner-approved safe test method to verify the next-day reset. Expect first three consume quota, fourth blocks truthfully, and approved rollover restores eligibility; record the approved method and no production-clock change.

**Execution**

1. On a clean eligible account/device state, complete three free scans and attempt a fourth.
2. Use `OWNER_REQUIRED_QUOTA_ROLLOVER_METHOD` (for example a testable controlled date source approved by the owner); do not alter production clocks, then retest eligibility.

**Expected result and evidence:** Count and block match policy; rollover is evidenced by the approved method.

**Failure handling:** Missing approved method leaves rollover `blocked_external`; quota bypass/false block is P1.

### AURA-QA-002-ST-12 — Review result language for prohibited framing

This verifies scores describe outfit/photo craft rather than attractiveness, body, or identity, preserving the product and privacy contract. Review result, empty/error, scorecard, export, and paywall-adjacent copy generated in ST-01–11. Expect no prohibited claim; record exact screens reviewed and any copy defect.

**Execution**

1. Inspect visible copy and exported scorecard/reveal labels for every completed matrix row.
2. Compare wording with the product contract and record screen identifier, observed text, and verdict.

**Expected result and evidence:** All reviewed language is craft-focused; evidence lists screens and findings.

**Failure handling:** Attractiveness/body/identity framing is P1; create a bug and block final archive until corrected.

## Acceptance criteria

- [ ] Every matrix row passes on at least one supported physical iPhone.
- [ ] Camera and import both reach a credible result.
- [ ] No data loss, false success, stuck progress, duplicate scan, or privacy mismatch occurs.
- [ ] Any P0/P1 finding creates a bug in `docs/BUGS.md` and blocks `AURA-OPS-012B`.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-QA-002/README.md` plus redacted CI/external artifact links. Do not commit personal photos.

## Stop and reverification conditions

Stop on missing signed hardware build, missing licensed fixture, or a P0/P1. A new build, changed camera/analysis/export/persistence/permission/quota copy, or changed privacy contract invalidates affected rows.
