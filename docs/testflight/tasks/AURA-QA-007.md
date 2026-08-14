---
id: AURA-QA-007
title: Execute external group and TestFlight App Review
gate: TF-G3
status: blocked_external
ownerBoundary: Owner/App Manager
dependsOn: [AURA-QA-006, AURA-LEG-003, AURA-LEG-004, AURA-LEG-005, AURA-LEG-008]
evidence: quality/evidence/testflight/AURA-QA-007/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-007 — External group and TestFlight App Review

## Task description

This task makes the reviewed candidate safely installable by people without App Store Connect access. It is necessary because external TestFlight requires approved beta metadata and Apple review, distinct from internal distribution. After internal smoke and required public/compliance/reviewer materials complete, use an authorized owner/App Manager to execute the nine App Store Connect steps below; the expected change is App Review approval and one real external install, with redacted review/group evidence and no personal tester data.

## Preconditions and inputs

- `AURA-QA-006` passed; `AURA-LEG-003`, `AURA-LEG-004`, `AURA-LEG-005`, and `AURA-LEG-008` evidence is complete.
- Authorized App Manager role and owner-approved beta description, feedback email, contact details, review notes, What to Test, and cohort authorization.
- Evidence index: `quality/evidence/testflight/AURA-QA-007/README.md`; never commit tester emails/names, public invitation URL, or review contact secrets.

## Subtasks

### AURA-QA-007-ST-01 — Confirm external eligibility

This verifies the candidate is eligible for external testing before group setup, preventing an unreviewable internal-only upload from being treated as beta-ready. In App Store Connect → Apps → AuraFit → TestFlight, inspect the exact candidate build and confirm it was not uploaded as `TestFlight Internal Only`. Expect an externally eligible build state; record version/build and redacted state.

**Execution**

1. Open the candidate build's TestFlight details with App Manager access.
2. Verify `TestFlight Internal Only` is not set and record the observed external eligibility state.

**Expected result and evidence:** Exact build is eligible to submit for external testing.

**Failure handling:** Internal-only or unavailable build is `blocked_external`; create/upload a new eligible build through the canonical release path, not a workaround.

### AURA-QA-007-ST-02 — Confirm internal group prerequisite

This verifies Apple's required internal-group prerequisite exists before external distribution. Inspect TestFlight groups and confirm AuraFit Internal (or owner-approved equivalent) contains the candidate build. Expect an existing internal group; record group name and build assignment without member data.

**Execution**

1. Navigate to TestFlight → Internal Testing and locate approved group.
2. Confirm candidate build association and record redacted group/build result.

**Expected result and evidence:** Internal group prerequisite is satisfied.

**Failure handling:** Missing group/build assignment returns to `AURA-QA-006`; do not create an external group first.

### AURA-QA-007-ST-03 — Create controlled external group

This creates the initial limited beta cohort, reducing support/privacy risk versus a broad public link. In TestFlight → External Testing create exactly `AuraFit External Beta 1`, or reuse only an owner-approved equivalent. Expect one controlled group with no testers yet recorded in Git.

**Execution**

1. Search external groups for an owner-approved equivalent.
2. If none exists, create `AuraFit External Beta 1` and record group settings/count only.

**Expected result and evidence:** Controlled external beta group exists.

**Failure handling:** Missing owner/App Manager authorization is `blocked_external`; do not invite from an unapproved group.

### AURA-QA-007-ST-04 — Enter complete beta and reviewer metadata

This supplies reviewers/testers enough accurate information to evaluate the candidate, preventing improvised claims. For the group/build enter approved Beta App Description, Feedback Email, Contact Information, review notes, and build-specific What to Test from repository drafts. Expect all required fields saved and sourced; record field names, source paths, and save state, not private values.

**Execution**

1. Open TestFlight beta information for AuraFit and select the candidate build/group.
2. Paste only approved owner values and `AURA-LEG-008` draft content; save and re-open to verify persistence.

**Expected result and evidence:** Required beta/reviewer fields are complete and repository-sourced.

**Failure handling:** Missing approved contact/copy is `human_review_required`; do not invent wording or addresses.

### AURA-QA-007-ST-05 — Submit candidate to TestFlight App Review

This starts Apple's external-beta approval process and ties it to one reviewed build. Add the candidate build to the external group, validate all required beta fields, and submit. Respect Apple’s current one-build-per-version-in-review and six-submissions-per-24-hours limits by checking portal state at execution time. Expect review status Submitted/In Review; record timestamp and build.

**Execution**

1. Confirm candidate, metadata, and external group settings, then use Submit for Review.
2. Record Apple-visible review status/time and any portal limit message, without retrying around a stated limit.

**Expected result and evidence:** Candidate enters TestFlight App Review or a precise portal blocker is recorded.

**Failure handling:** Required-field rejection or submission limit is `blocked_external`; correct named fields/wait for limit, never submit a different build silently.

### AURA-QA-007-ST-06 — Respond to review questions from evidence

This ensures Apple receives verifiable product/privacy/purchase explanations instead of invented claims. Monitor the review messages; for each question cite relevant repository evidence, owner-approved contact response, and build behavior. Expect a redacted question/response/outcome log; escalate legal/commercial matters to the owner.

**Execution**

1. Check the candidate review message center on a fixed owner-approved cadence.
2. Draft response from task evidence and canonical documents, obtain owner approval when required, submit, and record redacted reference/outcome.

**Expected result and evidence:** Every review question receives an evidence-backed response.

**Failure handling:** Unknown claim or legal/commercial question is `human_review_required`; do not improvise.

### AURA-QA-007-ST-07 — Invite approved external cohort after approval

This proves an actual non-account user can install while keeping the cohort manageable. After App Review approval, invite the owner-approved 15–30-person email cohort to the controlled group and record only aggregate invited/accepted/install counts. Expect at least one true external tester installs the approved build.

**Execution**

1. Verify external approval and `OWNER_REQUIRED_EXTERNAL_COHORT_APPROVAL`.
2. Send invitations through App Store Connect, then obtain redacted confirmation from at least one external TestFlight install.

**Expected result and evidence:** Approved cohort invitation is sent and one true external install is recorded.

**Failure handling:** No approval/cohort authorization is `blocked_external`; never export or commit recipient data.

### AURA-QA-007-ST-08 — Safeguard any later public link

This preserves privacy/support capacity if distribution expands beyond controlled invitations. Only after owner approval, configure public-link device/OS criteria and tester limit in the external group, then retain the link outside Git and do not publish broadly until privacy/support capacity is confirmed. Expect bounded public-link settings or an explicit no-link decision.

**Execution**

1. Set `OWNER_REQUIRED_PUBLIC_LINK_DECISION`; if approved, open public-link settings and configure owner-approved device/OS criteria and tester limit.
2. Record settings and capacity confirmation without recording the actual URL.

**Expected result and evidence:** Public link is either safely bounded or explicitly not used.

**Failure handling:** Missing capacity/approval stops this subtask; no broad publication.

### AURA-QA-007-ST-09 — Record review and cohort outcome safely

This creates auditable external-beta evidence without retaining personal data. Record approval/rejection, review messages, group settings, candidate build, and invited count in the task evidence index. Expect a complete redacted outcome record supporting `TF-G3`; preserve failures and reasons.

**Execution**

1. Compile redacted review timeline, build version, group configuration, aggregate cohort counts, and defect links.
2. Check no names, email addresses, invitation URLs, credentials, or private review attachments entered Git.

**Expected result and evidence:** Evidence supports approval/install outcome with only aggregate tester data.

**Failure handling:** Privacy-bearing data must be removed from proposed evidence before completion; rejection remains recorded and blocks G3.

## Acceptance criteria

- [ ] TestFlight App Review approves the build and metadata.
- [ ] At least one true external tester installs it.
- [ ] No tester personal data is committed.
- [ ] Status advances to `TF-G3`.

## Completion and evidence

Keep the complete redacted review/group/cohort record in `quality/evidence/testflight/AURA-QA-007/README.md`.

## Stop and reverification conditions

Stop for missing prerequisite evidence, missing owner values, App Review rejection, or privacy-risking data. New build, beta metadata/legal/public-page change, or material review feedback requires renewed review/distribution evidence.
