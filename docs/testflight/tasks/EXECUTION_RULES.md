---
id: DOC-TESTFLIGHT-TASK-EXECUTION-RULES
canonicalFor: testflight-task-execution-rules
status: active
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# TestFlight Task Execution Rules

Read this file and the selected task plan before doing any work. Work on one parent task at a
time unless the task explicitly permits parallel subtasks.

## Description standard

Every task and subtask description must concisely establish what the work is, what will be
done, why it matters, what observable result is expected, and exactly how to obtain that result.
Descriptions must not depend on unstated knowledge or phrases such as “configure as appropriate.”

## Execution standard

- Follow subtask IDs in order. Do not renumber existing IDs; append a new ID if work is added.
- Verify prerequisites and external state before mutation. Never invent Apple values, prices,
  URLs, contacts, build numbers, roles, tester identities, or legal answers.
- Commands must state the working directory, variable inputs, output location, expected exit
  status, and success marker. Use `/tmp` for archives, apps, result bundles, and raw logs.
- Apple UI steps must name the portal, navigation path, required role, fields, expected state,
  and redacted evidence. Never commit credentials, certificates, profiles, `.p8` keys, session
  data, banking/tax details, receipts, or tester personal data.
- QA steps must record preconditions, device/environment, fixture, exact actions, expected and
  actual results, artifact location, and defect ID. Simulator evidence cannot replace hardware,
  signing, StoreKit sandbox, upload, or TestFlight evidence.
- If an owner value or external capability is unavailable, create the task evidence index,
  record the precise request, set `blocked_external` or `human_review_required`, and stop.
- A UI click is not completion. A task is `done` only when every acceptance criterion has
  evidence under `quality/evidence/testflight/<TASK-ID>/`.
- Any source change after archive creation invalidates later archive, upload, and TestFlight
  evidence. Use a new unused build number and repeat the affected gates.

## Evidence record

Each task uses `quality/evidence/testflight/<TASK-ID>/README.md` with:

- status, commit SHA, version/build, timestamp/time zone, operator role, and environment;
- one checkbox per subtask ID and acceptance criterion;
- commands or Apple navigation used, expected/actual result, and artifact links;
- blockers, approved exceptions, and reverification trigger.

Keep only compact, redacted indexes in Git. Failures remain recorded and must not be converted
to passes by weakening the criterion.

