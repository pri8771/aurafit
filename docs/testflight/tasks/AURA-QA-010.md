---
id: AURA-QA-010
title: Execute StoreKit sandbox and TestFlight purchase matrix
gate: TF-G2
status: blocked_external
ownerBoundary: Owner + agent + sandbox account
dependsOn: [AURA-MON-008, AURA-OPS-012A]
evidence: quality/evidence/testflight/AURA-QA-010/README.md
lastVerified: 2026-07-29
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-QA-010 — StoreKit sandbox and TestFlight purchase matrix

## Task description

This task proves production StoreKit entitlements, restore, lifecycle changes, offline behavior, and errors use Apple's sandbox/TestFlight services rather than the local `.storekit` configuration. It is required because the real subscription lifecycle can diverge from Xcode testing. After `AURA-MON-008` catalog readiness and `AURA-OPS-012A` hardware install, perform every scenario below on a physical device, record account type without credentials, build source, product, state transition, expected/actual, artifact, and defect; the expected result is evidence-backed entitlement behavior and truthful recovery UI.

## Preconditions and inputs

- `AURA-MON-008` confirms product/catalog readiness; `AURA-OPS-012A` supplies signed physical-device Release build.
- A dedicated Sandbox Apple Account exists; credentials and receipts never enter Git.
- Xcode StoreKit configuration is disabled for every claimed sandbox/TestFlight result.
- Evidence index: `quality/evidence/testflight/AURA-QA-010/README.md`.

## Subtasks

### AURA-QA-010-ST-01 — Create and protect a dedicated Sandbox Apple Account

This establishes an isolated tester identity so purchase state is reproducible and personal Apple accounts are not exposed. In App Store Connect create `OWNER_REQUIRED_SANDBOX_TEST_ACCOUNT`, assign the needed sandbox role/state, and record only a redacted account label and creation confirmation. Expect a usable dedicated account with credentials stored outside Git.

**Execution**

1. In App Store Connect, navigate Users and Access → Sandbox (or current Apple-equivalent account management path) with an authorized role.
2. Create the dedicated account using owner-controlled secure credentials; record only redacted identifier and account status.

**Expected result and evidence:** Dedicated sandbox account exists and no credential/receipt is committed.

**Failure handling:** Missing role/account capability is `blocked_external`; stop rather than using an owner personal account.

### AURA-QA-010-ST-02 — Prove physical-device sandbox configuration

This prevents local StoreKit fixtures from being mistaken for Apple sandbox evidence. On the physical iPhone build, remove/disable the Xcode StoreKit configuration, verify the active scheme/build source, sign in only when Apple prompts for sandbox purchase, and capture redacted configuration evidence. Expect no `.storekit` file influences the run.

**Execution**

1. In Xcode scheme settings, set StoreKit Configuration to None for the run; build/install the signed Release candidate.
2. Record device, version/build, scheme setting, and sandbox prompt/result without account secrets.

**Expected result and evidence:** Physical-device run has local StoreKit configuration disabled.

**Failure handling:** Any local `.storekit` involvement invalidates this evidence; correct setup and restart matrix.

### AURA-QA-010-ST-03 — Exercise purchase and restore variants

This verifies all requested payment/restore paths behave as configured. Test monthly purchase, yearly purchase, user cancellation, pending/Ask-to-Buy if available, template-only purchase, restore on same install, reinstall plus restore, and restore with no purchase. Expect accurate entitlement/messaging per scenario; record product, initial state, actions, Apple dialog outcome, and final entitlement.

**Execution**

1. Reset or use dedicated eligible sandbox state per scenario; never force unverified state changes.
2. Execute each named flow through the Release paywall, then inspect entitlement/UI after completion, cancellation, or restore.

**Expected result and evidence:** Every listed scenario has expected/actual evidence and truthful recovery messaging.

**Failure handling:** Product mismatch, incorrect entitlement, or broken restore is P1; unavailable Ask-to-Buy is recorded `not_available` with Apple limitation evidence.

### AURA-QA-010-ST-04 — Test offline entitlement and product loading

This verifies a cached active entitlement supports offline launch while unavailable product loading never blocks free use. With a verified active entitlement, enable Airplane Mode and relaunch; separately open product loading offline. Expect cached entitlement behavior as designed and a truthful recoverable product error; record connectivity and entitlement cache state.

**Execution**

1. Verify active entitlement online, enable Airplane Mode, force-quit/relaunch, and inspect gated benefits.
2. Open paywall/product loading offline and attempt no purchase; observe recovery UI.

**Expected result and evidence:** Offline state is truthful, free flow remains usable, and cached entitlement outcome is recorded.

**Failure handling:** Core free use blocked or entitlement misrepresented is P1.

### AURA-QA-010-ST-05 — Exercise sandbox lifecycle and interruption controls

This verifies entitlement updates under renewal, billing retry, expiration, refund/revocation, and interrupted purchase, which are release-critical lifecycle states. Use Apple sandbox controls where available, record actual accelerated TestFlight renewal dates, and execute each state transition without inventing results. Expect StoreKit-driven state updates and clear user messaging.

**Execution**

1. Use authorized Apple sandbox controls to schedule/observe renewal, billing retry, expiration, refund/revocation, and an interrupted purchase.
2. Record Apple-visible event time, app observation time, product, and resulting entitlement/UI for each transition.

**Expected result and evidence:** Each available lifecycle transition has timestamped expected/actual evidence.

**Failure handling:** Unavailable Apple control is `not_available`, not passed; incorrect entitlement update is P1.

### AURA-QA-010-ST-06 — Verify Pro benefit unlocks

This checks purchased Pro is connected to every advertised benefit rather than merely changing a badge. With verified monthly/yearly entitlement, test unlimited scans beyond the free quota, watermark removal, and reveal/templates access. Expect all and only Pro benefits to unlock; record product, before/after UI, and quota count.

**Execution**

1. Establish active monthly or yearly entitlement from ST-03.
2. Exercise each named benefit and compare to free state using licensed fixtures.

**Expected result and evidence:** Active Pro unlocks unlimited scans, no watermarks, reveal, and templates.

**Failure handling:** Missing or over-broad benefit is P1; create defect.

### AURA-QA-010-ST-07 — Verify template-only isolation and restore messaging

This verifies non-consumable templates do not accidentally become a Pro subscription and restore instructions remain correct. Purchase the Streetwear or Soft Luxury template only, verify available template content, verify Pro remains locked, then use Restore and inspect messaging. Expect template-only entitlement without Pro and truthful restore feedback.

**Execution**

1. Use a sandbox state with no Pro entitlement and purchase one template product.
2. Inspect templates/Pro gates, invoke Restore, and record observed messages and final entitlements.

**Expected result and evidence:** Template purchase unlocks only its template and Restore is accurate.

**Failure handling:** Template granting Pro or misleading restore is P1.

### AURA-QA-010-ST-08 — Verify expiration/revocation removes Pro

This confirms revoked or expired subscriptions do not leave premium access indefinitely. After ST-05 produces a verified expiration or revocation, foreground/relaunch as appropriate and wait for StoreKit updates. Expect Pro benefits to disappear while retained non-Pro/template state remains correct; record Apple event and app observation.

**Execution**

1. Trigger/observe expiration or refund/revocation using Apple sandbox controls.
2. Refresh app lifecycle and inspect entitlement, paywall, quota, watermark, reveal, and templates.

**Expected result and evidence:** Pro is removed after verified StoreKit update; exact observation time is logged.

**Failure handling:** Persistent Pro after verified update is P1; unavailable transition remains pending, never passed.

### AURA-QA-010-ST-09 — Repeat StoreKit smoke in processed TestFlight

This proves the same critical purchase behavior survives Apple's processed distribution build, which local signing cannot establish. After `AURA-QA-006` makes the processed build available, install via TestFlight on physical iPhone and repeat product loading, one purchase/restore, Pro benefit, and failure messaging checks. Expect TestFlight sandbox and real catalog behavior; record TestFlight version/build and outcome.

**Execution**

1. Wait for `AURA-QA-006` processed-build install evidence; delete development build and install through TestFlight.
2. Run the listed short StoreKit smoke with local `.storekit` disabled and log all actual results.

**Expected result and evidence:** Processed TestFlight build demonstrates real catalog and sandbox behavior.

**Failure handling:** Until `AURA-QA-006` is complete, this row is `blocked_external`; failures are P1.

## Acceptance criteria

- [ ] Every matrix scenario has expected/actual evidence.
- [ ] No local `.storekit` file is involved.
- [ ] Entitlements survive relaunch/restoration and disappear on verified revocation/expiration.
- [ ] Product/load failures produce truthful recoverable UI.

## Completion and evidence

Store redacted scenario evidence in `quality/evidence/testflight/AURA-QA-010/README.md`; never commit sandbox credentials, receipts, or personal account data.

## Stop and reverification conditions

Stop if catalog/account/physical build is unavailable or any P1 appears. New product IDs, entitlement logic, paywall changes, build changes, or Apple state transition changes invalidate affected rows.
