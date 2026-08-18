# AURA-MON-008 evidence

- Status: `not_applicable` — closed by DEC-006 (2026-08-18): AuraFit 1.0 has no in-app
  purchases, so this task has no work product. Content below is retained for history.

- Status: `blocked_external` — the repository-side catalog preflight is complete, but the
  owner-controlled commercial policy, Apple account/app record, App Store Connect catalog,
  propagation, sandbox, and TestFlight observations have no evidence.
- Commit SHA: `OWNER_REQUIRED_COMMIT_SHA_AT_CATALOG_REVIEW`
- Version/build: `OWNER_REQUIRED_SIGNED_RELEASE_VERSION_AND_BUILD`
- Date/time and time zone: 2026-07-29, America/New_York (static preflight)
- Operator/reviewer role: repository agent; Apple catalog operator/owner is still required.
- Environment/device: source/configuration audit only. No App Store Connect mutation, signed
  hardware install, sandbox account, or processed TestFlight build was used.

## Static catalog contract

| Product ID | Required Apple type | Source-backed delivered entitlement | Local StoreKit fixture |
|---|---|---|---|
| `com.aurafit.pro.monthly` | auto-renewable subscription, one month | Pro: unlimited scans, no watermark, reveal clips, all scorecard styles | `RecurringSubscription`, `P1M` |
| `com.aurafit.pro.yearly` | auto-renewable subscription, one year | Pro: unlimited scans, no watermark, reveal clips, all scorecard styles | `RecurringSubscription`, `P1Y` |
| `com.aurafit.template.streetwear` | non-consumable | Streetwear scorecard style only when the user is not Pro | `NonConsumable` |
| `com.aurafit.template.softluxury` | non-consumable | Soft Luxury scorecard style only when the user is not Pro | `NonConsumable` |

`AuraFit/Resources/AuraFit.storekit` is a development fixture, not production catalog evidence.
Its prices, storefront, localizations, disabled Family Sharing, and empty offer configuration
must not be copied into App Store Connect without `AURA-MON-002` owner approval. It is excluded
from the Release bundle; any signed-device or TestFlight check must run with the Xcode StoreKit
configuration disabled.

## Subtask evidence

- [ ] `AURA-MON-008-ST-01` — Blocked external. The owner must create exactly one subscription
  group in App Store Connect after `OWNER_REQUIRED_SUBSCRIPTION_GROUP_REFERENCE_NAME` and
  localized display values are approved. The local fixture's `AuraFit Pro` group name is not
  owner approval.
- [ ] `AURA-MON-008-ST-02` — Blocked external. Static preflight confirms the four IDs and their
  intended type/period above; it cannot prove that immutable production records exist or are
  unique in App Store Connect.
- [ ] `AURA-MON-008-ST-03` — Blocked external. The owner must supply approved localization,
  price, availability, tax category, review notes, and rights-cleared review asset for every
  record. Fixture display prices/descriptions are test-only and not approved production values.
- [ ] `AURA-MON-008-ST-04` — Blocked external. The subscription rank and Apple transition
  semantics require the owner-approved commercial decision and the App Store Connect ranking UI.
- [ ] `AURA-MON-008-ST-05` — Blocked external/human review required. `AURA-MON-002` has not
  recorded `OWNER_REQUIRED_INTRO_OFFER_POLICY`, `OWNER_REQUIRED_FAMILY_SHARING_POLICY`, or
  `OWNER_REQUIRED_LAUNCH_DISCOUNT_POLICY`. Fixture values remain non-authoritative defaults.
- [x] `AURA-MON-008-ST-06` — Static reconciliation passed. `ProductCatalog.allProductIDs` is
  the sole StoreKit request list; `StoreKitService` orders those IDs, `PaywallView` filters the
  same catalog sets and displays StoreKit-provided name/description/price, and
  `EntitlementManager`/`FitResultView` deliver the mapped Pro and template benefits above.
  Signed-Release product loading remains unverified.
- [ ] `AURA-MON-008-ST-07` — Blocked external. No production save time or current Apple
  propagation guidance has been recorded; no production product-load observation exists.
- [ ] `AURA-MON-008-ST-08` — Blocked external. No App Store Connect product status or sandbox
  visibility has been observed. Do not infer approval from the local fixture or passing tests.
- [x] `AURA-MON-008-ST-09` — Static architecture audit passed. The project context prohibits a
  backend; production constructs `StoreKitService`, derives ownership only from verified
  StoreKit transactions/current entitlements, and the source audit found no server-notification
  endpoint, server secret, or third-party purchase backend. Debug mock/force-Pro paths are
  conditionally compiled and the Release configuration test asserts the local fixture is absent
  from the app bundle.

## Acceptance criteria

- [ ] All shipping product IDs resolve in sandbox/TestFlight with localized price and duration.
- [ ] Product type, subscription group, duration, price, availability, tax, and UI copy agree.
- [x] No source-defined IAP is invisible or unimplemented: all four requested IDs map to a
  StoreKit fixture type and a code-delivered benefit. Production catalog visibility remains
  unverified.

## Commands and results

Run from `/Users/pchordia/Documents/other/ios_apps/aurafit`:

1. `ruby -rjson -e 'JSON.parse(File.read("AuraFit/Resources/AuraFit.storekit"))'` — expected
   exit `0`; validates the JSON fixture syntax only. `plutil -lint` is not applicable because
   `.storekit` is JSON and returned `Unexpected character { at line 1` during this audit.
2. `xcodebuild test -project AuraFit.xcodeproj -scheme AuraFit -configuration Debug -destination 'platform=iOS Simulator,name=iPhone Air,OS=26.4.1' -derivedDataPath /tmp/AuraFit-MON-008-DerivedData CODE_SIGNING_ALLOWED=NO -only-testing:AuraFitTests/EntitlementManagerTests -only-testing:AuraFitTests/ReleaseConfigurationTests` — expected exit `0`; validates deterministic entitlement mapping and Release-bundle exclusion checks. Raw results belong in `/tmp`, not Git.

Static inspection also covered `ProductCatalog`, `StoreKitService`, `EntitlementManager`,
`PaywallView`, `FitResultView`, `ScorecardModel`, `AppEnvironment`, the shared scheme,
`FEAT-004`, `.factory/project-context.json`, and `AuraFit.storekit`.

### Command outcomes — 2026-07-29

- The Ruby JSON parse completed with exit `0`.
- The targeted simulator test command did not reach test execution: CoreSimulatorService became
  unavailable (`connection refused` / unavailable simulator runtimes). This is an environment
  failure, not a passing or failing entitlement result; rerun the unchanged command when the
  simulator service is healthy. The repository's prior 98-test evidence is not substituted for
  this task's failed targeted run.

## Blockers and owner requests

1. Complete `AURA-OPS-009`, `AURA-OPS-010`, and owner approval `AURA-MON-002`.
2. Provide approved group reference/localizations, product metadata, prices, territories, tax
   category, ranking, Family Sharing, offers, and review assets.
3. Use App Store Connect to create/inspect the exact four immutable records, then record only
   redacted statuses and opaque identifiers here.
4. Record current Apple propagation guidance and execute `AURA-QA-010` with local StoreKit
   configuration disabled on signed hardware and the processed TestFlight build.

## Reverification trigger

Reopen this audit after any product ID/type/period, entitlement benefit, paywall claim, local
fixture, commercial policy, catalog metadata/availability, StoreKit architecture, or Release
scheme/configuration change. Any production catalog edit also requires fresh propagation and
sandbox/TestFlight evidence.
