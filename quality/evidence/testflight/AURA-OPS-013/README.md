# AURA-OPS-013 evidence — delivery and processing runbook

- Status: `blocked_external`; requires a current, validated OPS-012B archive plus OPS-014 export-compliance outcome.
- Authorized role: Account Holder, Admin, App Manager, or Developer. First beta uses Organizer manual upload; do not substitute another archive or reuse any Apple-received build tuple.

## Subtask checklist

- [ ] `AURA-OPS-013-ST-01` — Xcode → Window → Organizer → Archives: select only archive whose SHA/version/build matches OPS-012B → Distribute App → App Store Connect → Upload. Use owner-approved automatic-signing/default choices. Record selected archive, tuple, uploader role, and submission outcome. Mismatch: `verification_pending`; delivery error: classify but do not upload a different archive.
- [ ] `AURA-OPS-013-ST-02` — After submission, record delivery ID, upload timestamp/timezone, tuple, archive reference, uploader role, and status; never record account information. Missing delivery ID: `verification_pending` with Organizer message.
- [ ] `AURA-OPS-013-ST-03` — ASC → Apps → AuraFit → TestFlight → iOS Builds: open exact version/build and refresh at owner-approved cadence. Record first-seen and final state; email alone is not proof. Prolonged processing is blocked; never reupload same build.
- [ ] `AURA-OPS-013-ST-04` — Record redacted ASC delivery message/code and one recovery path: `Invalid Binary` → precise repair + new unused build + OPS-011 onward; `Missing Compliance` → OPS-014; warning → owner-approved impact decision. Any unresolved state blocks task.
- [ ] `AURA-OPS-013-ST-05` — Exact TestFlight build details must match OPS-011/012B: bundle ID, version/build, min OS, device variants, privacy manifest, symbols/dSYM, export-compliance state. Record each `match|mismatch|unavailable`; do not infer unavailable data. Mismatch blocks internal distribution.
- [ ] `AURA-OPS-013-ST-06` — Once Apple receives it, list tuple/state as consumed. Any correction returns to OPS-011-ST-01 for new verified-unused positive integer; build reuse is `human_review_required` and upload stops.

```text
archive path / SHA / frozen tuple / uploader role:
delivery ID / upload time / processing first-seen-final state:
Apple message/code / classification / next action:
metadata comparisons (bundle, tuple, OS, variants, privacy, symbols, compliance):
consumed tuple and next-build rule:
blocker:
```

Processing action, metadata mismatch, archive invalidation, or any source change blocks distribution and requires affected gates to repeat.
