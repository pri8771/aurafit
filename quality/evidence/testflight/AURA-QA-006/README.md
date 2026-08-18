# AURA-QA-006 evidence — internal TestFlight distribution and smoke

- **2026-08-18 update:** **not run** for build 3; version 1.0 was submitted directly for App Review
  on 2026-08-18 without an internal TestFlight round (DEC-007). Remains open, not done.

- Status: `blocked_external` — no processed build, internal group, eligible tester, TestFlight installation, or telemetry result is evidenced.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-006.md`](../../../../docs/testflight/tasks/AURA-QA-006.md)
- Dependencies: `AURA-OPS-013` must provide the exact processed, action-free candidate; `OWNER_REQUIRED_WHAT_TO_TEST_COPY` must be approved. Never record tester names/emails, invitation links, receipts, Apple IDs, or unredacted screenshots.
- Repository sources for execution: [`TESTFLIGHT_WHAT_TO_TEST.md`](../../../../docs/release/TESTFLIGHT_WHAT_TO_TEST.md), product IDs in `ProductCatalog.swift`, and QA matrices `AURA-QA-002`/`AURA-QA-010`.

## Run header and prerequisites

| Field | Required value |
| --- | --- |
| Candidate | Processed version/build, SHA/archive reference, App Store Connect build status and opaque ID. |
| Group/tester | Approved group name/opaque ID; tester role/count/invite state only. |
| Device/install | iPhone model, iOS, TestFlight app version, clean-install confirmation, TestFlight source. |
| Fixture/account | Licensed/synthetic fixture ID; dedicated sandbox account label only, local `.storekit` disabled. |
| Evidence | Operator role/time-zone, redacted artifact root, defect IDs, aggregate TestFlight telemetry. |

## Matrix

| Done | Subtask | Exact action and required record | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-006-ST-01` internal group | Apps → AuraFit → TestFlight → Internal Testing; search owner-approved group, otherwise create exactly `AuraFit Internal`; record group name/opaque ID/settings only. | One controlled internal group, no duplicate. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-006-ST-02` eligible tester | Users and Access: verify `OWNER_REQUIRED_INTERNAL_TESTER` is an AuraFit account user; add to group; record role/count/invite state only. | At least one eligible internal tester. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-006-ST-03` build/What to Test | Assign exact `AURA-OPS-013` processed build; paste only approved copy from canonical What to Test source; save/reopen and record version/build/source path. | Correct build and approved instructions are available. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-006-ST-04` clean TestFlight install | Delete development AuraFit from physical iPhone → TestFlight install assigned build → launch; verify no debug/local-test controls. | Processed TestFlight candidate launches from TestFlight. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-006-ST-05` identity/expiry | In TestFlight details record version/build/90-day expiration and compare exactly to `AURA-OPS-013`. | Installed identity equals candidate; expiration visible. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-006-ST-06` processed smoke | Execute onboarding; Camera/import→Result; save/share; relaunch/History; product load + one authorized sandbox purchase/restore; privacy/Terms links; confirm no debug/test data. Use fixture/account rules above and log each expected/actual. | Every path works; TestFlight sandbox/real catalog is used; no P0/P1. | Actual by path: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-006-ST-07` telemetry/feedback | Candidate build → TestFlight sessions, crashes, feedback; record check time, aggregate counts, redacted report references, linked defect IDs. | No unexplained crash/session anomaly or untriaged feedback. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Severity, stop, and invalidation

- P0/P1 includes launch/install crash, wrong build identity, core smoke failure, incorrect sandbox/catalog behavior, or privacy/public-link failure. Create a bug, stop smoke, and block `TF-G2`.
- [ ] At least one eligible internal tester installed the exact processed build.
- [ ] Smoke has zero launch crash and zero P0/P1; telemetry/feedback has been reviewed.
- A new archive/upload/build, catalog/product change, or core-flow change requires a new internal smoke.
