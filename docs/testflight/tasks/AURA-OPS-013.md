---
id: AURA-OPS-013
title: Upload and clear App Store Connect processing
gate: TF-G1
status: done
ownerBoundary: Owner/App Manager/Developer
dependsOn: [AURA-OPS-012B]
evidence: quality/evidence/testflight/AURA-OPS-013/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-013 — Upload and clear App Store Connect processing

## Task description

This task delivers the validated archive to App Store Connect and proves Apple processed the exact frozen build for internal TestFlight. We use Organizer's manual upload path for build one, record delivery metadata, monitor processing, and classify any Apple action because upload success alone does not make a build testable. The expected result is the matching build under TestFlight with no Invalid Binary, Missing Compliance, or unresolved warning; any received build string is never reused.

## Preconditions and inputs

- AURA-OPS-012B archive validation passed and archive has not been invalidated.
- Account Holder/Admin/App Manager/Developer role; frozen tuple and archive path.
- AURA-OPS-014 outcome available for export compliance.

## Subtasks

### AURA-OPS-013-ST-01 — Upload the validated archive manually

Use Xcode Organizer to upload the validated archive because first-beta automation is deferred to OPS-003. Expected result: Organizer accepts the exact archive and begins App Store Connect delivery.

**Execution**

1. Xcode → Window → Organizer → Archives; select archive whose SHA/version/build matches OPS-012B evidence.
2. Select Distribute App → App Store Connect → Upload → automatic signing/default upload choices approved by owner; complete only for the selected app/team.

**Expected result and evidence:** Archive path, tuple, uploader role, and Organizer submission result are recorded.

**Failure handling:** Selected archive mismatch is `verification_pending`; Organizer upload error is `blocked_external` or `source_failure` according to delivery message—do not upload a different archive.

### AURA-OPS-013-ST-02 — Record delivery identity

Capture delivery metadata so the Apple build can be tied back to the archive. Expected result: delivery ID, upload time/time zone, version/build, and uploader role are in evidence without account details.

**Execution**

1. Copy Organizer/App Store Connect delivery ID and timestamp after upload submission.
2. Update `quality/evidence/testflight/AURA-OPS-013/README.md` with tuple, archive reference, delivery ID, uploader role, and status.

**Expected result and evidence:** One delivery record links archive to Apple processing.

**Failure handling:** Missing delivery ID is `verification_pending`; retain Organizer message and stop status claim.

### AURA-OPS-013-ST-03 — Monitor Apple processing

Wait for Apple processing because the first upload creates the beta version and status can change after delivery. Expected result: TestFlight → iOS Builds shows the frozen build's final actionable state.

**Execution**

1. In App Store Connect → Apps → AuraFit → TestFlight → iOS Builds, open exact version/build and refresh at an owner-approved cadence.
2. Record first-seen time, final status, and any required action; do not claim processed from email alone.

**Expected result and evidence:** Build state and observed time are recorded.

**Failure handling:** Prolonged processing is `blocked_external`; preserve delivery metadata and wait rather than reuploading the same build.

### AURA-OPS-013-ST-04 — Classify processing outcomes

Classify Apple's response so each failure has the correct recovery route. Expected result: Invalid Binary triggers binary/config repair plus new build; Missing Compliance routes to OPS-014; warnings have a documented testing impact decision.

**Execution**

1. Inspect App Store Connect delivery logs and related Apple email; record redacted message summary and code if displayed.
2. For `Invalid Binary`, create/fix the precise issue, choose new unused build, and repeat OPS-011 through archive/upload; for `Missing Compliance`, complete OPS-014; for warning, determine owner-approved impact before proceeding.

**Expected result and evidence:** One explicit classification and next action exists.

**Failure handling:** Unresolved warning/error blocks the task; never mark it harmless without recorded rationale.

### AURA-OPS-013-ST-05 — Verify processed build metadata

Verify Apple's processed metadata matches the frozen candidate because processing can expose wrong target/device/privacy/symbol information. Expected result: bundle ID, version/build, minimum OS, device variants, privacy manifest, symbols, and export-compliance state agree with evidence.

**Execution**

1. In TestFlight build details inspect the exact build and compare fields to OPS-011/012B evidence.
2. Record each field as match/mismatch and link dSYM/symbol/manifest processing status; do not infer unavailable fields.

**Expected result and evidence:** Metadata comparison checklist is complete.

**Failure handling:** Mismatch is `source_failure` or `blocked_external`; stop before internal distribution.

### AURA-OPS-013-ST-06 — Enforce build-number non-reuse

Document Apple build-string permanence so failed processing does not cause an accidental reuse. Expected result: evidence lists the received tuple as consumed and identifies the next build selection path through OPS-011.

**Execution**

1. Add the delivered version/build and state to evidence after Apple receives it.
2. For any correction, return to OPS-011/ST-01 and choose a verified-unused positive integer; never retry delivery with the same build string.

**Expected result and evidence:** Non-reuse rule is checked in evidence.

**Failure handling:** Any proposed reuse is `human_review_required`; stop upload.

## Acceptance criteria

- [ ] Correct build appears under TestFlight with no action-required status.
- [ ] Processed metadata matches release tuple.
- [ ] No Missing Compliance, Invalid Binary, or unresolved warning remains.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-013/README.md`.

## Stop and reverification conditions

Archive invalidation, processing action, metadata mismatch, or source change blocks distribution. A corrected binary must use a new build and repeat affected gates.
