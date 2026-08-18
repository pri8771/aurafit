---
id: AURA-MON-008
title: Configure the production StoreKit catalog
gate: TF-G2
status: blocked_external
ownerBoundary: Owner
dependsOn: [AURA-OPS-009, AURA-OPS-010, AURA-MON-002]
evidence: quality/evidence/testflight/AURA-MON-008/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

> **Not applicable — DEC-006 (2026-08-18).** AuraFit 1.0 ships as one full, free product with
> no StoreKit code, products, prices, or purchase/restore paths. This task is retained for
> history and for any future monetization decision; do not execute it for the 1.0 release.

# AURA-MON-008 — Configure the production StoreKit catalog

## Task description

This task creates the production App Store Connect records that the shipping binary requests. It is needed for truthful price display and sandbox/TestFlight purchases; the observable result is four exact IDs with approved metadata and no unimplemented IAP. An authorized owner follows the App Store Connect UI only after account, app-record, and commercial prerequisites have evidence; do not add a backend or server notifications.

## Preconditions and inputs

- `AURA-OPS-009`, `AURA-OPS-010`, and `AURA-MON-002` evidence is complete.
- Required role: Account Holder, Admin, or App Manager with In-App Purchases access; do not assume a role.
- Inputs include owner-approved names, localization, prices, territories, tax category, offers, and review assets.

## Subtasks

### AURA-MON-008-ST-01 — Create the approved subscription group

This step creates the shared upgrade/downgrade container for Pro subscriptions. In App Store Connect → Apps → AuraFit → Monetization → Subscriptions, create one group only after `OWNER_REQUIRED_SUBSCRIPTION_GROUP_REFERENCE_NAME` and display/localization inputs are approved; the expected result is one documented group, proposed name `AuraFit Pro`, not a guessed display name.

**Execution**

1. Confirm prerequisites and role, then open the stated App Store Connect path.
2. Create the group using owner-approved reference/localized display values.
3. Record the group reference and redacted status in evidence.

**Expected result and evidence:** One subscription group exists and is linked in the evidence README.

**Failure handling:** Stop `blocked_external` for missing access or owner values; do not create duplicate groups.

### AURA-MON-008-ST-02 — Create the immutable products matching code

This step registers the only identifiers the current code may request, preventing product lookup failures. Create the products in App Store Connect exactly as listed; the observable result is four records whose type and duration match the binary.

**Execution**

1. Under the group, create `com.aurafit.pro.monthly` as auto-renewable, one month, and `com.aurafit.pro.yearly` as auto-renewable, one year.
2. Under Monetization → In-App Purchases, create `com.aurafit.template.streetwear` and `com.aurafit.template.softluxury` as non-consumables.
3. Re-read every ID before saving because IDs are immutable; record the exact IDs and type in redacted evidence.

**Expected result and evidence:** Four exact product IDs exist once, with the stated types/durations.

**Failure handling:** If an ID exists with a wrong type, stop and ask the owner; never create an approximate replacement without a code-scope decision.

### AURA-MON-008-ST-03 — Complete each product's approved metadata

This step makes each product reviewable and user-readable. For every record, enter only owner-approved reference name, localization, customer description, price, availability, tax category, review notes, and App Review screenshot; the expected result is complete fields with no fabricated marketing/legal claim.

**Execution**

1. Open each product → metadata/localization fields in App Store Connect.
2. Enter `OWNER_REQUIRED_*` values approved in `AURA-MON-002`; attach a rights-cleared App Review screenshot.
3. Record field-completeness and status, not screenshots containing private information, in evidence.

**Expected result and evidence:** All required product fields are complete and traceable to approvals.

**Failure handling:** Stop for missing localized copy, price, tax, availability, or review asset; do not submit placeholders.

### AURA-MON-008-ST-04 — Set subscription rank and verify transition semantics

This step establishes the intended relationship between monthly and yearly Pro options. In the subscription group’s subscription-order UI, rank the owner-approved order and inspect Apple’s displayed upgrade/downgrade behavior; the expected result is a documented order consistent with the product policy.

**Execution**

1. Open the group’s subscription order/ranking screen.
2. Apply the owner-approved rank for monthly and yearly; do not assume a preferred tier.
3. Record displayed upgrade/downgrade information and rank in evidence.

**Expected result and evidence:** Subscription rank and transition behavior are known before sandbox testing.

**Failure handling:** Stop for an unresolved owner choice or confusing UI behavior; route the behavior to `AURA-QA-010` rather than guessing.

### AURA-MON-008-ST-05 — Apply approved sharing and offer policy

This step ensures StoreKit configuration exactly reflects the commercial decision. On each relevant product’s availability/offers controls, apply only the explicit Family Sharing and introductory-offer decisions from `AURA-MON-002`; the expected result is no accidental trial, discount, or sharing entitlement.

**Execution**

1. Retrieve the approved policy record.
2. Enable or leave disabled Family Sharing and offers exactly as recorded.
3. Record each resulting setting in the redacted evidence index.

**Expected result and evidence:** App Store Connect settings match the owner-approved policy.

**Failure handling:** Missing policy is `human_review_required`; default remains disabled and no offer is invented.

### AURA-MON-008-ST-06 — Reconcile the catalog with the Release paywall

This step prevents review of invisible or undeliverable purchases. On a signed Release-capable build, compare every product ID and benefit with the paywall and feature contract; the expected result is that each visible product loads and delivers its stated value, or is removed from both product scope and shipping UI/code before external review.

**Execution**

1. Inspect the Release paywall and `quality/feature-contracts/FEAT-004.json`.
2. Compare ID, product type, displayed duration/price source, and benefit with the catalog record.
3. File a code/catalog removal task for any template not actually delivered; do not mask it with copy.

**Expected result and evidence:** No catalog product or visible paywall option is unsupported.

**Failure handling:** Block external review until mismatches are resolved and affected evidence is reverified.

### AURA-MON-008-ST-07 — Allow documented Apple propagation before diagnosing loading

This step distinguishes normal propagation from a real StoreKit defect. After saving catalog changes, wait only within Apple’s then-current documented propagation guidance, record start/end times, then test product loading; the expected result is a time-bounded, evidence-based diagnosis.

**Execution**

1. Record the App Store Connect save time and applicable Apple guidance URL/date.
2. Wait no longer than the documented window before calling loading broken.
3. Run the product-loading prerequisite for `AURA-QA-010` and record outcome.

**Expected result and evidence:** Loading status is measured after an appropriate propagation interval.

**Failure handling:** Escalate a post-window failure as StoreKit/catalog investigation; do not repeatedly recreate products.

### AURA-MON-008-ST-08 — Record product status without overstating approval

This step preserves the actual App Store Connect state. Record each product’s displayed status and sandbox visibility in evidence; the expected result is clear separation of `Ready to Submit` or sandbox availability from App Store approval, including the rule that the first subscription is later submitted with an app version.

**Execution**

1. Open each product’s status in App Store Connect.
2. Record the exact visible status and date in the evidence README.
3. State whether sandbox visibility has been observed, without claiming App Store approval.

**Expected result and evidence:** Status evidence is accurate and review readiness is not overstated.

**Failure handling:** Missing/invalid status remains `blocked_external`; do not relabel it approved.

### AURA-MON-008-ST-09 — Preserve the no-backend entitlement architecture

This step confirms catalog setup has not introduced prohibited infrastructure. Verify that no App Store Server Notifications or backend endpoints were added and that current StoreKit entitlements remain the authority; the expected result is catalog configuration compatible with AuraFit’s local-first, no-backend constraint.

**Execution**

1. Compare changes with `.factory/project-context.json` and the StoreKit feature contract.
2. Confirm no server-notification endpoint, secret, or third-party dependency was created.
3. Record the architecture check in evidence.

**Expected result and evidence:** The catalog uses Apple/StoreKit only and retains on-device entitlement authority.

**Failure handling:** Stop and require an approved architecture change if a backend is proposed.

## Acceptance criteria

- [ ] All shipping product IDs resolve in sandbox/TestFlight with localized price and duration.
- [ ] Product type, subscription group, duration, price, availability, tax, and UI copy agree.
- [ ] No invisible or unimplemented IAP is exposed to review.

## Completion and evidence

Use the redacted `quality/evidence/testflight/AURA-MON-008/README.md`; never commit App Store Connect sessions, financial details, or screenshots with personal information.

## Stop and reverification conditions

Missing agreements, banking/tax, app record, access, or owner policy keeps this task `blocked_external`. Reopen after any product-ID, price, availability, benefit, paywall, or StoreKit architecture change.
