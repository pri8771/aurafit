# AURA-OPS-005 evidence

- Status: `verification_pending` — the release-candidate gate is implemented locally; a clean
  101-test simulator run and the canonical App Factory verifier require a supplied rules checkout
  and functioning simulator service.
- Commit SHA: pending implementation commit
- Version/build: `1.0 (1)` expected by the CI invocation; update its two explicit environment
  values after `AURA-OPS-011` freezes a replacement tuple.
- Date/time and time zone: 2026-07-29 America/New_York
- Operator/reviewer role: implementation agent
- Environment/device: local macOS implementation environment; no physical-device claim

## Acceptance criteria

- [ ] Script passes on the frozen candidate with a supplied canonical rules checkout and simulator.
- [x] Controlled privacy/bundle violation fails the script and is restored before commit.
- [x] CI calls the shared gate without duplicating its checks.
- [x] `shellcheck` passed for the final script.

## Subtask status

| Subtask | Status | Evidence or remaining proof |
|---|---|---|
| `AURA-OPS-005-ST-01` | `code_complete` | `--help`, input validation, caller-owned `/tmp` output contract, Bash syntax, and ShellCheck passed. |
| `AURA-OPS-005-ST-02` | `verification_pending` | Governed JSON parsing is implemented and passed independently; the shared gate still needs the canonical rules verifier checkout. |
| `AURA-OPS-005-ST-03` | `code_complete` | Privacy manifest lint passed and the controlled duplicate-manifest case failed as `source_failure`. |
| `AURA-OPS-005-ST-04` | `verification_pending` | The updated suite passes 101/101 in `/tmp/AuraFit-BadPhoto-Full-Tests.xcresult`; one shared-gate run with the canonical verifier is still required. |
| `AURA-OPS-005-ST-05` | `code_complete` | Unsigned generic-device Release build completed successfully at the path below. |
| `AURA-OPS-005-ST-06` | `verification_pending` | Audit logic is implemented; it must run through the shared positive gate against the discovered Release app. |
| `AURA-OPS-005-ST-07` | `verification_pending` | Warning classification is implemented; final source/infrastructure classification requires the shared positive build log. |
| `AURA-OPS-005-ST-08` | `verification_pending` | CI integration, ShellCheck, and negative proof passed; the positive shared-gate result remains. |

## Commands or Apple UI path used

- `bash scripts/release_candidate_check.sh --help` — exited 0 and documented all required
  caller inputs and preserved outputs.
- `bash -n scripts/release_candidate_check.sh && shellcheck scripts/release_candidate_check.sh`
  — both exited 0.
- A temporary second `PrivacyInfo.xcprivacy` was added only for the controlled negative check.
  With a disposable rules-verifier fixture and an empty `/tmp` derived-data directory, the gate
  exited 1 with `source_failure` and `Expected exactly one ...; found 2`; the source fixture was
  removed immediately after the check.
- The CI workflow supplies only a workspace rules checkout, a dedicated simulator ID, and a
  unique `/tmp` derived-data directory. Raw logs and `.xcresult` are retained as its artifact.

## Results

- Static/interface validation and privacy-manifest negative coverage passed.
- An unsigned generic-device Release build completed successfully with signing disabled at
  `/tmp/AuraFit-TestFlight-Final-Release-Escalated`.
- The updated full simulator suite passed 101/101 with zero failed and zero skipped at
  `/tmp/AuraFit-BadPhoto-Full-Tests.xcresult`.
- The shared positive gate still has not produced one 101/101 result because no canonical App
  Factory rules checkout was supplied. Do not combine the two result bundles into a gate pass.

## Artifacts

- CI artifact name: `AuraFit-release-candidate`.
- Expected contents: `app-factory-verifier.log`, `release-candidate-test.log`,
  `release-candidate-build.log`, `test-summary.json`, `AuraFit-tests.xcresult`, and unsigned
  `AuraFit.app`, all outside Git under the caller-controlled `/tmp` directory.

## Blockers or approved exceptions

- AURAFIT_RULES_PATH must point to the locked App Factory rules checkout that contains the
  canonical registration verifier.
- A clean simulator restart restored test execution, but a single full shared-gate invocation
  with the real verifier has not yet produced 101/101; this evidence does not claim that pass.

## Reverification trigger

Any script, CI, privacy manifest, project, test, or bundle-input change invalidates this record.
