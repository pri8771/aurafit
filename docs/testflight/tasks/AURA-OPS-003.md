---
id: AURA-OPS-003
title: Automate archive/upload after the manual path works
gate: Post-TF-G2
status: planned
ownerBoundary: Agent + owner
dependsOn: [AURA-QA-006]
evidence: quality/evidence/testflight/AURA-OPS-003/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-003 — Automate archive/upload after the manual path works

## Task description

This post-internal-beta task makes later archive/upload cycles repeatable without making automation a prerequisite for build one. We configure Xcode Cloud around the proven manual path, enforce a tag/build convention, run the shared release gate, and preserve audit logs because automated signing must not introduce committed secrets or silent build reuse. The expected result is one approved tag producing one correctly signed processed build, with manual TestFlight group assignment explicitly retained unless separate API automation is approved.

## Preconditions and inputs

- AURA-QA-006 evidence proves manual signed upload and internal smoke.
- Owner authorization for Xcode Cloud project/team and `OWNER_REQUIRED_TESTFLIGHT_TAG_CONVENTION`.
- OPS-005 shared release-candidate gate is passing.

## Subtasks

### AURA-OPS-003-ST-01 — Confirm manual-path prerequisite

Confirm the manual signing/upload path worked before automating it, preventing automation from obscuring an unproven base process. Expected result: QA-006 evidence identifies a processed build and successful internal install.

**Execution**

1. Read `quality/evidence/testflight/AURA-QA-006/README.md` and verify processed build tuple, internal install, smoke result, and no P0/P1.
2. Link that evidence in this task index.

**Expected result and evidence:** Manual-path proof is recorded.

**Failure handling:** Missing/incomplete QA-006 is `blocked_external`; do not configure automation.

### AURA-OPS-003-ST-02 — Configure Xcode Cloud signing and archive

Configure the AuraFit scheme's Release archive in Xcode Cloud so Apple manages signing rather than exporting credentials into CI. Expected result: workflow builds Release archive for the correct team/scheme with no certificates/profiles/API keys committed.

**Execution**

1. Xcode → Product → Xcode Cloud → Create Workflow (or App Store Connect → Xcode Cloud); select AuraFit repository, `AuraFit` scheme, Release archive, and owner-authorized team.
2. Review repository changes before commit; reject `.p8`, certificates, profiles, secrets, or hard-coded account paths.

**Expected result and evidence:** Workflow URL/ID, scheme/configuration, and signing-managed confirmation are recorded.

**Failure handling:** Missing authorization/signing failure is `blocked_external`; do not export signing material to GitHub Actions.

### AURA-OPS-003-ST-03 — Define and validate tag trigger

Trigger only approved release tags so arbitrary commits cannot ship. Expected result: workflow trigger matches one documented format such as `testflight/v1.0-b<BUILD>` and the tag's build equals unused frozen project build.

**Execution**

1. Require `OWNER_REQUIRED_TESTFLIGHT_TAG_CONVENTION`; if absent use no trigger and stop.
2. Configure workflow tag rule; before tag creation run `git rev-parse <tag>` and verify its project tuple against App Store Connect unused-build evidence.

**Expected result and evidence:** Tag rule and sample approved tag/SHA/tuple are recorded.

**Failure handling:** Unapproved/mismatched tag is `human_review_required`; do not trigger upload.

### AURA-OPS-003-ST-04 — Run shared gate before archive

Require OPS-005 before archive so cloud automation cannot bypass policy, tests, or bundle audit. Expected result: workflow invokes the same script/shared implementation and retains its result paths/logs.

**Execution**

1. Add a workflow action before archive with explicit rules/simulator/derived-data inputs compatible with Xcode Cloud.
2. Verify workflow log shows the gate command, 98/0/0 result, and bundle audit summary before archive starts.

**Expected result and evidence:** Workflow log links and gate result are recorded.

**Failure handling:** Duplicated/divergent checks are `source_failure`; stop automation promotion.

### AURA-OPS-003-ST-05 — Upload and retain auditable workflow evidence

Upload successful archives to App Store Connect and retain enough metadata to trace each tag to processing. Expected result: workflow/build URLs, archive/upload status, delivery ID, version/build, and action-required warnings are in evidence.

**Execution**

1. Enable the owner-approved Xcode Cloud post-archive App Store Connect upload action.
2. Trigger one approved tag; inspect workflow and App Store Connect processing, then record links/IDs/statuses without private account URLs or credentials.

**Expected result and evidence:** One tag-to-processed-build trace exists.

**Failure handling:** Action-required warning or processing failure is a failed automation run; use new build only after root-cause correction.

### AURA-OPS-003-ST-06 — Preserve manual tester-group boundary

Document the remaining manual TestFlight group step so stakeholders do not assume upload automatically distributes builds. Expected result: runbook says internal/external group assignment stays manual unless owner approves distinct App Store Connect API automation.

**Execution**

1. Add boundary statement and responsible role to evidence/runbook.
2. If API automation is requested, stop and create a new owner-approved task covering API key storage, least privilege, and audit requirements.

**Expected result and evidence:** Distribution boundary is explicit.

**Failure handling:** Any claim of end-to-end distribution without API proof is `verification_pending`.

### AURA-OPS-003-ST-07 — Define retry, build-number, and emergency-stop behavior

Define safe failure behavior so automation cannot loop, reuse builds, or deliver during an incident. Expected result: failures preserve logs, require root-cause review, select new unused build, and support an owner-controlled disable switch.

**Execution**

1. Document retry policy: no automatic retry after delivery/build failure that may have consumed a build; inspect Apple/Xcode Cloud status first.
2. Document emergency stop (disable workflow/trigger in Xcode Cloud) and owner role; test only non-destructively by verifying control location.

**Expected result and evidence:** Policies and emergency-control location are recorded.

**Failure handling:** Unknown delivery/build consumption is `verification_pending`; stop new tags until confirmed.

## Acceptance criteria

- [ ] One tag produces one correctly signed processed build.
- [ ] No signing/API secret is committed.
- [ ] Failures retain auditable logs and never reuse build numbers.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-003/README.md`.

## Stop and reverification conditions

QA-006 regression, signing/workflow/tag changes, or workflow failure requires revalidation. Automation does not replace manual group assignment unless separately approved and evidenced.
