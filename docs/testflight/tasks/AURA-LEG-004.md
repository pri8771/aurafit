---
id: AURA-LEG-004
title: Publish App Store privacy answers
gate: TF-G3
status: done
ownerBoundary: Owner
dependsOn: [AURA-MKT-004]
evidence: quality/evidence/testflight/AURA-LEG-004/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-LEG-004 — Publish App Store privacy answers

## Task description

This task publishes the App Store privacy declaration only after it matches the actual Release binary and public policy. It prevents an inaccurate nutrition label; the observable result is a published, human-signed source-to-declaration comparison and a public policy URL. The current audited baseline is local-only/no developer or third-party collection, but an owner must re-audit and make the App Store Connect declaration—never infer a declaration from old evidence.

## Preconditions and inputs

- `AURA-MKT-004` evidence includes a public final privacy URL.
- Required role: Account Holder, Admin, or App Manager with app-information access.
- Read `PrivacyInfo.xcprivacy`, generated Release `Info.plist`, `docs/PRIVACY_POLICY.md`, in-app policy, and `quality/feature-contracts/FEAT-005.json`.

## Subtasks

### AURA-LEG-004-ST-01 — Re-audit actual data behavior

This step inventories current Release behavior before any declaration. Inspect source, linked packages/frameworks, and Release configuration for network calls, third-party SDKs, StoreKit, sharing, Photos, camera, local storage, crash/analytics services, and new diagnostics; the expected result is a dated behavior inventory with each item classified as local, Apple-managed, user-initiated, or developer/third-party collection.

**Execution**

1. Review current source/configuration and `docs/STATUS.md` for changed diagnostics or dependencies.
2. Record each audited category, implementation location, and collection conclusion in evidence.
3. Escalate uncertain SDK/network behavior rather than treating absence of a manifest entry as proof.

**Expected result and evidence:** A reviewable data-flow inventory exists for the exact candidate.

**Failure handling:** Any new collection, transmission, SDK, analytics, or crash service reopens policy/legal review and blocks declaration.

### AURA-LEG-004-ST-02 — Compare every privacy artifact

This step finds conflicts across policy and binary disclosures. Compare ST-01 with `PrivacyInfo.xcprivacy`, generated Release `Info.plist`, in-app policy, hosted policy, and proposed App Store answers; the expected result is a signed comparison showing every source agrees or a correction list.

**Execution**

1. Create a source-to-declaration matrix in the evidence README.
2. Verify permission descriptions, local-storage claims, StoreKit explanation, sharing behavior, tracking, and collected-data claims.
3. Have a human owner sign/date the final comparison.

**Expected result and evidence:** All privacy artifacts describe the same shipping behavior.

**Failure handling:** Do not publish while any artifact conflicts; correct source/policy then re-run the audit.

### AURA-LEG-004-ST-03 — Select the supported collection response

This step enters only the privacy choice supported by ST-01/02. If behavior remains local-only with no developer or third-party collection, select “No, we do not collect data from this app”; the expected result is no invented collection declaration for Apple-managed StoreKit transactions.

**Execution**

1. Confirm the signed matrix supports the local-only conclusion.
2. If it does, use App Store Connect → Apps → AuraFit → App Privacy and select the no-collection response.
3. If it does not, stop for human privacy/legal review to determine current Apple fields; do not guess categories/purposes.

**Expected result and evidence:** The selected privacy answer is traceable to the audited binary.

**Failure handling:** Uncertain collection classification is `human_review_required`, not a “Data Not Collected” pass.

### AURA-LEG-004-ST-04 — Enter only a real public privacy URL

This step connects the listing to the published policy. In App Store Connect → Apps → AuraFit → App Information, enter the final `AURA-MKT-004` privacy-policy URL; the expected result is a tested public HTTPS URL, while the optional privacy-choices URL stays blank unless a real applicable page exists.

**Execution**

1. Copy the final URL from `AURA-MKT-004` evidence, not a preview or placeholder.
2. Paste it into the privacy-policy field and save.
3. Leave privacy choices unset unless `OWNER_REQUIRED_PRIVACY_CHOICES_URL` is an existing public page.

**Expected result and evidence:** App Store Connect stores the same final URL tested logged out.

**Failure handling:** Stop for a missing, private, or mismatched URL.

### AURA-LEG-004-ST-05 — Publish and capture the product-page preview

This step makes the declaration externally visible and confirms rendering. Save/publish App Privacy answers in App Store Connect and open the product-page preview; the expected result is a redacted capture of final state and preview, plus date and operator role.

**Execution**

1. Reconfirm ST-01–04 evidence immediately before publishing.
2. Save the App Privacy answers and open the product-page preview.
3. Store only redacted status/capture references in the evidence README.

**Expected result and evidence:** Published answers and preview correspond to the signed comparison.

**Failure handling:** Validation errors or changed fields are recorded precisely; do not claim published until preview exists.

### AURA-LEG-004-ST-06 — Record automatic reopen triggers

This step keeps the declaration accurate after release changes. Record that any analytics, crash reporting, third-party SDK, network, sharing, storage, diagnostic, permission, or policy change requires ST-01–05 again; the expected result is an explicit maintenance trigger in evidence and downstream release notes.

**Execution**

1. Add the trigger list to this task’s evidence README.
2. Link it from the release change-review process.
3. Do not treat an unchanged App Store Connect form as permanent verification.

**Expected result and evidence:** Future implementation changes reliably reopen privacy review.

**Failure handling:** Any listed change invalidates prior completion until re-audited.

## Acceptance criteria

- [ ] App Store Connect privacy answers are published.
- [ ] Privacy URL is public and matches repository/in-app policy.
- [ ] A human signs the source-to-declaration comparison.

## Completion and evidence

Use `quality/evidence/testflight/AURA-LEG-004/README.md`; redact account data and do not commit App Store Connect credentials or screenshots containing personal information.

## Stop and reverification conditions

Missing public URL/access or unresolved behavior keeps this task `blocked_external`. Reopen on any analytics, crash/SDK, networking, permission, storage, sharing, diagnostics, or policy change.
