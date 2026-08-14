# AURA-OPS-001 evidence — CI verification on candidate SHA

- Status: `blocked_external` — workflow contract audited locally on 2026-07-29; no GitHub Actions run, job summary, or retained artifact was observable.
- Canonical plan: [`docs/testflight/tasks/AURA-OPS-001.md`](../../../../docs/testflight/tasks/AURA-OPS-001.md)
- Local checkout at audit: branch `claude/phase0-production-readiness`, HEAD `0f48aa22ea1cea7d8a33ba5bceea0926c055e120` (`Record OpenAI Sites as the web host, with the two gates it must clear`). This is not a frozen candidate: the working tree has tracked and untracked changes, including `.github/workflows/ci.yml`; no remote claim may use this SHA until the candidate is committed and frozen.
- GitHub access result: `gh auth status` reported the active `pri8771` token is invalid. No remote run lookup, dispatch, push, PR action, artifact download, or main/current-branch status was attempted.

## Workflow contract audit — `.github/workflows/ci.yml`

| Requirement | Observed workflow evidence | Result |
| --- | --- | --- |
| Triggers | `push` to `main`, `pull_request` targeting `main`, and `workflow_dispatch`. | present |
| Bounded job | `build-and-test` on `macos-15`, `timeout-minutes: 30`, concurrency cancellation by ref. | present |
| Versioned actions | `actions/checkout@v4` (twice) and `actions/upload-artifact@v4`. | version tags present; not immutable commit-SHA pins, so strict pinning is a `source_failure` gap if the project requires SHA pinning. |
| Rules checkout | Checks out `pri8771/iOS_app_factory_rules` at `main` to `.factory/rules`. | present, but mutable `main` means the remote standard revision must be recorded from the actual run. |
| Simulator selection | Selects newest available iOS runtime and iPhone 16-or-first-iPhone type, then creates/boots dedicated `AuraFitCI`. | present; runtime/device are dynamic and must be captured from run logs. |
| Fixture seeding | Booted simulator receives `AuraFitUITests/Fixtures/QAFitPhoto.jpg` through `xcrun simctl addmedia`. Fixture exists in checkout. | present |
| Release gate | Runs `scripts/release_candidate_check.sh` with dedicated simulator, `/tmp` derived data, expected version `1.0`, build `1`. Checker requires `101/101/0/0`, emits `.xcresult`, test/build logs, summary, and unsigned Release bundle. | coherent with plan, pending remote execution |
| Artifact retention | Always uploads derived-data root as `AuraFit-release-candidate`, retention 14 days. This should include `AuraFit-tests.xcresult`, `release-candidate-test.log`, `release-candidate-build.log`, and `test-summary.json`. | present, pending downloaded inspection |
| Cleanup | Always deletes dedicated simulator. | present |
| YAML syntax | Ruby `YAML.safe_load` parsed the workflow successfully. | passed |

## Matrix

| Done | Subtask | What was done / next exact action | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [x] | `AURA-OPS-001-ST-01` workflow audit | Read workflow and checker; validate YAML; compare trigger/job/runtime/fixture/gate/artifact/cleanup contract above. Release-gate agent owns workflow changes. | Contract facts recorded; strict immutable action-pin concern made explicit. | Actual: audit above; Artifact: `.github/workflows/ci.yml`, `scripts/release_candidate_check.sh`; Status: `code_complete` |
| [ ] | `AURA-OPS-001-ST-02` authorized run | First commit/freeze intended candidate SHA and clean-tree identity. Then re-authenticate GitHub CLI or use authorized browser/PR route; find or create CI only for that SHA. Record URL, run ID, SHA, branch/PR, initiator, start time. | Authorized remote run bound to exact frozen SHA. | Actual: GitHub token invalid; dirty/uncommitted candidate; Artifact: local `gh auth status`; Status: `blocked_external` |
| [ ] | `AURA-OPS-001-ST-03` exact-success check | In run → `build-and-test`, verify displayed SHA equals frozen candidate; record conclusion, Xcode/runtime, and job summary exactly `98` passed, `0` failed, `0` skipped. | Green exact-SHA job with required totals. | Actual: no authorized run lookup; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-OPS-001-ST-04` retained artifact | Download run artifact to `/tmp/AURA-OPS-001-artifact.zip`; run `unzip -l`; record artifact name/retention and `.xcresult`, test log, build log, summary paths. Do not commit raw files. | Readable artifact has result bundle and both Xcode logs. | Actual: no run ID/artifact access; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-OPS-001-ST-05` failure classification | Only if CI fails: inspect first failure/log/xcresult; assign exactly one primary category: source, Xcode/runtime drift, Photos picker, permissions, or GitHub infrastructure; do not retry/quarantine/disable tests. | Evidence-backed root-cause and next owner action. | Actual: no remote failure observed; Artifact: ; Defect: ; Status: `not_available` |
| [x] | `AURA-OPS-001-ST-06` evidence index | Created this compact redacted index with SHA/branch state, workflow audit, GitHub access blocker, acceptance checks, and invalidation conditions. | No incomplete remote evidence is presented as a pass. | Actual: this README; Artifact: `quality/evidence/testflight/AURA-OPS-001/README.md`; Status: `code_complete` |

## Acceptance and unblock request

- [ ] Exact frozen beta SHA is green in GitHub Actions.
- [ ] `build-and-test` reports `98 passed`, `0 failed`, `0 skipped` for that SHA.
- [ ] No test is disabled, quarantined, or converted to expected failure.
- [ ] Retained artifact contains `.xcresult`, test log, and build log.

Current blockers:

1. `OWNER_REQUIRED_FROZEN_CANDIDATE_SHA`: commit the intended candidate and provide its exact SHA; current checkout is dirty.
2. `OWNER_REQUIRED_GITHUB_ACCESS`: re-authenticate a GitHub account with read access to Actions; provide push/PR/dispatch authorization only if no run already exists for that SHA.
3. `OWNER_REQUIRED_CI_PINNING_DECISION`: accept version-tag action references or authorize the workflow owner to replace `@v4` action tags with immutable SHAs before a strict pinning claim.

Any candidate SHA, workflow/checker, fixture, simulator/runtime, test count, or action-reference change invalidates the eventual remote evidence.
