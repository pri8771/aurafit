# GitHub Copilot Instructions

This repository is registered with the App Factory.

Before suggesting or changing code, use these files as context:

1. `.factory/project-context.json`
2. `.factory/standard-lock.json`
3. `.factory/AGENTS.factory.md`
4. `quality/quality-manifest.json`
5. relevant project documentation and feature contracts

The `projectType` field determines whether new-project or existing-project rules apply. Do not overwrite an existing architecture with a new scaffold. Do not introduce fake production data, disconnected UI controls, stale errors, duplicate consequential actions, or unsupported completion claims.

Treat `code_complete`, `verification_pending`, `verified`, and `done` as distinct states.
