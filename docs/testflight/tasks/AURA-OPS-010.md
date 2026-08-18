---
id: AURA-OPS-010
title: Verify App ID and App Store Connect app record
gate: TF-G1
status: done
ownerBoundary: Owner + agent
dependsOn: [AURA-OPS-009]
evidence: quality/evidence/testflight/AURA-OPS-010/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-010 — Verify App ID and App Store Connect app record

## Task description

This task establishes one immutable Apple identity for the shipping AuraFit binary. We locate or create the explicit identifier and iOS app record, then compare Apple fields with Xcode settings because duplicate or mismatched records prevent signing, uploads, and StoreKit attachment. The expected result is one record under team `796XH483R4` for `com.pchordia.aurafit`, with owner-controlled fields recorded and no unresolved duplicate.

## Preconditions and inputs

- AURA-OPS-009 evidence is complete; qualified Apple role is available.
- Target values: team `796XH483R4`, name `AuraFit`, bundle ID `com.pchordia.aurafit`, platform iOS.
- `OWNER_REQUIRED_PRIMARY_LANGUAGE`, `OWNER_REQUIRED_SKU`, and `OWNER_REQUIRED_USER_ACCESS` if creation is needed.

## Subtasks

### AURA-OPS-010-ST-01 — Locate or register the explicit App ID

Find the explicit identifier before creating anything so the shipping bundle remains uniquely tied to the correct team. In developer.apple.com → Certificates, Identifiers & Profiles → Identifiers, search `com.pchordia.aurafit`; if absent and authorized, register an explicit App ID under team `796XH483R4`. Expected result: exactly one explicit matching ID.

**Execution**

1. Select team `796XH483R4`, search the exact bundle ID, and record whether one match exists.
2. If zero matches, choose `+` → App IDs → App, enter description `AuraFit` and the exact explicit bundle ID, then register only after owner authorization.

**Expected result and evidence:** Team, exact ID, explicit-ID type, and Apple identifier reference/status are recorded.

**Failure handling:** An ID owned by another team is `blocked_external`; never create a similar/suffixed ID.

### AURA-OPS-010-ST-02 — Verify only the In-App Purchase capability

Ensure the identifier supports StoreKit while avoiding capabilities the target does not use, because each capability affects entitlements and signing. In the selected App ID's capability page, verify In-App Purchase is enabled and compare other enabled capabilities to the target. Expected result: In-App Purchase enabled; any unused capability is an owner decision rather than silently changed.

**Execution**

1. Open the exact identifier → Capabilities.
2. Record In-App Purchase status and list capability names only; do not enable anything else.

**Expected result and evidence:** `In-App Purchase: enabled` and capability review result are recorded.

**Failure handling:** Capability mismatch is `human_review_required`; stop before changing entitlements/capabilities.

### AURA-OPS-010-ST-03 — Locate or create the iOS app record

Locate the App Store Connect record before upload so Apple can receive the archive against the correct product. In App Store Connect → Apps, search `AuraFit` and the exact bundle ID; if no record exists, choose `+` → New App and create it only with all owner-required fields. Expected result: one iOS app record linked to the explicit ID.

**Execution**

1. Search Apps for `AuraFit`, `AuraFit AI`, and `com.pchordia.aurafit`; record all matches.
2. If none is the exact app, use `+` → New App; set Name `AuraFit`, Platform `iOS`, Bundle ID `com.pchordia.aurafit`, then use owner-approved language/SKU/access values.

**Expected result and evidence:** Apple ID and create/located outcome are recorded.

**Failure handling:** Unavailable name, missing owner field, or duplicate is `blocked_external`; do not guess or create a second record.

### AURA-OPS-010-ST-04 — Validate immutable record fields

Validate the record's identifying fields because SKU and language choices are difficult or impossible to change later. Expected result: name, platform, bundle ID, primary language, SKU, and user access match approved values.

**Execution**

1. In App Store Connect → Apps → AuraFit → App Information, record Name, Bundle ID, Primary Language, SKU, and User Access mode.
2. Require `OWNER_REQUIRED_PRIMARY_LANGUAGE`, `OWNER_REQUIRED_SKU`, and `OWNER_REQUIRED_USER_ACCESS` for missing values; do not infer from repository language or project name.

**Expected result and evidence:** Non-secret values are recorded without user names/emails.

**Failure handling:** A wrong immutable field is `human_review_required`; stop for owner decision.

### AURA-OPS-010-ST-05 — Resolve AuraFit AI duplicates

Rule out a second AuraFit/AuraFit AI record or identifier so uploads and products cannot attach to the wrong app. Expected result: search results show no unresolved duplicate and any historical item has an owner-approved disposition.

**Execution**

1. Repeat searches in Apple Developer Identifiers and App Store Connect Apps for `AuraFit AI` and exact bundle IDs.
2. Record each match's non-sensitive ID/name/status and request owner direction before deletion, transfer, or reuse.

**Expected result and evidence:** Duplicate-check table is complete.

**Failure handling:** Any ambiguous duplicate is `blocked_external`; do not delete or rename records.

### AURA-OPS-010-ST-06 — Record Apple identity values

Persist a redacted identity mapping for later release tasks. Expected result: evidence includes App Store Connect Apple ID, SKU, primary language, bundle ID, team, and access mode, with no person/email data.

**Execution**

1. Update `quality/evidence/testflight/AURA-OPS-010/README.md` with one checkbox per subtask.
2. Include Apple ID, SKU, primary language, bundle ID, team, access mode, timestamp, and operator role.

**Expected result and evidence:** A complete identity record exists under the task evidence path.

**Failure handling:** Missing value leaves the relevant criterion unchecked and task blocked.

### AURA-OPS-010-ST-07 — Compare Apple identity to Release settings

Compare Apple data to the Release target to catch a mismatch before signing. Expected result: `PRODUCT_BUNDLE_IDENTIFIER`, development team, display name, deployment target, iPhone device family, and category intent agree with the app record or have a documented owner decision.

**Execution**

1. From repository root run `xcodebuild -showBuildSettings -project AuraFit.xcodeproj -scheme AuraFit -configuration Release > /tmp/AURA-OPS-010-build-settings.txt`; require exit 0.
2. Inspect `PRODUCT_BUNDLE_IDENTIFIER`, `DEVELOPMENT_TEAM`, `INFOPLIST_KEY_CFBundleDisplayName`, `IPHONEOS_DEPLOYMENT_TARGET`, and `TARGETED_DEVICE_FAMILY`; compare to Apple evidence and project category intent.

**Expected result and evidence:** Redacted matching values and `/tmp` output path are recorded.

**Failure handling:** Any mismatch is `source_failure` or `human_review_required` as appropriate; stop before archive/signing.

## Acceptance criteria

- [ ] Explicit App ID and app record exist under correct team.
- [ ] Bundle ID matches exactly and is immutable.
- [ ] Record values are captured in evidence.
- [ ] No unused capability or duplicate remains unresolved.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-010/README.md`.

## Stop and reverification conditions

Stop for bundle ownership conflict, unavailable name, duplicate, unknown SKU/language, wrong legal entity, or capability mismatch. Reverify after any App ID, record, entitlement, or Release-build-setting change.
