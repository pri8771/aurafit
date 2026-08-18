# AURA-QA-005 evidence — performance, lifecycle, storage, and thermal smoke

- **2026-08-18 update:** **not run**; consciously waived by the owner for the 1.0 (3) App Store
  submission on 2026-08-18 (DEC-007, `quality/waivers/1.0-3-device-qa-owner-waiver-2026-08-18.md`).
  Remains open, not done, for any later build.

- Status: `blocked_external` — no physical measurements or budget approvals exist yet.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-005.md`](../../../../docs/testflight/tasks/AURA-QA-005.md)
- Dependency: `AURA-OPS-012A` signed Release build on physical iPhone. Simulator may prepare safe storage only; it cannot satisfy a measurement row.
- Use one fixed licensed/synthetic fixture ID per comparable run. Keep raw Instruments traces and device analytics outside Git; link only a redacted path/opaque ID.

## Measurement header and blocker log

| Field | Required value |
| --- | --- |
| Run ID / commit / version-build | Exact candidate identity, never inferred from Debug. |
| Device / iOS / battery / thermal start | Model, OS, charge range, initial thermal state, free storage. |
| Fixture / method / repetitions | Fixture ID, Instruments/signpost/stopwatch method, start-stop definition, every sample and units. |
| Artifact root | Redacted trace, Organizer/crash lookup, and measurement record outside Git. |
| Owner-required input | `OWNER_REQUIRED_HISTORY_SEED_METHOD`, `OWNER_REQUIRED_SAFE_LOW_STORAGE_METHOD`, `OWNER_REQUIRED_PERFORMANCE_BUDGET_APPROVAL`. |

## Matrix

| Done | Subtask | Preconditions / setup | Exact procedure | Expected observable change | Actual metrics / artifact / defect / status |
| --- | --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-005-ST-01` launch/result timing | Force-quit candidate; fixed fixture; choose method and repeat count before timing. | Time cold launch to usable initial screen; separately time accepted image to usable Result; retain all samples in seconds. | Reproducible numeric baselines, method, sample count, and trace/record; no invented threshold. | Samples: ; Method: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-005-ST-02` 50-session History | Approved seed method or 50 synthetic sessions; record source. | Open History; scroll top→bottom→top repeatedly; observe responsiveness/memory with Instruments where available. | Usable scrolling without main-thread stall or unexplained memory spike. | Seed/memory/observations: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-005-ST-03` repeated scans/camera | Five approved fixtures and five-minute camera-coach session. | Complete five scans sequentially; record before/after memory/thermal where observable; keep coach active 5 min then exit. | All scans finish; no crash/runaway growth/overheat warning; camera stops cleanly. | Per-scan/thermal/memory: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-005-ST-04` background/foreground | Camera, analysis, scorecard render, and active-entitlement reveal render each available. | Start each operation separately → background → foreground → inspect screen/history/export state; record timing/order. | Coherent completion/pause/cancel/recovery; no corruption, duplicate output, or stuck operation. | Per-operation state: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-005-ST-05` safe low storage | Owner-approved disposable-device or safe simulator preparation; pre-space recorded. | Apply approved constraint → bounded import/export/history action → record UI/result → release test storage → verify recovery and post-space. | Truthful failure/retry and intact data; no false success or corruption. | Method/pre-post space: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-005-ST-06` crash/hang inspection | ST-01–ST-05 attempted; candidate version/build known. | Xcode → Window → Organizer → Crashes; use available device diagnostics; filter candidate; record zero findings or redacted timestamp/classification. | Explicit candidate diagnostic result, no unexplained AuraFit crash/hang. | Findings: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-005-ST-07` budget decision | Completed ST-01–ST-06 baseline rows and `docs/TEST_PLAN.md`. | Compare proposed budgets to all samples; request owner approval if absent/unrealistic; preserve rationale and decision source. | Approved budgets tied to measurements, or `human_review_required`; a baseline alone is not a pass. | Decision/budgets: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Severity, acceptance, and reverification

- P0/P1: crash, hang, runaway memory, permanent camera lock, corrupted persistence, false storage success, or blocked core operation. Create a defect and block archive.
- [ ] No P0/P1 remains from the seven rows.
- [ ] Timings, repeated-use, lifecycle, storage, thermal, and crash/hang results are recorded with evidence.
- [ ] Owner-approved budgets exist or status is honestly `human_review_required`.
- Retest after build, camera/analysis/history/rendering/lifecycle change, or budget change. Missing safe method/device is `blocked_external`, never a simulated pass.
