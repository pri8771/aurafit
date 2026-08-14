---
id: AURA-OPS-001
title: Verify CI on the current branch and main
gate: TF-G1
status: blocked_external
ownerBoundary: Agent + GitHub access
dependsOn: []
evidence: quality/evidence/testflight/AURA-OPS-001/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-001 — Verify CI on the current branch and main

## Task description

This task proves the beta commit builds and runs all 101 tests in GitHub Actions rather than only on an operator's machine. We inspect the workflow, obtain an authorized run, and preserve its result bundle because local state can conceal release defects. The observable result is a green `build-and-test` check for the exact candidate SHA with 101 passed, zero failed, zero skipped, and retrievable logs; lack of GitHub authorization or runner availability is an external blocker, not a pass.

## Preconditions and inputs

- Current candidate commit SHA and branch; do not substitute a later SHA.
- `.github/workflows/ci.yml` and `AuraFitUITests/Fixtures/QAFitPhoto.jpg` exist in the checkout.
- GitHub access and owner authorization to push or use a PR when a new run is required.

## Subtasks

### AURA-OPS-001-ST-01 — Audit the workflow contract

Inspect the CI workflow before running it so the remote check actually seeds the fixture, creates the intended simulator, retains evidence, and has bounded cleanup. Read `.github/workflows/ci.yml`; record pinned action references, trigger branches, timeout, simulator/runtime selection, fixture-seeding command, `.xcresult` and Xcode-log upload paths, and cleanup command in the evidence index. Expected result: every listed contract is present or a source defect is recorded; do not edit the workflow in this documentation task.

**Execution**

1. From repository root, run `sed -n '1,260p' .github/workflows/ci.yml`; exit status must be 0.
2. Compare the output with the required items above and record exact line-level gaps in `quality/evidence/testflight/AURA-OPS-001/README.md` when it is created during execution.

**Expected result and evidence:** A redacted workflow audit and the checked commit SHA are recorded in the task evidence.

**Failure handling:** Missing fixture, artifact, timeout, cleanup, trigger, or pinned action is `source_failure`; stop the CI claim until the workflow is corrected and rerun.

### AURA-OPS-001-ST-02 — Obtain an authorized remote run

Start or select a GitHub Actions run only for the candidate SHA, because a green run for another commit does not certify the beta. Use an existing PR/run if it targets that SHA; otherwise request `OWNER_REQUIRED_GITHUB_PUSH_OR_PR_AUTHORIZATION` before pushing or opening a PR. Expected result: a GitHub run URL and run ID are bound to the candidate SHA.

**Execution**

1. In GitHub, open the repository → Actions → CI and find `build-and-test` for the exact SHA.
2. If none exists, stop and record the owner authorization request; after approval, use the repository's approved PR/push workflow to create a run. Do not force-push or modify workflow triggers.

**Expected result and evidence:** Record workflow URL, run ID, branch/PR, SHA, initiator role, and start time; do not record personal access tokens.

**Failure handling:** No access or authorization is `blocked_external`; do not use a local `xcodebuild` result as CI evidence.

### AURA-OPS-001-ST-03 — Verify the exact successful check

Confirm the remote `build-and-test` job completed successfully on the selected SHA, because branch-level green badges can point to a different commit. Expected result: job status is Success and its displayed SHA equals the frozen candidate.

**Execution**

1. Open the run URL → `build-and-test`; copy the displayed commit SHA and job conclusion into evidence.
2. Inspect the job summary/log for test totals and Xcode/runtime versions; require `101` passed, `0` failed, and `0` skipped.

**Expected result and evidence:** Evidence contains run URL, SHA, job name/conclusion, Xcode version, runtime, and test totals.

**Failure handling:** A different SHA is `verification_pending`; a failed job proceeds to ST-05; any skipped/disabled/quarantined test is `source_failure`.

### AURA-OPS-001-ST-04 — Inspect retained CI artifacts

Verify uploaded artifacts contain the result bundle and both Xcode logs, so failures can be audited after the runner disappears. Expected result: the named artifact downloads and contains one `.xcresult` plus the two expected logs.

**Execution**

1. In the completed run → Artifacts, download the result artifact to `/tmp/AURA-OPS-001-artifact.zip`; do not commit it.
2. List it with `unzip -l /tmp/AURA-OPS-001-artifact.zip`; exit status must be 0. Record the artifact name and matching `.xcresult`/log entries without copying raw logs to Git.

**Expected result and evidence:** Artifact name, retention availability, and contained relative paths are recorded.

**Failure handling:** Missing/corrupt artifact is `source_failure` if workflow upload is absent, otherwise `infrastructure`; stop and rerun after the cause is resolved.

### AURA-OPS-001-ST-05 — Classify a failed CI run without masking it

Classify failures precisely so fixes address the root cause rather than adding retries that hide release instability. Expected result: one category—source failure, Xcode/runtime drift, flaky Photos picker, permissions, or GitHub infrastructure—is supported by logs and has a next action.

**Execution**

1. Read failed job logs and `.xcresult` from ST-04; record the first failing test/build command and error text summary.
2. Assign exactly one primary category and link the source file, issue, or external incident; do not add retry loops, disable tests, quarantine tests, or convert failures to expected failures.

**Expected result and evidence:** Failure category, reproduction context, owner, and next action are recorded.

**Failure handling:** Infrastructure/runtime availability remains `blocked_external`; all other categories remain failed until a root-cause change produces a new green run.

### AURA-OPS-001-ST-06 — Finalize CI evidence

Write a compact redacted evidence index so later archive work can prove which remote result certified the candidate. Expected result: every acceptance item is checked only when backed by the same run and SHA.

**Execution**

1. Create/update `quality/evidence/testflight/AURA-OPS-001/README.md` following `EXECUTION_RULES.md`.
2. Include status, SHA, branch, run URL/ID, Xcode/runtime, 98/0/0 count, artifact name/paths, operator role, timestamp/time zone, and reverification trigger (`candidate SHA or workflow/runtime change`).

**Expected result and evidence:** The indexed evidence is complete and redacted.

**Failure handling:** If any field is unavailable, leave the relevant checkbox unchecked and use `verification_pending` or `blocked_external`; never mark this task done from incomplete evidence.

## Acceptance criteria

- [ ] Exact beta SHA is green in GitHub Actions.
- [ ] `build-and-test` reports 98 passed, zero failed, zero skipped.
- [ ] No test is disabled, quarantined, or converted to expected failure.
- [ ] Artifact includes `.xcresult` and both Xcode logs.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-001/README.md` and must retain the remote URL/ID rather than raw logs.

## Stop and reverification conditions

Stop as `blocked_external` for missing GitHub access, authorized push/PR, or unavailable GitHub runtime. Any candidate SHA, workflow, fixture, simulator/runtime, or test change invalidates this evidence.
