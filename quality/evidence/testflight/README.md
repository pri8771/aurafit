# TestFlight Evidence Convention

Create one directory per task:

`quality/evidence/testflight/<TASK-ID>/README.md`

Use this template:

```markdown
# <TASK-ID> evidence

- Status: planned | blocked_external | in_progress | verification_pending |
  human_review_required | done
- Commit SHA:
- Version/build:
- Date/time and time zone:
- Operator/reviewer role:
- Environment/device:
- Acceptance criteria:
  - [ ] ...
- Commands or Apple UI path used:
- Results:
- Artifacts:
- Blockers or approved exceptions:
- Reverification trigger:
```

Evidence rules:

- Link durable GitHub/App Store Connect records where access permits; record opaque IDs.
- Store large/raw archives, IPAs, result bundles, screenshots, and logs outside git and link
  a redacted index.
- Never commit certificates, profiles, `.p8` keys, passwords, session data, receipts,
  banking/tax details, tester addresses, or unredacted account screenshots.
- Record failures as failures. Do not delete evidence or weaken acceptance criteria.
- A code change after archive invalidates archive, upload, and later TestFlight evidence.

