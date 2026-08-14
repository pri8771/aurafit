# Claude Code Instructions

This repository is registered with the App Factory.

Use this context path before editing:

1. `.factory/repository-map.json`
2. `.factory/project-context.json`
3. `.factory/standard-lock.json`
4. `docs/README.md`
5. Only the canonical documents and feature contracts routed for the current task

Do not scan the entire repository by default. Use the repository map and documentation index to retrieve the smallest authoritative context set.

The `projectType` field is authoritative:

- `new`: establish scope, architecture, contracts, and reusable-library review before broad implementation.
- `existing`: inventory and preserve the current codebase before restructuring.

Search `.factory/library-catalog.json` before implementing cross-cutting infrastructure. Prefer released shared packages plus thin product adapters. Keep generic local modules extraction-ready and record them in `docs/REUSABLE_COMPONENTS.md`.

Do not create duplicate documentation authorities or mix current facts with unapproved proposals. Do not claim `done` when platform checks or human review remain. Record actual verification and limitations.
