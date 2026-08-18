# AURA-OPS-009 evidence — account readiness runbook

- **2026-08-18 update:** the owner's account session uploaded build `1.0 (3)` and submitted version
  1.0 for App Review via the App Store Connect web UI, which is functional proof that membership,
  agreements, and role were sufficient for a free app on that date. Record:
  `quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md`.

- Status: `blocked_external`; Account Holder evidence has not been supplied.
- Operator: Account Holder only for Apple actions; agents record redacted statuses only.
- Required input: `OWNER_REQUIRED_BETA_WINDOW_END`; target team: `796XH483R4`.
- Never record names, email addresses, account numbers, tax IDs, recovery details, 2FA codes, or screenshots containing them.

## Subtask checklist

- [ ] `AURA-OPS-009-ST-01` — In developer.apple.com → Account → Membership, Account Holder records only `membership_status: Active|other` and `expiration_date: YYYY-MM-DD`; compare expiration strictly after `OWNER_REQUIRED_BETA_WINDOW_END`. Expected: Active through the window. Any other result: `blocked_external`, request renewal.
- [ ] `AURA-OPS-009-ST-02` — On the same Membership page, compare displayed Team ID to `796XH483R4` and obtain `OWNER_REQUIRED_LEGAL_ENTITY_CONFIRMATION: yes|no`. Record team ID and yes/no only. Expected: both match. Wrong/unknown entity: stop; do not use another team.
- [ ] `AURA-OPS-009-ST-03` — App Store Connect → Business → Agreements: record each agreement title and `Active|action_required` only. Expected: no action-required row. Pending agreement: Account Holder accepts it; task remains blocked.
- [ ] `AURA-OPS-009-ST-04` — In Business → Agreements and Banking/Tax, record three status-only fields: Paid Apps Agreement, banking, tax. Expected: `Active`, `Active`, `Complete`. Any other value: `blocked_external`; never copy underlying values.
- [ ] `AURA-OPS-009-ST-05` — App Store Connect → Users and Access: record a qualified role label (not a person) for app record (`Account Holder|Admin|App Manager`), upload (`Account Holder|Admin|App Manager|Developer`), and external TestFlight (`Account Holder|Admin|App Manager`). Missing role: request owner assignment; do not impersonate/invite.
- [ ] `AURA-OPS-009-ST-06` — Account Holder confirms a current successful 2FA login and that a recovery owner exists. Record two booleans and timestamp only. Failed/no recovery: `blocked_external`; never request codes/material.
- [ ] `AURA-OPS-009-ST-07` — Populate the fields below, retain only this redacted index, and leave every unresolved row unchecked.

## Evidence fields to fill after owner execution

```text
timestamp/timezone:
beta_window_end:
membership_status / expiration_date:
team_id_match / legal_entity_match:
agreements (title: status):
paid_apps / banking / tax:
qualified_roles (app_record, upload, external_testflight):
2fa_confirmed / recovery_owner_confirmed:
blocker and owner request:
```

Acceptance is unmet until membership, agreements, commerce, and roles are all evidenced. Reverify before a beta window beyond the recorded expiration or after membership, legal entity, agreement, role, banking, tax, or recovery changes.
