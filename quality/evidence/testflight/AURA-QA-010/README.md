# AURA-QA-010 evidence — StoreKit sandbox and TestFlight purchase matrix

- Status: `blocked_external` — StoreKit source audit is recorded below; no Apple sandbox/TestFlight scenario has passed.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-010.md`](../../../../docs/testflight/tasks/AURA-QA-010.md)
- Dependencies: `AURA-MON-008` production catalog evidence and `AURA-OPS-012A` signed physical Release build. ST-09 also requires `AURA-QA-006` processed TestFlight install.
- Repository audit facts (not sandbox proof): products requested are `com.aurafit.pro.monthly`, `com.aurafit.pro.yearly`, `com.aurafit.template.streetwear`, and `com.aurafit.template.softluxury`; free daily limit is 3; Pro unlocks unlimited scans, watermark removal, reveal video, and all templates; a template unlock must not grant Pro. `AuraFit.storekit` exists for local development and must be disabled for every claimed row.
- Never commit sandbox credentials, receipts, transaction IDs, account email, or Apple dialog screenshots containing personal data.

## Run header, configuration proof, and blockers

| Field | Required value |
| --- | --- |
| Run ID / commit / version-build | Exact signed Release or processed TestFlight build. |
| Device / iOS / source | Physical iPhone, OS, install source (`signed-release` or `testflight`). |
| Account label | Redacted dedicated Sandbox account label only; credentials remain owner-controlled outside Git. |
| Catalog proof | Link redacted `AURA-MON-008` product status evidence for all four IDs. |
| Local configuration proof | Xcode scheme → Run → Options → StoreKit Configuration = `None`; record redacted screenshot/text before ST-02 onward. |
| Artifacts / defects | Redacted external paths and bug IDs; actual Apple event/app observation timestamps for lifecycle tests. |

| Prerequisite | Required result | Status |
| --- | --- | --- |
| Dedicated sandbox identity | `OWNER_REQUIRED_SANDBOX_TEST_ACCOUNT` exists; no personal account substitution. | `blocked_external` |
| Real catalog and signed device build | `AURA-MON-008` and `AURA-OPS-012A` evidence matches candidate build. | `blocked_external` |
| Local StoreKit disabled | No `.storekit` configuration is active; otherwise invalidate and restart the matrix. | `blocked_external` |
| Processed TestFlight build | `AURA-QA-006` evidence exists before ST-09. | `blocked_external` |

## Matrix

| Done | Subtask | Preconditions / setup | Exact procedure | Expected observable change | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-010-ST-01` dedicated Sandbox account | Authorized App Store Connect role; owner-controlled secure credentials. | Users and Access → Sandbox (or current Apple equivalent) → create account; record redacted label/status only. | Isolated usable Sandbox account; no credential or receipt enters Git. | Actual account status: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-02` physical sandbox configuration | ST-01, catalog, signed physical build. | Set scheme StoreKit Configuration to None → install candidate → record device/build/config → sign in only at Apple sandbox prompt. | Physical run has no local `.storekit` influence. | Actual configuration: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-03` purchase/restore variants | Separate/reset eligible state for each variant; ST-02 proof. | Test monthly, yearly, cancellation, pending/Ask-to-Buy if Apple makes available, template-only, same-install restore, reinstall+restore, restore-empty; record product/initial state/dialog/final entitlement. | Accurate entitlement and truthful message for every available variant; unavailable Ask-to-Buy=`not_available`, not pass. | Variant records: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-04` offline cache/load | Verified active entitlement for cache branch; Airplane Mode confirms Wi-Fi/cellular off. | Online entitlement → Airplane Mode → force-quit/relaunch → inspect gated benefits; separately open product loading offline without purchase. | Cached entitlement behavior is truthful; product failure is recoverable; free use remains available. | Actual cache/load: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-05` lifecycle/interruption | Apple-supported sandbox controls and actual accelerated renewal timing. | Exercise/observe renewal, billing retry, expiration, refund/revoke, interrupted purchase; log Apple event time, app observation time, product, UI/entitlement. | StoreKit-driven updates with clear messaging; unavailable Apple control=`not_available`. | Event records: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-06` Pro benefits | Verified active monthly or yearly entitlement. | Test >3 scans, watermark removal, reveal, templates; compare before/after against free state using synthetic fixtures. | All and only Pro benefits unlock. | Product/quota/benefits: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-07` template isolation | No Pro entitlement; one template product eligible. | Purchase Streetwear or Soft Luxury → inspect template and Pro gates → Restore → record messages/final entitlements. | Purchased template only unlocks itself; Pro stays locked; Restore feedback is accurate. | Product/final state: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-08` remove Pro after lifecycle event | Verified expiration/revocation from ST-05. | Foreground/relaunch until StoreKit update → inspect paywall, quota, watermark, reveal, templates; log Apple/app times. | Pro is removed after verified event; non-Pro/template state remains correct. | Event/final state: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-010-ST-09` TestFlight smoke | `AURA-QA-006` processed install; local StoreKit disabled. | Delete development build → install TestFlight build → product load, one purchase/restore, Pro benefit, failure-message smoke. | Processed build demonstrates real catalog/sandbox behavior; exact TestFlight version/build logged. | Actual smoke: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Severity, acceptance, and reverification

- P1: wrong product, unverified/incorrect entitlement, broken restore, free-loop blockage, inaccurate purchase state, template grants Pro, persistent Pro after verified revocation/expiration, or false recovery success. Stop the affected release path and create a defect.
- [ ] All scenarios contain expected/actual evidence and a real build source.
- [ ] Local `.storekit` is disabled for every claimed sandbox/TestFlight row.
- [ ] Relauch/restore and verified revocation/expiration produce correct entitlement transitions.
- [ ] Product failures are truthful and recoverable.
- New product IDs/catalog state, entitlement/paywall code, build, or Apple lifecycle behavior invalidates affected rows. Missing Apple controls are `not_available`/`blocked_external`, never passed.
