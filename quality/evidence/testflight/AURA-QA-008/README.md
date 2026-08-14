# AURA-QA-008 evidence — structured external-beta feedback loop

- Status: `blocked_external` — no approved external cohort, feedback cadence, consent/retention policy, response, or finding is evidenced.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-008.md`](../../../../docs/testflight/tasks/AURA-QA-008.md)
- Question source: [`docs/release/TESTFLIGHT_FEEDBACK_QUESTIONS.md`](../../../../docs/release/TESTFLIGHT_FEEDBACK_QUESTIONS.md). Do not change question meaning. Never commit individual replies, source photos, Apple IDs, receipts, payment data, private screenshots, or tester contact data.

## Run header

For each cohort record: processed version/build, external-group opaque ID, send/start/end dates/time-zone, owner-approved route/cadence, aggregate invited/responded count, consent/retention reference for voluntarily shared media, and redacted aggregate artifact root.

## Matrix

| Done | Subtask | Exact action and required record | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-008-ST-01` canonical questions | Copy the eight core questions and defect fields from the canonical file into owner-approved communication unchanged; send to each approved tester; record source path/date/cohort count/aggregate response count only. | Uniform questions reach whole cohort. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-008-ST-02` required topics | Before sending, verify communication covers completion, camera/import clarity, respectful useful result language, permission trust, export/persistence, purchase/Restore, failures/performance, repeat use/priority change. | Every response is comparable across required topics. | Actual coverage: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-008-ST-03` cadence/metrics | On approved cadence, review aggregate TestFlight feedback/crashes/sessions and response progress; log date/build/counts/trends/defect IDs. | Fixed-cadence aggregate review, not anecdotal monitoring. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-008-ST-04` media/privacy handling | Before accepting media, obtain owner-approved consent/retention route; tell testers not to send source photos/sensitive data; store voluntary media outside Git and record aggregate count/retention reference only. | Personal media is optional, controlled, and never committed. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-QA-008-ST-05` aggregate/disposition | Sanitize findings into category/count/build/impact; link each actionable item to existing/new `docs/BUGS.md`, canonical task, or written owner “won’t fix” rationale. | Every actionable observation has a disposition for `AURA-QA-009`. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Acceptance and invalidation

- [ ] Cohort, dates, common questions, aggregate response count, cadence, and sanitized results are recorded.
- [ ] Every actionable observation is a bug/task or explicit rationale.
- Stop for missing external cohort/authority/cadence or privacy-bearing content. A new build or material beta-flow change begins a fresh cohort.
