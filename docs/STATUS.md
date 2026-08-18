# Project Status

## Lifecycle status

`mvp_development`

## Release status

`human_review_required` — on 2026-08-18 the owner decided (DEC-006) that AuraFit 1.0 ships as
**one full, free product**: every StoreKit, paywall, quota, watermark, and Pro/tier surface was
removed from the code, tests, project, and docs; `CURRENT_PROJECT_VERSION` was bumped to `3`
(builds `1.0 (1)` and `1.0 (2)` are already consumed in App Store Connect); the suite passes
94/94; the release-candidate gate passes; and a signed Release archive plus a locally exported
App Store IPA of `1.0 (3)` exist under `/private/tmp/AuraFit-1.0-3-export/` — **not uploaded**
(evidence: `quality/evidence/release/1.0-3-full-free/README.md`). Uploading build 3, physical-
device QA, and the App Store Connect metadata/legal items remain owner work. The canonical
backlog is `TESTFLIGHT_READINESS.md`; Jira and Notion are mirrors only.

## Verified on 2026-08-18

- DEC-006 implemented: `Features/Paywall`, `Services/Store` (`StoreKitService`,
  `EntitlementManager`, `ProductCatalog`, `MockPurchaseProvider`), `Resources/AuraFit.storekit`,
  the scheme's StoreKit reference, `PaywallContext`, `EntitlementTier`, the daily-scan counters,
  the export watermark flag, and all Pro/upgrade/restore/quota copy are gone from the app
  target. `StoreKit` is not imported and `otool -L` shows no StoreKit link in the Release binary.
- New guard: `FullFreeProductTests` (5 tests) fails the suite if tier vocabulary reappears in
  the app target, proves every scorecard style renders without an ownership check, and proves
  scans are unlimited. `EntitlementManagerTests` (11) and the daily-rollover model test were
  deleted with the code they tested.
- Full suite on iPhone 17 Pro simulator, iOS 26.4.1: **94/94** (93 unit/integration + 1
  UI smoke), zero failed, zero skipped.
- `scripts/release_candidate_check.sh` (now defaulting to build `3`, 94 tests, plus
  `audit_no_tier_source` and the StoreKit-link/tier-string bundle audit) passed end-to-end
  with the canonical App Factory rules checkout: `RELEASE_CANDIDATE_GATE=PASS`.
- Signed archive `AuraFit-1.0-3.xcarchive` and App Store-method export (`destination: export`)
  produced; IPA verified for bundle ID, `1.0`/`3`, `ITSAppUsesNonExemptEncryption = NO`, no
  `.storekit`, no StoreKit link, and no tier strings; SHA-256 recorded in the evidence file.
- Privacy manifest still declares no collected data, no tracking, and the `C617.1` file-
  timestamp reason; its comment no longer references StoreKit. Privacy policy (doc + in-app),
  support page, review notes, What to Test, beta description, and feedback questions state
  plainly: no account, nothing to buy, all features free.
- `docs/release/APP_STORE_LISTING.md` added with the full App Store Connect metadata set,
  App Privacy / age-rating / export-compliance answers, and the evidence for each.

## Verified on 2026-08-13

- A signed Release device archive of `1.0 (1)` was produced and uploaded to App Store Connect
  (`quality/evidence/testflight/AURA-OPS-012A/UPLOAD-2026-08-13.md`), evidencing a working
  account/agreements session (`AURA-OPS-009`) and an existing app record (`AURA-OPS-010`).
  Build 2 was later consumed as well; both numbers are unavailable for reuse.

## Verified on 2026-07-29

- App Factory registration passes the canonical `iOS_app_factory_rules` 0.4.0 verifier.
- Camera and add-only Photos usage descriptions match the implemented permission paths.
- Shipping copy and the privacy policy accurately describe the deterministic, on-device
  heuristic instead of claiming an absent learned image model.
- The TestFlight backlog validates as 26 canonical task plans and 179 stable subtasks with
  evidence/runbook packs under `quality/evidence/testflight/`.

## Verification pending

- Owner upload of `1.0 (3)` to App Store Connect and Apple processing/TestFlight availability.
- Physical-device install, launch, and signing inspection of the `1.0 (3)` Release build
  (`AURA-OPS-012A` on-device half, `AURA-QA-002/004/005`).
- Physical-device camera, import, export/share, relaunch, deletion, interruption, low-storage,
  permission deny/revoke, and supported-device checks.
- Dynamic Type, layout, dark appearance, and performance/thermal review (VoiceOver deferred per
  DEC-005).
- App Store Connect privacy, age-rating, review-information, and export-compliance entry using
  `docs/release/APP_STORE_LISTING.md`.
- TestFlight internal smoke and any required external Beta App Review.
- GitHub Actions verification on the frozen candidate; local GitHub authentication was invalid
  at last check.

## Blockers

- The `1.0 (3)` IPA has been built and verified but not uploaded; the owner must upload it (or
  re-run the recipe in the evidence file) before any TestFlight or App Store step can proceed.
- Physical-device matrices have not been executed.
- Public support/privacy URLs are published but owner line-by-line approval (`AURA-MKT-004`)
  and App Store Connect metadata entry are still open.

## Next action

Owner: review the DEC-006 change and `quality/evidence/release/1.0-3-full-free/README.md`,
then upload `/private/tmp/AuraFit-1.0-3-export/AuraFit.ipa` (or re-archive from the branch and
upload) to App Store Connect, enter the metadata from `docs/release/APP_STORE_LISTING.md`, and
run the device matrices against build 3.

## Gate snapshot

| Gate | Status | Blocking task families |
|---|---|---|
| `TF-G1` upload eligible | `human_review_required` | Build 3 archive/IPA on file (not uploaded); OPS-013, device QA, and export-compliance sign-off remain |
| `TF-G2` internal beta | `blocked_external` | Internal TestFlight smoke (MON-002/MON-008/QA-010 are N/A by DEC-006) |
| `TF-G3` external beta | `blocked_external` | Public URL approval, privacy/legal metadata, beta packet, Beta App Review |
