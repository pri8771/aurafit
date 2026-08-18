# AURA-QA-004 evidence — accessibility and supported layout

- **2026-08-18 update:** **not run**; VoiceOver is deferred (DEC-005) and the Dynamic Type /
  appearance / layout matrix was consciously waived by the owner for the 1.0 (3) App Store
  submission on 2026-08-18 (DEC-007, `quality/waivers/1.0-3-device-qa-owner-waiver-2026-08-18.md`).
  Remains open, not done, for any later build.

- Status: `blocked_external` — this is an execution-ready matrix, not proof of accessibility.
- Canonical plan: [`docs/testflight/tasks/AURA-QA-004.md`](../../../../docs/testflight/tasks/AURA-QA-004.md)
- Dependency: `AURA-OPS-012A` signed Release build on physical iPhone; smallest/largest supported phones when distinct.
- Source facts: core root identifiers include `aurafit.scan.root.container`, `aurafit.result.root.container`, `aurafit.history.root.container`, `aurafit.paywall.root.container`, and `aurafit.settings.root.container`. Re-query on the candidate build; source presence is not a pass.

## Run header and blockers

| Field | Required value |
| --- | --- |
| Run ID / commit / version-build | Exact Release candidate identity. |
| Reviewer / date-time-zone | Accessibility-capable human reviewer and timestamp. |
| Device matrix | Model, iOS, smallest/largest role, portrait; no iPad substitution. |
| Settings matrix | VoiceOver, Dynamic Type default/XL/XXXL/accessibility size, Dark, Increase Contrast, Reduce Motion, Button Shapes, Differentiate Without Color. |
| Artifacts | Redacted screenshots/screen recordings/Accessibility Inspector or UI-test output stored outside Git. |
| Blockers | Missing signed build/device is `blocked_external`; unresolved P1 stops the affected claim. |

## Matrix

| Done | Subtask | Preconditions / setup | Exact procedure | Expected observable change | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- | --- |
| [ ] | `AURA-QA-004-ST-01` VoiceOver journey | VoiceOver enabled; signed Release; safe fixture/result where needed. | Traverse and operate Scan, permission primer, analysis, Result, History, Paywall, Settings, privacy policy in order using VoiceOver gestures. | Every named screen is understandable and its primary action is completable without sight. | Actual per screen: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-004-ST-02` VoiceOver semantics | ST-01 route available. | Swipe focus through each screen; activate primary/secondary controls; during analysis verify progress; open/dismiss sheets and cancel where available. | Logical focus; meaningful labels/roles/headings; announced progress; reachable cancel/dismiss; no duplicate/unlabeled critical control. | Actual labels/focus: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-004-ST-03` Dynamic Type | Physical device; select default, XL, XXXL, one accessibility size. | For every size, relaunch as needed and check Scan, Result, Paywall, Settings, privacy, and terms; exercise primary actions. | Reflowed readable text; no clipping/horizontal truncation; purchase/legal content and buttons remain reachable. | Actual device-size matrix: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-004-ST-04` visual settings | Configure one setting at a time then relaunch if required. | Test Dark, Increase Contrast, Reduce Motion, Button Shapes, Differentiate Without Color on Scan, analysis, Result, Paywall, Settings, error/permission states. | States are not color-only, contrast is usable, and no required animation blocks progress. | Actual setting-screen matrix: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-004-ST-05` small/large layout | Same signed build on available smallest and largest supported iPhones; portrait. | Run Scan→Result, History, Paywall, Settings, privacy/legal routes on both. | No clipped, hidden, reordered, or unreachable blocking content; do not claim unsupported platforms. | Actual device-route matrix: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-004-ST-06` identifiers | Physical-device accessibility inspector or Release-compatible UI-test route. | Query each core root ID and child action IDs; record identifier, count, screen, query tool/output. | Each required target resolves once and parent containers do not mask child actions. | Actual query list: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-QA-004-ST-07` Nutrition Label decision | Completed manual evidence from ST-01–ST-06 and current Apple criteria. | Summarize confirmed features/gaps with evidence links; request `OWNER_REQUIRED_ACCESSIBILITY_NUTRITION_LABEL_DECISION`; do not mutate App Store Connect. | Owner-approved evidence-based claim/no-claim, or explicit `human_review_required`. | Decision/evidence: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Severity, acceptance, and reverification

- P1: VoiceOver-unusable core route, missing critical label/focus/action, inaccessible purchase/legal content,
  blocking clip, color-only critical state, or required-motion blocker. P2: non-critical identifier issue unless it
  blocks accessibility/automation. Log every defect without weakening the criterion.
- [ ] VoiceOver independently completes the core beta journey.
- [ ] Purchase/legal content is readable and actionable at the tested accessibility sizes.
- [ ] No P1 contrast, focus, clipping, layout, or motion defect remains.
- Retest affected rows after a build, UI/accessibility copy/layout, identifier, or Apple-criteria change.
