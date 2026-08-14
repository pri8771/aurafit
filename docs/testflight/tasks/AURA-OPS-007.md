---
id: AURA-OPS-007
title: Refresh Jira and Notion mirrors
gate: Non-blocking
status: planned
ownerBoundary: Owner/PM
dependsOn: [This document approved]
evidence: quality/evidence/testflight/AURA-OPS-007/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-007 — Refresh Jira and Notion mirrors

## Task description

This task mirrors repository-owned TestFlight planning into Jira and Notion without creating a competing source of truth. We validate the canonical index and CSV, upsert by stable `AURA-*` IDs, retain canonical links, and record mirror targets because status and task definitions must continue to originate in the repository. The expected result is matching external parent records with no secrets, personal data, duplicate IDs, or mirror-only status/task changes.

## Preconditions and inputs

- `docs/TESTFLIGHT_READINESS.md` is owner-approved and `docs/mirrors/TESTFLIGHT_BACKLOG.csv` exists.
- `OWNER_REQUIRED_JIRA_PROJECT_KEY` and `OWNER_REQUIRED_NOTION_DATABASE_OR_PARENT_PAGE` are supplied with authorized access.
- This task's detailed task-plan files are canonical source material; external tools are mirrors only.

## Subtasks

### AURA-OPS-007-ST-01 — Validate canonical source and CSV

Read the authoritative readiness document and mirror CSV before external updates so imported content matches repository truth. Expected result: task count and `AURA-*` IDs agree and every mirror row can link to its canonical document/task plan.

**Execution**

1. From repository root run `python3 -c "import csv; rows=list(csv.DictReader(open('docs/mirrors/TESTFLIGHT_BACKLOG.csv'))); print(len(rows)); print([r for r in rows if not any('AURA-' in str(v) for v in r.values())])"`; require exit 0.
2. Compare CSV IDs with `docs/TESTFLIGHT_READINESS.md`; record counts/mismatches before any external mutation.

**Expected result and evidence:** Source revision/date, CSV count, IDs, and validation result are recorded.

**Failure handling:** Missing/mismatched source is `source_failure`; do not import.

### AURA-OPS-007-ST-02 — Preserve stable IDs and canonical links

Map every external item to its exact `AURA-*` key and repository source so mirrors can be reconciled later. Expected result: Jira external-ID/custom field and Notion ID property contain the exact canonical task key, and body/properties link to `docs/TESTFLIGHT_READINESS.md` plus the task plan where available.

**Execution**

1. Define one external ID field/property named `AuraFit Task ID` (or owner-approved equivalent); populate exact CSV key without renumbering.
2. Include canonical repository path/link in each record; do not make an external URL the canonical definition.

**Expected result and evidence:** Field/property mapping table is recorded.

**Failure handling:** No stable-ID field is `human_review_required`; stop instead of relying on titles.

### AURA-OPS-007-ST-03 — Upsert Jira records without duplicates

Create or update Jira records by exact stable ID so repeated refreshes do not duplicate tasks. Expected result: one Jira record per CSV parent task, containing concise description, gate/status, dependency, canonical link, and nested subtask checklist where supported.

**Execution**

1. Require `OWNER_REQUIRED_JIRA_PROJECT_KEY`; search the project by exact `AuraFit Task ID` before create.
2. Update exactly one matching issue; create only when zero matches. Preserve existing Jira key and write canonical source/digest/refresh date.

**Expected result and evidence:** Project key, counts created/updated/unchanged, and duplicate-search results are recorded.

**Failure handling:** Multiple matches, missing project, or missing authorization is `blocked_external`; do not guess which issue to overwrite.

### AURA-OPS-007-ST-04 — Upsert Notion records without duplicates

Create or update Notion records by the same stable ID so Notion remains a view of repository planning. Expected result: one database/page record per CSV parent task with canonical link and nested checklist, if supported by the owner-approved target.

**Execution**

1. Require `OWNER_REQUIRED_NOTION_DATABASE_OR_PARENT_PAGE`; search its `AuraFit Task ID` property before creation.
2. Update one match or create zero-match record; include task description/subtasks and canonical source/digest/refresh date.

**Expected result and evidence:** Target identifier and counts are recorded.

**Failure handling:** Multiple matches/missing database/access is `blocked_external`; do not create an unlinked page elsewhere.

### AURA-OPS-007-ST-05 — Enforce repository-originated status and data safety

Ensure mirror refresh cannot leak sensitive information or create independent planning truth. Expected result: statuses are copied from canonical document only, and imported bodies exclude secrets, tester identities, banking/tax data, unredacted screenshots, and private Apple links.

**Execution**

1. Before each upsert, compare external status to canonical status and overwrite only from canonical source; log external-only changes for owner reconciliation rather than adopting them.
2. Scan outgoing fields for credentials, emails, account/recovery details, tester data, banking/tax, raw screenshots, and private Apple URLs; omit them.

**Expected result and evidence:** Safety review and status-source rule are recorded.

**Failure handling:** Sensitive/external-only content is `source_failure` or `human_review_required`; stop synchronization until removed/reconciled.

### AURA-OPS-007-ST-06 — Record mirror targets and refresh evidence

Write a compact audit record so the next refresh knows where and when the mirrors were updated. Expected result: `docs/mirrors/README.md` and task evidence list Jira project/database identifiers, source digest, task count, refresh date, and operator role without personal data.

**Execution**

1. Update `docs/mirrors/README.md` only after successful upserts with non-secret project/database IDs, date/time zone, source revision/digest, and counts.
2. Update `quality/evidence/testflight/AURA-OPS-007/README.md` with subtask/acceptance checkboxes and unresolved blockers.

**Expected result and evidence:** Mirror audit trail is complete and repository remains authoritative.

**Failure handling:** Missing target/partial sync is `blocked_external`/`verification_pending`; record exact completed scope and do not claim full mirror parity.

## Acceptance criteria

- [ ] Task count and IDs match CSV.
- [ ] Jira/Notion items link to canonical repository source.
- [ ] No mirror-only task or status exists.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-007/README.md`.

## Stop and reverification conditions

Missing authorized Jira/Notion target blocks external work. Any canonical plan/CSV change requires source validation and a new mirror digest before refresh.
