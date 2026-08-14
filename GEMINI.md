# Gemini Agent Instructions

This repository is registered with the App Factory.

Use this context path before changing code:

1. `.factory/repository-map.json`
2. `.factory/project-context.json`
3. `.factory/standard-lock.json`
4. `docs/README.md`
5. Only the canonical files routed for the current task

Do not scan every file by default. Retrieve the smallest authoritative context set from the repository map and documentation index.

Treat `projectType` as authoritative. Existing projects require a baseline inventory before restructuring; new projects require defined scope, architecture, contracts, and reusable-library review before broad implementation.

Search `.factory/library-catalog.json` before implementing generic infrastructure. Prefer released shared packages plus product adapters. Record local reusable candidates in `docs/REUSABLE_COMPONENTS.md`.

Do not create overlapping sources of truth. Report actual checks run, checks not run, known issues, and remaining placeholders. `code_complete` is not `done`.
