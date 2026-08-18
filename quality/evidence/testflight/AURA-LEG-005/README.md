# AURA-LEG-005 evidence — age rating and content rights

- **2026-08-18 update:** the age-rating questionnaire was answered in App Store Connect per
  `docs/release/APP_STORE_LISTING.md` and the computed rating is **4+**; content rights answered
  "no third-party content" (owner's assistant, owner-approved). Version 1.0 was submitted for App
  Review the same day. Record:
  `quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md`.

- Status: `blocked_external` — repository scope inventory is prepared; current App Store Connect questionnaire, rating, asset-rights records, and owner approval are absent.
- Canonical plan: [`docs/testflight/tasks/AURA-LEG-005.md`](../../../../docs/testflight/tasks/AURA-LEG-005.md)
- Apple references checked 2026-07-29: [Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating) requires current questionnaire answers and produces global/region ratings; an Unrated app cannot publish. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information) requires rights for third-party content and says Made for Kids commits subsequent updates to Kids guidelines.

## Repository scope and asset inventory — not questionnaire answers

| Area | Evidence source | Observed scope / required decision |
| --- | --- | --- |
| Children | `docs/PRIVACY_POLICY.md` says AuraFit is not directed at children. | Owner must confirm product audience against live questionnaire; do not select Made for Kids by assumption. |
| Wellness/body/appearance | `FEAT-001`, policy, and copy frame output as subjective outfit/photo guidance, not person measurement, identity, recognition, profiling, or health diagnosis. | Answer live descriptors only after Release UI review; regulated-medical prompt triggers legal review. |
| Social/UGC | No accounts, feed, voting, messaging, or network backend are documented; user may locally import/capture and voluntarily share through iOS. | Confirm exact candidate behavior; local user media is not an authorization for third-party content claims. |
| Production assets | Current source inventory found only `AuraFit/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`; test/synthetic QA media must stay excluded from Release. | Owner supplies `OWNER_REQUIRED_ASSET_RIGHTS_RECORD` for icon, fonts, any future media/models, and real-person images. |

## Matrix

| Done | Subtask | What to do and evidence required | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [ ] | `AURA-LEG-005-ST-01` current questionnaire | Authorized role: Apps → AuraFit → General → App Information → Age Ratings → Set Up/Edit. Capture schema/date and every current question; answer only after matching Release behavior/control/capability evidence. | Saved, evidence-backed response set for current Apple schema. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-005-ST-02` not Kids | Compare live selector with policy and Release onboarding/metadata; select no Made for Kids only if owner confirms unchanged audience. | No child-directed classification unless owner changes product scope. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-005-ST-03` wellness/body/UGC | Review live prompts alongside Release copy/features. Record the exact relevant prompt and evidence; stop if wording implies medical/diagnostic/body/appearance/social/UGC behavior beyond established scope. | Responses reflect subjective local outfit/photo guidance without unsupported claim. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-LEG-005-ST-04` calculated rating | Record global/region calculation before changes. Keep it unless owner provides `OWNER_REQUIRED_RATING_OVERRIDE_RATIONALE` plus legal review; then record reason. | Apple-calculated rating or documented lawful higher override. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-005-ST-05` content rights | Audit every shipping image/model/font/media; map category to owner rights record/license/removal action; verify QA fixtures are excluded from archive. | Redacted rights basis supports Content Rights attestation. | Actual inventory: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-005-ST-06` ratings/approval | Save questionnaire; record global and region output, questionnaire date, authorized role, and redacted owner-approval reference. | Auditable non-Unrated rating and approval without personal data. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-005-ST-07` regulated trigger stop | If Apple displays a regulated-medical or equivalent declaration, transcribe the live requirement, identify affected answer/build, request owner/legal direction, and do not confirm it. | No fabricated regulatory attestation. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |

## Acceptance and invalidation

- [ ] Current questionnaire saved with evidence-backed answers; global/region results are non-Unrated.
- [ ] Owner has approved audience, calculated/overridden rating, and content-rights basis.
- [ ] No unreviewed regulated-medical declaration or unknown asset right remains.
- Reopen after UI/content/asset, audience, legal agreement, or Apple-questionnaire change.
