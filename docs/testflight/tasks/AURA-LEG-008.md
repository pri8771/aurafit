---
id: AURA-LEG-008
title: Prepare TestFlight and reviewer information packet
gate: TF-G3
status: human_review_required
ownerBoundary: Agent draft + owner contact details
dependsOn: [AURA-MKT-004, AURA-MON-008]
evidence: quality/evidence/testflight/AURA-LEG-008/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-LEG-008 — Prepare TestFlight and reviewer information packet

## Task description

This task produces deterministic tester and Apple review instructions for AuraFit’s local, photo-based analysis and four IAPs. It prevents accidental rejection or unusable beta instructions; the observable result is four repository drafts that a reviewer can follow from a fresh install without developer assistance. Agent drafts may use verified product behavior, but all contact details and public test-image access must remain explicit owner-required inputs.

## Preconditions and inputs

- `AURA-MKT-004` supplies public support/privacy URLs and `AURA-MON-008` supplies real product status/metadata when available.
- Read `docs/PRIVACY_POLICY.md`, `docs/TEST_PLAN.md`, `quality/feature-contracts/FEAT-004.json`, Release UI, and test fixture licensing/source.
- Draft files are `docs/release/TESTFLIGHT_BETA_DESCRIPTION.md`, `TESTFLIGHT_WHAT_TO_TEST.md`, `TESTFLIGHT_REVIEW_NOTES.md`, and `TESTFLIGHT_FEEDBACK_QUESTIONS.md`.

## Subtasks

### AURA-LEG-008-ST-01 — Draft the beta description from verified behavior

This step gives testers a compact truthful orientation. Create `docs/release/TESTFLIGHT_BETA_DESCRIPTION.md` describing AuraFit as a local-first outfit/photo coach, the owner-confirmed iPhone/iOS requirement, no account, no cloud photo upload, and subjective craft guidance; the expected result is beta copy that does not overclaim AI, health, or remote processing.

**Execution**

1. Derive claims from `docs/PRIVACY_POLICY.md`, Release UI, and feature contracts.
2. Insert `OWNER_REQUIRED_MINIMUM_IOS_TESTFLIGHT_COPY` only if the user-facing requirement is not confirmed.
3. Keep App Store marketing copy separate; this file is TestFlight beta information.

**Expected result and evidence:** Beta description accurately communicates scope and privacy.

**Failure handling:** Remove or flag any claim not supported by shipping behavior; do not guess device requirements.

### AURA-LEG-008-ST-02 — Draft a complete What to Test checklist

This step tells testers exactly which beta paths matter. Create `docs/release/TESTFLIGHT_WHAT_TO_TEST.md` with onboarding, camera, import, result explanation, save/share, history/relaunch, quota, purchase/restore, permission denial/recovery, and feedback prompts; the expected result is a scannable action/expected-result list aligned with task QA matrices.

**Execution**

1. Use `docs/TEST_PLAN.md` and relevant feature contracts to state precondition, action, expected visible result, and feedback prompt for each path.
2. Link recovery instructions to public support content where appropriate.
3. Do not represent unexecuted physical-device/StoreKit tests as passed.

**Expected result and evidence:** Testers can exercise all primary flows without implied knowledge.

**Failure handling:** Mark an unavailable or blocked path explicitly; do not omit it or invent a workaround.

### AURA-LEG-008-ST-03 — Draft deterministic Apple review notes

This step lets App Review reproduce the core experience and understand non-obvious behavior. Create `docs/release/TESTFLIGHT_REVIEW_NOTES.md` with fresh-install steps to camera and library results, permission behavior, no login/demo account, local analysis, synthetic-test-image instructions, exact IAP IDs/locations, deterministic-heuristic disclosure, and owner-required contact placeholders; the expected result is a reviewer-runbook rather than marketing prose.

**Execution**

1. Write numbered steps with exact UI labels/current behavior, expected result, and recovery for denied Camera/Photos access.
2. Include IDs: `com.aurafit.pro.monthly`, `com.aurafit.pro.yearly`, `com.aurafit.template.streetwear`, and `com.aurafit.template.softluxury`, only where `AURA-MON-008` confirms them.
3. Add `OWNER_REQUIRED_REVIEW_CONTACT_NAME`, `OWNER_REQUIRED_REVIEW_CONTACT_EMAIL`, and `OWNER_REQUIRED_REVIEW_CONTACT_PHONE` plainly; never invent values.

**Expected result and evidence:** A reviewer can finish local analysis and find each purchase option unaided.

**Failure handling:** If any step is not reproducible on the Release build, file a correction or state the limitation truthfully.

### AURA-LEG-008-ST-04 — Draft structured feedback questions

This step turns subjective beta reactions into comparable findings. Create `docs/release/TESTFLIGHT_FEEDBACK_QUESTIONS.md` using the core topics—first-result completion, advice credibility, confusing language, permission trust, export value, purchase clarity, failures/crashes, and willingness to use again; the expected result is reusable questions without collecting unnecessary personal data.

**Execution**

1. Write short neutral questions with optional free-text response.
2. Avoid asking testers to send photos or personal identifiers through the repository.
3. Point operational feedback handling to `AURA-QA-008`.

**Expected result and evidence:** All testers can receive the same privacy-conscious question set.

**Failure handling:** Remove questions that require sensitive images/data unless an owner-approved external consent process exists.

### AURA-LEG-008-ST-05 — Supply a rights-cleared public reviewer test image

This step ensures Apple can test photo analysis without repository access or personal media. Use a synthetic/licensed full-body subject image with no personal metadata, publish it at an owner-approved public URL or clear in-app path, and verify access logged out; the expected result is a reviewer-accessible fixture with recorded rights/source.

**Execution**

1. Verify rights and remove metadata from the candidate image before publication.
2. Obtain `OWNER_REQUIRED_PUBLIC_TEST_IMAGE_URL` or document an in-app delivery path that works for App Review.
3. Open it in a logged-out browser and record URL, rights basis, and access result in evidence.

**Expected result and evidence:** Review notes link to an accessible, rights-cleared test image.

**Failure handling:** A repository path, private link, unknown rights, or real-person private photo is not acceptable; stop until replaced.

### AURA-LEG-008-ST-06 — Separate beta information from future App Store marketing

This step prevents reviewer operational notes from becoming unsupported customer-facing claims. Review the four draft files against App Store marketing metadata and keep beta description/What to Test/review notes scoped to testing; the expected result is separate artifacts with no accidental publication of owner placeholders or reviewer-only detail.

**Execution**

1. Check each draft’s audience and remove promotional claims not verified in Release.
2. Keep owner-required placeholders only where contacts are needed; do not expose them in public marketing.
3. Record owner approval of contacts and final packet before external submission.

**Expected result and evidence:** Beta/reviewer documentation is complete and safely distinct from store marketing.

**Failure handling:** Missing contact approval keeps external submission blocked; do not substitute developer/private contact data.

## Acceptance criteria

- [ ] All four repository drafts exist and contain no placeholder except explicitly owner-required fields.
- [ ] Owner fills and approves contact fields before external submission.
- [ ] A reviewer can follow the notes without developer assistance.
- [ ] Review notes describe every non-obvious IAP and no unavailable feature.

## Completion and evidence

Use `quality/evidence/testflight/AURA-LEG-008/README.md`; include draft paths, build/version context, owner approvals, and redacted public test-image reachability evidence.

## Stop and reverification conditions

Missing real contact details, product status, public fixture, support URL, or reproducible Release steps blocks external submission. Reopen after any UI, permission, IAP, policy, support URL, or contact change.
