# TestFlight Readiness Evidence — 2026-07-29

## Scope

Audit AuraFit against the canonical `pri8771/iOS_app_factory_rules` repository and
Apple TestFlight submission prerequisites. This evidence supports `FEAT-005`.

## Environment

- macOS 26.5.2
- Xcode 26.6 / iOS Simulator SDK 26.5
- Simulator: iPhone Air, iOS 26.4.1
- App identifier: `com.pchordia.aurafit`
- Release version/build: 1.0 (1)

## Passed checks

1. App Factory registration:
   `/tmp/ios_app_factory_rules_audit/scripts/verify-project-registration.sh`
   reported AuraFit registered as an existing project on standard 0.4.0 with
   repository-map 1.0.0 and library-catalog 0.1.0.
2. Debug automated suite:
   `xcodebuild test` passed all 98 tests: 97 unit/integration checks plus the UI
   smoke below, with zero failures or skips.
3. UI smoke:
   clean in-memory launch, onboarding, Scan, camera primer, system Photos import,
   deterministic on-device analysis, persistence, and Fit Score result passed.
4. Release build:
   `xcodebuild build -configuration Release` succeeded for both
   `generic/platform=iOS` and `generic/platform=iOS Simulator` with
   `CODE_SIGNING_ALLOWED=NO`, using fresh derived-data directories without app
   compiler warnings.
5. Release bundle inspection:
   `PrivacyInfo.xcprivacy` is present and declares
   `NSPrivacyAccessedAPICategoryFileTimestamp` with reason `C617.1`;
   collection/tracking arrays are empty; generated `Info.plist` includes camera and
   add-only Photos descriptions, omits broad Photos-library read access, and sets
   `ITSAppUsesNonExemptEncryption=false`.
6. Release exclusions:
   no `.storekit`, MobileCLIP/learned-model asset, `MockPurchaseProvider`,
   `UITestInMemoryStore`, `UITestStubVision`, or `forceProForTesting` was found.
7. App Factory UI manifests:
   `screens.yaml` and `journeys.yaml` generated Maestro flows successfully with
   `MAESTRO_APP_ID=com.pchordia.aurafit`.

## Local artifact locations

- Unit/UI result bundle:
  `/tmp/AuraFit-CodexAudit-Verified/Logs/Test/Test-AuraFit-2026.07.29_13-00-37--0400.xcresult`
- Release simulator app:
  `/tmp/AuraFit-CodexAudit-WarningScan/Build/Products/Release-iphonesimulator/AuraFit.app`
- Unsigned generic-device build:
  `/tmp/AuraFit-CodexAudit-DeviceRelease/Build/Products/Release-iphoneos/AuraFit.app`
- Generated Maestro flows:
  `/tmp/AuraFit-Maestro-Generated`

These are ephemeral local paths; CI should retain equivalent `.xcresult`, archive,
bundle-audit output, screenshots, and device evidence for a real release.

## Checks not run

- Signed generic-device archive, Organizer validation, notarized upload, or App Store
  Connect processing.
- Physical camera/import/export/share/relaunch/delete/permission/device matrix.
- StoreKit sandbox purchase, restore, offline, refund/revoke, price, and product-ID checks.
- VoiceOver, Dynamic Type, supported layouts, performance, memory, and thermal checks.
- Maestro CLI execution (manifest generation only).
- Public logged-out privacy-policy/support URL check and App Store Connect metadata review.
- Internal TestFlight install/smoke and external Beta App Review.

## Determination

App Factory conformance: **passed for repository registration and required artifacts**.

TestFlight readiness: **human review required**. Code/build evidence is green for the
audited simulator scope, but the signed-device, App Store Connect, StoreKit, accessibility,
and beta-distribution gates above prevent an honest `done` or `verified` release status.

## Apple prerequisite research

Researched against Apple’s official documentation on 2026-07-29. These sources establish
the task gates in `docs/TESTFLIGHT_READINESS.md`; they do not prove AuraFit’s external
account state.

| Requirement used in the plan | Official source |
|---|---|
| Create the App Store Connect app record before upload; required fields include name, primary language, bundle ID, and SKU; the latest agreement must be signed. | [Add a new app](https://developer.apple.com/help/app-store-connect/create-an-app-record/add-a-new-app/) |
| Account Holder, Admin, App Manager, or Developer can upload; bundle ID/version associate the build; build string must be unique; processing must complete. | [Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/) |
| TestFlight builds are testable for up to 90 days; limits are 100 internal and 10,000 external testers. | [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/) |
| Internal groups require tester access and a What to Test description; builds must be selected for testing. | [Add internal testers](https://developer.apple.com/help/app-store-connect/test-a-beta-version/add-internal-testers/) |
| External testing requires an internal group first; the first build receives full TestFlight App Review; internal-only builds cannot be external. | [Invite external testers](https://developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers) |
| External test information includes a beta description and feedback email; review contact/test information must be supplied. | [Provide test information](https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-test-information) |
| Review information includes reachable contact details, notes, and demo credentials only when login is required; Support URL is a platform-version field. | [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information) |
| A privacy-policy URL is required for all apps and privacy answers must be published. | [Manage app privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy) |
| Submission should be tested on device and review notes should explain non-obvious features and In-App Purchases; a privacy policy must also be accessible in-app. | [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) |
| The Paid Apps Agreement plus banking/tax setup is required for In-App Purchase configuration/testing; product IDs and metadata must match. | [In-App Purchase configuration overview](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/) |
| TestFlight uses the sandbox for In-App Purchases; sandbox accounts support test scenarios and accelerated subscription renewal. | [Test subscriptions and In-App Purchases in TestFlight](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testing-subscriptions-and-in-app-purchases-in-testflight/) |
| Subscription setup includes a subscription group, localization, pricing/availability, and review information; the first subscription is submitted with an app version. | [Offer auto-renewable subscriptions](https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/) |
| An age rating questionnaire is required and App Store Connect calculates territory ratings. | [Set an app age rating](https://developer.apple.com/help/app-store-connect/manage-app-information/set-an-app-age-rating) |
| Export-compliance applicability must be determined; a build may show Missing Compliance; the Info.plist declaration can avoid repeated questions when appropriate. | [Export compliance overview](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance) and [Determine and upload encryption documentation](https://developer.apple.com/help/app-store-connect/manage-app-information/determine-and-upload-app-encryption-documentation) |
| An explicit App ID uses the exact bundle ID; Account Holder or Admin manages identifiers. | [Register an App ID](https://developer.apple.com/help/account/identifiers/register-an-app-id/) |
| The Account Holder signs updated agreements; paid distribution requires the Paid Apps Agreement to remain active. | [Sign and update agreements](https://developer.apple.com/help/app-store-connect/manage-agreements/sign-and-update-agreements/) |

## Scope distinctions from the research

- Public support/privacy URLs and external-review metadata block `TF-G3`, not the first
  processed internal build, except any value App Store Connect makes mandatory earlier.
- A signed, valid, processed build and authorized internal tester block `TF-G2`.
- StoreKit is treated as a product-readiness gate even though Apple may technically process
  a binary before every commercial field is final; AuraFit exposes purchases in the beta.
- Full App Store marketing assets and final App Review submission are `AS-G1`, not TestFlight
  internal-beta blockers.
