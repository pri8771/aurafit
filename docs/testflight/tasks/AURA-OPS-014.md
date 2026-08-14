---
id: AURA-OPS-014
title: Confirm export compliance
gate: TF-G1
status: human_review_required
ownerBoundary: Owner + human legal determination
dependsOn: [AURA-OPS-010]
evidence: quality/evidence/testflight/AURA-OPS-014/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-014 — Confirm export compliance

## Task description

This task records App Store Connect’s export-compliance determination for the exact build so TestFlight processing does not remain in Missing Compliance. The repository currently sets `ITSAppUsesNonExemptEncryption=false` and has no networking/backend, but that setting alone is not a legal determination; the observable result is an owner-completed Apple response matching a fresh source/framework audit and any required approved documentation. This plan gives no legal advice and never invents CCATS, ANSSI, or exemption classifications.

## Preconditions and inputs

- `AURA-OPS-010` app record exists; owner has App Store Connect access sufficient to answer compliance questions.
- Read `AuraFit.xcodeproj/project.pbxproj`, Release `Info.plist`, linked frameworks, source networking/security use, and `docs/ARCHITECTURE.md`.
- Archive/build-specific compliance state cannot be claimed before a build is uploaded.

## Subtasks

### AURA-OPS-014-ST-01 — Re-audit encryption use in source and linked frameworks

This step establishes technical facts for the owner’s compliance response. Inspect linked frameworks and source for encryption use, including networking, custom crypto, secure transport, key handling, and bundled libraries; the expected result is a dated inventory rather than an inference from the Info.plist flag.

**Execution**

1. From `/Users/pchordia/Documents/other/ios_apps/aurafit`, inspect project build settings, source imports, and linked frameworks for encryption-related behavior.
2. Record framework/source location, purpose, and whether it is Apple-system or app-implemented in the evidence README.
3. Include any dependency or architecture change since the last audit.

**Expected result and evidence:** A reproducible technical encryption-use inventory exists.

**Failure handling:** Unknown or newly introduced crypto/networking blocks determination pending owner/legal review.

### AURA-OPS-014-ST-02 — Compare the audit with the current release declaration

This step tests whether the project setting remains factually aligned. Confirm whether AuraFit uses, accesses, contains, or implements encryption beyond exempt Apple-system functionality, and compare that conclusion with `ITSAppUsesNonExemptEncryption=false`; the expected result is a documented technical comparison, not a legal conclusion.

**Execution**

1. Read the generated Release Info.plist value and ST-01 inventory.
2. Record current facts: AuraFit has no networking/backend only if source audit still proves it.
3. Mark any mismatch as requiring human legal/owner direction before archive/upload.

**Expected result and evidence:** Info.plist and technical facts are either aligned or explicitly blocked.

**Failure handling:** Do not change the flag merely to clear processing; escalate mismatches.

### AURA-OPS-014-ST-03 — Have the owner answer Apple’s App Encryption questions

This step produces Apple’s authoritative processing determination. In App Store Connect → Apps → AuraFit → build/compliance flow, the owner answers the currently displayed App Encryption questions using ST-01/02 and legal guidance where needed; the expected result is a recorded response state for the exact build.

**Execution**

1. Confirm role and current Apple UI; field labels may change.
2. Present the technical inventory to the owner, who selects answers.
3. Record build number, date, displayed result, and redacted answer summary in evidence.

**Expected result and evidence:** Apple’s compliance workflow is completed by an authorized owner.

**Failure handling:** Missing owner access or uncertain answer remains `human_review_required`; agents must not submit answers.

### AURA-OPS-014-ST-04 — Record a no-documentation determination when Apple permits it

This step documents the simple path without overstating it. If App Store Connect states no export documentation is required, retain the matching Info.plist value and record Apple’s result/build/date; the expected result is a build whose processing no longer shows Missing Compliance.

**Execution**

1. Confirm Apple’s visible result after ST-03.
2. Preserve current build setting unless an authorized technical change is separately approved.
3. Record the redacted determination and observed build status.

**Expected result and evidence:** No-documentation outcome is tied to a specific build and Apple result.

**Failure handling:** A later build or changed encryption use invalidates this result and requires re-check.

### AURA-OPS-014-ST-05 — Handle required documentation through approval

This step follows Apple’s required-document route when the simple path is unavailable. If App Store Connect requires documentation, the owner/legal authority obtains and uploads the required material, waits for approval, and attaches/associates it with the build as Apple directs; the expected result is approved required documentation before Beta App Review.

**Execution**

1. Record Apple’s exact requirement and deadline in evidence without uploading documents to Git.
2. Assign preparation/upload to authorized owner/legal personnel.
3. Confirm approved status and build association in App Store Connect.

**Expected result and evidence:** Required documentation is approved and attached to the intended build.

**Failure handling:** Remain `blocked_external` until approval; do not upload fabricated or agent-authored classifications.

### AURA-OPS-014-ST-06 — Prohibit fabricated legal classifications

This step makes the escalation boundary explicit. Do not give legal advice or create CCATS/ANSSI/exemption classifications; the expected result is a precise owner/legal request whenever technical facts do not settle Apple’s questions.

**Execution**

1. Add the uncertainty, requested decision, technical audit link, and affected build to evidence.
2. Mark status `human_review_required`.
3. Resume only after authorized written direction or Apple’s completed determination.

**Expected result and evidence:** Legal decisions remain with appropriate human authority.

**Failure handling:** No substitute answer is permitted.

## Acceptance criteria

- [ ] The processed build does not show `Missing Compliance`.
- [ ] App Store Connect determination and Info.plist agree.
- [ ] Any required documentation is approved and attached.

## Completion and evidence

Use `quality/evidence/testflight/AURA-OPS-014/README.md`; retain only redacted determination status and never commit legal documents, keys, or account data.

## Stop and reverification conditions

Missing owner decision/access or an uncertain legal classification keeps this task `human_review_required`. Any build, source, linked-framework, network, or encryption change reopens the audit and Apple determination.
