---
id: AURA-MON-002
title: Approve initial prices and offer policy
gate: TF-G2
status: human_review_required
ownerBoundary: Owner + agent research
dependsOn: []
evidence: quality/evidence/testflight/AURA-MON-002/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

> **Not applicable — DEC-006 (2026-08-18).** AuraFit 1.0 ships as one full, free product with
> no StoreKit code, products, prices, or purchase/restore paths. This task is retained for
> history and for any future monetization decision; do not execute it for the 1.0 release.

# AURA-MON-002 — Approve initial prices and offer policy

## Task description

This task creates the owner-approved commercial policy for the four proposed StoreKit products. It prevents an agent from inventing prices, territories, trials, discounts, or Family Sharing; the observable result is one dated decision that the paywall and catalog can implement consistently. Research only from primary product pages, compare bounded options, then stop until `OWNER_REQUIRED_COMMERCIAL_APPROVAL` is recorded in `docs/DECISIONS.md`.

## Preconditions and inputs

- Read `docs/PLAN.md` §6.7, `docs/DECISIONS.md`, `quality/feature-contracts/FEAT-004.json`, and this task's evidence index.
- Treat the current intended free experience as three scans/day; verify it against the shipping Release UI before relying on it.
- Never enter prices or offers in App Store Connect in this task.

## Subtasks

### AURA-MON-002-ST-01 — Refresh comparable-price evidence

This step supplies dated pricing context for an owner decision. Record comparable products from their actual product pages—not search snippets—in the evidence index with country, currency, product, billing period, observed date/time, and source URL; the result is traceable research, not a recommended price.

**Execution**

1. Read the monetization and market-research material in `docs/PLAN.md`.
2. For each comparable whose price may have changed, open its official product or App Store page and record the required fields in `quality/evidence/testflight/AURA-MON-002/README.md`.
3. Mark inaccessible or ambiguous prices as unavailable; do not convert currencies or infer tiers.

**Expected result and evidence:** Dated, source-linked observations exist in the evidence README.

**Failure handling:** If a source cannot be verified, exclude it and record `verification_pending`; do not use snippets as evidence.

### AURA-MON-002-ST-02 — Verify the value each product would sell

This step checks that the proposed catalog corresponds to real Release behavior, because a price cannot rescue an unavailable entitlement. Inspect the Release paywall and `FEAT-004` for the free limit, Pro benefits, and Streetwear/Soft Luxury delivery; the result is a pass/fail list of benefits that can truthfully be sold.

**Execution**

1. Confirm the free path is three scans per day in the current Release configuration.
2. List exact Pro benefits and the distinct benefit delivered by each template product.
3. If a template has no actual distinct delivery, record it as an explicit removal decision required before catalog setup.

**Expected result and evidence:** Evidence maps every proposed product to an implemented, reviewable benefit.

**Failure handling:** Stop with `human_review_required` if a claimed benefit is absent or ambiguous; do not create an IAP for it.

### AURA-MON-002-ST-03 — Prepare two bounded subscription structures

This step gives the owner comparable monthly/yearly choices instead of a vague recommendation. Use only observed inputs and explicit formulas; the result is at least two named options showing monthly price, yearly price, annual effective monthly price, annual discount, customer expectation, and risk.

**Execution**

1. Draft at least two structures in the evidence README without calling either approved.
2. Calculate effective monthly price as yearly price divided by 12; calculate discount against 12 monthly payments only when both prices are supplied.
3. State the customer expectation and commercial risk for each option without presenting legal or financial advice.

**Expected result and evidence:** Two complete, comparable options are ready for owner selection.

**Failure handling:** If a required price is missing, write `OWNER_REQUIRED_PRICE_*`; do not estimate it.

### AURA-MON-002-ST-04 — Obtain storefront and territory decisions

This step fixes where the catalog will be available, because App Store Connect availability must reflect an owner decision. Present base storefront/currency and initial territory choices to the owner; the result is `OWNER_REQUIRED_BASE_STOREFRONT`, `OWNER_REQUIRED_BASE_CURRENCY`, and `OWNER_REQUIRED_TERRITORIES` resolved in the decision record.

**Execution**

1. Present the bounded options and research from ST-01–03.
2. Ask the owner to select a base storefront/currency and territory availability.
3. Record the exact approved values and rationale in `docs/DECISIONS.md`.

**Expected result and evidence:** A dated owner decision identifies storefront, currency, and territories.

**Failure handling:** Leave `human_review_required` and stop if the owner has not selected values.

### AURA-MON-002-ST-05 — Obtain offer and sharing decisions

This step separately decides introductory offers/trials, Family Sharing, and launch discounts so they are not silently enabled. The expected change is an explicit on/off decision for each policy item, with off remaining the default until approved.

**Execution**

1. Present `OWNER_REQUIRED_INTRO_OFFER_POLICY`, `OWNER_REQUIRED_FAMILY_SHARING_POLICY`, and `OWNER_REQUIRED_LAUNCH_DISCOUNT_POLICY`.
2. Record the owner's explicit enabled/disabled decision and rationale in `docs/DECISIONS.md`.
3. Do not set any duration, eligibility, or discount level unless the owner supplies it.

**Expected result and evidence:** All three policies are explicit and suitable for later catalog entry.

**Failure handling:** Missing approval remains `human_review_required`; do not infer commercial consent.

### AURA-MON-002-ST-06 — Reconcile paywall language with the approved policy

This step ensures the user-visible purchase flow can state only facts the catalog will deliver. Compare Release paywall copy with approved benefits, duration, renewal, price source, restore behavior, and legal links; the expected result is either a consistency pass or a separately filed code/copy task.

**Execution**

1. Inspect `quality/feature-contracts/FEAT-004.json` and the Release paywall implementation.
2. Compare each claim with ST-02 and approved decisions; price must come from StoreKit, not hard-coded copy.
3. Record discrepancies as a specific follow-up task before catalog configuration.

**Expected result and evidence:** No proposed StoreKit configuration conflicts with shipping UI.

**Failure handling:** Stop for a source/copy change when copy is untruthful or a required legal link is unavailable.

### AURA-MON-002-ST-07 — Record the approval before catalog configuration

This step makes the commercial choice durable and auditable. The owner records one selected option, its sources/date, product prices or removals, territories, and policies in `docs/DECISIONS.md`, then updates applicable monetization text in `docs/PLAN.md`; the expected result is a canonical input for `AURA-MON-008`.

**Execution**

1. Confirm all owner-required fields from ST-04 and ST-05 are resolved.
2. Have the owner add the approval and rationale to `docs/DECISIONS.md` and update `docs/PLAN.md`.
3. Add a redacted pointer and date to this task's evidence README.

**Expected result and evidence:** One owner-approved, internally consistent commercial policy exists.

**Failure handling:** Do not advance to catalog configuration without this record; retain `human_review_required`.

## Acceptance criteria

- [ ] Monthly, annual, Streetwear, and Soft Luxury prices or explicit removal decisions are owner-approved.
- [ ] Territory, offer, trial, and Family Sharing decisions are explicit.
- [ ] The decision identifies sources and observation dates.
- [ ] Code, paywall, and catalog scope are internally consistent.

## Completion and evidence

Use `quality/evidence/testflight/AURA-MON-002/README.md`; do not store financial account details or private research credentials.

## Stop and reverification conditions

No owner commercial approval or any unimplemented template benefit keeps this task `human_review_required`. Reopen it when product benefits, paywall claims, territories, or commercial policy change.
