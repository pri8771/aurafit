---
id: AURA-QA-005
title: Execute performance, interruption, storage, and thermal smoke
gate: TF-G1
status: blocked_external
ownerBoundary: Human reviewer + iPhone
dependsOn: [AURA-OPS-012A]
evidence: quality/evidence/testflight/AURA-QA-005/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-005 — Performance, interruption, storage, and thermal smoke

## Task description

This task establishes release-stability evidence that functional tests cannot provide: timing, memory, thermal behavior, lifecycle recovery, constrained storage, and crash/hang visibility on physical iPhone hardware. It is necessary to prevent a technically functional build from failing under repeated or interrupted use. Execute the seven reproducible measurements below from the signed `AURA-OPS-012A` Release build and record device, OS, build, fixture, method, expected/actual, metric units, artifact, and defect; the expected change is documented baselines and budgets or a release-blocking finding.

## Preconditions and inputs

- `AURA-OPS-012A` signed Release build and one supported physical iPhone; simulator may only support the safe low-storage preparation, never replace hardware evidence.
- Licensed/synthetic image fixtures and a redacted measurement method (signposts/Instruments or stopwatch).
- Evidence index: `quality/evidence/testflight/AURA-QA-005/README.md`.

## Subtasks

### AURA-QA-005-ST-01 — Measure cold launch and image-to-result time

This measures the two user-visible latency boundaries because subjective “fast” is not a release criterion. On a physical iPhone, cold-launch AuraFit and time launch readiness, then time accepted image to Result using a fixed licensed fixture and signposts/Instruments or a reproducible stopwatch. Expect numeric baselines with method and repetitions; record all samples, not only the best one.

**Execution**

1. Force-quit AuraFit, start the selected measurement tool, launch, and stop at usable initial screen; repeat with documented count.
2. Import/capture the fixed fixture, start timing at accepted image, stop when Result is usable, and retain redacted trace/log path.

**Expected result and evidence:** Reproducible launch/result baselines in seconds with method, samples, and actual outcome.

**Failure handling:** Crash/hang is P0/P1; otherwise record baseline and defer pass threshold to ST-07 rather than inventing one.

### AURA-QA-005-ST-02 — Test seeded 50-session history scrolling

This verifies history scale does not create main-thread stalls or memory spikes. Seed or create 50 sessions using approved synthetic data without altering production data, then scroll History repeatedly on physical hardware while observing responsiveness/memory. Expect smooth usable scrolling and stable memory trend; record seeding method, scroll route, observations, and trace if available.

**Execution**

1. Use `OWNER_REQUIRED_HISTORY_SEED_METHOD` or create 50 licensed/synthetic sessions; record which method was used.
2. Open History, scroll top-to-bottom and back several times, observe stalls and memory with Instruments where available.

**Expected result and evidence:** 50-session history remains responsive with no unexplained memory spike.

**Failure handling:** Main-thread stall or runaway memory is P1; lack of approved seed method is `blocked_external`.

### AURA-QA-005-ST-03 — Test repeated scans and sustained camera session

This verifies camera teardown and resource stability under ordinary repetition. Run five consecutive scans and a five-minute live camera-coach session on physical hardware, recording memory, thermal state, and camera stop behavior. Expect no crash, runaway growth, overheating warning, or permanently active camera; record per-scan outcomes and end state.

**Execution**

1. Complete five scans using approved fixtures, allowing each to finish before the next.
2. Keep camera coach active for five minutes, then exit it; record thermal state and memory before/after where observable.

**Expected result and evidence:** All scans complete and camera session stops cleanly; evidence includes thermal/memory observations.

**Failure handling:** Crash, permanent camera lock, or runaway memory is P0/P1 and blocks archive.

### AURA-QA-005-ST-04 — Test background/foreground active operations

This verifies lifecycle handling during camera, analysis, scorecard render, and reveal render because iOS can interrupt any of them. Start each operation separately, background AuraFit, return, and verify completion, pause, cancellation, or recovery is truthful and leaves no corrupted persistence. Expect no stuck progress or duplicate output; log operation and timing.

**Execution**

1. For camera, analysis, scorecard render, and entitled reveal render, start the operation then background and foreground AuraFit.
2. Inspect resulting screen/history/export state and repeat only if needed for reproducibility.

**Expected result and evidence:** Each operation returns to a coherent recoverable state with no corrupted data.

**Failure handling:** Crash, stuck operation, duplicate output, or corruption is P0/P1.

### AURA-QA-005-ST-05 — Test safely constrained storage

This verifies the app fails honestly when storage is low without risking the owner's personal device. Use an owner-approved disposable device or safe simulator method to create low storage, then perform a bounded import/export/history action and restore space afterward. Expect truthful failure/retry behavior and intact data; record method and pre/post free-space values.

**Execution**

1. Set `OWNER_REQUIRED_SAFE_LOW_STORAGE_METHOD`; do not fill a personal device indiscriminately.
2. Under constrained storage, run a bounded operation, capture actual UI/result, then release test storage and confirm app recovery.

**Expected result and evidence:** No corruption or false success; free-space method and recovery are recorded.

**Failure handling:** No safe method is `blocked_external`; false success/corruption is P1.

### AURA-QA-005-ST-06 — Inspect candidate crash and hang logs

This checks device and Xcode Organizer diagnostics because visible smoke success can conceal termination or hang evidence. After ST-01–05, inspect device analytics and Xcode Organizer for the candidate version/build, record zero findings or redacted identifiers/summaries, and link any defect. Expect no unexplained AuraFit crash/hang; do not commit raw personal diagnostic data.

**Execution**

1. In Xcode → Window → Organizer → Crashes (and the device diagnostic route available), filter by AuraFit version/build.
2. Record timestamp, build, classification, and redacted artifact/reference for every matching report.

**Expected result and evidence:** Candidate crash/hang inspection result is explicitly recorded.

**Failure handling:** A reproducible crash/hang is P0/P1; create bug and block archive.

### AURA-QA-005-ST-07 — Establish owner-approved beta budgets

This turns measurements into release criteria without inventing performance thresholds. Compare ST-01–06 measurements with existing proposed `docs/TEST_PLAN.md` budgets; if they are unrealistic, record baselines and request owner-approved thresholds. Expect documented metrics/budgets with decision source; do not mark performance passed solely because a number exists.

**Execution**

1. Read current relevant proposed budgets in `docs/TEST_PLAN.md` and compare each to collected samples.
2. If a budget is absent/unrealistic, set `OWNER_REQUIRED_PERFORMANCE_BUDGET_APPROVAL` and record proposed baseline/rationale for review.

**Expected result and evidence:** Measured baselines and approved or pending budgets are recorded.

**Failure handling:** Without approved realistic thresholds remain `human_review_required`; P0/P1 findings still block archive.

## Acceptance criteria

- [ ] No crash, hang, runaway memory growth, permanent camera lock, or corrupted persistence.
- [ ] Measured baselines and budgets are documented.
- [ ] P0/P1 findings block the final archive.

## Completion and evidence

Store the redacted metric table, traces/log references, device data, and defect links in `quality/evidence/testflight/AURA-QA-005/README.md`.

## Stop and reverification conditions

Stop for missing signed hardware, unsafe storage method, or P0/P1. New build or changes to camera, analysis, history, rendering, lifecycle, or performance budget invalidate relevant measurements.
