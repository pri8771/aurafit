# AURA-OPS-007 evidence

- Status: `blocked_external` — canonical/CSV validation and mirror mapping are ready, but the
  owner has not selected or authorized an AuraFit Jira project or Notion database/parent page.
- Source snapshot date/time and time zone: 2026-07-29, America/New_York
- Operator/reviewer role: repository agent prepared validation and mapping; owner/PM with target
  access is required for external writes.
- External action: none. No Jira issue, Notion page, project, database, or status was created or
  changed.

## Canonical source snapshot

| Source | SHA-256 | Result |
|---|---|---|
| `docs/TESTFLIGHT_READINESS.md` | `3e144b34c067ae9ddfa74e5e12a81eacec2a45491de96fc0cfa63d2959db8983` | canonical index present |
| `docs/mirrors/TESTFLIGHT_BACKLOG.csv` | `1b361959b8ead918dde08068dc161a7aadf73139daed6cd38a7ea0ac98448471` | 26 parent rows; all have `AURA-*` IDs |
| `docs/testflight/tasks/AURA-OPS-003.md` | `e6723c13bd6cd450d4b3b85a4890e94ba460738cb6b3749ef3d7f9b63b79c43a` | 7 stable subtasks |
| `docs/testflight/tasks/AURA-OPS-007.md` | `f1c84319ff75441155b1c0f7341eab29befe034b893aede441528b46146acefe` | 6 stable subtasks |

Validation run from `/Users/pchordia/Documents/other/ios_apps/aurafit`:

```text
ruby scripts/testflight_task_docs.rb --mirror
```

Expected exit is `0`; success output is `Validated 26 task plans and 179 subtasks.` The source
snapshot above was produced by `shasum -a 256` on the named files. Recompute it immediately
before every external refresh; a changed digest invalidates any pending mirror payload.

## Required field mapping

| Canonical field | Jira field/body | Notion property/body | Rule |
|---|---|---|---|
| `External issue ID` | `AuraFit Task ID` custom field | `AuraFit Task ID` text property | exact stable ID; never derive from title |
| `Summary` | Summary | Name/Title | copy CSV value |
| `Type`, `Priority`, `Gate`, `Depends on`, `Owner boundary`, `Labels`, `Status` | corresponding field or labeled body section | corresponding property or labeled body section | repository values overwrite mirror values |
| `Canonical source` | Canonical source link/path | Canonical source link/path | task file remains authoritative |
| task-file SHA-256 | `Canonical SHA-256` field/body | `Canonical SHA-256` property/body | calculate from current task file |
| task description + stable subtasks | issue description + checklist | page body + checklist | copy full current plan; keep IDs intact |
| refresh date/time + operator role | `Mirror refreshed` / audit section | same | role only; no personal contact data |

Every external item must state: “Repository canonical source; do not edit status or task text
here as an authoritative change.” Links should point to the repository index and its exact task
file, not to a mirror-only document.

## Upsert and drift-control procedure

1. Run the validation command and regenerate the source/task SHA-256 values before connecting to
   Jira or Notion. Stop on any validator error, row-count mismatch, missing task path, or digest
   change during the refresh.
2. Require `OWNER_REQUIRED_JIRA_PROJECT_KEY` and
   `OWNER_REQUIRED_NOTION_DATABASE_OR_PARENT_PAGE` with authorized access. `docs/mirrors/README.md`
   records that no AuraFit target has been selected; never guess from visible projects/pages.
3. In Jira, search the selected project for the exact `AuraFit Task ID` value. In Notion, search
   the selected database/page scope for the exact property value. Do not use title search as the
   identity key.
4. Zero exact matches: create one parent record from the CSV plus its full task-plan body.
   One exact match: update that one record in place, retaining its external key/page ID.
   More than one exact match: stop `human_review_required`, record all opaque IDs/counts, and do
   not overwrite, merge, or create another record.
5. Before each update, replace external status/task wording with the canonical payload and record
   any external-only comment or proposed change separately for owner review. Never import an
   external-only status back into this repository automatically.
6. After each system completes, list records by exact stable ID and compare the set/count against
   all 26 CSV IDs. Verify each record’s canonical source path and task-file digest. A missing,
   extra, duplicate, or digest-mismatched record is partial synchronization, not success.
7. Record created/updated/unchanged/duplicate/failed counts, target opaque IDs, source digest,
   date/time, and operator role in this README. Update `docs/mirrors/README.md` only after both
   targets pass the complete parity check.

## Outgoing-content safety filter

Before every external create/update, exclude credentials, certificates, provisioning profiles,
`.p8` files, issuer/key IDs, passwords, sessions, banking/tax data, receipts, Apple IDs,
personal email/phone/contact values, tester identities/invitations, raw screenshots, private
Apple URLs, and private repository paths. A blocked task’s `OWNER_REQUIRED_*` marker is safe to
mirror only when it contains no resolved personal or secret value.

## Subtask evidence

- [x] `AURA-OPS-007-ST-01` — Canonical index/CSV/task plans validate; CSV has 26 rows and no
  row lacking an `AURA-*` ID. Current source digests are recorded above.
- [x] `AURA-OPS-007-ST-02` — Exact Jira/Notion stable-ID, canonical-link, digest, and content
  mapping is defined.
- [ ] `AURA-OPS-007-ST-03` — Blocked external pending selected
  `OWNER_REQUIRED_JIRA_PROJECT_KEY` and authorized access. No Jira upsert was attempted.
- [ ] `AURA-OPS-007-ST-04` — Blocked external pending selected
  `OWNER_REQUIRED_NOTION_DATABASE_OR_PARENT_PAGE` and authorized access. No Notion upsert was
  attempted.
- [x] `AURA-OPS-007-ST-05` — Repository-originated status rule, safety filter, duplicate stop,
  and drift check are prepared.
- [ ] `AURA-OPS-007-ST-06` — Blocked external. No approved targets or successful parity result
  exist, so `docs/mirrors/README.md` remains unchanged.

## Acceptance criteria

- [x] Task count and IDs match CSV in the current repository snapshot.
- [ ] Jira and Notion items link to canonical repository source.
- [ ] No mirror-only task or status exists in selected external targets.

## Reverification trigger

Any canonical index, CSV, task-plan, target, field-schema, or external record change requires a
new validation run and fresh digest before update. A source digest mismatch, duplicate ID, or
partial system result blocks parity and must be resolved before the next refresh.
