# AURA-OPS-010 evidence — Apple identity runbook

- **2026-08-18 update:** build `1.0 (3)` (`com.pchordia.aurafit`) processed and was attached to
  version 1.0 of the App Store Connect record, and the version was submitted for App Review.
  Record: `quality/evidence/release/1.0-3-full-free/SUBMISSION-2026-08-18.md`.

- Status: `blocked_external`; depends on completed OPS-009 and authorized Apple access.
- Fixed repository facts for comparison: team `796XH483R4`; name `AuraFit`; bundle ID `com.pchordia.aurafit`; iOS; Release min OS `18.0`; iPhone family `1`; category intent `public.app-category.lifestyle`.
- Creation inputs that must be supplied, never guessed: `OWNER_REQUIRED_PRIMARY_LANGUAGE`, `OWNER_REQUIRED_SKU`, `OWNER_REQUIRED_USER_ACCESS`.

## Subtask checklist

- [ ] `AURA-OPS-010-ST-01` — Apple Developer → Certificates, Identifiers & Profiles → Identifiers: select team `796XH483R4`, search exact `com.pchordia.aurafit`, and record count/type/status. Expected: exactly one explicit ID. If zero, register only after authorization with description AuraFit and exact ID; if foreign/ambiguous, stop—never suffix the ID.
- [ ] `AURA-OPS-010-ST-02` — Open that ID → Capabilities. Record capability names and `In-App Purchase: enabled`; do not enable or remove any capability. Any additional/unexpected capability is `human_review_required`.
- [ ] `AURA-OPS-010-ST-03` — App Store Connect → Apps: search `AuraFit`, `AuraFit AI`, and exact bundle ID. Expected: exactly one iOS record tied to exact ID. Create only when no exact record exists and all three owner-required creation inputs are supplied; use Name AuraFit/Platform iOS/exact ID.
- [ ] `AURA-OPS-010-ST-04` — Apps → AuraFit → App Information: record Name, Bundle ID, Primary Language, SKU, User Access; compare to approved inputs. Wrong immutable value: stop as `human_review_required`.
- [ ] `AURA-OPS-010-ST-05` — Repeat Developer/ASC searches for `AuraFit AI` and any exact IDs. Record non-sensitive name/ID/status and owner-approved disposition. Do not delete, transfer, rename, or reuse any duplicate.
- [ ] `AURA-OPS-010-ST-06` — Record Apple ID, SKU, language, bundle ID, team, access mode, timestamp, and operator role below; exclude people/emails.
- [ ] `AURA-OPS-010-ST-07` — From repository root run `xcodebuild -showBuildSettings -project AuraFit.xcodeproj -scheme AuraFit -configuration Release > /tmp/AURA-OPS-010-build-settings.txt`. Require exit 0; compare PRODUCT_BUNDLE_IDENTIFIER, DEVELOPMENT_TEAM, display name, deployment target, and device family to Apple evidence. Mismatch: source failure or owner review; no signing/archive.

```text
Apple ID / App ID reference:
explicit-ID count and type:
IAP capability / all capability names:
App Store record search results and duplicate disposition:
primary language / SKU / access mode:
Release settings artifact and compared values:
blocker and owner request:
```

Acceptance remains blocked until one correct identifier/record exists, all immutable fields are evidenced, and no capability/duplicate conflict remains. Reverify after App ID, entitlement, app record, or Release-setting changes.
