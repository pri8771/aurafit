# Release candidate `1.0 (3)` — one full, free product (DEC-006) — 2026-08-18

- Status: `verification_pending` — repository gate passed, signed archive and App Store-method
  IPA produced and verified locally. ~~**Not uploaded to App Store Connect.**~~ **2026-08-18
  update:** the same archive was uploaded (`Upload succeeded` 13:34:57 local), processed by
  Apple, attached to version 1.0 with the listing entered, and **submitted for App Review at
  ~13:41 local ("Waiting for Review")** — see `SUBMISSION-2026-08-18.md` in this directory.
  Device QA was consciously waived by the owner for this submission (DEC-007), not run.
- Decision implemented: `docs/DECISIONS.md` DEC-006 (2026-08-18).
- Source: branch `release/1.0-3-full-free`, based on `claude/phase0-production-readiness @
  fada834`; the commit SHA of the change itself is recorded in the branch log (this file is
  committed in that same commit).
- Version/build: `MARKETING_VERSION 1.0`, `CURRENT_PROJECT_VERSION 3` (both configurations;
  builds 1 and 2 are consumed in App Store Connect).
- Date/time and time zone: 2026-08-18 12:50–13:05 America/New_York.
- Operator role: implementation agent on the owner's Mac; no physical-device claim.
- Environment: macOS 26.5.2, Xcode 26.6 (17F113), simulator iPhone 17 Pro
  `C55B344B-4C1B-44E5-9580-50126FB71088` on iOS 26.4.1, App Factory rules checkout
  `/Users/pchordia/Documents/other/studio_ops/iOS_app_factory_rules @ 89ce224` (standard 0.4.0).

## What was removed

| Removed | Was |
|---|---|
| `AuraFit/Features/Paywall/PaywallView.swift` | StoreKit 2 upsell/purchase/restore screen |
| `AuraFit/Services/Store/{StoreKitService,EntitlementManager,ProductCatalog,MockPurchaseProvider}.swift` | Product loading, purchase, restore, entitlement derivation, free-scan quota, mock |
| `AuraFit/Resources/AuraFit.storekit` + scheme `StoreKitConfigurationFileReference` + pbxproj membership exception | Local StoreKit test configuration |
| `PaywallContext` (`AppRouter`), `EntitlementTier` (`Enums`), `AppLog.store` | Paywall routing, tier enum, store log category |
| `AppSettings.scanCountToday/scanCountDayStart/rolloverIfNeeded()`, `Date.isSameDay` | Daily free-scan accounting |
| `ScorecardModel.includeWatermark`, `ScorecardTheme.requiredProductID/paywallPersona`, `FitSession.scorecardIncludesWatermark`, `SessionRepository.attachScorecard(includesWatermark:)` | Free-tier watermark and template locks |
| Settings "Membership" section (Upgrade to Pro / Manage Subscription / Restore Purchases / free-plan footer), Scan quota banner and `ensureCanScan`, Home "N free scans left" subtitle, Result "Pro unlocks all", lock icons, "Reveal Clip · Pro" | Tier UI and copy |
| Privacy manifest comment references to StoreKit; in-app policy "Purchases"/"Manage Subscription" text | Purchase language |
| `AuraFitTests/EntitlementManagerTests.swift` (11 tests), `ModelTests.testRolloverResetsCountOnNewDay` | Tests of deleted code |

Added: `AuraFitTests/FullFreeProductTests.swift` (5 tests), `audit_no_tier_source` and the
StoreKit-link/tier-string bundle audit in `scripts/release_candidate_check.sh`,
`docs/release/APP_STORE_LISTING.md`.

## Tests

- Full suite (`xcodebuild test`, scheme `AuraFit`, Debug, iPhone 17 Pro / iOS 26.4.1):
  **94 total / 94 passed / 0 failed / 0 skipped** — 93 unit/integration + 1 UI smoke.
  Result bundle: `/tmp/aurafit-release-candidate-1.0-3/AuraFit-tests.xcresult`
  (`test-summary.json`: `totalTestCount 94, passedTests 94, failedTests 0, skippedTests 0`).
- Previous count 101 → 94: −11 (`EntitlementManagerTests`), −1 (rollover), +5
  (`FullFreeProductTests`).

## Release-candidate gate

`AURAFIT_RULES_PATH=… AURAFIT_SIMULATOR_DESTINATION='id=C55B344B-…' AURAFIT_DERIVED_DATA_PATH=/tmp/aurafit-release-candidate-1.0-3 bash scripts/release_candidate_check.sh`

```
APP_FACTORY=PASS
GOVERNED_JSON=PASS count=16
PRIVACY_MANIFEST=PASS path=…/AuraFit/Resources/PrivacyInfo.xcprivacy required_reason=C617.1
NO_TIER_SOURCE=PASS
TESTS=PASS total=94 passed=94 failed=0 skipped=0
SOURCE_WARNINGS=PASS count=0
INFRASTRUCTURE_WARNINGS: appintentsmetadataprocessor "Metadata extraction skipped. No AppIntents.framework dependency found." (Xcode 26 toolchain notice, classified as infrastructure in this change)
BUNDLE_CHECK=PASS CFBundleIdentifier=com.pchordia.aurafit / CFBundleShortVersionString=1.0 / CFBundleVersion=3 / MinimumOSVersion=18.0 / LSApplicationCategoryType=public.app-category.lifestyle / camera + photos-add usage strings / ITSAppUsesNonExemptEncryption=false
BUNDLE_EXCLUSIONS=PASS no_storekit_link=1 no_tier_strings=1
RELEASE_CANDIDATE_GATE=PASS
```

Logs: `/tmp/aurafit-release-candidate-1.0-3/{app-factory-verifier.log,release-candidate-test.log,release-candidate-build.log,test-summary.json}`.
A first invocation stopped at `verification_pending` on the unclassified AppIntents toolchain
warning; the classifier was extended (`scripts/release_candidate_check.sh`) and the gate was
re-run from an empty derived-data directory to the PASS above. ShellCheck: clean.

## Signed archive and local export (uploaded later the same day — see `SUBMISSION-2026-08-18.md`)

```
xcodebuild archive -project AuraFit.xcodeproj -scheme AuraFit -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath /private/tmp/AuraFit-1.0-3-export/AuraFit-1.0-3.xcarchive \
  -derivedDataPath /private/tmp/AuraFit-1.0-3-export/dd-archive \
  -allowProvisioningUpdates CODE_SIGN_STYLE=Automatic DEVELOPMENT_TEAM=796XH483R4
→ ** ARCHIVE SUCCEEDED **

xcodebuild -exportArchive -archivePath /private/tmp/AuraFit-1.0-3-export/AuraFit-1.0-3.xcarchive \
  -exportOptionsPlist /private/tmp/AuraFit-1.0-3-export/ExportOptions.plist \
  -exportPath /private/tmp/AuraFit-1.0-3-export/ipa -allowProvisioningUpdates
→ ** EXPORT SUCCEEDED **
```

`ExportOptions.plist`: `method app-store-connect`, `destination export`, `signingStyle
automatic`, `teamID 796XH483R4`, `uploadSymbols true`, `manageAppVersionAndBuildNumber false`.

| Artifact | Path | SHA-256 | Size |
|---|---|---|---|
| IPA | `/private/tmp/AuraFit-1.0-3-export/ipa/AuraFit.ipa` | `d5300abd3b31a1b1d11692d0d55b072a28736625d052efef8445fbf02e606664` | 1,433,722 bytes |
| IPA main executable | `Payload/AuraFit.app/AuraFit` (inside the IPA) | `a28d3877557239641e2126e79c9493983fbe3f17db1b15b7e03dcb47e94282c8` | — |
| Archive | `/private/tmp/AuraFit-1.0-3-export/AuraFit-1.0-3.xcarchive` (`Products/Applications/AuraFit.app`, `dSYMs/AuraFit.app.dSYM`) | executable `9af6d19f3f95b4d9e8cb9c5d883dade796feca61396b80793a0710ee100f58db` | — |

Logs: `/private/tmp/AuraFit-1.0-3-export/{archive.log,export.log,ipa/DistributionSummary.plist,ipa/Packaging.log}`.

### IPA verification (unzipped to `/private/tmp/AuraFit-1.0-3-export/ipa-inspect`)

- `Info.plist`: `CFBundleIdentifier=com.pchordia.aurafit`, `CFBundleShortVersionString=1.0`,
  `CFBundleVersion=3`, `ITSAppUsesNonExemptEncryption=false`, `MinimumOSVersion=18.0`,
  `LSApplicationCategoryType=public.app-category.lifestyle`.
- No `.storekit`, `.mlmodelc`, or `.xctest` inside the bundle (find count 0).
- `otool -L Payload/AuraFit.app/AuraFit`: no StoreKit link (0 matches).
- `strings` over the executable: 0 matches for `paywall|StoreKitService|EntitlementManager|
  ProductCatalog|PurchaseProviding|com.aurafit.pro|com.aurafit.template|freeDailyScanLimit|
  AuraFit Pro|Upgrade to Pro|Restore Purchases|Go Pro|MockPurchaseProvider|UITestVisionStub`
  and 0 matches for `subscription|purchase|entitlement|paywall|premium|quota|watermark`.
- `PrivacyInfo.xcprivacy` in bundle: `NSPrivacyTracking=false`, empty tracking domains, empty
  collected data types, `NSPrivacyAccessedAPICategoryFileTimestamp` / `C617.1`.
- `codesign -dv`: `Identifier=com.pchordia.aurafit`, `TeamIdentifier=796XH483R4`, authority
  `Apple Distribution: Priyansh Chordia (796XH483R4)`; entitlements contain only
  `application-identifier`, `beta-reports-active`, `com.apple.developer.team-identifier`,
  `get-task-allow=false` — no `com.apple.developer.in-app-payments` or other capability.
- Archive `Info.plist` `ApplicationProperties`: `CFBundleVersion 3`, `Team 796XH483R4`,
  arm64; the archive itself was signed with the development identity and re-signed for
  distribution during export, as expected for automatic signing.

## Not evidenced by this record

- Upload to App Store Connect, Apple processing, TestFlight availability (`AURA-OPS-013`).
- Physical-device install/launch/QA (`AURA-OPS-012A` on-device half, `AURA-QA-002/004/005`).
- App Store Connect metadata, App Privacy, age rating, and export-compliance entry
  (`docs/release/APP_STORE_LISTING.md` supplies the answers and their evidence).
- Owner line-by-line approval of the hosted privacy/support pages (`AURA-MKT-004`); the hosted
  copies must be regenerated from the updated `docs/PRIVACY_POLICY.md` /
  `docs/release/SUPPORT_PAGE.md` before external distribution.

## Reverification trigger

Any change to the app target, project, scheme, privacy manifest, tests, or the gate script
invalidates this record; re-run the gate and re-archive with `CURRENT_PROJECT_VERSION` ≥ 4.
