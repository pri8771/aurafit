---
id: AURA-OPS-012B
title: Create and validate the final signed archive
gate: TF-G1
status: done
ownerBoundary: Owner + agent
dependsOn: [AURA-OPS-005, AURA-QA-002, AURA-QA-004, AURA-QA-005, AURA-QA-010, AURA-OPS-014]
evidence: quality/evidence/testflight/AURA-OPS-012B/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-012B — Create and validate the final signed archive

## Task description

This task creates the single distribution-signed archive that will be uploaded after all required gates pass. We bind a clean commit and frozen tuple to a fresh release-gate run, audit archive contents, and validate in Organizer because an archive is invalidated by later source changes. The expected result is a validated `/tmp/AuraFit-1.0-<BUILD>.xcarchive` with dSYM and matching identifier/team, while signing assets and raw outputs remain outside Git.

## Preconditions and inputs

- No open P0/P1 bugs; OPS-005, QA-002, QA-004, QA-005, QA-010, and OPS-014 pass with evidence.
- Frozen tuple and unused build from OPS-011; authorized owner signing account/team.

## Subtasks

### AURA-OPS-012B-ST-01 — Freeze commit and worktree

Record the exact archive source and ensure no unreviewed release change is hidden in the worktree. Expected result: SHA, branch, and clean/approved worktree state are in evidence.

**Execution**

1. From repository root run `git rev-parse HEAD`, `git branch --show-current`, and `git status --short`; each must exit 0.
2. Record SHA/branch and either an empty status or owner-approved release changes; do not archive unknown changes.

**Expected result and evidence:** Archive source identity is fixed.

**Failure handling:** Unreviewed changes are `human_review_required`; stop.

### AURA-OPS-012B-ST-02 — Re-run the release candidate gate

Run OPS-005 immediately before archive so the archive follows a proven candidate. Expected result: current SHA passes the gate and evidence links its run/artifact paths.

**Execution**

1. Run the documented `scripts/release_candidate_check.sh` invocation with explicit rules, simulator, and `/tmp` derived-data inputs.
2. Require exit 0 and record exact command, time, SHA, `.xcresult`, app, and log paths.

**Expected result and evidence:** Fresh OPS-005 pass is linked.

**Failure handling:** Nonzero/unknown result is `source_failure`/`verification_pending`; do not archive.

### AURA-OPS-012B-ST-03 — Produce the distribution archive

Archive with automatic signing using the authorized team so the artifact reflects Apple distribution settings. Expected result: `xcodebuild archive` exits 0 and creates the specified archive outside Git.

**Execution**

1. From repository root run `xcodebuild archive -project AuraFit.xcodeproj -scheme AuraFit -configuration Release -destination 'generic/platform=iOS' -archivePath /tmp/AuraFit-1.0-<FROZEN_BUILD>.xcarchive -allowProvisioningUpdates`.
2. Save raw command output under `/tmp/AuraFit-1.0-<FROZEN_BUILD>-archive.log`; record only path/status.

**Expected result and evidence:** Archive path, version/build, and exit 0 are recorded.

**Failure handling:** Signing/archive failure is `blocked_external` or `source_failure`; do not export assets or change identity to bypass it.

### AURA-OPS-012B-ST-04 — Audit archive contents and signing

Inspect all archive elements before validation so metadata, symbols, privacy, entitlements, and exclusions match the candidate. Expected result: archive/app Info.plists, root privacy manifest, dSYM, signature, embedded profile, entitlements, architectures, tuple, and bundle exclusions all pass.

**Execution**

1. Inspect only archive contents under `/tmp/AuraFit-1.0-<BUILD>.xcarchive`; use `plutil`, `codesign`, and `lipo` as needed; preserve raw output in `/tmp`.
2. Compare identifier/team/version/build/privacy `C617.1` and exclusions against OPS-005/011; record redacted result names/paths and dSYM existence.

**Expected result and evidence:** Checklist records every inspected element.

**Failure handling:** Mismatch/missing dSYM/forbidden bundle content is `source_failure`; increment build and repeat after fixes.

### AURA-OPS-012B-ST-05 — Validate with Xcode Organizer

Run Apple's pre-upload validation to surface distribution issues before delivery. Expected result: Organizer → Archives → selected archive → Distribute App → App Store Connect → Validate App completes with no unresolved warning/error.

**Execution**

1. In Xcode Organizer select exact archive path/tuple and run Validate App using automatic signing.
2. Record validation date, result, warning/error summaries, and raw log location in `/tmp`; no screenshots with account data.

**Expected result and evidence:** Validation pass or categorized outcome is recorded.

**Failure handling:** Any unresolved warning/error blocks upload; classify and fix/rearchive rather than waive it.

### AURA-OPS-012B-ST-06 — Keep signing material out of Git

Protect certificates, profiles, and archives while retaining reproducible evidence. Expected result: raw archive/validation/profile/log files remain in `/tmp` or approved secure storage; Git contains only redacted evidence index.

**Execution**

1. Check `git status --short` and ensure no `.xcarchive`, `.mobileprovision`, certificate, `.p8`, raw profile, or raw log is staged.
2. Record secure/raw artifact location references without copying secrets.

**Expected result and evidence:** Clean Git safety check is recorded.

**Failure handling:** Sensitive artifact in working tree/staging is `source_failure`; remove from staging using non-destructive Git index action and notify owner if committed history is implicated.

### AURA-OPS-012B-ST-07 — Declare archive invalidation rules

Make later changes explicitly invalidate the artifact so a stale archive is never uploaded. Expected result: evidence says any source/config/signing/privacy/version/build change requires a new unused build and repeat archive/validation.

**Execution**

1. Add invalidation trigger list and archive SHA/tuple to task evidence.
2. If a triggering change occurs, mark this archive superseded and restart at OPS-011/ST-06 or ST-01 as applicable.

**Expected result and evidence:** Candidate validity state is unambiguous.

**Failure handling:** Unknown post-archive change is `verification_pending`; do not upload.

## Acceptance criteria

- [ ] Archive is distribution-signed by correct team and identifier.
- [ ] Organizer validation has no unresolved warning/error.
- [ ] dSYM exists and bundle audit passes.
- [ ] Evidence binds archive, commit, version, build, validation.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-012B/README.md`.

## Stop and reverification conditions

Any unmet prerequisite, source/config/signing change, or unresolved validation result blocks this task; source change requires new unused build and a new archive.
