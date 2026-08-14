# AURA-LEG-008 evidence

- Status: `human_review_required` — repository drafts are refined against the audited source,
  but owner inputs, a processed build, production StoreKit confirmation, public URLs, and a
  rights-cleared public test image are not evidenced.
- Commit SHA: `OWNER_REQUIRED_COMMIT_SHA_AT_REVIEW`
- Version/build: `OWNER_REQUIRED_PROCESSED_VERSION_AND_BUILD`
- Date/time and time zone: 2026-07-29, America/New_York (draft audit)
- Operator/reviewer role: repository agent; owner approval and App Store Connect operator are
  still required.
- Environment/device: source and canonical-document audit only; no signed device, processed
  TestFlight build, App Store Connect mutation, sandbox purchase, or public-URL check was run.

## Draft artifacts

- `docs/release/TESTFLIGHT_BETA_DESCRIPTION.md`
- `docs/release/TESTFLIGHT_WHAT_TO_TEST.md`
- `docs/release/TESTFLIGHT_REVIEW_NOTES.md`
- `docs/release/TESTFLIGHT_FEEDBACK_QUESTIONS.md`

## Subtask evidence

- [x] `AURA-LEG-008-ST-01` — Beta description is source-audited: iPhone/iOS 18, no account,
  local analysis, local History, and subjective-guidance language match the privacy policy,
  project target, and Release UI. Before submission, the owner must replace
  `OWNER_REQUIRED_FEEDBACK_EMAIL` and approve the exact processed-build copy.
- [x] `AURA-LEG-008-ST-02` — What to Test gives concrete Scan, result, History, permission,
  accessibility, quota/paywall, purchase, and restore actions with expected observations.
  Physical-device, sandbox, and TestFlight outcomes are explicitly verification-pending.
- [x] `AURA-LEG-008-ST-03` — Review notes give a fresh-install route and source-confirmed UI
  labels, permission recovery, local-processing disclosure, and candidate product identifiers.
  The owner must supply `OWNER_REQUIRED_PROCESSED_VERSION_AND_BUILD`, contacts, support/privacy
  URLs, and confirm the processed build plus the production catalog.
- [x] `AURA-LEG-008-ST-04` — The canonical feedback questions cover first result, advice,
  language, permission trust, export value, purchase clarity, failures, and repeat use without
  requesting photos or payment/account data.
- [ ] `AURA-LEG-008-ST-05` — Blocked external. The owner must provide a public,
  rights-cleared full-body test image at `OWNER_REQUIRED_PUBLIC_TEST_IMAGE_URL`, record its
  source/rights basis, remove metadata, and verify anonymous browser access. Do not use a
  repository path, private link, or personal photo.
- [ ] `AURA-LEG-008-ST-06` — Blocked pending owner approval of contacts and final packet,
  public support/privacy URLs from `AURA-MKT-004`, processed-build review, and confirmation
  that no reviewer-only content or owner placeholder is submitted as public App Store copy.

## Acceptance criteria

- [x] All four repository drafts exist and contain only explicit `OWNER_REQUIRED_*` placeholders
  for owner-controlled fields.
- [ ] Owner fills and approves contact fields before external submission.
- [ ] A reviewer can follow the notes on the exact processed build without developer assistance.
- [ ] Review notes describe every non-obvious IAP available in the production catalog and no
  unavailable feature.

## Source audit and results

- Checked: `docs/PRIVACY_POLICY.md`, `docs/TEST_PLAN.md`, `quality/feature-contracts/FEAT-004.json`,
  `AuraFit.xcodeproj/project.pbxproj`, `AuraFit/App/RootView.swift`, Scan, Results, History,
  Settings, Paywall, and StoreKit catalog sources.
- Source-confirmed: iOS deployment target 18.0; no account/backend; selected-photo local
  analysis; system photo picker; Camera recovery; StoreKit product identifiers; local history;
  result share/save controls; Pro and template entitlement boundaries.
- Not verified: signed Release behavior, processed build behavior, Apple product record status,
  localized catalog metadata/prices, sandbox lifecycle, owner contacts, public URLs, or image
  rights/reachability.

## Blockers and owner requests

1. `OWNER_REQUIRED_PROCESSED_VERSION_AND_BUILD`
2. `OWNER_REQUIRED_REVIEW_CONTACT_NAME`, `OWNER_REQUIRED_REVIEW_CONTACT_EMAIL`, and
   `OWNER_REQUIRED_REVIEW_CONTACT_PHONE`
3. `OWNER_REQUIRED_FEEDBACK_EMAIL`
4. `OWNER_REQUIRED_PUBLIC_SUPPORT_URL` and `OWNER_REQUIRED_PUBLIC_PRIVACY_URL` from
   `AURA-MKT-004`
5. `OWNER_REQUIRED_PUBLIC_TEST_IMAGE_URL`, its rights/source record, metadata-removal record,
   and signed-out reachability result
6. `AURA-MON-008` evidence confirming the production catalog’s IDs, product types, localized
   names, prices, durations, benefits, and availability

## Reverification trigger

Reopen this packet after any release UI, permission, privacy-policy, StoreKit ID/benefit,
catalog metadata, support/privacy URL, contact, test-image, or processed build change. Replace
only the relevant `OWNER_REQUIRED_*` field after the owner supplies the value; do not infer it.
