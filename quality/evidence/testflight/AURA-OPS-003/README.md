# AURA-OPS-003 evidence

- Status: `blocked_external` — archive/upload automation is intentionally deferred until
  `AURA-QA-006` proves a manually uploaded, processed build and internal TestFlight smoke.
- Commit SHA: `OWNER_REQUIRED_APPROVED_TAG_SHA`
- Version/build: `OWNER_REQUIRED_UNUSED_RELEASE_VERSION_AND_BUILD`
- Date/time and time zone: 2026-07-29, America/New_York (runbook preparation)
- Operator/reviewer role: repository agent prepared the runbook; owner/Xcode Cloud operator is
  required for workflow creation, signing, tag authorization, and upload.
- Environment/device: no Xcode Cloud workflow, tag, archive, upload, signing asset, API key, or
  TestFlight group was created or changed.

## Automation boundary

The first build follows the manual archive/upload and internal-smoke sequence. Automation may
start only after `quality/evidence/testflight/AURA-QA-006/README.md` shows the exact processed
version/build, clean TestFlight install, completed internal smoke, reviewed telemetry, and no
P0/P1. A passing local build, archive, simulator test, or Xcode Cloud setup page is not a
replacement for that evidence.

Xcode Cloud must use Apple-managed signing for the owner-authorized AuraFit team and `AuraFit`
scheme. Do not commit certificates, provisioning profiles, `.p8` keys, issuer IDs, key IDs,
passwords, session cookies, webhook URLs containing tokens, or hard-coded account paths. If a
future App Store Connect API workflow is requested, it is a separate task: store its key outside
Git, give it least privilege, record the authorized purpose and rotation owner, and prove its
audit behavior before use.

Internal/external TestFlight group assignment remains manual. Archive/upload automation does not
invite testers, distribute a build to a group, or submit external testing unless a separately
approved and evidenced API task adds that capability.

## Execution runbook

1. Read `AURA-QA-006` evidence and stop unless all manual-path proof fields above are present.
2. Obtain `OWNER_REQUIRED_XCODE_CLOUD_AUTHORIZATION` and
   `OWNER_REQUIRED_TESTFLIGHT_TAG_CONVENTION`. Do not create a workflow or trigger rule without
   both values.
3. In Xcode Cloud, create an owner-authorized workflow for the `AuraFit` scheme’s **Release
   archive**. Record workflow URL/opaque ID, team role, scheme, configuration, and signing mode
   in this README; never record secrets.
4. Add the same `AURA-OPS-005` release-candidate gate before archive. The cloud log must show the
   exact command, result summary, and retained artifact/log reference before archive starts.
5. Choose the next unused build using `AURA-OPS-011`/App Store Connect evidence. Confirm project
   version/build, commit SHA, and intended tag all match before creating any tag.
6. Create only an owner-approved release tag matching
   `OWNER_REQUIRED_TESTFLIGHT_TAG_CONVENTION`; record the tag, resolved SHA, tuple, creator role,
   and trigger result. Do not use an arbitrary branch push as a release trigger.
7. First execute a **build/archive-only dry run** with App Store Connect upload disabled. Review
   gate, signing, archive, and logs. Do not call a dry run successful upload evidence.
8. After owner approval of the dry run, enable the approved upload action and trigger one new,
   unused-build tag. Record workflow/build URL or opaque ID, archive result, delivery ID,
   App Store Connect processing state, exact version/build, and all action-required warnings.
9. Leave group assignment manual and hand the processed build to `AURA-QA-006`/`AURA-QA-007`.

## Retry and emergency stop

- Never automatically retry a delivery/build failure. It may have consumed the build number.
  First inspect Xcode Cloud and App Store Connect, preserve logs, classify the root cause, and
  confirm whether Apple received the build.
- If receipt/upload/build-number consumption is unknown, set `verification_pending`, create no
  tag, and stop until an authorized owner confirms the state.
- After a source/configuration fix, allocate a new unused build number, repeat the shared gate,
  and create a new authorized tag. Never retag a different commit or reuse a received build.
- Emergency stop: an owner-authorized Xcode Cloud operator disables the workflow or its tag
  trigger in Xcode Cloud. Record the control location and the disabled time/role, but test this
  control only non-destructively until a real workflow exists.

## Subtask evidence

- [ ] `AURA-OPS-003-ST-01` — Blocked external. `AURA-QA-006` currently has no processed build,
  internal install, or smoke result.
- [ ] `AURA-OPS-003-ST-02` — Blocked external. Requires Xcode Cloud/team authorization and
  Apple-managed signing confirmation; no signing material may enter Git.
- [ ] `AURA-OPS-003-ST-03` — Blocked external. Requires an owner-approved tag convention,
  unused-build evidence, and approved tag/SHA/tuple.
- [ ] `AURA-OPS-003-ST-04` — Blocked external. Workflow must invoke the same OPS-005 gate and
  retain logs; no divergent cloud-only check is acceptable.
- [ ] `AURA-OPS-003-ST-05` — Blocked external. Requires one approved tag-to-processed-build
  trace with redacted workflow/delivery metadata.
- [x] `AURA-OPS-003-ST-06` — Runbook prepared: group assignment stays manual unless a separate
  API-automation task is approved and evidenced.
- [x] `AURA-OPS-003-ST-07` — Retry, new-build-number, log-retention, and emergency-stop rules
  are prepared. Actual Xcode Cloud control location remains unverified until workflow access.

## Acceptance criteria

- [ ] One tag produces one correctly signed processed build.
- [x] Runbook prohibits committing signing/API secrets and keeps group assignment manual.
- [ ] Failures retain auditable logs and never reuse build numbers in a real workflow run.

## Reverification trigger

Reopen after a QA-006 regression, Xcode Cloud/team/signing/tag/gate configuration change,
workflow failure, release-tuple policy change, or any request to automate tester distribution.
