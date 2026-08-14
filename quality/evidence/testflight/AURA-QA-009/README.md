# AURA-QA-009 evidence — beta triage and go/no-go

- Status: `human_review_required` — no internal/external beta findings or owner release decision are evidenced.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-009.md`](../../../../docs/testflight/tasks/AURA-QA-009.md)
- Required inputs: exact candidate commit/version/build, `AURA-QA-006`; for external decision `AURA-QA-008`; current `docs/BUGS.md`, `RISKS.md`, affected feature contracts, `STATUS.md`, and `RELEASE_CHECKLIST.md`. Only owner selects final decision.

## Decision packet header

| Field | Required value |
| --- | --- |
| Candidate identity | Commit/archive/version/build and evidence root; never mix builds. |
| Finding sources | QA task IDs, TestFlight aggregate metrics, sanitized feedback cohort, crash/report references. |
| Decision owner/date | `OWNER_REQUIRED_GO_NO_GO_DECISION`, decision-maker role, timestamp/time-zone. |
| Allowed outcomes | `go`, `conditional go` (only time-bounded non-code external item), or `no-go`. |
| Safety | No P0/P1 waiver without written owner rationale; no personal tester data. |

## Matrix

| Done | Subtask | Exact action and required record | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-009-ST-01` severity register | Collect all candidate findings; classify P0: crash/data loss/privacy/purchase/signing/blocking core loop; P1: major incorrect result/broken export-restore-accessibility/repeatable severe UX; P2/P3 non-blocking. Record evidence, impact, reproduction, owner, rationale per finding. | No finding remains unclassified or silently downgraded. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-009-ST-02` canonical disposition | Search `docs/BUGS.md`, contracts, and `RISKS.md`; update existing/add only confirmed issue with severity, build, evidence, owner/next action/task relation. Keep unconfirmed reports as observations. | All confirmed findings have one canonical disposition. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-009-ST-03` rebuild/retest chain | For any source change, invalidate archive/upload/TestFlight evidence; allocate unused build; require `AURA-OPS-005` → affected device QA → `AURA-OPS-012B` → `AURA-OPS-013` → `AURA-QA-006`, plus `AURA-QA-010` for StoreKit. | Decision uses evidence only for current candidate. | Actual: ; Artifact: ; Defect: ; Status: `not_available` |
| [ ] | `AURA-QA-009-ST-04` checklist reconciliation | Review `RELEASE_CHECKLIST.md` line by line against exact build; list each checked/unchecked gate, evidence path, owner, blocker, next action; compare `STATUS.md`/completion report and record discrepancies. | One coherent current-state view, no hidden gate. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-009-ST-05` owner decision | Present ST-01–04 packet; owner selects allowed outcome; record build, decision/date, defects, P0/P1 rationale, conditional deadline if any, and rollback/retest plan. | Explicit build-specific decision with accountable recovery plan. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |

## Stop and invalidation

- [ ] Decision/date/owner/build/open defects/rollback plan recorded.
- [ ] No P0/P1 waived without written owner rationale.
- [ ] Status, checklist, and completion report agree.
- Stop for missing beta evidence, document conflict, or owner decision. Any finding, source/build, legal/compliance state, or retest change reopens the decision.
