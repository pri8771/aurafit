# Release Checklist

This is the release sign-off view. `TESTFLIGHT_READINESS.md` is authoritative for task
instructions, dependencies, statuses, and evidence. A checkbox may be selected only when the
linked task evidence exists under `quality/evidence/testflight/<TASK-ID>/`.

## `TF-G1` — upload eligible

- [ ] `AURA-OPS-001`: exact release commit is green in CI with 94/94 tests.
- [ ] `AURA-OPS-009`: membership, agreements, and roles are verified (Paid Apps Agreement, banking, and tax are not required for a free app — DEC-006).
- [ ] `AURA-OPS-010`: explicit App ID and App Store Connect record match `com.pchordia.aurafit`.
- [ ] `AURA-OPS-011`: version/build identity and beta scope are frozen.
- [ ] `AURA-OPS-005`: machine-checkable release-candidate script passes.
- [ ] `AURA-OPS-012A`: signed Release build installs and launches on a physical supported iPhone.
- [ ] `AURA-QA-002`: camera/import/export/persistence/permission device matrix passes.
- [ ] `AURA-QA-004`: VoiceOver, Dynamic Type, appearance, and supported-layout matrix passes.
- [ ] `AURA-QA-005`: performance/interruption/storage/thermal smoke passes or exceptions are approved.
- [ ] `AURA-OPS-014`: export-compliance determination is recorded and matches the archive.
- [ ] `AURA-OPS-012B`: final signed archive validates; immutable identifiers are recorded.
- [ ] `AURA-OPS-013`: upload finishes processing without blocking issues.

## `TF-G2` — internal TestFlight ready

- [x] `AURA-MON-002`: N/A by decision — no prices, offers, or Family Sharing policy exist for a free app (DEC-006, 2026-08-18).
- [x] `AURA-MON-008`: N/A by decision — no StoreKit products or subscription group are shipped (DEC-006, 2026-08-18).
- [x] `AURA-QA-010`: N/A by decision — there is no purchase, restore, expiry, refund, or offline-entitlement path to test (DEC-006, 2026-08-18).
- [ ] `AURA-QA-006`: an internal tester installs from TestFlight and passes the release-build smoke.

## `TF-G3` — external TestFlight ready

- [ ] `AURA-MKT-004`: durable public privacy-policy and support URLs return correct content.
- [ ] `AURA-LEG-003`: EULA/terms choice is approved (subscription legal links are N/A by decision — DEC-006).
- [ ] `AURA-LEG-004`: App Privacy answers are published and match the binary.
- [ ] `AURA-LEG-005`: age rating and content-rights answers are complete.
- [ ] `AURA-LEG-008`: beta description, What to Test, feedback contact, and reviewer notes are approved.
- [ ] `AURA-QA-007`: external group exists and the build passes TestFlight App Review.
- [ ] `AURA-QA-008`: structured beta questions and feedback intake are operating.
- [ ] `AURA-QA-009`: findings are triaged and the owner records an external-beta go/no-go.

## Already verified in the repository

- [x] Shipping analysis claims match bundled behavior.
- [x] Privacy manifest and usage descriptions match implemented access.
- [x] Unsigned Release builds are warning-free for generic device and Simulator.
- [x] The full suite passes in the audited environment (count recorded per candidate in `quality/evidence/`).
- [x] Test-only controls/assets are excluded or protected from Release.
- [x] Known limitations are documented.
- [x] No tier: no StoreKit configuration, purchase surface, locked template, or scan quota in the app target (`FullFreeProductTests`, DEC-006).
