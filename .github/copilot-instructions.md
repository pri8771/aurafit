# GitHub Copilot Instructions

This repository is registered with the App Factory.

Use this context path before suggesting or changing code:

1. `.factory/repository-map.json`
2. `.factory/project-context.json`
3. `.factory/standard-lock.json`
4. `docs/README.md`
5. Only the canonical documents and feature contracts routed for the current task

Do not scan every repository file by default. Use the repository map and documentation index to retrieve the smallest authoritative context set.

The `projectType` field determines whether new-project or existing-project rules apply. Do not overwrite an existing architecture with a new scaffold.

Search `.factory/library-catalog.json` before creating generic infrastructure. Prefer released packages and thin product adapters. Keep missing reusable capabilities modular and record promotion candidates in `docs/REUSABLE_COMPONENTS.md`.

Do not create duplicate documentation authorities or introduce fake production data, disconnected UI controls, stale errors, duplicate consequential actions, or unsupported completion claims. Treat `code_complete`, `verification_pending`, `verified`, and `done` as distinct states.
