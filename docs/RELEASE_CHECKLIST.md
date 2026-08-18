# Release Checklist

This is the release sign-off view. `TESTFLIGHT_READINESS.md` is authoritative for task
instructions, dependencies, statuses, and evidence. A checkbox may be selected only when the
linked task evidence exists under `quality/evidence/testflight/<TASK-ID>/`.

**2026-08-18:** build `1.0 (3)` was uploaded (13:34:57 local), processed, attached, and version
1.0 was **submitted for App Review at ~13:41 local** ("Waiting for Review"); see the `AS-G1`
section below and `quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md`. The
physical-device gates marked *waived* below were **not run**; the owner consciously waived them for
this submission only (DEC-007, `quality/waivers/1.0-3-device-qa-owner-waiver-2026-08-18.md`).
They stay unchecked.

## `TF-G1` — upload eligible

- [ ] `AURA-OPS-001`: exact release commit is green in CI with 94/94 tests.
- [x] `AURA-OPS-009`: membership, agreements, and roles are verified (Paid Apps Agreement, banking, and tax are not required for a free app — DEC-006). Functionally proven 2026-08-18: the account session uploaded build 3 and submitted version 1.0 for review (`SUBMISSION-2026-08-18.md`).
- [x] `AURA-OPS-010`: explicit App ID and App Store Connect record match `com.pchordia.aurafit`. Proven 2026-08-18: build 3 (`com.pchordia.aurafit`) processed and attached to the record's version 1.0.
- [x] `AURA-OPS-011`: version/build identity and beta scope are frozen — `1.0 (3)`, no in-app purchases (DEC-006); frozen 2026-08-18 and consumed by the upload/submission the same day. Next build `≥ 4`.
- [ ] `AURA-OPS-005`: machine-checkable release-candidate script passes.
- [ ] `AURA-OPS-012A`: signed Release build installs and launches on a physical supported iPhone. Archive half done (the archive was uploaded and processed 2026-08-18); **on-device half not run — waived by the owner for the 1.0 submission on 2026-08-18** (DEC-007).
- [ ] `AURA-QA-002`: camera/import/export/persistence/permission device matrix passes. **Not run — waived by the owner for the 1.0 submission on 2026-08-18** (DEC-007).
- [ ] `AURA-QA-004`: VoiceOver, Dynamic Type, appearance, and supported-layout matrix passes. VoiceOver deferred (DEC-005); **the rest not run — waived by the owner for the 1.0 submission on 2026-08-18** (DEC-007).
- [ ] `AURA-QA-005`: performance/interruption/storage/thermal smoke passes or exceptions are approved. **Not run — waived by the owner for the 1.0 submission on 2026-08-18** (DEC-007).
- [ ] `AURA-OPS-014`: export-compliance determination is recorded and matches the archive. The archive carries `ITSAppUsesNonExemptEncryption = NO` and neither the 2026-08-18 upload nor the submission raised a Missing Compliance prompt; a separately signed owner/legal determination is still not on file.
- [x] `AURA-OPS-012B`: final signed archive validates; immutable identifiers are recorded. `AuraFit-1.0-3.xcarchive` (2026-08-18); IPA SHA-256 `d5300abd…606664`; accepted and processed by App Store Connect 2026-08-18 (`quality/evidence/release/1.0-3-full-free/`).
- [x] `AURA-OPS-013`: upload finishes processing without blocking issues. Done 2026-08-18: `Upload succeeded` / `** EXPORT SUCCEEDED **` at 13:34:57 local via `xcodebuild -exportArchive` (destination upload); processed within ~6 min; build 3 selectable and attached (`quality/evidence/testflight/AURA-OPS-013/UPLOAD-2026-08-18.md`).

## `TF-G2` — internal TestFlight ready

- [x] `AURA-MON-002`: N/A by decision — no prices, offers, or Family Sharing policy exist for a free app (DEC-006, 2026-08-18).
- [x] `AURA-MON-008`: N/A by decision — no StoreKit products or subscription group are shipped (DEC-006, 2026-08-18).
- [x] `AURA-QA-010`: N/A by decision — there is no purchase, restore, expiry, refund, or offline-entitlement path to test (DEC-006, 2026-08-18).
- [ ] `AURA-QA-006`: an internal tester installs from TestFlight and passes the release-build smoke. Not run for build 3; the version went straight to App Review on 2026-08-18 (DEC-007).

## `TF-G3` — external TestFlight ready

- [x] `AURA-MKT-004`: durable public privacy-policy and support URLs return correct content. Verified 2026-08-18: `priyanshchordia.com` `main @ 4372f22` pushed; privacy/support/product pages regenerated with 0 tier words; live `curl` 200 / 0 tier-word hits; the same URLs entered in ASC (`quality/evidence/testflight/AURA-MKT-004/README.md`).
- [ ] `AURA-LEG-003`: EULA/terms choice is approved (subscription legal links are N/A by decision — DEC-006).
- [x] `AURA-LEG-004`: App Privacy answers are published and match the binary. "Data Not Collected" published in ASC 2026-08-18 with the privacy-policy URL; matches `PrivacyInfo.xcprivacy` and the IPA audit (`quality/evidence/testflight/AURA-LEG-004/README.md`).
- [x] `AURA-LEG-005`: age rating and content-rights answers are complete. Entered 2026-08-18: age rating computed 4+; content rights: no third-party content (`quality/evidence/testflight/AURA-LEG-005/README.md`).
- [ ] `AURA-LEG-008`: beta description, What to Test, feedback contact, and reviewer notes are approved. App Review contact and review notes were entered in ASC 2026-08-18 (sign-in not required); the TestFlight beta description / What to Test were not entered because no beta round was run.
- [ ] `AURA-QA-007`: external group exists and the build passes TestFlight App Review. Not run; superseded for 1.0 by the direct App Store submission of 2026-08-18.
- [ ] `AURA-QA-008`: structured beta questions and feedback intake are operating.
- [ ] `AURA-QA-009`: findings are triaged and the owner records an external-beta go/no-go.

## `AS-G1` — App Store submission (added 2026-08-18)

- [x] Store listing entered per `docs/release/APP_STORE_LISTING.md` on 2026-08-18: name/subtitle
      "Private on-device outfit coach", Lifestyle + Photo & Video, promotional text, description,
      keywords, support/marketing/privacy URLs, copyright, content rights none.
- [x] Pricing Free; availability 175 territories (2026-08-18).
- [x] 8 iPhone 6.5" screenshots uploaded from `quality/store-assets/1.0-3/iphone-6.5/`
      (synthetic silhouette fixture subject; owner may re-shoot later).
- [x] Build `1.0 (3)` attached; release option automatic.
- [x] Version 1.0 **submitted for App Review 2026-08-18 ~13:41 local**; ASC "Waiting for Review".
      Evidence: `quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md`.
- [ ] Apple App Review approves 1.0 (3) and the automatic release goes live.
- [ ] Owner re-shoots screenshots with a rights-cleared real subject (optional, post-1.0).

## Already verified in the repository

- [x] Shipping analysis claims match bundled behavior.
- [x] Privacy manifest and usage descriptions match implemented access.
- [x] Unsigned Release builds are warning-free for generic device and Simulator.
- [x] The full suite passes in the audited environment (count recorded per candidate in `quality/evidence/`).
- [x] Test-only controls/assets are excluded or protected from Release.
- [x] Known limitations are documented.
- [x] No tier: no StoreKit configuration, purchase surface, locked template, or scan quota in the app target (`FullFreeProductTests`, DEC-006).
