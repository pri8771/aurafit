# Project Status

## Lifecycle status

`mvp_development`

## Release status

`human_review_required` — the repository and simulator release candidate are
code-complete for the audited scope, and all 26 TestFlight tasks now have executable evidence
packs, but AuraFit has not passed `TF-G1` and is not yet ready to upload. The canonical backlog
is `TESTFLIGHT_READINESS.md`; Jira and Notion are mirrors only.

## Verified on 2026-07-29

- App Factory registration passes the canonical `iOS_app_factory_rules` 0.4.0 verifier.
- The Release configuration builds warning-free for generic iOS device and Simulator
  destinations with code signing disabled.
- The Release bundle contains the privacy manifest and required-reason declaration,
  contains no StoreKit test configuration or unlicensed model assets, and exposes no
  DEBUG-only test switches.
- The updated suite passes 101/101 on an iPhone Air simulator running iOS 26.4.1:
  100 unit/integration tests plus the deterministic import-to-result UI smoke.
- Camera and add-only Photos usage descriptions match the implemented permission paths.
- Shipping copy and the privacy policy accurately describe the deterministic,
  on-device heuristic instead of claiming an absent learned image model.
- The TestFlight backlog validates as 26 canonical task plans and 179 stable subtasks; all 26
  tasks have repository evidence/runbook packs under `quality/evidence/testflight/`.
- The release-candidate gate, CI integration, controlled negative check, ShellCheck validation,
  reviewer drafts, support-page source, compliance preflights, and StoreKit preflight are
  implemented.
- A fresh unsigned generic-device Release build passed. The current full simulator verification
  passes 101/101 in one result bundle, including the bad-photo scoring regressions.

## Verification pending

- Signed device archive and installation with the distribution identity/provisioning profile.
- Physical-device camera, import, export/share, relaunch, deletion, interruption,
  low-storage, permission deny/revoke, and supported-device checks.
- StoreKit sandbox purchase, restore, offline entitlement, prices, and App Store Connect
  product-ID validation.
- VoiceOver, Dynamic Type, layout, dark appearance, and performance/thermal review.
- Hosted public support and privacy-policy URLs plus App Store Connect privacy,
  age-rating, test-information, and export-compliance metadata.
- TestFlight internal smoke and any required external Beta App Review.
- One clean 101/101 invocation of the shared release-candidate gate using the canonical App
  Factory rules checkout; the split result above is useful diagnosis but is not a gate pass.
- GitHub Actions verification on the frozen candidate and main; local GitHub authentication is
  currently invalid.

## Blockers

- Apple membership, agreements, roles, App ID/app record, build history, and signed candidate
  evidence have not been supplied.
- The physical-device and StoreKit sandbox matrices have not been executed.
- The repository does not prove that public support/privacy URLs and App Store metadata
  are configured and reachable.
- Owner choices are still required for pricing/offers, EULA, support contact/URLs, asset rights,
  age rating, export compliance, reviewer contacts/test image, and Jira/Notion targets.

## Next action

Owner: execute `AURA-OPS-009` and `AURA-OPS-010` using their evidence packs, then freeze
`AURA-OPS-011`. In parallel, restore GitHub access for `AURA-OPS-001`, supply the canonical
rules checkout for the clean `AURA-OPS-005` gate run, and provide the owner-required values
listed above. Then install the signed Release build (`AURA-OPS-012A`) and run the prepared
device/accessibility/performance/StoreKit matrices.

## Gate snapshot

| Gate | Status | Blocking task families |
|---|---|---|
| `TF-G1` upload eligible | `blocked_external` | OPS-009/010/011/012A/012B/013, device QA, export compliance |
| `TF-G2` internal beta | `blocked_external` | StoreKit catalog/testing and internal TestFlight smoke |
| `TF-G3` external beta | `blocked_external` | Public URLs, privacy/legal metadata, beta packet, Beta App Review |
