---
id: DOC-TESTFLIGHT-READINESS
canonicalFor: testflight-readiness-execution
status: active
lastVerified: 2026-08-18
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
| Version/build | `1.0 (3)` — uploaded and submitted for App Review 2026-08-18 (builds 1 and 2 remain in App Store Connect unused; next build `≥ 4`) | Xcode project; `quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md` |
| Minimum OS | iOS 18.0 | Xcode project |
| Devices | iPhone only, portrait | Xcode project |
| Category intent | Lifestyle | `LSApplicationCategoryType` |
| Encryption flag | Non-exempt encryption is `false` | Release `Info.plist` |
| In-app purchases | None — one full, free product (DEC-006, 2026-08-18) | `FullFreeProductTests`, `scripts/release_candidate_check.sh` |
| Backend | Prohibited | `.factory/project-context.json` |

External unknowns include Apple membership/agreements/roles, App ID and app-record state,
uploaded build numbers, signing health, public URLs/contacts, tester identities, and Apple
processing/review state. The selected task file
defines the exact owner request and stop behavior for each unknown.

## 4. Dependency order

```text
OPS-009 → OPS-010 → OPS-011 → OPS-012A
    │          │          │         ├→ QA-002 → QA-004 / QA-005
    │          │          │         └→ (MON-002 → MON-008 → QA-010: N/A by DEC-006)
    │          │          └→ OPS-005
    │          └→ LEG-005 / OPS-014
    └→ (MON-008: N/A by DEC-006)

MKT-004 → LEG-003 / LEG-004 / LEG-008

QA-002 + QA-004 + QA-005 + LEG-003/004/005/008 + OPS-014
    → OPS-012B → OPS-013 → QA-006 → QA-007 → QA-008 → QA-009

OPS-003 occurs only after QA-006. OPS-007 is non-blocking mirror work.
```

## 5. Canonical task catalog

| Order | Task plan | Gate | Owner boundary | Status | Depends on |
|---:|---|---|---|---|---|
| 1 | [`AURA-OPS-001`](testflight/tasks/AURA-OPS-001.md) Verify CI | `TF-G1` | Agent + GitHub access | `blocked_external` | — |
| 2 | [`AURA-OPS-009`](testflight/tasks/AURA-OPS-009.md) Verify Apple account readiness | `TF-G1` | Owner | `done` (functional proof: build-3 upload + submission 2026-08-18) | — |
| 3 | [`AURA-OPS-010`](testflight/tasks/AURA-OPS-010.md) Verify App ID and app record | `TF-G1` | Owner + agent | `done` (build 3 attached to the record 2026-08-18) | OPS-009 |
| 4 | [`AURA-OPS-011`](testflight/tasks/AURA-OPS-011.md) Freeze release identity and scope | `TF-G1` | Owner + agent | `done` (`1.0 (3)`, no IAP; consumed 2026-08-18) | OPS-010 |
| 5 | [`AURA-OPS-005`](testflight/tasks/AURA-OPS-005.md) Implement release-candidate gate | `TF-G1` | Agent | `verification_pending` | OPS-011 |
| 6 | [`AURA-OPS-012A`](testflight/tasks/AURA-OPS-012A.md) Install signed Release on device | `TF-G1` | Owner + agent + iPhone | `human_review_required` (archive half done; on-device half not run — waived by owner for the 1.0 submission 2026-08-18, DEC-007) | OPS-010, OPS-011 |
| 7 | [`AURA-QA-002`](testflight/tasks/AURA-QA-002.md) Run core-loop device matrix | `TF-G1` | Owner + agent + iPhone | `blocked_external` (not run; waived by owner for the 1.0 submission 2026-08-18, DEC-007) | OPS-012A |
| 8 | [`AURA-QA-004`](testflight/tasks/AURA-QA-004.md) Run accessibility/layout matrix | `TF-G1` | Human reviewer + iPhone | `blocked_external` (not run; VoiceOver deferred DEC-005; rest waived by owner for the 1.0 submission 2026-08-18, DEC-007) | OPS-012A |
| 9 | [`AURA-QA-005`](testflight/tasks/AURA-QA-005.md) Run performance/stability smoke | `TF-G1` | Human reviewer + iPhone | `blocked_external` (not run; waived by owner for the 1.0 submission 2026-08-18, DEC-007) | OPS-012A |
| 10 | [`AURA-MON-002`](testflight/tasks/AURA-MON-002.md) Approve prices and offers | `TF-G2` | — | `not_applicable` (DEC-006, 2026-08-18) | — |
| 11 | [`AURA-MON-008`](testflight/tasks/AURA-MON-008.md) Configure production StoreKit catalog | `TF-G2` | — | `not_applicable` (DEC-006, 2026-08-18) | — |
| 12 | [`AURA-QA-010`](testflight/tasks/AURA-QA-010.md) Run StoreKit sandbox/TestFlight matrix | `TF-G2` | — | `not_applicable` (DEC-006, 2026-08-18) | — |
| 13 | [`AURA-MKT-004`](testflight/tasks/AURA-MKT-004.md) Publish privacy/support pages | `TF-G3` | Owner + hosting access | `done` (site `main @ 4372f22`, live 200 / 0 tier words, verified 2026-08-18) | [evidence](../quality/evidence/testflight/AURA-MKT-004/README.md) |
| 14 | [`AURA-LEG-003`](testflight/tasks/AURA-LEG-003.md) Confirm EULA/legal links | `TF-G3` | Owner + human review | `human_review_required` | MKT-004 |
| 15 | [`AURA-LEG-004`](testflight/tasks/AURA-LEG-004.md) Publish App Privacy answers | `TF-G3` | Owner | `done` ("Data Not Collected" published 2026-08-18) | MKT-004 |
| 16 | [`AURA-LEG-005`](testflight/tasks/AURA-LEG-005.md) Complete age rating/content rights | `TF-G3` | Owner | `done` (4+, no third-party content, 2026-08-18) | OPS-010 |
| 17 | [`AURA-OPS-014`](testflight/tasks/AURA-OPS-014.md) Confirm export compliance | `TF-G1` | Owner + human legal determination | `human_review_required` (`NO` in bundle; no ASC prompt on 2026-08-18 upload/submission; signed determination not on file) | OPS-010 |
| 18 | [`AURA-LEG-008`](testflight/tasks/AURA-LEG-008.md) Prepare reviewer packet | `TF-G3` | Agent draft + owner contacts | `human_review_required` (App Review contact + notes entered 2026-08-18; beta description/What to Test not entered — no beta round) | MKT-004 |
| 19 | [`AURA-OPS-012B`](testflight/tasks/AURA-OPS-012B.md) Create/validate final archive | `TF-G1` | Owner + agent | `done` (`1.0 (3)` archive uploaded and processed 2026-08-18; device prerequisites waived by owner, DEC-007) | OPS-005, QA-002, QA-004, QA-005, OPS-014 |
| 20 | [`AURA-OPS-013`](testflight/tasks/AURA-OPS-013.md) Upload and clear processing | `TF-G1` | Owner/App Manager/Developer | `done` (uploaded 2026-08-18 13:34:57 local; processed; attached) | OPS-012B |
| 21 | [`AURA-QA-006`](testflight/tasks/AURA-QA-006.md) Run internal TestFlight smoke | `TF-G2` | Owner + internal tester | `blocked_external` (not run for build 3; direct App Store submission 2026-08-18, DEC-007) | OPS-013 |
| 22 | [`AURA-QA-007`](testflight/tasks/AURA-QA-007.md) Run external TestFlight review | `TF-G3` | Owner/App Manager | `blocked_external` | QA-006, LEG-003/004/005/008 |
| 23 | [`AURA-QA-008`](testflight/tasks/AURA-QA-008.md) Run structured feedback | `TF-G3` | Owner | `planned` | QA-007 |
| 24 | [`AURA-QA-009`](testflight/tasks/AURA-QA-009.md) Triage and decide go/no-go | `TF-G3` | Owner + agent | `planned` | QA-006; QA-008 for external decision |
| 25 | [`AURA-OPS-003`](testflight/tasks/AURA-OPS-003.md) Automate later uploads | Post-`TF-G2` | Agent + owner | `planned` | QA-006 |
| 26 | [`AURA-OPS-007`](testflight/tasks/AURA-OPS-007.md) Refresh Jira/Notion mirrors | Non-blocking | Owner/PM | `planned` | Canonical plans approved |

## 6. Current critical path

**2026-08-18 update (submission).** Later on 2026-08-18 the `1.0 (3)` archive was uploaded
(`Upload succeeded` 13:34:57 local), processed by Apple within ~6 minutes, attached to version
1.0 with the listing from `docs/release/APP_STORE_LISTING.md` entered (App Privacy "Data Not
Collected" published, age rating 4+, Free / 175 territories, 8 iPhone 6.5" screenshots), and
**version 1.0 was submitted for App Review at ~13:41 local ("Waiting for Review")**. The hosted
privacy/support/product pages were regenerated with 0 tier words (`priyanshchordia.com` `main @
4372f22`, live 200). OPS-009/010/011/012B/013, MKT-004, LEG-004, and LEG-005 are `done`; the
physical-device gates (OPS-012A on-device half, QA-002/004/005) and the TestFlight smoke
(QA-006) were **not run and were consciously waived by the owner for this submission** (DEC-007;
`quality/waivers/1.0-3-device-qa-owner-waiver-2026-08-18.md`) — they stay open. The remaining
path for 1.0 is Apple's review decision and the automatic release; any resubmission or later
version needs build `≥ 4` and must run (or explicitly re-waive) the device gates. Record:
`quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md`. The paragraphs below are
retained for history.

**2026-08-18 update (DEC-006).** The owner decided AuraFit 1.0 ships as one full, free product.
Every StoreKit/paywall/quota surface was removed, `CURRENT_PROJECT_VERSION` was bumped to `3`
(builds 1 and 2 are consumed in App Store Connect), the suite passes 94/94, the release gate
passes, and a signed archive plus locally exported IPA of `1.0 (3)` exist — **not uploaded**
(evidence: `quality/evidence/release/1.0-3-full-free/README.md`). MON-002, MON-008, and QA-010
are `not_applicable`; the remaining path is owner upload of build 3, device QA, and the legal
metadata items. The paragraph below describes the state as of 2026-08-13 and is retained for
history.

On 2026-08-13 a signed Release archive of `1.0 (1)` was produced and uploaded to App Store
Connect (evidence: `quality/evidence/testflight/AURA-OPS-012A/UPLOAD-2026-08-13.md`), which is
functional-proof for OPS-009 (account/agreements), OPS-010 (app record), and the archive half
of OPS-012A — all three now carry `human_review_required` pending owner sign-off, not
`blocked_external`. Apple's processing completion and TestFlight availability of that build are
still unconfirmed, and OPS-012A's on-device install/launch/signing-inspection subtasks have not
run. Build number 1 is now consumed, so OPS-011 must select build `2` before any future
re-archive. Repository-side work for OPS-005, LEG-008, MKT-004, compliance, StoreKit preflight,
and every execution/evidence pack remains prepared. OPS-001 still needs working GitHub access;
OPS-005 still needs a canonical rules checkout and one clean CI or local gate run.

The shortest internal-beta path from here is:

1. Owner review of the OPS-009/OPS-010/OPS-012A evidence now on file, and confirmation of Apple
   processing/TestFlight availability for `1.0 (1)`.
2. OPS-012A on-device install/launch/signing inspection (the archive/upload half is done).
3. QA-002/004/005 (MON-002/MON-008/QA-010 are N/A by DEC-006).
4. OPS-005 release gate.
5. OPS-014 export determination.
6. OPS-011 freeze of the next candidate (build `2`) and OPS-012B final archive, if a new build
   is required.
7. OPS-013 upload/processing.
8. QA-006 internal TestFlight smoke.

External beta adds MKT-004, LEG-003/004/005/008, QA-007, QA-008, and QA-009.

## 7. Validation and Apple-source baseline

Run `ruby scripts/testflight_task_docs.rb --mirror` after any task-plan or mirror change.
The validator requires 26 canonical tasks, 179 stable subtasks, contiguous IDs, required
execution/evidence/failure sections, correct evidence paths, and mirror parity.

Official Apple-source research is indexed in
`quality/evidence/testflight-readiness-2026-07-29.md`. Recheck it when execution occurs more
than 30 days after `lastVerified`, App Store Connect differs, or Apple changes requirements.
