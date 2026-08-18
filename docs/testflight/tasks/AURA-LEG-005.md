---
id: AURA-LEG-005
title: Complete age rating and content-rights review
gate: TF-G3
status: done
ownerBoundary: Owner
dependsOn: [AURA-OPS-010]
evidence: quality/evidence/testflight/AURA-LEG-005/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-LEG-005 — Complete age rating and content-rights review

## Task description

This task completes Apple’s current age-rating and content-rights information from verified AuraFit behavior. It avoids unsupported medical, attractiveness, social-comparison, or child-directed representations; the observable result is a non-Unrated rating with dated owner approval and rights basis. Use the live App Store Connect questionnaire wording, answer only facts established by the app, and stop for legal review instead of interpreting regulated classifications.

## Preconditions and inputs

- `AURA-OPS-010` app record exists; role is Account Holder, Admin, or App Manager.
- Read `docs/PLAN.md` LEG-005/LEG-007 context, `docs/PRIVACY_POLICY.md`, current UI copy, and Release asset inventory.
- The synthetic QA image is test-only; never assert rights for unverified third-party assets.

## Subtasks

### AURA-LEG-005-ST-01 — Complete the current Apple questionnaire from actual behavior

This step provides Apple the required rating inputs. In App Store Connect → Apps → AuraFit → App Information → Age Rating, open the current questionnaire and answer from actual in-app controls, capabilities, content descriptors, and chance-based activities; the expected result is a saved response set tied to the current schema/date.

**Execution**

1. Capture the questionnaire version/date and its exact current questions in redacted evidence.
2. Inspect Release behavior before each answer; do not reuse answers blindly from a prior Apple schema.
3. Save only supported responses and record their evidence source.

**Expected result and evidence:** Every required current question has an evidence-backed response.

**Failure handling:** Stop for unclear behavior or a new category; do not infer an answer from marketing intent.

### AURA-LEG-005-ST-02 — Keep the app out of Made for Kids

This step preserves the app’s documented audience classification. Confirm AuraFit is not directed at children and do not select Made for Kids; the expected result is an age-rating configuration consistent with the policy’s Children statement and current product scope.

**Execution**

1. Compare the selector with `docs/PRIVACY_POLICY.md` and Release onboarding/metadata.
2. Select no Made for Kids classification when the live questionnaire presents it.
3. Record the selected state and evidence source.

**Expected result and evidence:** No child-directed designation is made for AuraFit.

**Failure handling:** Stop for owner/legal review if target audience or child-directed functionality changes.

### AURA-LEG-005-ST-03 — Answer wellness, body, appearance, and UGC prompts cautiously

This step ensures AuraFit is described as subjective outfit/photo craft guidance, not health diagnosis, body measurement, attractiveness ranking, or social UGC. Review every relevant live prompt against actual UI; the expected result is evidence-backed responses without claims the app does not make.

**Execution**

1. Inspect current strings and feature behavior for medical/wellness, body, appearance, social, and UGC functionality.
2. Record the app’s actual scope: no health diagnosis, no accounts/feed/voting, local subjective guidance.
3. Answer the current Apple prompts only from that scope.

**Expected result and evidence:** Responses match implemented behavior and approved framing.

**Failure handling:** A prompt implying regulated medical/diagnostic functionality triggers legal review; do not falsely attest.

### AURA-LEG-005-ST-04 — Preserve the calculated rating unless a documented reason exists

This step avoids unsupported manual changes to Apple’s result. Review the calculated global/region rating and leave it unchanged unless the owner supplies a documented policy or legal reason; the expected result is an unmodified, supported rating.

**Execution**

1. Record the calculated rating before any override.
2. If an override is requested, require `OWNER_REQUIRED_RATING_OVERRIDE_RATIONALE` and human legal review record.
3. Save the calculated rating when no approved basis exists.

**Expected result and evidence:** The published rating follows Apple calculation or has documented justification.

**Failure handling:** Do not override based on preference or anticipated marketing impact.

### AURA-LEG-005-ST-05 — Verify content-rights basis for shipping assets

This step supports Apple’s Content Rights attestation. Audit production photos, models, fonts, media, and other assets; the expected result is a rights basis for every shipping asset and confirmation that the synthetic QA image remains test-only/excluded from Release.

**Execution**

1. Inspect Release bundle/assets and rights records supplied by the owner.
2. Record rights basis or removal requirement for each third-party asset category.
3. Verify test fixtures are excluded from Release and do not use real-person media without documented permission.

**Expected result and evidence:** Content-rights attestation is supported by a redacted asset-rights inventory.

**Failure handling:** Unknown asset rights block attestation and require removal or owner/legal evidence.

### AURA-LEG-005-ST-06 — Record ratings and owner approval

This step leaves a durable record of the actual App Store output. Capture global and region-specific ratings, questionnaire date, operator role, and owner approval in the evidence README; the expected result is an auditable non-Unrated status without personal data.

**Execution**

1. Save the completed questionnaire in App Store Connect.
2. Record exact visible ratings/date and a redacted owner-approval reference.
3. Do not include account emails, personal addresses, or full unredacted screenshots in Git.

**Expected result and evidence:** Rating output and approval are available for external-beta readiness.

**Failure handling:** A missing save/approval keeps status `blocked_external`.

### AURA-LEG-005-ST-07 — Stop on regulated-medical classification triggers

This step prevents a false regulatory declaration. If App Store category or questionnaire answers trigger a regulated-medical-device declaration, stop, correct the product classification, or obtain human legal review; the expected result is no unsupported attestation.

**Execution**

1. Read Apple’s displayed trigger/requirement exactly.
2. Record the trigger and affected answer in evidence.
3. Request owner/legal direction; do not click confirmation based on agent judgment.

**Expected result and evidence:** Any regulated classification is resolved by authorized human decision.

**Failure handling:** Remain `human_review_required` until resolution; do not submit inaccurate metadata.

## Acceptance criteria

- [ ] Age rating is no longer Unrated.
- [ ] Answers are supported by actual app behavior.
- [ ] Content-rights attestation has a recorded basis.
- [ ] No unsupported medical or attractiveness claim appears in metadata or UI.

## Completion and evidence

Use `quality/evidence/testflight/AURA-LEG-005/README.md` with redacted question/result references and asset-rights basis.

## Stop and reverification conditions

Missing app access, unverified asset rights, changed behavior/copy, a new Apple schema, or regulated-medical trigger keeps this task `blocked_external` or `human_review_required`. Reopen after any relevant content, category, or rights change.
