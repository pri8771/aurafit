---
id: AURA-QA-009
title: Triage beta findings and make the go/no-go decision
gate: TF-G3
status: planned
ownerBoundary: Owner + agent
dependsOn: [AURA-QA-006, AURA-QA-008]
evidence: quality/evidence/testflight/AURA-QA-009/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-009 — Triage beta findings and make the go/no-go decision

## Task description

This task converts internal/external beta evidence into an explicit, build-specific release decision. It is required so P0/P1 defects and remaining external gates cannot be silently waived. After `AURA-QA-006` and, for external go/no-go, `AURA-QA-008`, classify every finding, update canonical records, enforce rebuild/retest rules, run the checklist, and obtain the owner's bounded decision; the expected change is a traceable `go`, `conditional go`, or `no-go` record with open defects and recovery plan.

## Preconditions and inputs

- `AURA-QA-006` evidence; include `AURA-QA-008` results for external-beta go/no-go.
- Current candidate version/build/commit, `docs/BUGS.md`, `docs/RISKS.md`, affected feature contracts, `docs/STATUS.md`, and `docs/RELEASE_CHECKLIST.md`.
- Evidence index: `quality/evidence/testflight/AURA-QA-009/README.md`; only the owner may select final decision.

## Subtasks

### AURA-QA-009-ST-01 — Classify every finding by release severity

This applies one shared severity rule so blocking behavior is not minimized by wording. Review all beta, crash, telemetry, and QA findings and classify P0 as crash/data loss/privacy/purchase/signing/blocking core loop; P1 as major incorrect result, broken export/restore/accessibility, or repeatable severe UX; P2/P3 as non-blocking polish/future work. Expect every finding to have evidence, severity, build, owner, and rationale.

**Execution**

1. Collect findings from QA task evidence, TestFlight metrics, and feedback aggregates for the candidate build.
2. Assign the defined severity, record rationale/impact/reproduction state, and link supporting evidence.

**Expected result and evidence:** Complete severity register with no unclassified finding.

**Failure handling:** Ambiguous severity is escalated to owner; do not downgrade P0/P1 without written rationale.

### AURA-QA-009-ST-02 — Update bugs, contracts, and risks

This keeps canonical documents aligned with confirmed release evidence so fixes and decisions have an owner. Add confirmed bugs to `docs/BUGS.md`, update affected feature contracts and `docs/RISKS.md`, and link each record to build/evidence/task ID. Expect every confirmed issue has a canonical disposition; do not create duplicate or speculative bugs.

**Execution**

1. For each confirmed finding, search existing canonical bug/contract/risk entries and update the existing record or add one if absent.
2. Add severity, reproducibility, candidate build, evidence link, owner/next action, and task relation.

**Expected result and evidence:** Canonical records accurately reflect all confirmed findings.

**Failure handling:** Missing reproduction remains an observation with follow-up, not a confirmed defect; P0/P1 still blocks while investigated.

### AURA-QA-009-ST-03 — Enforce new-build and retest chain for code fixes

This prevents a fixed source tree from inheriting evidence for an older archive. For any code fix, allocate a new unused build number and repeat `AURA-OPS-005` → affected device tests → `AURA-OPS-012B` → `AURA-OPS-013` → `AURA-QA-006`; include `AURA-QA-010` when StoreKit is affected. Expect the decision references only evidence for the current candidate.

**Execution**

1. Compare candidate commit/build to each reported fix; if source changed, mark prior archive/upload/TestFlight evidence invalid.
2. Follow the named task sequence in order using a new unused build number and attach resulting evidence links.

**Expected result and evidence:** Fixed build has its own complete retest chain.

**Failure handling:** Missing link in chain means `verification_pending`; do not claim fix verified.

### AURA-QA-009-ST-04 — Run and reconcile the release checklist

This exposes each unresolved gate with an accountable next action before a decision is made. Run `docs/RELEASE_CHECKLIST.md` against the current build, record every unchecked gate, owner, blocker, and next action in task evidence, then compare status with `docs/STATUS.md` and completion report. Expect one coherent current-state view.

**Execution**

1. Review checklist line by line using only current candidate evidence.
2. Record checked/unchecked state, evidence path, owner, and next action; reconcile any disagreement with the canonical status documents.

**Expected result and evidence:** All open gates are explicit and documents agree or discrepancy is recorded.

**Failure handling:** Unresolved document disagreement prevents final decision until corrected; do not hide unchecked gates.

### AURA-QA-009-ST-05 — Obtain and record owner go/no-go decision

This makes the release choice explicit and bounded. Present the owner with current defects/gates and the only permitted choices: `go` when no P0/P1 and known limits are accepted; `conditional go` when only an explicitly time-bounded non-code external item remains; `no-go` when a blocker exists, retaining `human_review_required`. Expect decision date, decision-maker, build, open defects, written P0/P1 rationale if any, and rollback/retest plan.

**Execution**

1. Prepare a concise evidence-backed decision packet from ST-01–04.
2. Set `OWNER_REQUIRED_GO_NO_GO_DECISION`; record the selected option, rationale, time bound for conditional go, and rollback/retest plan in evidence and canonical status documents.

**Expected result and evidence:** Build-specific decision is recorded with accountable plan.

**Failure handling:** No owner decision remains `human_review_required`; a P0/P1 cannot be waived without written owner rationale and full documented acceptance.

## Acceptance criteria

- [ ] Decision, date, decision-maker, build, open defects, and rollback/retest plan are recorded.
- [ ] No P0/P1 is waived without a written owner rationale.
- [ ] `docs/STATUS.md`, `RELEASE_CHECKLIST.md`, and completion report agree.

## Completion and evidence

Store the decision packet, severity register, checklist reconciliation, and links in `quality/evidence/testflight/AURA-QA-009/README.md`.

## Stop and reverification conditions

Stop for missing required beta evidence, unresolved document conflicts, or missing owner decision. Any new finding, source/build change, changed legal/compliance state, or retest failure reopens the decision.
