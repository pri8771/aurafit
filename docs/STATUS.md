# Project Status

## Lifecycle status

`mvp_development`

## Release status

`human_review_required` — **AuraFit 1.0 (build 3) was submitted for App Review on 2026-08-18
at ~13:41 local; App Store Connect shows "Waiting for Review".** Apple's decision and the
automatic release are the remaining external gates; the candidate is not `done`.

On 2026-08-18 the owner decided (DEC-006) that AuraFit 1.0 ships as **one full, free product**:
every StoreKit, paywall, quota, watermark, and Pro/tier surface was removed from the code, tests,
project, and docs; `CURRENT_PROJECT_VERSION` was bumped to `3` (builds `1.0 (1)` and `1.0 (2)`
remain in App Store Connect unused); the suite passes 94/94; the release-candidate gate passes;
a signed Release archive of `1.0 (3)` was produced, exported locally, then **uploaded**
(`Upload succeeded` 13:34:57 local), processed by Apple within ~6 minutes, attached, and
submitted with the listing from `docs/release/APP_STORE_LISTING.md`. Physical-device QA was
**not run** — the owner consciously waived it for this submission (DEC-007). Evidence:
`quality/evidence/release/1.0-3-full-free/{README.md,SUBMISSION-2026-08-18.md}`. The canonical
backlog is `TESTFLIGHT_READINESS.md`; Jira and Notion are mirrors only.

## Submitted for App Review (2026-08-18)

Done by the owner's assistant (upload via `xcodebuild`, everything else via the App Store Connect
web UI), owner-approved:

- Build `1.0 (3)` uploaded from `/private/tmp/AuraFit-1.0-3-export/AuraFit-1.0-3.xcarchive`
  with `xcodebuild -exportArchive` (destination upload): "Upload succeeded" / "** EXPORT
  SUCCEEDED **" at **2026-08-18 13:34:57 local**; local-export IPA SHA-256
  `d5300abd3b31a1b1d11692d0d55b072a28736625d052efef8445fbf02e606664`. Processed within ~6 min
  and attached to version 1.0.
- Listing entered per `docs/release/APP_STORE_LISTING.md`: subtitle "Private on-device outfit
  coach", Lifestyle + Photo & Video, content rights none, age rating **4+**, App Privacy **"Data
  Not Collected"** published, **Free** in 175 territories, privacy URL, promotional text /
  description / keywords / URLs / copyright, review contact + notes, sign-in not required.
- 8 iPhone 6.5" screenshots uploaded from `quality/store-assets/1.0-3/iphone-6.5/` (synthetic
  silhouette fixture subject; the owner may re-shoot later). Release option: automatic.
- Version 1.0 **submitted at ~13:41 local** — ASC "Waiting for Review". No TestFlight beta round
  was run for build 3.
- Hosted pages: `priyanshchordia.com` `main @ 4372f22` pushed 2026-08-18; AuraFit
  privacy/support/product pages regenerated with 0 tier words; live `curl` 200, 0 hits
  (`AURA-MKT-004`).
- Builds `1` and `2` remain in App Store Connect unused; next build must be `≥ 4`.

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

- Apple App Review decision for the 1.0 (3) submission of 2026-08-18 ("Waiting for Review") and
  the automatic release going live.
- Physical-device install, launch, and signing inspection of the `1.0 (3)` Release build
  (`AURA-OPS-012A` on-device half, `AURA-QA-002/004/005`) — **not run; consciously waived by the
  owner for the 1.0 submission on 2026-08-18** (DEC-007). Stays open, not satisfied.
- Physical-device camera, import, export/share, relaunch, deletion, interruption, low-storage,
  permission deny/revoke, and supported-device checks — same waiver, not run.
- Dynamic Type, layout, dark appearance, and performance/thermal review (VoiceOver deferred per
  DEC-005) — same waiver, not run.
- TestFlight internal smoke (`AURA-QA-006`) — not run for build 3; the version went straight to
  App Review.
- A separately signed owner/legal export-compliance determination (`AURA-OPS-014`); the bundle
  carries `ITSAppUsesNonExemptEncryption = NO` and no compliance prompt appeared.
- GitHub Actions verification on the frozen candidate; local GitHub authentication was invalid
  at last check.

## Blockers

- None for the submission itself; Apple's review outcome is external and pending.
- Physical-device matrices have not been executed (waived for 1.0 only, DEC-007); any
  resubmission or later version needs build `≥ 4` and must run or explicitly re-waive them.
- Owner line-by-line approval of the hosted privacy page (`AURA-MKT-004` ST-02 /
  `legal_approved` flag in the site repository) is not separately recorded, though the pages
  are live with 0 tier words and were entered in ASC.

## Next action

Owner: watch App Store Connect for the App Review decision on 1.0 (3) and record the outcome
(date, any reviewer message) in `docs/STATUS.md` and
`quality/evidence/release/1.0-3-full-free/`. If rejected, fix on a build `≥ 4`, re-run the gate,
and run (or explicitly re-waive) the device matrices before resubmitting. Optionally re-shoot the
store screenshots with a rights-cleared real subject.

## Gate snapshot

| Gate | Status | Blocking task families |
|---|---|---|
| `TF-G1` upload eligible | `human_review_required` | Build 3 uploaded and processed 2026-08-18 (OPS-013 done); OPS-012A on-device / QA-002/004/005 not run — waived by owner for 1.0 (DEC-007); OPS-014 signed determination not on file |
| `TF-G2` internal beta | `blocked_external` | Internal TestFlight smoke not run for build 3 (MON-002/MON-008/QA-010 are N/A by DEC-006) |
| `TF-G3` external beta | `blocked_external` | MKT-004, LEG-004, LEG-005 done 2026-08-18; LEG-003/LEG-008 open; no external beta round was run |
| `AS-G1` App Store submission | `human_review_required` | Listing entered, build 3 attached, **submitted for App Review 2026-08-18** — awaiting Apple's decision |
