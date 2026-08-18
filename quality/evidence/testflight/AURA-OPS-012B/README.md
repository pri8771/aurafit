# AURA-OPS-012B evidence — final archive runbook

- **2026-08-18 (later) update:** the same `AuraFit-1.0-3.xcarchive` was uploaded to App Store
  Connect (`Upload succeeded` 13:34:57 local), processed, attached to version 1.0, and submitted
  for App Review (~13:41 local). Immutable identifiers are recorded in
  `quality/evidence/release/1.0-3-full-free/{README.md,SUBMISSION-2026-08-18.md}`. Device QA
  prerequisites were **waived by the owner for this submission** (DEC-007), not run.

- **2026-08-18 update:** a signed Release archive and App Store-method export of `1.0 (3)` were
  produced locally (`destination: export`, **not uploaded**) after the release gate passed
  94/94; IPA SHA-256 `d5300abd3b31a1b1d11692d0d55b072a28736625d052efef8445fbf02e606664`. Device
  QA prerequisites (QA-002/004/005) are still open; QA-010 is N/A by DEC-006. Full record:
  `quality/evidence/release/1.0-3-full-free/README.md`.

- Status: `blocked_external`; do not begin until OPS-005, QA-002/004/005/010, and OPS-014 all pass with evidence and there are no open P0/P1 bugs.
- Archive path format after OPS-011 freeze: `/tmp/AuraFit-<VERSION>-<BUILD>.xcarchive`; raw archive, profiles, certificates, entitlements, and logs remain outside Git.

## Subtask checklist

- [ ] `AURA-OPS-012B-ST-01` — From root run `git rev-parse HEAD`, `git branch --show-current`, `git status --short`. Record SHA/branch and empty or owner-approved changes. Unknown changes: `human_review_required`; do not archive.
- [ ] `AURA-OPS-012B-ST-02` — Immediately run `scripts/release_candidate_check.sh` with explicit rules checkout, simulator destination, and fresh `/tmp` derived path. Require exit 0; record command, time, SHA, `.xcresult`, app, and logs. Nonzero/unknown: stop.
- [ ] `AURA-OPS-012B-ST-03` — From root run `xcodebuild archive -project AuraFit.xcodeproj -scheme AuraFit -configuration Release -destination 'generic/platform=iOS' -archivePath /tmp/AuraFit-<VERSION>-<BUILD>.xcarchive -allowProvisioningUpdates 2>&1 | tee /tmp/AuraFit-<VERSION>-<BUILD>-archive.log`. Require exit 0; record paths/status only. Do not change identity to bypass signing.
- [ ] `AURA-OPS-012B-ST-04` — Under that archive only, inspect app Info.plist, root privacy manifest (`C617.1`), dSYM existence, signature/team, embedded profile, entitlement names, architectures, tuple, and OPS-005 exclusions. Keep raw output in `/tmp`; record only redacted checklist/path results. Mismatch/missing dSYM/forbidden content: fix, choose new build, repeat.
- [ ] `AURA-OPS-012B-ST-05` — Xcode → Window → Organizer → Archives: select exact path/tuple → Distribute App → App Store Connect → Validate App with automatic signing. Record validation time/result/warning summary/raw log path. Unresolved issue blocks upload.
- [ ] `AURA-OPS-012B-ST-06` — `git status --short` must show no staged `.xcarchive`, `.mobileprovision`, cert, `.p8`, raw profile, or raw log. Record secure/raw locations without copying values. Sensitive staging is a source failure.
- [ ] `AURA-OPS-012B-ST-07` — Record SHA/tuple and invalidation: any source/config/signing/privacy/version/build change requires new unused build, new archive, and new validation. Unknown post-archive change: `verification_pending`; no upload.

```text
prerequisite evidence links / P0-P1 state:
SHA / branch / worktree approval:
fresh OPS-005 artifact paths:
archive path / command exit:
archive audit (plist/privacy/dSYM/signature/profile/entitlements/architectures/exclusions):
Organizer validation result/log:
Git sensitive-artifact check / invalidation state:
```
