# External Task Mirrors

`TESTFLIGHT_BACKLOG.csv` is the import copy for Jira and Notion. The canonical source is
`../TESTFLIGHT_READINESS.md`.

Mirror rules:

1. Update the canonical Markdown first.
2. Regenerate or edit the CSV to match it.
3. Import by stable `External issue ID` so refreshes update instead of duplicate.
4. Copy the complete task description and nested stable-subtask checklist from the canonical
   `docs/testflight/tasks/<TASK-ID>.md` file into the external card.
5. Do not treat status or wording changed only in Jira/Notion as authoritative.
6. Before a refresh, review external comments manually and incorporate approved changes into
   the repository.
7. Store the canonical task path and SHA-256 digest on the mirror item so drift can be detected.
   The external copy never becomes an authoring source.

The CSV contains no credentials, tester identities, contact details, or private Apple data.

## External-target discovery — 2026-07-29

- Jira connection is healthy, but no AuraFit project or existing `AURA-*` issue was found.
  Visible create targets are `AIP`, `DT`, `HIND`, `MALA`, `OR`, `PCH`, and `UN`.
  Do not guess the project. The owner must choose a project key; the Jira spec-to-backlog
  workflow must then present the Epic plus 26-ticket breakdown for confirmation before creation.
- Notion connection is healthy, but search found no AuraFit page/database. The apparent
  candidate, **Post-MVP Task Board**, belongs under **Hindsight — Planning Hub** and contains
  `E*` tasks, so it was not mutated. The owner must provide an AuraFit database/page target or
  authorize creation of a dedicated **AuraFit TestFlight Mirror** database.

Until those targets are selected, this CSV is the complete, validated mirror payload and
`AURA-OPS-007` remains `planned`.
