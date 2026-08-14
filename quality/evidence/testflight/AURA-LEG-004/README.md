# AURA-LEG-004 evidence — App Store privacy declaration

- Status: `blocked_external` — static source audit supports a provisional local-only conclusion; owner sign-off, public URL, and published App Store Connect declaration are absent.
- Canonical plan: [`docs/testflight/tasks/AURA-LEG-004.md`](../../../../docs/testflight/tasks/AURA-LEG-004.md)
- Apple references checked 2026-07-29: [Manage App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy) requires a privacy-policy URL for iOS apps and directs Account Holder/Admin/App Manager to select `No, we do not collect data from this app` only when the audited app and third-party partners do not collect data. [App privacy details](https://developer.apple.com/app-store/app-privacy-details/) defines collection as off-device transmission accessible beyond the real-time request.

## Static candidate audit — repository facts, not published answers

| Area | Exact source / observed fact | Provisional conclusion | External confirmation required |
| --- | --- | --- | --- |
| Data declaration | `AuraFit/Resources/PrivacyInfo.xcprivacy`: `NSPrivacyTracking=false`, empty tracking domains and collected-data types; only File Timestamp reason `C617.1`. | Manifest declares no collected/tracked data. | Inspect exact Release bundle and any new SDKs. |
| Release configuration | `AuraFitTests/ReleaseConfigurationTests.swift` asserts no broad Photos-read usage string, Camera/add-only Photos strings exist, manifest is bundled. | Automated regression coverage exists; not a source-to-store signature. | Run candidate tests/build inspection and record output. |
| Network/SDK scan | Source search found only Apple EULA and subscription-management links; project has no package references; policy states no analytics/crash/advertising SDK. | No repository evidence of developer/third-party collection. | Owner signs exact-candidate audit; inspect linked frameworks/archive. |
| Local processing/storage | `FEAT-005`, policy, and in-app policy describe on-device Vision/Core Image/heuristics, SwiftData/Documents, user-initiated share/save, and Apple StoreKit. | Local storage/Apple-managed purchase state alone does not prove developer collection. | Confirm shipping behavior and any changed diagnostics. |
| Public policy | `docs/PRIVACY_POLICY.md` and in-app view agree, but document explicitly says hosted final URL is still required. | App Store URL cannot yet be entered. | `AURA-MKT-004` logged-out public HTTPS evidence. |

## Matrix

| Done | Subtask | What to do and evidence required | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [ ] | `AURA-LEG-004-ST-01` re-audit behavior | For the exact candidate, record source/framework/config audit of Camera, Photos, local storage, StoreKit, sharing, networking, diagnostics, analytics/crash SDKs, and dependencies. Flag uncertainty rather than extrapolating this audit. | Dated data-flow inventory classifies each item local, Apple-managed, user-initiated, or developer/third-party collection. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-004-ST-02` compare artifacts | Compare ST-01 to Release `Info.plist`, `PrivacyInfo.xcprivacy`, `docs/PRIVACY_POLICY.md`, `PrivacyPolicyView.swift`, hosted policy, and proposed Apple form. Owner signs/date the matrix. | Every artifact agrees or has a correction list. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-LEG-004-ST-03` collection response | Only when ST-01/02 support it, authorized owner uses Apps → AuraFit → App Privacy → Get Started and chooses no collection; otherwise stop for privacy/legal review of live Apple fields. | Published selection is traceable to signed audit, never guessed from an old manifest. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-004-ST-04` privacy URL | Copy exact final logged-out URL from `AURA-MKT-004`; Apps → AuraFit → App Privacy → Privacy Policy → Edit; leave Privacy Choices blank unless an actual public applicable page exists. | Stored URL equals tested public HTTPS policy. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-004-ST-05` publish/preview | Immediately recheck ST-01–04, save/publish, open Product Page Preview/See Details, and retain redacted state/build/date/operator evidence. | Preview matches signed comparison; published state is observable. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-004-ST-06` reopen triggers | Record source change review for analytics, crash/SDK, networking, permissions, sharing, storage, diagnostics, or policy changes; rerun ST-01–05 whenever any occurs. | Privacy form cannot be treated as permanent verification. | Actual: trigger list recorded; Artifact: this README; Status: `code_complete` |

## Acceptance and invalidation

- [ ] Owner-signed source-to-declaration comparison exists.
- [ ] Public policy URL is live, logged-out reachable, and matches repository/in-app policy.
- [ ] App Privacy response is published with a redacted product-page preview.
- Any change listed in ST-06 invalidates published evidence. Do not commit account screenshots or credentials.
