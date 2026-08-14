---
id: DOC-TESTFLIGHT-READINESS
canonicalFor: testflight-readiness-execution
status: active
lastVerified: 2026-07-29
readWhen:
  - preparing a signed beta
  - working on App Store Connect
  - assigning TestFlight work
  - mirroring release tasks to Jira or Notion
related:
  - STATUS.md
  - RELEASE_CHECKLIST.md
  - TEST_PLAN.md
  - testflight/tasks/EXECUTION_RULES.md
  - ../quality/feature-contracts/FEAT-005.json
  - ../quality/feature-contracts/FEAT-006.json
  - ../quality/evidence/testflight-readiness-2026-07-29.md
supersedes:
  - PLAN.md#47-execution-queue--the-next-20-tasks
---

# TestFlight Readiness Execution Plan

## 1. Authority and scope

This is the canonical index for getting AuraFit into TestFlight. Each linked file in
`docs/testflight/tasks/` is the authoritative definition of one task, its stable subtasks,
execution procedure, acceptance criteria, stop conditions, and evidence contract.
`docs/PLAN.md` remains the broader product program.

Jira and Notion are one-way mirrors. They carry the same task/subtask IDs, full descriptions,
canonical file path, and digest. If a mirror disagrees with the repository, the repository wins.
Update the task file first, validate it, regenerate mirror metadata, then refresh external copies.

| Gate | Meaning | Required outcome |
|---|---|---|
| `TF-G1` | Upload eligible | Account, app record, signing, export compliance, and a validated archive are ready. |
| `TF-G2` | Internal TestFlight ready | Apple processed the build; an internal tester installed it and passed the smoke. |
| `TF-G3` | External TestFlight ready | Compliance information is complete; Beta App Review passed; an external tester can install. |
| `AS-G1` | App Store submission ready | Store listing, screenshots, pricing, App Review submission, and launch operations are ready; this is later work. |

The target of this backlog is `TF-G3`. App Store screenshots, ASO, featuring, and launch
content do not block the first internal TestFlight build.

## 2. Rules for an implementing agent

1. Read `AGENTS.md`, the repository map/context/lock, `docs/README.md`, this index,
   `testflight/tasks/EXECUTION_RULES.md`, and only the selected task file and linked sources.
2. Work on one parent task unless its plan explicitly permits parallel subtasks.
3. Follow stable subtask IDs in order and attach evidence to each one.
4. Never invent Apple state, prices, URLs, contacts, build numbers, legal answers, or testers.
5. A UI action is not completion. Use `done` only when every acceptance criterion has evidence.
6. Any source change after archive invalidates archive, upload, and later TestFlight evidence.

Allowed statuses are `planned`, `blocked_external`, `in_progress`, `verification_pending`,
`human_review_required`, and `done`.

## 3. Fixed facts and external unknowns

### Verified repository facts

| Field | Value | Source |
|---|---|---|
| App name | AuraFit | Release `Info.plist` |
| Bundle ID | `com.pchordia.aurafit` | Xcode project |
| Development team | `796XH483R4` | Xcode project; Apple ownership still requires verification |
| Version/build | `1.0 (1)` locally | Xcode project; build reuse must be checked in App Store Connect |
| Minimum OS | iOS 18.0 | Xcode project |
| Devices | iPhone only, portrait | Xcode project |
| Category intent | Lifestyle | `LSApplicationCategoryType` |
| Encryption flag | Non-exempt encryption is `false` | Release `Info.plist` |
| Subscriptions | `com.aurafit.pro.monthly`, `com.aurafit.pro.yearly` | `ProductCatalog.swift` |
| Non-consumables | `com.aurafit.template.streetwear`, `com.aurafit.template.softluxury` | `ProductCatalog.swift` |
| Free limit | 3 scans/day | `ProductCatalog.swift` |
| Backend | Prohibited | `.factory/project-context.json` |

External unknowns include Apple membership/agreements/roles, App ID and app-record state,
uploaded build numbers, signing health, public URLs/contacts, StoreKit commercial metadata,
sandbox accounts, tester identities, and Apple processing/review state. The selected task file
defines the exact owner request and stop behavior for each unknown.

## 4. Dependency order

```text
OPS-009 → OPS-010 → OPS-011 → OPS-012A
    │          │          │         ├→ QA-002 → QA-004 / QA-005
    │          │          │         └→ MON-002 → MON-008 → QA-010
    │          │          └→ OPS-005
    │          └→ LEG-005 / OPS-014
    └→ MON-008

MKT-004 → LEG-003 / LEG-004 / LEG-008

QA-002 + QA-004 + QA-005 + QA-010 + LEG-003/004/005/008 + OPS-014
    → OPS-012B → OPS-013 → QA-006 → QA-007 → QA-008 → QA-009

OPS-003 occurs only after QA-006. OPS-007 is non-blocking mirror work.
```

## 5. Canonical task catalog

| Order | Task plan | Gate | Owner boundary | Status | Depends on |
|---:|---|---|---|---|---|
| 1 | [`AURA-OPS-001`](testflight/tasks/AURA-OPS-001.md) Verify CI | `TF-G1` | Agent + GitHub access | `blocked_external` | — |
| 2 | [`AURA-OPS-009`](testflight/tasks/AURA-OPS-009.md) Verify Apple account readiness | `TF-G1` | Owner | `human_review_required` | — |
| 3 | [`AURA-OPS-010`](testflight/tasks/AURA-OPS-010.md) Verify App ID and app record | `TF-G1` | Owner + agent | `human_review_required` | OPS-009 |
| 4 | [`AURA-OPS-011`](testflight/tasks/AURA-OPS-011.md) Freeze release identity and scope | `TF-G1` | Owner + agent | `planned` | OPS-010 |
| 5 | [`AURA-OPS-005`](testflight/tasks/AURA-OPS-005.md) Implement release-candidate gate | `TF-G1` | Agent | `verification_pending` | OPS-011 |
| 6 | [`AURA-OPS-012A`](testflight/tasks/AURA-OPS-012A.md) Install signed Release on device | `TF-G1` | Owner + agent + iPhone | `human_review_required` | OPS-010, OPS-011 |
| 7 | [`AURA-QA-002`](testflight/tasks/AURA-QA-002.md) Run core-loop device matrix | `TF-G1` | Owner + agent + iPhone | `blocked_external` | OPS-012A |
| 8 | [`AURA-QA-004`](testflight/tasks/AURA-QA-004.md) Run accessibility/layout matrix | `TF-G1` | Human reviewer + iPhone | `blocked_external` | OPS-012A |
| 9 | [`AURA-QA-005`](testflight/tasks/AURA-QA-005.md) Run performance/stability smoke | `TF-G1` | Human reviewer + iPhone | `blocked_external` | OPS-012A |
| 10 | [`AURA-MON-002`](testflight/tasks/AURA-MON-002.md) Approve prices and offers | `TF-G2` | Owner + agent research | `human_review_required` | — |
| 11 | [`AURA-MON-008`](testflight/tasks/AURA-MON-008.md) Configure production StoreKit catalog | `TF-G2` | Owner | `blocked_external` | OPS-009, OPS-010, MON-002 |
| 12 | [`AURA-QA-010`](testflight/tasks/AURA-QA-010.md) Run StoreKit sandbox/TestFlight matrix | `TF-G2` | Owner + agent + sandbox account | `blocked_external` | MON-008, OPS-012A |
| 13 | [`AURA-MKT-004`](testflight/tasks/AURA-MKT-004.md) Publish privacy/support pages | `TF-G3` | Owner + hosting access | `human_review_required` | [evidence](../quality/evidence/testflight/AURA-MKT-004/README.md) |
| 14 | [`AURA-LEG-003`](testflight/tasks/AURA-LEG-003.md) Confirm EULA/legal links | `TF-G3` | Owner + human review | `human_review_required` | MKT-004 |
| 15 | [`AURA-LEG-004`](testflight/tasks/AURA-LEG-004.md) Publish App Privacy answers | `TF-G3` | Owner | `blocked_external` | MKT-004 |
| 16 | [`AURA-LEG-005`](testflight/tasks/AURA-LEG-005.md) Complete age rating/content rights | `TF-G3` | Owner | `blocked_external` | OPS-010 |
| 17 | [`AURA-OPS-014`](testflight/tasks/AURA-OPS-014.md) Confirm export compliance | `TF-G1` | Owner + human legal determination | `human_review_required` | OPS-010 |
| 18 | [`AURA-LEG-008`](testflight/tasks/AURA-LEG-008.md) Prepare reviewer packet | `TF-G3` | Agent draft + owner contacts | `human_review_required` | MKT-004, MON-008 |
| 19 | [`AURA-OPS-012B`](testflight/tasks/AURA-OPS-012B.md) Create/validate final archive | `TF-G1` | Owner + agent | `blocked_external` | OPS-005, QA-002, QA-004, QA-005, QA-010, OPS-014 |
| 20 | [`AURA-OPS-013`](testflight/tasks/AURA-OPS-013.md) Upload and clear processing | `TF-G1` | Owner/App Manager/Developer | `blocked_external` | OPS-012B |
| 21 | [`AURA-QA-006`](testflight/tasks/AURA-QA-006.md) Run internal TestFlight smoke | `TF-G2` | Owner + internal tester | `blocked_external` | OPS-013 |
| 22 | [`AURA-QA-007`](testflight/tasks/AURA-QA-007.md) Run external TestFlight review | `TF-G3` | Owner/App Manager | `blocked_external` | QA-006, LEG-003/004/005/008 |
| 23 | [`AURA-QA-008`](testflight/tasks/AURA-QA-008.md) Run structured feedback | `TF-G3` | Owner | `planned` | QA-007 |
| 24 | [`AURA-QA-009`](testflight/tasks/AURA-QA-009.md) Triage and decide go/no-go | `TF-G3` | Owner + agent | `planned` | QA-006; QA-008 for external decision |
| 25 | [`AURA-OPS-003`](testflight/tasks/AURA-OPS-003.md) Automate later uploads | Post-`TF-G2` | Agent + owner | `planned` | QA-006 |
| 26 | [`AURA-OPS-007`](testflight/tasks/AURA-OPS-007.md) Refresh Jira/Notion mirrors | Non-blocking | Owner/PM | `planned` | Canonical plans approved |

## 6. Current critical path

The first owner action is OPS-009, immediately followed by OPS-010. Repository-side work for
OPS-005, LEG-008, MKT-004, compliance, StoreKit preflight, and every execution/evidence pack is
prepared. OPS-001 now needs working GitHub access; OPS-005 needs a canonical rules checkout and
one clean CI or local gate run.

The shortest internal-beta path is:

1. OPS-009 account readiness.
2. OPS-010 app identity.
3. OPS-011 version/build.
4. OPS-012A signed Release install.
5. QA-002/004/005 and MON-002/MON-008/QA-010.
6. OPS-005 release gate.
7. OPS-014 export determination.
8. OPS-012B final archive.
9. OPS-013 upload/processing.
10. QA-006 internal TestFlight smoke.

External beta adds MKT-004, LEG-003/004/005/008, QA-007, QA-008, and QA-009.

## 7. Validation and Apple-source baseline

Run `ruby scripts/testflight_task_docs.rb --mirror` after any task-plan or mirror change.
The validator requires 26 canonical tasks, 179 stable subtasks, contiguous IDs, required
execution/evidence/failure sections, correct evidence paths, and mirror parity.

Official Apple-source research is indexed in
`quality/evidence/testflight-readiness-2026-07-29.md`. Recheck it when execution occurs more
than 30 days after `lastVerified`, App Store Connect differs, or Apple changes requirements.
