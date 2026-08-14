# AURA-QA-002 evidence — physical-device core loop and persistence

- Status: `blocked_external` — evidence pack prepared; no physical-device row is passed.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-002.md`](../../../../docs/testflight/tasks/AURA-QA-002.md)
- Dependency: `AURA-OPS-012A` must provide a signed Release build installed on a supported iPhone.
- Repository facts to verify during execution: `ProductCatalog.freeDailyScanLimit` is `3`; camera/import, cancellation, persistence, and export behavior are governed by `FEAT-001` through `FEAT-004`.
- Never commit fixture images, Photos-library entries, exported media, device UDIDs, or personal data. Store redacted screenshots/traces outside Git and link their approved location below.

## Run header — complete once per build/device/fixture set

| Field | Required value |
| --- | --- |
| Run ID | `YYYYMMDD-<build>-<device>-qa002-<attempt>` |
| Commit SHA / version / build | Exact signed-build source; do not infer from Debug or simulator. |
| Operator role / date-time-zone | Named role, timestamp, and IANA zone; no personal tester contact. |
| Device / iOS / installation source | Model, iOS, storage state, Release install method; TestFlight is not interchangeable here. |
| Fixture register | Licensed/synthetic IDs only: `valid`, `dark`, `bright`, `blurry`, `cropped`, `no-person`, `multiple-person`; private source location outside Git. |
| Artifact root | Redacted external folder/opaque IDs for screenshots, screen recordings, export inspection, and logs. |
| Defect tracker | `docs/BUGS.md` ID or external opaque ID; `none` only after the row passes. |

## Prerequisite and blocker log

| Check | Required evidence / action | Status |
| --- | --- | --- |
| Signed hardware build | Link `AURA-OPS-012A` evidence showing this exact version/build on the device. | `blocked_external` |
| Fixture rights | Record owner/fixture-license confirmation; never add the media to Git. | `blocked_external` |
| Add-only Photos reset | Confirm permissions can be reset without touching unrelated data. | `blocked_external` |
| Quota rollover | Obtain `OWNER_REQUIRED_QUOTA_ROLLOVER_METHOD`; do not change a production clock. | `blocked_external` |
| P0/P1 handling | If any row produces P0/P1, create a bug, mark the row `failed`, stop affected testing, and block `AURA-OPS-012B`. | ready |

## Matrix — one completed record per row

For every row, fill all cells. `actual` must describe the observed screen/state, not “works.”
Use `pending`, `passed`, `failed`, `blocked_external`, or `not_available`; only `passed` satisfies a checkbox.

| Done | Subtask | Preconditions and fixture | Exact procedure | Expected observable change | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-002-ST-01` clean-install camera | Delete AuraFit; signed Release build; `valid` fixture; Camera initially `Not Determined`. | Launch → complete onboarding → Scan → Camera → allow system prompt → capture once → wait → Result. | One credible Result; no stuck progress, duplicate scan, or false success. | Actual: `PENDING`; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-02` clean-install import | Delete/reinstall; `valid` fixture in Photos; Photos initially `Not Determined`. | Onboard → Scan → Import → grant only requested Photos access → select fixture → analyze → Result. | Credible Result and truthful permission UI. | Actual: `PENDING`; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-03` scorecard save/share | Known persisted Result; add-only Photos reset. | Export scorecard → Save to Photos → verify one saved image → Share → verify sheet → cancel/approved non-personal target. | Exactly one usable image; no saved claim before system success; share sheet appears. | Actual: `PENDING`; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-04` entitled reveal export | Active real entitlement documented without credentials; `valid` fixture. | From Result → Reveal → wait once → export → inspect media outside Git. | One usable unwatermarked/entitled reveal export; entitlement source recorded, not local StoreKit evidence. | Actual: `PENDING`; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-05` relaunch/history/favorite/delete | At least one known session and managed media. | Create/open result → force-quit → relaunch → History → inspect image → favorite → relaunch → delete → verify row and managed media absent. | Favorite/history persist once; deletion removes record and its managed asset without unrelated deletion. | Actual: `PENDING`; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-06` Camera recovery/fallback | Reset Camera state separately for allow, deny, Settings recovery, fallback. | Execute all four branches; after deny use app Settings route → enable Camera in iOS Settings → return; also choose import fallback. | Truthful state-specific messaging and usable next action in every branch. | Actual branches: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-07` add-only Photos recovery | Reset Photos permission between allow and deny branches. | Save scorecard with allow; reset → deny → retry save; record system permission and app message. | Allow saves; denial never says saved and exposes truthful retry/recovery. | Actual branches: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-08` input-quality mapping | Seven licensed/synthetic fixture IDs in run header. | Analyze each fixture once through camera/import; record score/result or guidance/error and retry affordance. | Valid input is credible; unsupported input gets truthful, recoverable treatment; no misleading identity/body claim. | Actual mapping: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-09` interruption/retry | Running analysis and approved controlled notification/call route. | Test background/foreground during analysis; cancel then immediate scan; portrait rotation attempt; controlled interruption. Record ordered transitions. | No crash, permanent progress, duplicate work, camera lock, or corrupted history. | Actual sequence: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-10` airplane-mode free loop | Airplane Mode with Wi-Fi/cellular confirmed off; free eligible state. | Enable Airplane Mode → launch/continue → one free analysis → open paywall/product loading without purchase attempt. | Free loop completes; product failure is truthful/recoverable and does not block free use. | Actual: `PENDING`; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-11` quota/rollover | Clean eligible state; approved `OWNER_REQUIRED_QUOTA_ROLLOVER_METHOD`. | Complete three scans → attempt fourth → use approved safe rollover method → retry. Record method and prove no production-clock mutation. | First three count; fourth blocks truthfully; approved next-day reset restores eligibility. | Actual counts/method: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-002-ST-12` prohibited-language review | Screens/artifacts from ST-01 through ST-11; `FEAT-001`/`FEAT-002` contract. | Inspect Result, empty/error, scorecard, export, and paywall-adjacent copy; record screen ID and observed text. | Copy is outfit/photo-craft focused; no attractiveness, body, or identity framing. | Actual screens/text: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Severity and acceptance

- P0: data/privacy breach, crash loop, or false safety claim. P1: core loop, export, persistence,
  permission recovery, quota, or prohibited framing failure. Both block the final archive.
- P2: non-blocking but reproducible quality issue; record and triage. Do not relabel P0/P1 as P2.
- [ ] All twelve rows pass on a supported physical iPhone.
- [ ] Camera and import reach a credible Result; persistence/export/permissions/quota behave as specified.
- [ ] No P0/P1 is open; all failures have a defect record and retest result.

## Reverification

Invalidate affected rows for a new build or changes to camera, analysis, export, persistence,
permission, quota, copy, or StoreKit gating. Missing hardware, fixture rights, or approved quota
rollover remains `blocked_external`; do not substitute simulator evidence.
