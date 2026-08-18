---
id: AURA-QA-004
title: Execute accessibility and supported-layout matrix
gate: TF-G1
status: blocked_external
ownerBoundary: Human reviewer + iPhone
dependsOn: [AURA-OPS-012A]
evidence: quality/evidence/testflight/AURA-QA-004/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-004 — Accessibility and supported-layout matrix

## Task description

This task verifies that AuraFit's beta journey is operable beyond default visual settings on supported physical iPhones. It matters because accessibility claims and release safety require real assistive-technology evidence, not simulator snapshots. Starting with the `AURA-OPS-012A` Release build, execute every matrix row below and record model, iOS, build, settings, screen/journey, expected/actual, artifact, and defect; the expected result is an independently usable core and purchase/legal flow or a tracked blocker.

## Preconditions and inputs

- `AURA-OPS-012A` Release build on physical iPhone; use smallest and largest supported iPhone models available.
- Record the exact accessibility settings and all evidence in `quality/evidence/testflight/AURA-QA-004/README.md`.
- Do not claim App Store Accessibility Nutrition Labels until manually verified against Apple's criteria.

## Subtasks

### AURA-QA-004-ST-01 — Run the core journey with VoiceOver

This validates real screen-reader access across Scan, permission primer, analysis, Result, History, Paywall, Settings, and privacy policy. Enable VoiceOver on a physical iPhone and traverse each named screen through its primary action. Expect each screen to be understandable and completable without sight; record screen, route, expected/actual, and focus artifact.

**Execution**

1. Enable Settings → Accessibility → VoiceOver and launch the signed Release build.
2. Visit and operate the eight named screens in order, including a camera/import result where access permits.

**Expected result and evidence:** Core journey is independently operable; log every screen and outcome.

**Failure handling:** Unusable core path is P1; create a bug and stop claiming VoiceOver coverage for that path.

### AURA-QA-004-ST-02 — Verify VoiceOver semantics and actions

This verifies the quality of the VoiceOver path, because a reachable control is insufficient if its role, label, progress, or cancellation is ambiguous. On the ST-01 journey inspect focus order, button labels, headings, progress announcements, dismiss/cancel actions, and duplicate/unlabeled controls. Expect logical order and meaningful announcements; capture observed labels rather than guessing them.

**Execution**

1. Swipe through each screen and activate primary/secondary controls using VoiceOver gestures.
2. During analysis, confirm progress is announced; open/dismiss sheets and invoke cancel where available.

**Expected result and evidence:** No duplicate/unlabeled control or broken focus/action; record observed behavior per screen.

**Failure handling:** Broken focus, hidden action, or missing critical label is P1; create defect.

### AURA-QA-004-ST-03 — Test Dynamic Type including accessibility sizes

This verifies text and legal terms remain readable at supported sizes. Test default, XL, XXXL, and one accessibility size, relaunching as needed, across Scan, Result, Paywall, Settings, privacy, and terms. Expect no clipped legal copy, hidden purchase terms, unreachable button, or horizontal truncation; record each size/device combination.

**Execution**

1. In Settings → Accessibility → Display & Text Size → Larger Text, select each required size.
2. Open the listed screens and attempt their primary actions, checking all purchase/legal content.

**Expected result and evidence:** Text reflows and actions remain reachable at every size; log screenshots and actual layout result.

**Failure handling:** Clipping or unreachable critical action is P1; create bug.

### AURA-QA-004-ST-04 — Test visual accessibility settings

This verifies controls do not rely only on default color/motion styling. On physical hardware test dark appearance, Increase Contrast, Reduce Motion, Button Shapes, and Differentiate Without Color across the core journey and paywall. Expect distinguishable states, legible contrast, and no required animation; record each setting combination used.

**Execution**

1. Enable one setting at a time in iOS Settings and relaunch AuraFit if needed.
2. Inspect Scan, analysis, Result, Paywall, Settings, and error/permission states for usable contrast and affordances.

**Expected result and evidence:** No blocker-level contrast, state, or motion issue; log screen and observed state.

**Failure handling:** A core action indicated only by color or a blocking motion/contrast defect is P1.

### AURA-QA-004-ST-05 — Test smallest and largest supported iPhone layouts

This verifies supported portrait iPhone layouts without expanding unsupported platform claims. Use the smallest and largest supported physical iPhone models available, keep portrait orientation, and run the primary Scan→Result, History, Paywall, Settings, privacy/legal routes. Expect no clipped/reordered blocking content; do not substitute iPad or claim iPad support.

**Execution**

1. Install the same Release build on each available smallest/largest supported iPhone.
2. Execute the named journey in portrait and record model, screen, and layout result.

**Expected result and evidence:** Both supported device extremes have usable portrait layouts.

**Failure handling:** Blocking layout issue is P1; missing a required physical device leaves that coverage `blocked_external`.

### AURA-QA-004-ST-06 — Verify accessibility identifiers remain queryable

This verifies automation can target stable parent and child actions without masking child IDs. On a physical-device accessibility/UITest-capable run, query identifiers used by core controls and confirm parents do not conceal child action identifiers. Expect each required ID to resolve once and child actions remain individually addressable; record query source and result.

**Execution**

1. Use the existing UI-test/accessibility inspector route against the signed Release-compatible build where available.
2. Query core identifiers and child action IDs; record exact identifier, count, and target screen.

**Expected result and evidence:** Stable IDs are individually queryable; evidence names each query outcome.

**Failure handling:** Missing/masked required ID is P2 unless it prevents critical accessibility/automation, then P1.

### AURA-QA-004-ST-07 — Decide Accessibility Nutrition Label claims

This converts tested evidence into a bounded App Store claim, preventing unsupported accessibility marketing. Compare only the manually verified ST-01–06 behaviors with Apple's current criteria, list supported features and gaps, then request owner approval before any claim. Expect a documented claim/no-claim decision tied to evidence; do not select labels speculatively.

**Execution**

1. Summarize passed/failed evidence by eligible label feature and attach redacted task evidence paths.
2. Set `OWNER_REQUIRED_ACCESSIBILITY_NUTRITION_LABEL_DECISION`; obtain owner decision before App Store mutation.

**Expected result and evidence:** Evidence-backed decision is recorded, or status remains `human_review_required`.

**Failure handling:** Missing owner decision or incomplete manual evidence stops this subtask; do not claim labels.

## Acceptance criteria

- [ ] Core beta journey is independently operable with VoiceOver.
- [ ] Purchase/legal content remains readable at accessibility sizes.
- [ ] No blocker-level contrast, focus, clipping, or motion issue remains.

## Completion and evidence

Use `quality/evidence/testflight/AURA-QA-004/README.md` for all setting/device/journey results and redacted artifacts.

## Stop and reverification conditions

Stop on missing hardware, untestable signed Release build, or blocker defect. New build, UI/accessibility copy/layout changes, changed identifiers, or changed App Store accessibility criteria require affected-row retest.
