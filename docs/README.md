---
id: DOC-INDEX
canonicalFor: documentation-navigation
status: active
lastVerified: 2026-08-18
readWhen:
  - onboarding
  - locating authoritative project information
related:
  - ../.factory/repository-map.json
supersedes: []
---

# Documentation Index

## Purpose

Use this index to find the smallest authoritative set of AuraFit documents for the current task.

## Two-minute project context

Read in order:

1. `../AGENTS.md`
2. `../.factory/repository-map.json`
3. `../.factory/project-context.json`
4. `STATUS.md`
5. `ARCHITECTURE.md`
6. Only the task-relevant documents below

## Canonical documents

| Topic | Canonical document | Authority |
|---|---|---|
| Project identity and constraints | `../.factory/project-context.json` | Machine-readable classification |
| Standards and catalog versions | `../.factory/standard-lock.json` | Installed central versions |
| Repository navigation | `../.factory/repository-map.json` | Reading and location map |
| Current status | `STATUS.md` | Current progress, blockers, verification |
| Current architecture | `ARCHITECTURE.md` | Implemented architecture |
| Feature inventory | `FEATURES.md` | Feature status and contract links |
| Required feature behavior | `../quality/feature-contracts/` | States and acceptance contracts |
| Program plan | `PLAN.md` | Approved work and sequencing, not verification truth |
| Current bugs | `BUGS.md` | Confirmed defects |
| Decisions | `DECISIONS.md` | Approved product and architecture decisions |
| Risks and assumptions | `RISKS.md`, `ASSUMPTIONS.md` | Unresolved exposure and unconfirmed facts |
| Testing | `TEST_PLAN.md` | Required scenarios and recorded environments |
| Release readiness | `RELEASE_CHECKLIST.md` | TestFlight and App Store release gates |
| TestFlight execution | `TESTFLIGHT_READINESS.md`, `testflight/tasks/` | Canonical index plus one self-contained task/subtask execution plan per task |
| Privacy policy | `PRIVACY_POLICY.md` | Current documented data practices |
| Reusable code | `REUSABLE_COMPONENTS.md` | Catalog review and local candidates |
| Handoff | `HANDOFF.md` | Next-agent context |

## Task-based reading routes

### Implement or change a feature

Read `STATUS.md`, `ARCHITECTURE.md`, the relevant feature contract, applicable decisions, and `TEST_PLAN.md`.

### Fix a bug

Read `BUGS.md`, the relevant feature contract, `ARCHITECTURE.md`, and `TEST_PLAN.md`.

### Add infrastructure or a dependency

Read `../.factory/library-catalog.json`, `REUSABLE_COMPONENTS.md`, `ARCHITECTURE.md`, and `DECISIONS.md`.

### Prepare a release

Read `STATUS.md`, `TESTFLIGHT_READINESS.md`, `TEST_PLAN.md`, `RELEASE_CHECKLIST.md`,
`PRIVACY_POLICY.md`, current bugs/risks, and `../quality/evidence/`.

Then open only the selected file under `testflight/tasks/` and its linked sources. Read
`testflight/tasks/EXECUTION_RULES.md` before executing any TestFlight task.

For Jira or Notion, regenerate `mirrors/TESTFLIGHT_BACKLOG.csv` from
`TESTFLIGHT_READINESS.md`. The repository is authoritative; external boards are copies.

## Historical and superseded documents

| Document | Status | Superseded by | Reason retained |
|---|---|---|---|
| `PROJECT_DOCUMENTATION.md` | historical overview | This index and the topic-specific canonical documents | Product history |

## Documentation gaps

- Physical-device camera, permission, export, accessibility, relaunch, performance,
  interruption, storage, and thermal evidence is still required.
- The `1.0 (3)` full-free candidate (DEC-006) has a signed archive and locally exported IPA
  (`quality/evidence/release/1.0-3-full-free/README.md`) but has not been uploaded.
- A signed archive of `1.0 (1)` was produced and uploaded to App Store Connect on 2026-08-13
  (`quality/evidence/testflight/AURA-OPS-012A/UPLOAD-2026-08-13.md`); Apple processing
  completion, TestFlight availability, and TestFlight install evidence remain outstanding, and
  public privacy/support URL and App Store Connect metadata confirmation are still externally
  blocked. See the task statuses in `TESTFLIGHT_READINESS.md`; these are known execution gaps,
  not undocumented work.
