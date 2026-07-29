# AuraFit — Program Plan

Owner: Priyansh Chordia · Created 2026-07-28 · Last updated 2026-07-28
Status: **Phase 0 in progress** · Horizon: v1.0 → v2.0

---

## 0. How to use this document

This is the **canonical program plan** across every discipline — engineering, QA, design,
legal, operations, marketing, growth, monetization, support. Jira and Notion are *mirrors*;
this file is the source of truth. Update here first, sync outward.

It supersedes the "next action" line in `docs/STATUS.md`.

**The plan is expected to be wrong.** That is the point. Sections 9 and 10 exist to capture
*how* it was wrong — scope changes, delays, missed estimates — so the next planning cycle is
better calibrated. A plan that never changes was never a plan; it was a wish. What matters is
that every change is *recorded* with its cost, rather than silently absorbed.

---

## 1. Planning method

### 1.1 Task ID scheme

`AURA-<DISCIPLINE>-<NNN>` — the discipline lives in the key so a flat board stays readable.

| Tag | Discipline | Scope |
|---|---|---|
| `ENG` | Engineering | App code, architecture, performance |
| `QA` | Quality assurance | Test strategy, device matrix, beta, release gates |
| `DATA` | Data / ML | Datasets, model evaluation, prompt tuning, calibration |
| `DES` | Design | UI/UX, brand, store assets, accessibility |
| `LEG` | Legal / compliance | Privacy, terms, licensing, App Review policy |
| `OPS` | Operations / tooling | CI/CD, signing, release automation, diagnostics, PM tooling |
| `MKT` | Marketing | Positioning, messaging, content, ASO copy, launch |
| `UA` | User acquisition | Channels, creators, community, paid |
| `MON` | Monetization | Pricing, paywall, conversion, subscription design |
| `SUP` | Support | Help content, review response, user comms |
| `PM` | Program management | Process, cadence, this document |

Legacy IDs remain valid and are cross-referenced: `AURA-B01` (bug, `docs/BUGS.md`),
`AURA-R01`–`R04` (risk, `docs/RISKS.md`), `AURA-CORE-001` (now `AURA-QA-002`).

### 1.2 Board schema (for Jira / Notion)

| Field | Values |
|---|---|
| **Key** | `AURA-<DISC>-<NNN>` |
| **Type** | Epic · Task · Bug · Spike · CR |
| **Discipline** | tag from §1.1 (also the Jira label) |
| **Phase** | 0 · 1 · 2 · 3 · Ongoing · Parked |
| **Priority** | P0 release-blocker · P1 must-for-phase · P2 should · P3 nice |
| **Status** | Backlog → Planned → In Progress → In Review → Blocked → Done (or Cancelled) |
| **Estimate** | ideal days (`d`), solo developer with agent assistance |
| **Actual** | filled on completion — feeds §10 |
| **Depends on** | task keys |
| **Acceptance** | verifiable condition, not a vibe |

Epics map to phases and workstreams. Jira import: CSV with columns
`Summary, Issue key, Issue Type, Labels, Priority, Description, Story Points, Epic Link`.

### 1.3 Estimation

Estimates are **ideal days** — uninterrupted working days for one developer with agent
assistance. They deliberately exclude review latency, App Review turnaround, and context
switching. Calendar dates in §3 apply a 1.6× factor over ideal days to absorb that.

Anything estimated above 3d must be split before it enters In Progress.

### 1.4 Change request process

Any scope change after a phase starts gets a CR entry in §9. Minimum fields: what changed,
who raised it, what it displaces, estimated delay, decision. **A CR is not a failure** — an
unrecorded CR is.

Rule: a CR that adds work to a phase must either (a) name what it displaces, or (b) move the
phase's milestone date. Silently absorbing scope is how the 2026-07-27/28 slip happened
(see CR-001/CR-002).

### 1.5 Planning-quality metrics (the meta-goal)

Reviewed at each phase retro (`AURA-PM-004`):

| Metric | Definition | Target |
|---|---|---|
| **Estimate accuracy** | median(actual ÷ estimate) per phase | 0.8–1.3 |
| **Scope volatility** | net ideal-days added by CRs ÷ phase estimate | < 25% |
| **Blocker discovery timing** | share of P0 blockers identified during planning vs. discovered in execution | > 70% in planning |
| **Rework rate** | tasks reopened after Done | < 10% |
| **Plan half-life** | days before a phase's task list changes materially | tracked, not targeted |

---

## 2. Strategic direction

### 2.1 Positioning

**From** "AI outfit scorer" **to "Look good in photos"** — a photo coach with a style lens.
Style analysis is the hook that earns the download; photography coaching is the substance
that earns retention and a subscription.

### 2.2 Why (evidence, not preference)

`ScoreEngine`'s own weighting already votes for this:

| Side | Metrics | Weight |
|---|---|---|
| Photography | Pose 15%, Lighting 15%, Framing 15%, Background 10% | **55%** |
| Wardrobe | Outfit Cohesion 25%, Colour Harmony 20% | **45%** |

The engine has always been more than half a photo coach; the positioning never caught up.
Everything built on 2026-07-27/28 (`PhotoCoach`, CLIP photo-issue detection,
`LiveCameraCoach`) landed on the photography side, because that is where objective signal is.

- **"Is my outfit good?" has no ground truth.** A 73/100 on style is arguable by definition.
  Crowded, faddish category, and scoring appearance carries product and App Review risk.
- **"Is this photo well-lit, sharp, well-framed?" has real answers.** Defensible score,
  verifiable advice, visible improvement when followed.

This widens the audience from fashion enthusiasts to anyone shooting a dating profile photo,
a headshot, or travel pictures — without discarding the style hook.

### 2.3 Charter constraints (non-negotiable without a CR + `DECISIONS.md` entry)

From `.factory/project-context.json`: `localFirst: true`, `backendAllowed: false`,
`thirdPartyDependenciesAllowed: false`. Bundled model *assets* and *build-time* tools are
acceptable; runtime dependencies and servers are not.

### 2.4 The measurement problem

No backend means **no analytics**: in-app funnels, screen flow, and mode usage cannot be
measured remotely. "Ship and let data decide" does not work by default. Resolved by
`AURA-OPS-006` before launch.

**Decision (2026-07-28, from `AURA-OPS-004`/`006` research): three-layer, no backend.**

1. **App Store Connect App Analytics** — free, no SDK, and better than assumed: impressions,
   product page views, conversion rate, installs by source, **day 1/7/28 retention cohorts**,
   plus full subscription metrics. Caveats: 24–48h lag, no custom events, and usage-side
   figures are sampled from the ~20–30% who opted into sharing — trends yes, absolute counts no.
2. **MetricKit, local only** — subscribe to `MXMetricManager`, append `.jsonRepresentation()`
   payloads to a capped ring buffer in the sandbox, expose a Settings → Diagnostics share
   sheet. Nothing leaves the device unless the user taps Share, so
   `NSPrivacyCollectedDataTypes` stays empty. Device-only, no debugger, one-day latency — this
   is a **beta-era debugging aid**, not production monitoring.
3. **Interviewed TestFlight cohort** (`AURA-QA-007/008`) — the only real source of *why*.

**Rejected: a minimal anonymous counter endpoint.** It breaks the charter, forces a non-empty
privacy nutrition label (Usage Data, plus IP is inherently transmitted), adds ATS/hosting/GDPR
work, and forfeits the "this app makes no network calls" claim — which the competitive research
identifies as the only structurally defensible moat (§6.9). The information delta over layers
1–3 is small.

---

## 3. Milestones and timeline

Week 1 = 2026-07-28. Dates are targets for measuring variance, not commitments.

| # | Milestone | Target | Gate |
|---|---|---|---|
| **M1** | Phase 0 code complete | end W3 · Aug 17 | All P0 ENG/LEG tasks Done, suite green |
| **M2** | Device QA passed, beta live | end W4 · Aug 24 | `AURA-QA-002` signed off; TestFlight external build approved |
| **M3** | v1.0 submitted | W5 · Aug 31 | Store assets, metadata, privacy answers complete |
| **M4** | **v1.0 live — launch** | W6 · Sep 7 | Approved; launch campaign executed |
| **M5** | v1.1 photo mode | end W11 · Oct 12 | Phase 1 exit criteria |
| **M6** | v1.2 lessons + premium | end W19 · Dec 7 | Phase 2 exit criteria |
| **M7** | v1.3 explainable filters | end W24 · Jan 11 2027 | Phase 3 exit criteria |

**Seasonal note:** App Review typically has reduced throughput and a submission freeze window
around late December. M6 is deliberately placed before it; anything slipping past ~Dec 12
should target January rather than fighting the queue.

**Planning correction (2026-07-28).** The first draft placed the Apple featuring nomination
(`AURA-MKT-006`) loosely "in Phase 0." Research shows nominations need a **minimum 3 weeks'
lead, with 2–3 months preferred**, so a nomination filed at M3 would arrive too late to affect
launch. It moves to **W2 (by Aug 10)** — before the app is even feature-complete, which is
allowed and expected. Logged as a planning miss in §10.1 rather than silently corrected.

---

## 4. Phase 0 — Production readiness (the gate)

**Goal:** a verified, shippable v1.0 of what already exists. **No new features.**
Nothing in Phases 1–3 begins before this closes.

### 4.1 Repo hygiene — `ENG`

| Key | Task | Pri | Est | Status | Acceptance |
|---|---|---|---|---|---|
| `AURA-ENG-001` | Commit all outstanding work on a review branch | P0 | 0.5d | **Done** | Clean tree; CLIP assets, coach features, docs, privacy manifest tracked |
| `AURA-ENG-002` | Confirm `build/` ignored, no derived data tracked | P0 | 0.1d | **Done** | `git ls-files build` empty |
| `AURA-ENG-003` | Decide Git LFS for the 22MB `.mlpackage` | P2 | 0.3d | Backlog | Decision recorded; clone time acceptable |

> `AURA-ENG-001` was release-blocking: Xcode synchronized folders derive target membership
> from the filesystem, so an untracked `PrivacyInfo.xcprivacy` meant any clean checkout or CI
> archive shipped **without a privacy manifest** — no build error, no warning. (Legacy `AURA-B01`.)

### 4.2 Release blockers — `ENG` / `LEG`

| Key | Task | Pri | Est | Files | Acceptance |
|---|---|---|---|---|---|
| `AURA-ENG-004` | Align analysis claims with what ships | P0 | 0.5d | `OnboardingView.swift:17`, `PermissionPrimerView.swift:32`, `FitResultView` persona card | Copy describes the real MobileCLIP + Vision stack; persona shown with its actual confidence, not as certainty |
| `AURA-ENG-005` | Remove fabricated confidences from the heuristic path | P0 | 0.2d | `OutfitClassifierService.swift:149,151` | No hardcoded `0.6`/`0.5`; heuristic tags carry no confidence or a documented one |
| `AURA-LEG-001` | AuraFit's own privacy policy, replacing Apple's URL | P0 | 0.5d | `SettingsView.swift:197`, `PaywallView.swift:192`, new `docs/PRIVACY_POLICY.md` + in-app view | Both links resolve to AuraFit's policy matching actual practice (local-only, no collection, no tracking) |
| `AURA-QA-002` | Device-verified core loop | P0 | 1.5d | — | See §5.2 |

> **Scope note on `AURA-ENG-004`:** the original audit finding was "copy overstates an absent
> model." Bundling MobileCLIP (CR-001) made "on-device AI reads your outfit" substantially
> *true*. The remaining gap is narrower — the Style Persona is presented as a certainty when
> it is a probability, and that persona is printed on shared scorecards and routes paywall
> upsells. Fix the certainty framing; keep the AI claim.

### 4.3 High-priority correctness and performance — `ENG`

| Key | Task | Pri | Est | Acceptance |
|---|---|---|---|---|
| `AURA-ENG-006` | Fix "Storage Unavailable" alert loop (`RootView.swift:33`) | P1 | 0.2d | Real `@State`, dismisses permanently, no re-presentation cycle |
| `AURA-ENG-007` | Async, downsampled, cached thumbnails | P1 | 1.5d | No full-res main-thread decode; `CGImageSourceCreateThumbnailAtIndex`; in-memory cache; 50-session history scrolls smoothly |
| `AURA-ENG-008` | Cancellable analysis + preserve captured photo | P1 | 1d | Cancel button; `Task.checkCancellation` between stages; JPEG written before analysis, cleaned up on failure/cancel |
| `AURA-ENG-009` | Challenge logic must match stated rules | P1 | 0.5d | "7-Day Glow Up" needs 7 distinct days; "Monochrome Mastery" actually checks monochromaticity |
| `AURA-MON-001` | Correct restore-purchases messaging (`PaywallView.swift:227`) | P1 | 0.2d | Template-only restore reports success, not "No purchases found" |
| `AURA-ENG-010` | Surface persistence failures (`SessionRepository.swift:111`) | P1 | 0.3d | Failed save reported, not silently losing a scan |
| `AURA-ENG-011` | Defensive free-scan quota binding | P1 | 0.3d | Nil `settings` logged and retried, never silently unlimited |

### 4.4 Configuration and hygiene — `ENG` / `OPS`

| Key | Task | Pri | Est | Acceptance |
|---|---|---|---|---|
| `AURA-ENG-012` | `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` | P1 | 0.1d | Present in both configs; uploads stop stalling on export compliance |
| `AURA-ENG-013` | Exclude `AuraFit.storekit` from the shipped bundle | P1 | 0.3d | Absent from Release `.app`; Debug StoreKit testing still works |
| `AURA-ENG-014` | `#if DEBUG`-gate dev-only code | P2 | 0.3d | `MockPurchaseProvider`, `AppEnvironment.preview()`, `-UITestInMemoryStore` not in Release |

### 4.5 Phase 0 exit criteria

All P0 tasks Done · full suite green · one complete capture→analyze→result→export→relaunch
loop verified on a physical iPhone · store submission prepared.

**Phase 0 estimate: ~11 ideal days** (≈3 calendar weeks at the 1.6× factor).

### 4.6 Phase 0 progress — as of 2026-07-28

**Engineering is essentially complete.** 16 tasks closed in one orchestrated session across
four parallel agents: `ENG-001/002/004/005/006/007/008/009/010/011/012/013/014`, `LEG-001`,
`LEG-007`, `MON-001`.

Verified on the merged tree, not per-package:

- **88/88 unit tests pass** (was 50 at the audit, 67 before this session).
- **Release build succeeds.**
- **Release bundle audited:** `AuraFit.storekit` absent; `PrivacyInfo.xcprivacy`,
  `MobileCLIPImageEncoder.mlmodelc`, `CLIPLabelEmbeddings.json` present;
  `ITSAppUsesNonExemptEncryption = false`; zero `MockPurchaseProvider` symbols and no
  `UITestInMemoryStore` string in the Release binary.

**What still gates the phase — none of it is code:**

| Key | Blocker | Needs |
|---|---|---|
| `AURA-ENG-038` | **MobileCLIP must be removed or replaced** — `DEC-004`. Top engineering item | An MIT/Apache encoder converted and palettized, or a decision to ship v1.0 heuristic-only |
| `AURA-QA-001` | UI smoke test still fails; the simulator cannot run Vision pose or segmentation | The DEBUG-gated Vision stub |
| `AURA-QA-002` | The core loop has still never been verified on a physical device | A person, a phone, the §5.2 matrix |
| `AURA-LEG-002` | MobileCLIP commercial licence unresolved | A human reading Apple's model licence. **Blocks M3** |
| `AURA-MKT-*`, `AURA-OPS-*`, `AURA-DES-*` | Store assets, landing page, release automation, featuring nomination | Owner time; the featuring nomination is due **Aug 10** |

The audit's original top finding is unchanged: **the loop has never run end to end on real
hardware.** Every engineering fix above is verified by unit tests and inspection only.

### 4.7 Execution queue — the next 20 tasks

Ordered by dependency and hard date. **Owner** column: `agent` = executable now without the
owner present; `owner` = needs Priyansh (device in hand, App Store Connect access, or a hosting
decision). The two tracks are deliberately parallel — they use different resources.

| # | Key | Task | Owner | Est | Depends on |
|---|---|---|---|---|---|
| 1 | `ENG-038` | Remove MobileCLIP: delete the two resource files, fix the 4 canary tests, confirm the heuristic path and `PhotoCoach` degrade cleanly | agent | 0.5d | `DEC-004` |
| 2 | `QA-001` | DEBUG-gated Vision stub so the UI smoke test runs deterministically | agent | 1d | — |
| 3 | `OPS-001` | CI green on main | agent | 0.3d | 2 |
| 4 | `ENG-035` | Launch-time orphan sweep for staged originals | agent | 0.5d | — |
| 5 | `ENG-037` | `FitResultView` full-resolution main-thread decode | agent | 0.3d | — |
| 6 | — | Signed Release build installed on the iPhone | agent | 0.2d | 1–5 |
| 7 | **`QA-002`** | **Physical-device QA matrix (§5.2) — THE GATE** | **owner** | 0.5d | 6 |
| 8 | — | Triage and fix whatever QA-002 finds | agent | **unknown** | 7 |
| 9 | `MKT-006` | **Apple featuring nomination — DUE AUG 10** | **owner** | 0.5d | 11 (light) |
| 10 | `MKT-004` | Landing page live — unblocks the hosted privacy-policy URL | owner | 1d | 11 |
| 11 | `MKT-001` | Positioning one-pager: one sentence, three proof points, named audience | agent draft | 0.5d | — |
| 12 | `MKT-002` | ASO title / subtitle / keyword field (§6.9.2 decisions) | agent draft | 1d | 11 |
| 13 | `DES-002` | App Store screenshots + app preview video (live coach leads) | owner | 1.5d | 7 |
| 14 | `LEG-008` | Reviewer test instructions + supplied test image | agent draft | 0.3d | — |
| 15 | `LEG-005` | Age-rating questionnaire, 2026 schema (wellness question needs care) | owner | 0.5d | — |
| 16 | `LEG-004` | Privacy nutrition labels — "Data Not Collected" | owner | 0.3d | — |
| 17 | `LEG-003` | Terms of service (Apple standard EULA or custom) | agent draft | 0.3d | — |
| 18 | `OPS-002` | App Store Connect API key + CI signing | owner | 0.5d | — |
| 19 | `QA-006` | TestFlight internal build + smoke pass | agent | 0.5d | 8, 18 |
| 20 | `QA-007` | TestFlight external, 15–30 recruited testers (Beta App Review) | owner | 1d | 19 |

**Notes on the queue**

- **Task 8 is deliberately unestimated.** The loop has never run on hardware; pretending to
  know the fix cost would be fake precision. It is the largest schedule risk in Phase 0 and the
  reason QA-002 is sequenced before the store assets rather than after.
- **Task 9 has the only hard external date.** Featuring nominations need 3 weeks' lead minimum.
  It does *not* depend on the app being finished — file it with what exists.
- **`ENG-003` (Git LFS for the 22MB model) is cancelled** — removing MobileCLIP removes the
  binary that raised the question.
- **`DES-001` (onboarding rewrite) is already done**, absorbed into Package C's copy work.
- Tasks 11, 12, 14, 17 are drafts an agent can produce; they still need owner review before
  they go near App Store Connect.

---

## 5. Quality assurance — `QA`

### 5.1 Test strategy

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-QA-001` | Redesign the UI smoke test around a Vision stub | 0 | 1d | `#if DEBUG` launch-argument-gated stub; CI green; impossible to activate in Release |
| `AURA-QA-003` | Regression suite definition | 0 | 0.5d | Named suite run before every submission |
| `AURA-QA-004` | Accessibility pass — VoiceOver + Dynamic Type XL | 0 | 1d | Scan, Result, History fully operable |
| `AURA-QA-005` | Performance budget | 1 | 0.5d | Cold launch < 1.5s; analysis < 4s; 60fps history scroll; documented and re-measured per release |

> **Why `AURA-QA-001` matters:** the simulator *cannot* validate this app's core loop.
> `VNDetectHumanBodyPoseRequest` and person segmentation do not run there — observed
> 2026-07-27 as `Unable to setup request` and `E5RT is not supported`. The existing smoke test
> fails for this reason, and CI fails identically. The test must assert the *UI contract*, not
> model quality.

### 5.2 `AURA-QA-002` — physical-device QA matrix

Manual, on a real iPhone. Results recorded in `docs/TEST_PLAN.md`. Minimum matrix:

- Camera capture → analysis → result → scorecard export → share
- Library import → same chain
- Relaunch → history intact, images render, favourite/delete work
- Permissions: camera denied → Settings deep link → library fallback; photo-add denied
- Live camera coach: every hint state reachable (dark, out of frame, too close, off-centre, perfect)
- PhotoCoach: deliberately dark / cropped / blurry photos produce right tips or rejection
- Interrupted analysis (background mid-scan), airplane mode, low storage
- StoreKit sandbox: purchase, restore, template-only restore, offline entitlement
- Dynamic Type XL, VoiceOver, dark appearance, long copy
- Thermal: 5-minute live-coach session does not overheat or drain excessively

### 5.3 Beta program

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-QA-006` | TestFlight internal build + smoke pass | 0 | 0.5d | Installable build, no launch crash |
| `AURA-QA-007` | External TestFlight, 15–30 recruited testers | 0 | 1d | Beta App Review approved; testers onboarded |
| `AURA-QA-008` | Structured beta feedback loop | 0 | 0.5d | Every tester asked the same 5 questions; responses logged |
| `AURA-QA-009` | Beta findings triaged into the board | 0 | 0.5d | Each item becomes a task or an explicit Won't Fix |

---

## 6. Supporting workstreams

### 6.1 Data & model quality — `DATA`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-DATA-001` | Labelled evaluation set (~100 photos, persona + quality labels) | 1 | 1.5d | Stored outside the app bundle; licence-clean; covers skin tones, body types, lighting, indoor/outdoor |
| `AURA-DATA-002` | Offline evaluation harness | 1 | 1d | One command scores the eval set and prints per-label accuracy — prompt changes become measurable rather than vibes |
| `AURA-DATA-003` | Prompt tuning + per-label calibration | 1 | 1d | Measured accuracy improvement over the current first-draft prompts |
| `AURA-DATA-004` | Encoder swap evaluation (S0 → S2 / BLT) | 2 | 0.5d | Accuracy vs. size/latency decision recorded |
| `AURA-DATA-005` | Linear probe on frozen embeddings | 2 | 2d | Beats zero-shot on the eval set at equal runtime cost |
| `AURA-DATA-006` | Fairness check across skin tone and body type | 1 | 1d | No systematic score gap; documented method and result |

> `AURA-DATA-006` is not optional politeness — an appearance-scoring app with a demographic
> score gap is both an ethical failure and a serious App Review and press risk (see `AURA-R08`).

### 6.2 Design — `DES`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-DES-001` | Onboarding rewritten for the new positioning | 0 | 0.5d | Communicates photo coaching + style, honestly |
| `AURA-DES-002` | App Store screenshots + preview video | 0 | 1.5d | All required sizes; leads with the live coach — the most demonstrable feature |
| `AURA-DES-003` | App icon review against category norms | 0 | 0.5d | Legible at 60pt, distinct in search results |
| `AURA-DES-004` | Fix contrast + Dynamic Type defects | 0 | 0.5d | `AFColors.textTertiary` meets WCAG AA; no fixed 9pt type |
| `AURA-DES-005` | Paywall redesign for the coaching offer | 2 | 1d | Sells the programme, not "unlimited scans" |

### 6.3 Legal & compliance — `LEG`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-LEG-002` | ~~Resolve MobileCLIP licence~~ | 0 | 0.5d | **CLOSED 2026-07-28 — negative. See `DEC-004`.** The Apple ML Research Model licence permits use *"exclusively for Research Purposes"* and explicitly excludes *"any commercial exploitation, product development or use in any commercial product or service."* MobileCLIP **cannot ship**. Superseded by `AURA-ENG-038` |
| `AURA-LEG-003` | Terms of service | 0 | 0.3d | Apple standard EULA accepted or custom terms published |
| `AURA-LEG-004` | App Store privacy nutrition labels | 0 | 0.3d | "Data Not Collected"; matches `PrivacyInfo.xcprivacy` and actual behaviour |
| `AURA-LEG-005` | Age rating questionnaire (2026 schema) | 0 | 0.5d | New 13+/16+/18+ tiers; social-media questions (required from Sept 2026) answered; **the "medical or wellness topics" question answered carefully** — a body/appearance-adjacent app must not overclaim |
| `AURA-LEG-006` | Subscription compliance | 0 | 0.3d | Price, term, renewal, restore, and links present per Schedule 2 |
| `AURA-LEG-007` | **Appearance-rating framing review** | 0 | 0.5d | Every user-facing string scores the *artifact* (outfit, photograph), never the person, face, body, or attractiveness. No leaderboards, no ranking against others, no "rate my looks" language. Disclaimer that scores are subjective craft guidance, not measurement |
| `AURA-LEG-008` | Reviewer test instructions | 0 | 0.3d | Review notes explain exactly how to exercise on-device photo analysis, with a supplied test image and steps |

> **`AURA-LEG-007` rationale.** Guideline 1.2 lists "objectification of real people (hot-or-not
> voting)" as removable — but that clause is **scoped to UGC/social services**, and AuraFit has
> no feed, no voting, and no other users, so it is not squarely in scope. Residual exposure is
> 1.1 (reviewer discretion on "creepy") and **1.4.1**, which rejects unvalidated accuracy claims
> about body/health measurement. The CR-003 repositioning is itself the strongest mitigation:
> it moves the object of judgement from the person to the picture. Reasoning is from guideline
> text, not precedent — no documented rejections were found for this app class.
>
> **`AURA-LEG-008` rationale.** An app whose core function needs a full-body photo of a real
> person, analysed on-device, is easy for a reviewer to fail by accident. Unclear reviewer
> instructions were identified as the single most likely rejection vector.

### 6.4 Operations & tooling — `OPS`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-OPS-001` | Fix CI (currently red — see `AURA-QA-001`) | 0 | 0.3d | Green on main |
| `AURA-OPS-002` | App Store Connect API key + CI signing | 0 | 0.5d | CI can upload to TestFlight unattended |
| `AURA-OPS-003` | Automated TestFlight upload on tag | 0 | 1d | Tag → build → signed → uploaded, no manual Xcode step. **Use Xcode Cloud** — 25 compute hours/month are included with the existing $99/yr membership (≈100–300 runs at this app's size) and it manages signing entirely, removing the whole class of certificate pitfalls. Keep GitHub Actions for PR build+test |
| `AURA-OPS-004` | Local MetricKit diagnostics + Organizer review habit | 0 | 0.5d | `MXMetricManager` subscriber writing a capped local ring buffer; Settings → Diagnostics share sheet; nothing auto-transmitted. Xcode Organizer Crashes/Metrics reviewed each release. dSYMs uploaded (never stripped) |
| `AURA-OPS-005` | Release checklist automation | 0 | 0.5d | `docs/RELEASE_CHECKLIST.md` machine-checkable where possible |
| `AURA-OPS-006` | **Decide the measurement approach** (§2.4) | 0 | 0.5d | `DECISIONS.md` entry + implementation. **Blocks M4.** |
| `AURA-OPS-007` | Jira + Notion board setup mirroring §1.2 | 0 | 1d | Schema created; this plan imported as CSV (Jira: System → External System Import; only `Summary` is strictly required). Carry each task key in an **External issue ID** column so re-imports update instead of duplicating. Notion imports the same CSV. **One-way sync only** — this file stays the source of truth; regenerate the mirrors, never merge back |
| `AURA-OPS-008` | Support inbox + review-response workflow | 0 | 0.3d | Address live before launch |

### 6.5 Marketing — `MKT`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-MKT-001` | Positioning + messaging one-pager | 0 | 0.5d | One sentence, three proof points, named audience |
| `AURA-MKT-002` | ASO: title, subtitle, keyword field | 0 | 1d | See §6.9.2. Never duplicate a term across fields — Apple counts it once |
| `AURA-MKT-003` | Store description + What's New template | 0 | 0.5d | Leads with benefit; no unverifiable AI claims (consistent with `AURA-ENG-004`) |
| `AURA-MKT-004` | Landing page | 0 | 1d | Hosted; privacy policy and support links live (**unblocks `AURA-LEG-001`'s hosted URL**). **Host decided 2026-07-29: OpenAI Sites** (Codex-deployed, owner action — not deployable from this repo's CI). GitHub Pages was built and reverted first; see `AURA-R14` for the two checks that must pass before this URL goes in App Store Connect |
| `AURA-MKT-005` | Launch content set: demo clips of the live coach | 0 | 1.5d | 5–8 short vertical videos ready before M4 |
| `AURA-MKT-006` | **Apple featuring nomination** | 0 | 0.5d | **Due W2 (Aug 10)** — App Store Connect → Featuring → Nominations, type "App Launch". Minimum 3 weeks' lead, 2–3 months preferred. Attach supplemental URLs (TestFlight link + demo video) and complete "Helpful Details". Lead with *runs entirely on-device, no account, no upload* |
| `AURA-MKT-007` | Press/launch-site outreach list | 0 | 0.5d | 20 named targets with angles |
| `AURA-MKT-008` | Post-launch content cadence | Ongoing | — | Weekly rhythm defined and sustainable solo |

### 6.6 User acquisition — `UA`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-UA-001` | Channel strategy + ranked bets | 0 | 0.5d | **Done — see the ranking below** |
| `AURA-UA-002` | Organic short-form video (owned accounts) | Ongoing | — | Daily posting for 90 days, not a launch burst. Formats: before/after, "the AI told me to move left" |
| `AURA-UA-003` | Creator seeding, micro only (5–50k) | 1 | 1d | 20–50 seeds with free premium codes; expect 2–3 that convert |
| `AURA-UA-004` | Community seeding (Reddit, Discord, forums) | 0 | 0.5d | Participate honestly; no astroturf. Primary value is qualitative feedback, not installs |
| `AURA-UA-005` | Referral / share loop | 2 | 1d | Scorecard share already exists — make it an acquisition loop |
| `AURA-UA-006` | Apple Search Ads — brand-defensive only | 1 | 0.5d | **Do not run category terms until LTV is known.** See the payback maths below |
| `AURA-UA-007` | Launch-day coordination | 0 | 0.5d | Content, outreach, community posts fire together at M4 |

**Channel ranking (`AURA-UA-001`, decided 2026-07-28):**

| # | Channel | Effort | Cost | Realistic expectation | Biggest failure mode |
|---|---|---|---|---|---|
| 1 | ASO | Med upfront, low ongoing | $0 | Compounding baseline; the majority of discovery at this size | Fighting for "rate my outfit" instead of claiming an unowned phrase |
| 2 | TikTok/Reels organic | High, sustained | $0 | The only realistic path to a spike | Treating it as a launch burst, not a 90-day habit — one video is not a channel |
| 3 | Creator seeding | Med | $0–50/creator | 20–50 seeds → 2–3 that convert | Paying mid-tier creators for one-off posts; almost always negative ROI at this budget |
| 4 | Reddit/community | Low–med | $0 | Modest and spiky | Self-promo bans — most relevant subs remove app posts on sight |
| 5 | PR / launch sites | Low | $0 | Hundreds, not thousands, of installs; useful for credibility links | Mistaking launch-day numbers for a growth channel |
| 6 | Apple featuring | Low (a form) | $0 | Low probability, enormous if it lands | Nominating late or generically — hence `AURA-MKT-006` moving to W2 |
| 7 | Apple Search Ads | Low | Median CPT ~$0.92 global / ~$1.91 US; subscription apps $1.00–3.50 | Defensive on brand terms only | Spending before payback is known: at ~2% conversion, a $1.43 CPA implies roughly **$70 effective CAC per subscriber** |

### 6.7 Monetization — `MON`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-MON-002` | Pricing decision + rationale | 0 | 0.5d | Monthly/annual set with a documented comparable-app basis |
| `AURA-MON-003` | Free-tier limit calibration | 0 | 0.3d | Daily limit generous enough to prove value before asking |
| `AURA-MON-004` | Paywall copy aligned to positioning | 0 | 0.3d | Sells coaching, not scan quota |
| `AURA-MON-005` | Intro offer / free trial decision | 1 | 0.5d | Configured in App Store Connect if adopted |
| `AURA-MON-006` | Conversion review | 1 | 0.5d | Reviewed against App Store Connect subscription metrics |
| `AURA-MON-007` | Premium repositioned around the coaching programme | 2 | 1d | Subscription sells lessons + personalized feedback + history |

> **Charter constraint:** `docs/HANDOFF.md` — *do not expand monetization before the core loop
> is verified.* `AURA-MON-007` is therefore blocked on `AURA-QA-002`, not merely on Phase 1.

**Target metrics (industry benchmarks, not forecasts).** Anything above these is a pleasant
surprise, not a plan input:

| Metric | Target | Benchmark basis |
|---|---|---|
| D1 retention | 25–30% | Cross-vertical median 25–26%; iOS ~27%; top quartile 30% |
| D7 retention | 10–13% | Median 11–13%; top quartile 15% |
| D30 retention | 5–8% | Median 5–7%; iOS ~8%. Task-specific utilities fall below 5%; habit utilities exceed 30% — AuraFit sits between and realistically near the low end unless the daily loop genuinely becomes habitual |
| Freemium → paid (d35) | 1.5–3% | ~2.1% median across 115k apps. Hard paywalls convert ~5× better (10.7%) but 1-year retention is near-identical, so the freemium choice stands |

### 6.9 Market intelligence (researched 2026-07-28)

#### 6.9.1 Competitive position

- **Outfit rating is crowded but nobody is entrenched.** A dense cluster of near-identical AI
  outfit raters shipped in the last ~18 months, almost all backend-LLM wrappers with $5–10/wk
  paywalls, thin review counts, no brand. The genuinely entrenched apps are *wardrobe*
  managers — they own "digital closet," not "score my look."
- **Photo critique is mostly web, not iOS.** The notable exception is Adobe's Project Indigo,
  which added AI photo critique in July 2026 — free and Adobe-branded, but aimed at
  photographers, not consumers.
- **Camera coaching is more crowded than expected.** Several live-pose/framing coaches exist;
  at least one is free, on-device, and does live aesthetic scoring — a direct analog that
  undercuts on price.
- **The unclaimed gap:** nobody credibly combines style judgement + photo-craft judgement +
  live coaching + genuine on-device privacy. Rivals do one leg each, and because they call an
  API, their privacy nutrition labels will say so. **Privacy is the only structurally
  defensible moat**, which is why `AURA-OPS-006` rejected the analytics endpoint.
- *Caveat:* no download or revenue data was obtainable. "None entrenched" is inference from
  store presence, not measurement — revisit before betting heavily on it.

#### 6.9.2 ASO decisions (input to `AURA-MKT-002`)

Avoid "rate my outfit" as the head term — it is the most contested phrase in the category and
already owned in title slots. **"Look good in photos" is the money phrase and is essentially
unclaimed in titles**, which independently validates CR-003.

- **Title (30 chars):** `AuraFit: Look Good in Photos`
- **Subtitle (30):** `Pose, Lighting & Outfit Score`
- **Keyword field (100):** fresh terms only — `selfie,framing,composition,style,mirror,check,picture,scanner,fit,confidence,camera,guide`
- **Screenshots:** only the first 2–3 appear in search. Order: (1) scorecard with a real number
  on a real photo, (2) live coach mid-correction with the instruction visible, (3) before/after,
  (4) "Photos never leave your iPhone", (5) paywall value. Plain honest overlays beat hype copy.
- **App preview video is not optional here** — the live coach is motion, and a static screenshot
  cannot convey it. 15–30s.

### 6.8 Program management — `PM`

| Key | Task | Phase | Est | Acceptance |
|---|---|---|---|---|
| `AURA-PM-001` | This plan | 0 | 1d | **Done** |
| `AURA-PM-002` | Weekly plan review | Ongoing | — | Status, estimates, and CR log updated every week |
| `AURA-PM-003` | Keep Jira/Notion in sync with this file | Ongoing | — | No divergence longer than one week |
| `AURA-PM-004` | Phase retro + §1.5 metrics | Per phase | 0.3d | Metrics computed; lessons folded into the next phase's estimates |

---

## 7. Post-MVP roadmap

### Phase 1 — Photo mode (v1.1, M5) · `ENG` + `DATA`

Score *any* photo, not just outfits. **~7 ideal days.**

| Key | Task | Est |
|---|---|---|
| `AURA-ENG-020` | Extract weights into `ScoringProfile` (`.fit` / `.photo`) | 1d |
| `AURA-ENG-021` | Subject placement via `VNGenerateAttentionBasedSaliencyImageRequest` | 1.5d |
| `AURA-ENG-022` | Horizon tilt via `VNDetectHorizonRequest` + "rotate 3° clockwise" tips | 1d |
| `AURA-DATA-007` | CLIP aesthetic + scene-type label groups; regenerate embeddings | 1d |
| `AURA-ENG-023` | Mode selection UX; auto-suggest Photo when no person detected instead of rejecting | 1d |
| `AURA-ENG-024` | Generalize `PhotoCoach` for non-human subjects | 0.5d |
| `AURA-ENG-025` | `FitSession.mode`; History filters; scorecard adapts | 1d |

**Exit:** a landscape, a pet photo, and a food photo each produce a defensible score with
actionable tips; no path rejects a photo merely for lacking a person.

### Phase 2 — Lessons & gamification (v1.2, M6) · `ENG` + `DES` + `MON`

Convert a novelty into a habit and an honest subscription. **~11 ideal days.**

| Key | Task | Est |
|---|---|---|
| `AURA-ENG-026` | Lesson data model extending `Challenge` | 1.5d |
| `AURA-ENG-027` | Weakness detection from `FitStatistics` trends → lesson assignment | 1.5d |
| `AURA-MKT-009` | Curriculum v1 — ~12 lessons (exposure, light direction, golden hour, thirds, headroom, leading lines, backgrounds, distance/compression, stability, verticals, colour, editing restraint) | 3d |
| `AURA-ENG-028` | Points, streaks, unlocks on existing streak logic | 1.5d |
| `AURA-ENG-029` | Personalized feedback via Foundation Models (iOS 26+, availability-gated, canned fallback) | 2d |
| `AURA-DES-005` | Paywall redesign | 1d |

**Exit:** a user completes a week of lessons, sees measured improvement in their own metric
trend, and the paywall offers something a reasonable person would pay for.

### Phase 3 — Explainable filters (v1.3, M7) · `ENG`

"Auto-edit, with reasons." **~5 ideal days.** Engine work, not content work — can be pulled
earlier if Phase 2's curriculum writing stalls.

| Key | Task | Est |
|---|---|---|
| `AURA-ENG-031` | ~10 named Core Image looks | 1d |
| `AURA-ENG-032` | Render candidates at preview size, rescore, rank | 1.5d |
| `AURA-ENG-033` | Explained before/after UI: "+18 lighting — lifted shadows without clipping" | 1.5d |
| `AURA-ENG-034` | Apply, export, persist; original never destroyed | 1d |

**Exit:** on an under-exposed photo the top suggestion measurably raises the lighting metric
and the stated reason matches the actual change.

### 7.1 Engineering debt — `ENG`, Ongoing

| Key | Task | Due by | Why |
|---|---|---|---|
| `AURA-ENG-030` | SwiftData versioned schema + migration plan | **before Phase 1 ships** | Schema is unversioned; Phases 1 and 2 both add fields. A failed store-open currently falls back to in-memory *forever*, stranding all user data with no export path. |
| `AURA-ENG-035` | Orphan reconciliation for image files | **Phase 0 → raised to P1** | Was "sessions and files written non-atomically." `AURA-ENG-008` now *deliberately* stages the JPEG before analysis to protect an unrepeatable capture, so a crash mid-pipeline reliably leaves an unreferenced file. The debt is no longer incidental — it is created by design and needs a launch-time sweep in `AuraFitApp`/`ImageFileStore`. |
| `AURA-ENG-036` | Move reveal-video rendering off the main actor | Phase 1 | 120 full-res frames render on `@MainActor`; UI freezes throughout |
| `AURA-ENG-037` | `FitResultView` still decodes full-resolution on the main actor | Phase 1 | Missed by `AURA-ENG-007`, which only owned the grid call sites. One decode on a detail screen, not per-cell, so materially smaller — but it is the same ~45MB main-thread decode |
| `AURA-DATA-008` | Calibrate monochrome-detection thresholds against real captures | Phase 0 (during `AURA-QA-002`) | `dominant: 3` / `maxHueSpread: 0.10` were tuned on synthetic palettes. Real photos carry background colour buckets. Too strict and "Monochrome Mastery" becomes uncompletable — the inverse of the bug just fixed |

---

## 8. Risk register

Extends `docs/RISKS.md`. P = probability, I = impact.

| Key | Risk | P | I | Mitigation | Status |
|---|---|---|---|---|---|
| `AURA-R01` | Analysis feels generic or misleading | med | high | CLIP classifier landed; honest copy (`AURA-ENG-004`); eval set (`AURA-DATA-001`) | mitigating |
| `AURA-R02` | Camera/import/export fails on real devices | med | high | `AURA-QA-002` device matrix | **open — top risk** |
| `AURA-R03` | Privacy declarations don't match behaviour | low | high | Manifest committed and verified accurate | mitigated |
| `AURA-R04` | Paywall precedes a credible first result | med | high | Monetization gated on `AURA-QA-002` | mitigating |
| `AURA-R05` | ~~MobileCLIP licence forbids commercial use~~ | — | high | **MATERIALISED 2026-07-28.** Confirmed research-only (`DEC-004`). No longer a risk; now scoped work as `AURA-ENG-038` | **realised → converted to work** |
| `AURA-R06` | No analytics → product decisions made blind | high | med | `AURA-OPS-006` | open |
| `AURA-R07` | Scope creep displaces the ship date | **high** | high | CR process §1.4; evidenced already by CR-001/002 | **open — active** |
| `AURA-R08` | Demographic bias in scoring | med | high | `AURA-DATA-006` fairness check | open |
| `AURA-R09` | App Review rejects appearance rating | low | high | `AURA-LEG-007` framing review; Guideline 1.2 is UGC-scoped so AuraFit is not squarely in scope; CR-003 repositioning moves judgement from person to picture | open |
| `AURA-R10` | Solo-developer bandwidth | high | med | Phase gating; agent delegation; explicit displacement rule | ongoing |
| `AURA-R11` | Category is crowded; organic discovery fails | med | med | Claim the unclaimed "look good in photos" phrase (§6.9.2); live coach as a content engine | open |
| `AURA-R12` | Reviewer cannot exercise on-device photo analysis and rejects | med | med | `AURA-LEG-008` reviewer notes + test image — identified as the single most likely rejection vector | open |
| `AURA-R13` | A free on-device live-coach competitor undercuts the wedge | med | med | Compete on the combination (style + craft + coaching + privacy), not on the coach alone; §6.9.1 | open |
| `AURA-R14` | The hosted privacy-policy URL is not publicly reachable, or does not outlive the app | med | high | Host is OpenAI Sites (`AURA-MKT-004`), a preview product whose sharing model is workspace-oriented. **Two gates before the URL enters App Store Connect:** (1) open it in a logged-out private window — a login redirect disqualifies it, since App Review and users must reach it with no account; (2) have a fallback host ready, because a policy URL must stay live for the life of the app | open |

---

## 9. Change request log

| CR | Date | Raised by | Change | Decision | Impact |
|---|---|---|---|---|---|
| **CR-001** | 2026-07-28 | Owner | Bundle a real vision model (MobileCLIP-S0) instead of the palette heuristic | **Accepted** | +1d ENG · +22MB bundle · created `AURA-LEG-002` (licence, now blocks M3) · *reduced* scope of `AURA-ENG-004` · **Phase 0 +1d** |
| **CR-002** | 2026-07-28 | Owner | Add `PhotoCoach` retake guidance and the live camera coach | **Accepted** | +1d ENG · +2 source files · +1 SwiftData field, raising urgency of `AURA-ENG-030` · **Phase 0 +1d** |
| **CR-003** | 2026-07-28 | Owner | Reposition "outfit scorer" → "look good in photos" | **Accepted** | Restructured roadmap; created Phase 1; invalidated draft store copy; no Phase 0 delay |
| **CR-004** | 2026-07-28 | Owner | Expand plan from engineering-only to full program (MKT/UA/MON/QA/OPS/LEG) with CR tracking | **Accepted** | +0.5d PM · this document · surfaced ~15 previously-unplanned non-engineering tasks |
| **CR-005** | 2026-07-28 | Licence finding | MobileCLIP must be removed or replaced before shipping (`DEC-004`) | **Forced** | Not optional scope — a licence breach. Invalidates the bundled encoder from CR-001. Est. 1–2d to swap to an MIT encoder + regenerate embeddings + re-verify, or 0.5d to remove and ship v1.0 heuristic-only. **Either displaces other Phase 0 work or moves M3** (§1.4 rule) |

### 9.1 Honest reading of CR-001 and CR-002

Both were accepted and executed *while* the release-blocking finding "core loop never verified
on a physical device" (`AURA-QA-002`, open since 2026-07-27) remained open. Two days of feature
work were done ahead of the gate that was supposed to precede feature work.

The features are good and the code is tested. That is not the point. The point is that the
displacement was never recorded, so the ship date silently moved. §1.4's displacement rule
exists specifically to stop this recurring — and `AURA-R07` is rated high probability because
this project has already demonstrated the pattern twice in two days.

---

## 10. Variance log

Populated as tasks complete; feeds the §1.5 metrics at each retro.

| Key | Est | Actual | Δ | Note |
|---|---|---|---|---|
Actuals are recorded as **agent-sessions (AS)** plus orchestrator review, not ideal days — see
PM-04 below for why the two are not converted.

| Key(s) | Est | Actual | Note |
|---|---|---|---|
| `ENG-001`, `ENG-002` | 0.6d | orchestrator, ~0.3d | Large but mechanical; 4 commits |
| `PM-001` | 1d | ~1.2d + 2 research AS | Research added scope and corrected 3 planning errors |
| `UA-001` | 0.5d | folded into research | — |
| `ENG-007` (pkg A) | 1.5d | 1 AS | 5→13 tests. Effect is arithmetic, unprofiled |
| `ENG-008/009/010` (pkg B) | 1.8d | 1 AS | 79→88 tests. Largest package; 3 follow-ups discovered |
| `ENG-004/005`, `LEG-001/007`, `MON-001` (pkg C) | 1.7d | 1 AS | Found the same restore bug in a second file |
| `ENG-006/011/012/013/014` (pkg D) | 1.0d | 1 AS | Found the `#Preview` assumption in the brief to be wrong |
| Merge verification | — | orchestrator, ~0.2d | 88/88 + Release build + bundle audit |

**Observed:** ~6.6 ideal days of estimated engineering closed in 4 parallel agent-sessions plus
roughly 0.5d of orchestration. The parallelism was only possible because the packages had
**disjoint file ownership**, which had to be designed deliberately — two of the four agents
still hit transient build failures from other agents' partial writes, and one had to verify
against a copy of the tree because a file it did not own was mid-edit.

### 10.1 Planning misses (feeds §1.5 "blocker discovery timing")

| # | Miss | Found by | Correction |
|---|---|---|---|
| **PM-01** | Apple featuring nomination was scheduled implicitly late; it needs 3 weeks minimum, 2–3 months preferred | Research, before execution | `AURA-MKT-006` moved to W2 |
| **PM-02** | Two compliance tasks were entirely absent from the first draft: the 2026 age-rating schema (new tiers, Sept 2026 social-media questions, wellness-topic question) and reviewer test instructions | Research, before execution | Added `AURA-LEG-005` (rescoped), `AURA-LEG-008` |
| **PM-03** | The measurement decision was left open with a vague default; App Store Connect's free analytics are substantially better than assumed, making the backend question moot | Research, before execution | §2.4 decided; `AURA-OPS-006` de-risked |
| **PM-04** | **The estimation basis does not match the execution model.** §1.3 estimates in "ideal developer days," but Phase 0 was executed by four parallel agents in one sitting. Wall-clock and ideal-days are not convertible, so the §1.5 estimate-accuracy metric currently has no honest denominator | Execution | See below — basis changed rather than faking actuals |
| **PM-05** | Four tasks were only discovered by *doing the work*, not by planning it: `AURA-ENG-037` (a call site `AURA-ENG-007` didn't own), `AURA-DATA-008` (thresholds tuned on synthetic data), the `AURA-ENG-035` priority raise, and the `SeedData` refresh problem — existing installs would have kept stale challenge copy forever because seeding was insert-only | Execution | All four filed |

**On PM-04.** Estimates stay in ideal days because that is the unit a human plans in and the
unit Jira/Notion expect. But actuals will be recorded as **agent-sessions + orchestrator review
time**, and the two are tracked in separate columns rather than pretending they're the same
number. The §1.5 estimate-accuracy target is suspended until Phase 1, when a full phase will
have been executed under a consistent model. Fabricating a day-count to fill the column would
defeat the point of measuring at all.

**On PM-05.** Four of roughly twenty Phase 0 tasks were discovered during execution, not
planning — about 80% found in planning, just above the §1.5 target of 70%. Worth noting the
*kind* that escaped: all four are the sort only visible with the file open (an unowned call
site, a threshold's real-world validity, an insert-only seeding path). That is the expected
residue; a plan that caught these would have required doing the work first.

| # | Miss | Found by | Correction |
|---|---|---|---|
| **PM-06** | **A factual error in the task brief itself.** The Package D brief asserted that SwiftUI `#Preview` blocks are excluded from Release builds. They are not, in this project — gating `AppEnvironment.preview()` broke the Release build across seven files, and `ENABLE_PREVIEWS=NO` did not strip them either | Execution, by the agent contradicting its instructions | `preview()` given a Release stub; full removal needs all seven `#Preview` blocks wrapped. The agent was right to deviate and say so |
| **PM-07** | Parallel agents need **disjoint file ownership designed up front**, and even then partial writes cause transient build failures in sibling agents. Two of four hit this; one had to verify against a copied tree | Execution | Ownership lists worked and there were zero merge conflicts, but *verification* must be re-run centrally on the merged tree — a per-package green result proves nothing on its own |

**On PM-06 specifically:** the brief was wrong and the agent proved it wrong rather than
working around it silently. That is the behaviour the process should reward — an instruction
being confidently stated does not make it true, and a plan is only as good as its willingness
to be corrected by contact with the code.

---

## 11. Parked — separate apps

Researched 2026-07-28. **Not scheduled.** Do not start before v1.0 ships (`AURA-R07`).

**Living pictures.** Live Photo → looping/boomerang video is straightforward (PhotoKit +
AVFoundation). Still → 2.5D depth parallax is feasible on-device. True generative animation is
server-scale only and violates the charter.

**Ambient living photo frame.** Settled platform facts:

- **No public API lets a third-party app set wallpaper** (home or lock screen). Hard sandbox
  limit, not a battery trade-off. Lock screen widgets are static WidgetKit snapshots — no video.
- **StandBy** (iOS 17+) needs iPhone locked + charging + landscape, with a red night mode.
  Third parties may contribute *widgets* only; full-screen photo mode is Apple's Photos app.
- **iPad has no StandBy at all** (iPadOS 17/18/26, nothing announced). That gap is the opportunity.
- Workable design: a foreground app using `isIdleTimerDisabled`, `UIDevice.batteryState`,
  orientation detection, and time/ambient night dimming — a docked-iPad ambient photo frame.
  Cap concurrent Live Photo players (~9–12 visible cells, pause on scroll); drift content to
  avoid OLED burn-in. Needs **full** photo-library permission, which is why it cannot live
  inside AuraFit's picker-only privacy posture.

---

## 12. Document change log

| Date | Change |
|---|---|
| 2026-07-28 | Created as an engineering-only phase plan. |
| 2026-07-28 | **CR-004:** expanded to a full program plan — planning method, board schema, CR process, planning-quality metrics, QA/DATA/DES/LEG/OPS/MKT/UA/MON/PM workstreams, milestones, risk register, variance log. |
| 2026-07-28 | Phase 0 engineering executed: 16 tasks closed across 4 parallel agents, 88/88 tests, Release bundle audited. Variance log and planning misses PM-04..PM-07 recorded. |
| 2026-07-28 | Market and tooling research folded in: §6.9 market intelligence, ASO decisions, UA channel ranking, monetization benchmarks. Corrected three planning misses (§10.1); added `AURA-LEG-007/008`, `AURA-R12/R13`; decided §2.4 measurement and `AURA-OPS-003` release automation. |
