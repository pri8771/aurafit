---
id: AURA-OPS-009
title: Verify account, agreements, roles, banking, and tax
gate: TF-G1
status: done
ownerBoundary: Owner
dependsOn: []
evidence: quality/evidence/testflight/AURA-OPS-009/README.md
lastVerified: 2026-08-18
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-009 — Verify account, agreements, roles, banking, and tax

## Task description

This owner-controlled task removes Apple account blockers before app creation, StoreKit, or upload. We verify membership, legal ownership, agreements, commerce readiness, roles, and recovery access because Apple will reject or prevent downstream work without them. The expected change is a redacted evidence checklist showing every prerequisite active through the beta window; agents must not infer account values or handle banking, tax, or authentication data.

## Preconditions and inputs

- Account Holder access to Apple Developer and App Store Connect for the legal entity.
- Target team identifier `796XH483R4`.
- Planned beta window supplied by the owner.

## Subtasks

### AURA-OPS-009-ST-01 — Verify Developer Program membership

Confirm the Apple Developer Program membership is active through the planned beta window so signing and identifier work will not expire mid-release. In developer.apple.com → Account, an Account Holder records membership status and expiration date only. Expected result: active membership with an expiration after `OWNER_REQUIRED_BETA_WINDOW_END`.

**Execution**

1. Sign in to Apple Developer → Account → Membership.
2. Compare displayed status/expiration to the beta window; record status and date in the evidence index, not screenshots containing personal data.

**Expected result and evidence:** `Active` and expiration date are redacted evidence fields.

**Failure handling:** Expired/expiring membership is `blocked_external`; only the Account Holder renews it.

### AURA-OPS-009-ST-02 — Verify legal entity and team ownership

Confirm the signed-in legal entity owns team `796XH483R4`, preventing work against the wrong developer team. In Apple Developer → Account → Membership/People, compare the Team ID and legal entity to owner-confirmed identity. Expected result: exact team match; record team ID and a yes/no legal-entity match without names or addresses.

**Execution**

1. Navigate to Apple Developer → Account → Membership.
2. Record `796XH483R4` match and `OWNER_REQUIRED_LEGAL_ENTITY_CONFIRMATION` outcome.

**Expected result and evidence:** Team ID and ownership-match result are present.

**Failure handling:** Wrong/unknown entity is `blocked_external`; do not create records in another team.

### AURA-OPS-009-ST-03 — Verify current App Store Connect agreements

Check all current agreements because an unaccepted Apple agreement can block uploads or distribution. An Account Holder opens App Store Connect → Business → Agreements and confirms no agreement requires action. Expected result: latest agreement rows are accepted/active with no action required.

**Execution**

1. Open App Store Connect → Business → Agreements.
2. Record each agreement's title/status only; exclude contract numbers and legal contact details.

**Expected result and evidence:** Redacted agreement-status checklist is complete.

**Failure handling:** Any pending action is `blocked_external`; stop until the Account Holder accepts it.

### AURA-OPS-009-ST-04 — Verify Paid Apps, banking, and tax readiness

Confirm paid-app commerce prerequisites are active because StoreKit sandbox testing requires the Paid Apps Agreement plus banking and tax information. An Account Holder checks App Store Connect → Business → Agreements and related Banking/Tax sections without exposing values. Expected result: Paid Apps Agreement `Active`, banking active, and tax active/complete.

**Execution**

1. Record only `Active`/`Complete` status for Paid Apps Agreement, banking, and tax.
2. Do not copy account numbers, tax IDs, addresses, forms, or screenshots with those fields.

**Expected result and evidence:** Three redacted status fields are present.

**Failure handling:** Any inactive/pending field is `blocked_external`; only authorized owner staff resolve it.

### AURA-OPS-009-ST-05 — Verify required operator roles

Confirm named operating roles can perform the next Apple actions, preventing late handoffs. In App Store Connect → Users and Access, compare roles against: app record—Account Holder/Admin/App Manager; upload—Account Holder/Admin/App Manager/Developer; external TestFlight—Account Holder/Admin/App Manager. Expected result: each role has a qualified operator, recorded by role label rather than person/email.

**Execution**

1. Open App Store Connect → Users and Access.
2. Record one qualified role label for each capability and whether the owner confirms availability.

**Expected result and evidence:** App-record, upload, and external-TestFlight role requirements are all covered.

**Failure handling:** Missing role is `blocked_external`; request owner assignment instead of inviting or impersonating users.

### AURA-OPS-009-ST-06 — Verify two-factor and recovery ownership

Confirm the Account Holder can pass two-factor authentication and has a recovery owner so release access is not dependent on a fragile session. The Account Holder performs a normal sign-in/recovery readiness check without revealing credentials or recovery data. Expected result: both checks are recorded as confirmed.

**Execution**

1. Owner confirms a successful current 2FA login and identifies that a recovery owner exists.
2. Record only `2FA confirmed` and `recovery owner confirmed` with date/time.

**Expected result and evidence:** Two boolean confirmation fields are present.

**Failure handling:** Failed 2FA/no recovery ownership is `blocked_external`; do not request codes or recovery material.

### AURA-OPS-009-ST-07 — Publish the redacted account evidence index

Create a minimal auditable checklist that proves readiness without storing sensitive account information. Expected result: all six checks, operator role, timestamp, blockers, and reverification triggers are documented under the canonical evidence path.

**Execution**

1. Create/update `quality/evidence/testflight/AURA-OPS-009/README.md` with one checkbox per subtask.
2. Include only statuses, dates, team ID, role labels, and owner confirmation; redact/omit personal, banking, tax, recovery, and authentication data.

**Expected result and evidence:** A compact redacted readiness record exists.

**Failure handling:** An unresolved row leaves the task `blocked_external`; do not work around Account Holder-only actions.

## Acceptance criteria

- [ ] Membership is active through planned beta window.
- [ ] Latest agreements have no action required.
- [ ] Paid Apps, banking, and tax are active for StoreKit sandbox.
- [ ] Required operator roles are assigned.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-009/README.md`; screenshots are optional and must be redacted.

## Stop and reverification conditions

Any membership, agreement, banking, tax, role, or recovery issue is `blocked_external`. Reverify after Apple account/legal-entity/role changes or before a beta window beyond the recorded expiration.
