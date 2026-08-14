# Agent Instructions

<!-- APP-FACTORY:BEGIN -->
This repository is registered with the App Factory.

Use this context path before editing:

1. `AGENTS.md`
2. `.factory/repository-map.json`
3. `.factory/project-context.json`
4. `.factory/standard-lock.json`
5. `docs/README.md`
6. Only the canonical documents and feature contracts relevant to the task

The `projectType` in `.factory/project-context.json` determines whether new-project or existing-project rules apply.

Before implementing cross-cutting infrastructure, read `.factory/library-catalog.json` and `docs/REUSABLE_COMPONENTS.md`. Prefer a released library plus a thin product adapter; otherwise create a library-ready local module and document it as a candidate.

Do not recursively scan the repository, create duplicate sources of truth, or mark work `done` unless required evidence exists. Use `code_complete` or `verification_pending` when checks remain.
<!-- APP-FACTORY:END -->
