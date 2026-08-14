---
id: AURA-LEG-003
title: Confirm Terms/EULA and subscription legal links
gate: TF-G3
status: human_review_required
ownerBoundary: Owner + human review
dependsOn: [AURA-MKT-004]
evidence: quality/evidence/testflight/AURA-LEG-003/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-LEG-003 — Confirm Terms/EULA and subscription legal links

## Task description

This task establishes one non-conflicting agreement path and verifies that purchase UI links and claims match the configured catalog. It protects subscribers and App Review from unclear renewal, restore, privacy, or terms information; the observable result is an owner/human-reviewed EULA decision and Release-tested links. It is not legal advice: pause for owner/legal review rather than interpreting or drafting legal terms.

## Preconditions and inputs

- `AURA-MKT-004` public URLs and `AURA-MON-002` commercial decisions are available.
- Read `quality/feature-contracts/FEAT-004.json`, `docs/PRIVACY_POLICY.md`, and the Release paywall.
- Required owner input: `OWNER_REQUIRED_EULA_CHOICE` = Apple standard EULA or custom terms.

## Subtasks

### AURA-LEG-003-ST-01 — Record the owner’s EULA choice

This step selects the single agreement that governs purchase terms. Ask the owner to choose Apple’s standard EULA or custom terms and record the decision in `docs/DECISIONS.md`; the expected result is an explicit choice—AuraFit currently links the standard EULA but that is not approval.

**Execution**

1. Present only the two choices and their operational consequence: standard official link or human-reviewed public custom agreement.
2. Record `OWNER_REQUIRED_EULA_CHOICE`, approver, date, and rationale in `docs/DECISIONS.md`.
3. Add a redacted pointer to the evidence README.

**Expected result and evidence:** One documented owner decision exists.

**Failure handling:** Keep `human_review_required` when no owner selection is recorded.

### AURA-LEG-003-ST-02 — Verify the standard EULA path when selected

This step validates the official agreement route without publishing contradictory terms. If standard EULA is selected, open the official Apple EULA from a Release build and a logged-out browser, record final URL/status/date, and ensure no custom `/terms` claims conflict; the expected result is a reachable official link.

**Execution**

1. Confirm ST-01 selected standard EULA.
2. Tap the in-app Terms link in Release and open the official target in a logged-out browser.
3. Record redacted reachability evidence and the decision.

**Expected result and evidence:** Terms link reaches Apple’s official EULA and no competing custom terms exist.

**Failure handling:** Stop if link is broken or routes elsewhere; file a specific app/link correction.

### AURA-LEG-003-ST-03 — Execute the custom-terms path only when selected

This step publishes custom terms safely if the owner chooses them. Obtain human legal review, host the approved text publicly, add the custom agreement in App Store Connect, and update the in-app link; the expected result is one reviewed public agreement consistent across all surfaces.

**Execution**

1. Confirm ST-01 selected custom terms and obtain `OWNER_REQUIRED_LEGAL_REVIEW_RECORD`.
2. Use `AURA-MKT-004` hosting evidence to publish final terms URL.
3. In App Store Connect → Apps → AuraFit → App Information/License Agreement, enter the approved custom agreement using an authorized role; update the in-app link.
4. Test public and Release links, then record redacted evidence.

**Expected result and evidence:** Custom terms are publicly reachable and match App Store Connect and app links.

**Failure handling:** Do not draft or alter legal text; stop for missing legal review, access, or public URL.

### AURA-LEG-003-ST-04 — Compare the Release paywall with configured purchases and links

This step detects misleading purchase presentation before review. Compare paywall title, StoreKit-sourced duration/price, auto-renewal wording, restore, manage-subscription link, privacy URL, and terms URL against approved catalog/terms; the expected result is a documented consistency pass or a specific correction task.

**Execution**

1. Launch a Release build and visit each purchase path.
2. Cross-check visible claims against `AURA-MON-002`, `AURA-MON-008`, `FEAT-004`, and public URLs.
3. Capture redacted screenshots/observations and list any mismatch with affected file/task.

**Expected result and evidence:** Subscription copy and legal routes agree with configuration.

**Failure handling:** Block external review on a broken, missing, hard-coded, or contradictory claim.

### AURA-LEG-003-ST-05 — Make purchase reviewability explicit

This step gives reviewers a truthful way to exercise all visible IAP. Verify purchase controls are reachable in Release/TestFlight-ready UI and document any IAP that cannot be exercised in `AURA-LEG-008` review notes; the expected result is no hidden or unexplained purchase flow.

**Execution**

1. Locate all four product entry points in Release.
2. For each unavailable review path, describe the limitation factually in reviewer notes and link its catalog status.
3. Do not claim a sandbox/TestFlight test passed here; that belongs to `AURA-QA-010`.

**Expected result and evidence:** Reviewer instructions account for every non-obvious purchase path.

**Failure handling:** Stop if a visible IAP cannot be explained or is not reviewable.

## Acceptance criteria

- [ ] EULA choice is recorded in `docs/DECISIONS.md`.
- [ ] Terms and privacy links work in Release.
- [ ] Subscription copy and configured products agree.
- [ ] Human owner/legal review is recorded.

## Completion and evidence

Use `quality/evidence/testflight/AURA-LEG-003/README.md`; keep legal-review material and contacts outside Git unless a redacted reference is approved.

## Stop and reverification conditions

No owner EULA choice, legal review for custom terms, public URL, or functioning Release link remains `human_review_required`. Reopen after EULA, product, paywall, or privacy-link changes.
