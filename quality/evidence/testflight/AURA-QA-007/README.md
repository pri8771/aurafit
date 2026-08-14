# AURA-QA-007 evidence — external group and TestFlight App Review

- Status: `blocked_external` — no external eligibility, group, review submission, approval, invitation, or external install is evidenced.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-007.md`](../../../../docs/testflight/tasks/AURA-QA-007.md)
- Required completed evidence: `AURA-QA-006`, `AURA-LEG-003`, `AURA-LEG-004`, `AURA-LEG-005`, and `AURA-LEG-008`. Required authorized values: beta description, feedback/review contacts, What to Test, cohort approval, and any public-link decision. Never store names, emails, invitation/public URLs, credentials, or review attachments in Git.

## Run header

Record candidate version/build/opaque ID; App Manager role; App Review timeline/status; controlled group opaque ID; aggregate invited/accepted/install counts; redacted artifact root; and defect links. Source drafts: `docs/release/TESTFLIGHT_BETA_DESCRIPTION.md`, `TESTFLIGHT_WHAT_TO_TEST.md`, and `TESTFLIGHT_REVIEW_NOTES.md`; do not submit unresolved `OWNER_REQUIRED_*` fields.

## Matrix

| Done | Subtask | Exact action and required record | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-007-ST-01` external eligibility | Apps → AuraFit → TestFlight → candidate build; verify `TestFlight Internal Only` is not set; record version/build/state. | Exact build is externally eligible. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-007-ST-02` internal prerequisite | TestFlight → Internal Testing; confirm approved internal group contains exact candidate build, no member data. | Internal group prerequisite is satisfied. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-007-ST-03` controlled group | TestFlight → External Testing; search first, then create exactly `AuraFit External Beta 1` only if no owner-approved equivalent; record settings/count only. | One controlled external group. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-007-ST-04` beta/reviewer metadata | Enter approved Beta Description, Feedback Email, Contact Information, review notes, and build-specific What to Test; save/reopen; record field names/source paths/save state, not values. | Complete sourced metadata, with no invented contact/copy. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-QA-007-ST-05` submit review | Add candidate to group, verify portal-required fields/current limits, Submit for Review; record build, time, and Submitted/In Review or exact portal block. | One exact build enters TestFlight App Review. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-007-ST-06` review responses | Check message center on owner-approved cadence; respond only from evidence/approved owner input; log redacted question category, source, response reference, outcome. | Every question has evidence-backed response. | Actual: ; Artifact: ; Defect: ; Status: `not_available` |
| [ ] | `AURA-QA-007-ST-07` invite after approval | After approval plus `OWNER_REQUIRED_EXTERNAL_COHORT_APPROVAL`, invite controlled 15–30 cohort in portal; record only aggregate invitation/accept/install counts. | At least one true external tester installs approved build. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-007-ST-08` public-link safeguard | Obtain `OWNER_REQUIRED_PUBLIC_LINK_DECISION`; if approved, configure device/OS criteria, tester limit, and support/privacy capacity; retain actual URL outside Git. | Bounded public link or explicit no-link decision. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-QA-007-ST-09` redacted outcome | Compile review timeline/outcome, build, group configuration, aggregate cohort counts, and defects; scan proposed evidence for personal/private data before saving. | Auditable external outcome without personal data. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Stop and invalidation

- Stop for missing prerequisite evidence, unresolved owner fields, App Review rejection, or privacy-bearing evidence.
- [ ] App Review approval; [ ] one true external install; [ ] zero personal data committed; [ ] `TF-G3` evidence supports status change.
- New build, beta metadata/legal/public-page change, or material review feedback requires renewed submission/distribution evidence.
