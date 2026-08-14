# AURA-OPS-014 evidence — export compliance

- Status: `human_review_required` — a static technical audit supports the current project setting, but only an authorized owner can complete Apple’s build-specific compliance flow.
- Canonical plan: [`docs/testflight/tasks/AURA-OPS-014.md`](../../../../docs/testflight/tasks/AURA-OPS-014.md)
- Apple references checked 2026-07-29: [Overview of export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance) requires an App Store Connect determination for apps that use/access/contain/implement/incorporate encryption. [Determine and upload documentation](https://developer.apple.com/help/app-store-connect/manage-app-information/determine-and-upload-app-encryption-documentation) directs Account Holder/Admin/App Manager to Apps → App Information → App Encryption Documentation or the missing-compliance build flow. These sources do not replace owner/legal determination.

## Static technical audit — exact sources checked 2026-07-29

| Check | Evidence | Observed technical fact | Boundary |
| --- | --- | --- | --- |
| Build declaration | `AuraFit.xcodeproj/project.pbxproj` Debug and Release app configurations set `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO`; `ReleaseConfigurationTests` asserts false. | Project says it does not use non-exempt encryption. | This flag is not a legal conclusion or Apple processing result. |
| Networking/custom crypto | Source search for `URLSession`, `URLRequest`, common analytics/crash SDKs, and URLs found only Apple EULA/subscription-management links; no custom crypto imports/implementation observed. | No app-implemented network transport/custom cryptography found in source audit. | Re-audit archive/linked frameworks and any later source change. |
| Dependencies/frameworks | No Swift package references in project; project context prohibits third-party dependencies; app frameworks are Apple system frameworks. | No third-party package cryptography identified. | Check added binary/framework/SDK at archive time. |
| Privacy/release regression | Manifest has no collection/tracking and Release test asserts encryption flag; Release candidate audit remains separate. | Existing automated guardrails support static audit. | Must run for candidate and preserve output outside Git. |

## Matrix

| Done | Subtask | What to do and evidence required | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [x] | `AURA-OPS-014-ST-01` technical audit | Audit build settings, source imports/networking/crypto, packages/frameworks, and architecture; record exact locations above and repeat against candidate archive. | Reproducible encryption-use inventory; unknown/new use blocks determination. | Actual: static audit above; Artifact: repository paths; Status: `code_complete` |
| [x] | `AURA-OPS-014-ST-02` declaration comparison | Compare technical facts to `ITSAppUsesNonExemptEncryption=false`; record alignment as technical, not legal. | Current source audit and project setting align provisionally. | Actual: aligned pending archive/owner review; Artifact: paths above; Status: `verification_pending` |
| [ ] | `AURA-OPS-014-ST-03` Apple questions | Authorized owner opens Apps → AuraFit → App Information → App Encryption Documentation (+), or build Missing Compliance → Manage; answer current dialogs using audit/legal direction; record build/date/redacted result. | Apple workflow completed for exact build. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-OPS-014-ST-04` no-documentation route | Only if Apple says documentation is not required: retain matching declaration, record Apple result/build/date, confirm processing no longer says Missing Compliance. | Build-specific no-documentation outcome is observable. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-OPS-014-ST-05` required-document route | If Apple requires documents: record exact requirement; owner/legal prepares/uploads outside Git; wait approval; associate approved declaration with intended build. | Required material is approved and attached before Beta App Review. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [x] | `AURA-OPS-014-ST-06` legal boundary | This README records: do not fabricate CCATS, ANSSI, exemption, or legal classification; uncertain facts must name build/audit and request owner/legal decision. | Technical work stops cleanly at legal/Apple authority boundary. | Actual: boundary recorded; Artifact: this README; Status: `code_complete` |

## Acceptance and invalidation

- [ ] Exact processed build no longer shows `Missing Compliance`.
- [ ] App Store Connect determination agrees with the build declaration and fresh technical audit.
- [ ] Required documentation, if any, is approved and attached; no legal material is committed.
- Any source, linked-framework, networking, crypto, build, or Apple-flow change invalidates ST-02–ST-05. Current blocker: `OWNER_REQUIRED_APP_ENCRYPTION_DETERMINATION` for uploaded build `OWNER_REQUIRED_PROCESSED_VERSION_AND_BUILD`.
