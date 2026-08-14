# Local App Factory Agent Standard

This file is the local minimum standard copied from the central rules repository.

## Fast context path

Read:

```text
AGENTS.md
→ .factory/repository-map.json
→ .factory/project-context.json
→ docs/README.md
→ only the task-relevant canonical documents
```

Do not recursively read the entire repository by default. Do not create duplicate sources of truth.

## Quality and reuse rules

- Never use undisclosed fake data in production.
- Never show success before confirmed success.
- Model loading, empty, error, cancellation, permission, and offline states where applicable.
- Prevent duplicate consequential operations and stale asynchronous results.
- Preserve recoverable user work after failure.
- Do not overwrite an existing project with a new scaffold.
- Keep preview and test fixtures out of production targets or bundles.
- Read `.factory/library-catalog.json` before implementing cross-cutting infrastructure.
- Prefer a released shared library plus a thin product adapter when a suitable package exists.
- When no library fits, build a narrow library-ready local module and record it in `docs/REUSABLE_COMPONENTS.md`.
- Keep product-specific behavior out of shared-library APIs.
- Use separate product, library, and central-registry changes for generic upstream improvements.
- Separate facts, decisions, assumptions, and proposals in documentation.
- Update the relevant feature contract and one canonical document when behavior changes.
- Report actual checks run and checks not run.
- `code_complete` is not `done`.

Canonical repository: `https://github.com/pri8771/iOS_app_factory_rules`
