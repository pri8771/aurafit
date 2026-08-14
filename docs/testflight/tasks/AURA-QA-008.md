---
id: AURA-QA-008
title: Run the structured beta feedback loop
gate: TF-G3
status: planned
ownerBoundary: Owner
dependsOn: [AURA-QA-007]
evidence: quality/evidence/testflight/AURA-QA-008/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-008 — Structured beta feedback loop

## Task description

This task turns external beta use into comparable, privacy-safe evidence rather than an unstructured stream of opinions. It matters because release decisions need known cohort, questions, cadence, and actionable follow-up. Once `AURA-QA-007` provides an approved external cohort, execute the five steps below, retain only sanitized aggregates in Git, and convert each actionable observation into a defect/task or written rationale; the expected change is a decision-ready feedback record.

## Preconditions and inputs

- `AURA-QA-007` external distribution and at least one external install.
- Canonical questionnaire: `docs/release/TESTFLIGHT_FEEDBACK_QUESTIONS.md`.
- Owner-approved feedback cadence, communication route, consent/retention policy for voluntarily shared media.
- Evidence index: `quality/evidence/testflight/AURA-QA-008/README.md`.

## Subtasks

### AURA-QA-008-ST-01 — Use the canonical question set

This standardizes responses so findings can be compared across testers. Send every tester the core questions from `docs/release/TESTFLIGHT_FEEDBACK_QUESTIONS.md` without changing question meaning, record cohort dates and aggregate response count, and retain any individual responses outside Git. Expect a documented uniform question source and coverage count.

**Execution**

1. Read the canonical question file and prepare the approved communication using its exact core questions.
2. Send it through the owner-approved route, record send date/cohort count, and store only aggregate response progress in evidence.

**Expected result and evidence:** Every tester receives the same core questions; evidence names source, dates, and counts.

**Failure handling:** Missing approved contact route leaves outreach `blocked_external`; do not substitute private data into Git.

### AURA-QA-008-ST-02 — Cover required feedback topics

This ensures the feedback set tests product risk, not only general liking. Verify the collected questions/responses cover first-result completion, advice credibility, confusing language, permission trust, export value, purchase clarity, failure/crash, and willingness to use again. Expect one aggregate coverage entry per topic and a gap note if no response addresses it.

**Execution**

1. Map canonical questions and received aggregate answers to the eight required topics.
2. Record topic coverage/count, common theme, and unresolved gap without quoting identifying feedback.

**Expected result and evidence:** All eight topics are represented or explicitly marked insufficient.

**Failure handling:** Missing topic coverage is a feedback-quality gap, not a pass; request the next cadence include it.

### AURA-QA-008-ST-03 — Review feedback and TestFlight signals on cadence

This catches problems between survey rounds using Apple’s feedback, crash, and session indicators. On the owner-approved fixed cadence, inspect TestFlight screenshot feedback, crash/session metrics, and feedback email, recording check time, candidate build, aggregate findings, and linked defects. Expect a repeatable review log rather than ad hoc checking.

**Execution**

1. Set `OWNER_REQUIRED_FEEDBACK_REVIEW_CADENCE` and record it in task evidence.
2. At each review, inspect the three named sources and add sanitized aggregate result plus any bug/task link.

**Expected result and evidence:** Cadenced reviews and outcome counts are recorded.

**Failure handling:** No access to a source is `blocked_external`; do not report it as reviewed.

### AURA-QA-008-ST-04 — Handle voluntarily shared personal media safely

This prevents tester photos from entering source control or remaining longer than necessary. Do not ask for personal photos in repository channels; if voluntarily sent, keep it outside Git, document consent and retention location/date under owner policy, use only if needed to reproduce, then delete it when no longer needed. Expect no personal media in the repository.

**Execution**

1. State the no-Git rule in feedback communication and use `OWNER_REQUIRED_MEDIA_CONSENT_RETENTION_POLICY` for any voluntary media.
2. Record only a non-identifying consent/retention/deletion status in evidence; never copy media or identifying content into docs.

**Expected result and evidence:** Personal media remains outside Git with lifecycle handling documented.

**Failure handling:** If personal media appears in a proposed repository change, remove it before proceeding and notify owner.

### AURA-QA-008-ST-05 — Publish sanitized aggregate findings and disposition

This makes feedback actionable for release triage while preserving tester privacy. Aggregate themes, counts, build/cohort/date range, and evidence links; for every actionable observation create a bug/task or add an explicit owner-approved “won’t fix” rationale. Expect no unowned actionable finding and no personal data.

**Execution**

1. Summarize only aggregate findings in the task evidence index.
2. Link each actionable item to `docs/BUGS.md`, a canonical task ID, or a recorded owner rationale.

**Expected result and evidence:** Sanitized findings have complete dispositions and can feed `AURA-QA-009`.

**Failure handling:** Undispositioned actionable finding blocks feedback-loop completion; privacy-bearing content must not be committed.

## Acceptance criteria

- [ ] Cohort, dates, response count, common questions, and sanitized results are recorded.
- [ ] Every actionable observation becomes a bug/task or explicit “won’t fix” rationale.

## Completion and evidence

Use `quality/evidence/testflight/AURA-QA-008/README.md` for aggregate-only findings, cadence logs, and disposition links.

## Stop and reverification conditions

Stop until external cohort/cadence/contact authority exists or any evidence contains personal data. A new external build or material beta-flow change begins a new feedback cohort and requires fresh aggregation.
