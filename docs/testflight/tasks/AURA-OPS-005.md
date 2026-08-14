---
id: AURA-OPS-005
title: Implement the machine-checkable release-candidate gate
gate: TF-G1
status: verification_pending
ownerBoundary: Agent
dependsOn: [AURA-OPS-011]
evidence: quality/evidence/testflight/AURA-OPS-005/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-005 — Implement the machine-checkable release-candidate gate

## Task description

This task creates one repeatable local/CI command that rejects malformed release candidates before signing or upload. It validates governed inputs, runs the full 101-test suite, builds unsigned Release output, and audits the app bundle because manual inspection is inconsistent. The expected change is `scripts/release_candidate_check.sh` plus a CI invocation, with a concise result identifying `.xcresult`, app bundle, and logs; source warnings fail while Xcode infrastructure warnings are separately reported.

## Preconditions and inputs

- Frozen AURA-OPS-011 release tuple and explicit simulator destination supplied as argument/environment.
- Configurable canonical App Factory rules checkout path; no hard-coded home path, UDID, certificate, or local rules path.
- Caller-supplied derived-data directory under `/tmp`.

## Subtasks

### AURA-OPS-005-ST-01 — Define a portable fail-fast command interface

Create the script interface first so local and CI runs share exactly the same checks. Expected result: `scripts/release_candidate_check.sh` uses `set -euo pipefail`, documents required simulator/rules/derived-data inputs, and writes logs/results under caller-controlled paths.

**Execution**

1. Create `scripts/release_candidate_check.sh` with a usage block requiring `AURAFIT_RULES_PATH`, `AURAFIT_SIMULATOR_DESTINATION`, and `AURAFIT_DERIVED_DATA_PATH` (or documented equivalent arguments).
2. Validate each supplied directory/value before work; reject empty values and do not default to a home path or UDID.

**Expected result and evidence:** `bash scripts/release_candidate_check.sh --help` exits 0 and explains inputs/outputs.

**Failure handling:** Missing input exits nonzero with a precise message; do not silently choose an environment.

### AURA-OPS-005-ST-02 — Validate App Factory and governed JSON

Run registration validation and parse every governed JSON before building so policy/schema errors fail early. Expected result: App Factory registration succeeds using the supplied rules checkout and all `.factory`, feature-contract, quality-manifest, and completion-report JSON files parse successfully.

**Execution**

1. Invoke the repository's canonical App Factory verifier with `AURAFIT_RULES_PATH`; record exact command/version in script output.
2. Use a standard-library parser or `jq` only when available to validate `.factory/*.json`, `quality/quality-manifest.json`, `quality/feature-contracts/**/*.json`, and `quality/completion-reports/**/*.json`; report each invalid path.

**Expected result and evidence:** Checker exits 0 and prints JSON/app-factory pass counts.

**Failure handling:** Invalid/missing governed input is `source_failure` and exits nonzero before tests.

### AURA-OPS-005-ST-03 — Lint the privacy manifest

Lint `PrivacyInfo.xcprivacy` before archive because Apple privacy omissions are upload blockers. Expected result: the manifest parses and contains the expected declaration including `C617.1` when bundle audit runs.

**Execution**

1. Locate the target `PrivacyInfo.xcprivacy` using repository-tracked paths; fail if zero or multiple ambiguous release manifests exist.
2. Run `plutil -lint <manifest-path>`; require exit 0 and preserve output in the script log.

**Expected result and evidence:** Script prints manifest path and lint pass.

**Failure handling:** Parse/missing manifest failure is `source_failure`; no archive proceeds.

### AURA-OPS-005-ST-04 — Run the explicit 101-test simulator suite

Run all 101 tests on the provided simulator so candidate regressions are caught before signing. Expected result: `.xcresult` under the caller-derived directory reports 101 passed, zero failed, zero skipped.

**Execution**

1. Run from repository root `xcodebuild test -project AuraFit.xcodeproj -scheme AuraFit -destination "$AURAFIT_SIMULATOR_DESTINATION" -derivedDataPath "$AURAFIT_DERIVED_DATA_PATH" -resultBundlePath "$AURAFIT_DERIVED_DATA_PATH/AuraFit-tests.xcresult"`; capture stdout/stderr to `$AURAFIT_DERIVED_DATA_PATH/release-candidate-test.log`.
2. Parse the result summary and fail on totals other than 101/0/0.

**Expected result and evidence:** Log and `.xcresult` paths are printed on success and failure.

**Failure handling:** Test/build failure is `source_failure` unless logs prove simulator infrastructure; never retry/disable tests automatically.

### AURA-OPS-005-ST-05 — Build unsigned generic-device Release output

Build Release with signing disabled to inspect what will ship without requiring secrets. Expected result: generic iOS Release build succeeds into caller-supplied derived data and yields a discoverable `.app` bundle.

**Execution**

1. Run `xcodebuild build -project AuraFit.xcodeproj -scheme AuraFit -configuration Release -destination 'generic/platform=iOS' -derivedDataPath "$AURAFIT_DERIVED_DATA_PATH" CODE_SIGNING_ALLOWED=NO`; log to `$AURAFIT_DERIVED_DATA_PATH/release-candidate-build.log`.
2. Locate exactly one Release `AuraFit.app`; fail if absent/ambiguous.

**Expected result and evidence:** App path and build log path are printed.

**Failure handling:** Compiler/source warning or build failure is `source_failure`; infrastructure warnings must be labelled separately and must not be counted as source warnings.

### AURA-OPS-005-ST-06 — Audit Release bundle content and metadata

Inspect the built app for required metadata and forbidden development material so a passing compile cannot upload an unsafe bundle. Expected result: exact bundle ID/display name/version/build/minimum OS/category, camera/add-only Photos strings, encryption flag, root privacy manifest with `C617.1`, and clean exclusions.

**Execution**

1. Use `plutil -p` on app `Info.plist` and privacy manifest; require `com.pchordia.aurafit`, expected frozen tuple, camera/add-only Photos descriptions, `ITSAppUsesNonExemptEncryption=false`, and `C617.1`.
2. Use `find`/`rg` scoped to the app bundle to fail on `.storekit`, unlicensed/model assets, preview data, test bundles, DEBUG launch arguments, and mock-provider strings; print each matching relative path/string.

**Expected result and evidence:** Bundle audit prints a pass checklist or exact failed condition.

**Failure handling:** Any wrong/missing/forbidden value is `source_failure` and exits nonzero.

### AURA-OPS-005-ST-07 — Separate source warnings from Xcode infrastructure warnings

Classify warnings so real source quality issues fail the gate without incorrectly blaming Xcode environment noise. Expected result: source compiler warnings cause nonzero exit; recognized Xcode infrastructure warnings remain visible in a separate summary.

**Execution**

1. Parse the saved build log for compiler warnings emitted from repository source paths and fail on any match.
2. Print all non-source/Xcode infrastructure warning lines under an `INFRASTRUCTURE_WARNINGS` heading and do not treat them as source pass/fail evidence.

**Expected result and evidence:** Summary lists zero source warnings or exact locations; infrastructure warnings are retained.

**Failure handling:** Unclassifiable warning is `verification_pending` until classified; do not suppress it.

### AURA-OPS-005-ST-08 — Integrate, prove negative coverage, and record evidence

Make CI invoke this single gate and prove it catches a controlled defect so it is not merely a green wrapper. Expected result: `.github/workflows/ci.yml` calls the script or a shared equivalent; a temporary privacy/bundle exclusion fixture causes nonzero exit and is reverted before commit; `shellcheck` passes when installed.

**Execution**

1. Add one CI step calling the script with CI-safe inputs; do not duplicate its logic in YAML.
2. On a disposable local worktree/change, introduce one known audit violation, run the script, record nonzero exit, and restore the exact original tracked state before committing.
3. Run `shellcheck scripts/release_candidate_check.sh` if available; otherwise record `shellcheck_not_installed` without claiming it passed. Run the normal candidate command and record paths/results in evidence.

**Expected result and evidence:** CI invocation, positive pass, negative nonzero result, shellcheck state, and artifact paths are indexed.

**Failure handling:** Script/CI divergence is `source_failure`; no release gate pass until both execute shared checks.

## Acceptance criteria

- [ ] Script passes on current candidate.
- [ ] Controlled privacy/bundle violation fails the script.
- [ ] CI calls the gate or an equivalent shared implementation.
- [ ] `shellcheck` passes when available; absence is recorded.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-005/README.md`.

## Stop and reverification conditions

Any script, workflow, privacy, project, test, or bundle-input change invalidates evidence. Missing simulator/rules path is `verification_pending`, not an excuse to skip a check.
