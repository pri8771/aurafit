---
id: DOC-REUSABLE-COMPONENTS
canonicalFor: reusable-code-review
status: active
lastVerified: 2026-07-29
readWhen:
  - adding cross-cutting infrastructure
  - considering package extraction
related:
  - ../.factory/library-catalog.json
  - ARCHITECTURE.md
supersedes: []
---

# Reusable Components

## Catalog reviewed

- Catalog version: `0.1.0`
- Date reviewed: 2026-07-29
- Capabilities searched: persistence, file storage, image thumbnails, permissions, StoreKit, export, logging, and UI-test support
- Result: the canonical catalog currently contains no registered libraries.

## Adopted shared libraries

None. AuraFit has no third-party runtime dependencies.

## App-local reusable candidates

| Module | Capability | Why local for now | Genericity evidence | Promotion trigger |
|---|---|---|---|---|
| `ImageFileStore` / `ImageThumbnailCache` | Managed media storage and downsampling | Product-specific paths and cleanup semantics | Unit-tested independently of views | A second product needs the same lifecycle |
| `StoreKitService` / `EntitlementManager` | StoreKit 2 loading, restore, and entitlement state | Product IDs and quota rules are AuraFit-specific | Purchase provider protocol supports deterministic tests | Common product adapter boundary is proven |
| `ScorecardRenderer` / `RevealVideoRenderer` | Local image and video export | Output is branded and model-specific | Rendering is service-oriented | A second app shares the same export contract |
| `PermissionManager` | Camera and add-only Photos permission mapping | Small wrapper with AuraFit-specific supported permissions | System state is isolated from views | More products require the same API surface |

## Upstream edge cases

None. No shared library is currently adopted.

## Rejected candidates

No catalog candidates existed to reject. Third-party dependencies remain prohibited by `.factory/project-context.json`.
