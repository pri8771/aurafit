# App Store Listing — AuraFit 1.0 (3)

Repository-authoritative App Store Connect metadata for the first public release. Every claim
below is backed by the shipped code as of 2026-08-18 (branch `release/1.0-3-full-free`); the
"Evidence" notes say where. Paste into App Store Connect verbatim; App Store Connect is a
delivery copy, not the authoring source. Field limits were checked mechanically
(`docs/release/APP_STORE_LISTING.md` lengths verified 2026-08-18).

## Identity

| Field | Value |
|---|---|
| Name (≤30) | `AuraFit: Scan Your Fit` |
| Subtitle (≤30) | `Private on-device outfit coach` |
| Bundle ID | `com.pchordia.aurafit` |
| SKU (suggested) | `aurafit-ios` |
| Version / build | `1.0` / `3` |
| Primary language | English (U.S.) |
| Price | Free (no in-app purchases — DEC-006) |
| Primary category | Lifestyle (`LSApplicationCategoryType = public.app-category.lifestyle`) |
| Secondary category (suggested) | Photo & Video |
| Support URL | https://priyanshchordia.com/apps/aurafit/support/ |
| Marketing URL | https://priyanshchordia.com/products/aurafit/ |
| Privacy Policy URL | https://priyanshchordia.com/apps/aurafit/privacy/ |
| Copyright | `2026 Priyansh Chordia` |

## Promotional text (≤170)

```
Snap or import a full-body photo and get a private Fit Score, honest tips, and a shareable scorecard. Everything runs on your iPhone. Free, no account, nothing to buy.
```

## Description (≤4000)

```
AuraFit is a private outfit and photo coach that lives entirely on your iPhone. Take a full-body photo or import one from your library, and in a few seconds you get a Fit Score, a clear breakdown of what's working, specific tips for next time, and a scorecard worth sharing.

Everything is free. There is no account, no subscription, no locked feature, and nothing to buy inside the app.

WHAT YOU GET
• Fit Score out of 100 with a label from "Needs a Glow-Up" to "Main Character".
• Breakdown across seven signals: Outfit Cohesion, Color Harmony, Pose / Posture, Lighting, Framing, Background, and Confidence Energy.
• Glow-Up Tips — concrete styling suggestions based on what the analysis actually saw.
• Sharper Shot Next Time — photo advice on light, framing, and pose so your next picture does the outfit justice.
• Palette — the dominant colors of your look as swatches you can reuse.
• Closest Style Match — Streetwear, Soft Luxury, Minimalist, Sporty, Classic, Bold & Expressive, Cozy, or Eclectic, always shown with how confident the estimate is.
• Scorecards in three styles — Classic, Streetwear, and Soft Luxury — ready for the share sheet or your Photos library.
• Reveal Clip — a short video of your score animating in, for stories and messages.
• History with favorites, weekly average, streak, and best score, plus light-hearted challenges like "7-Day Glow Up" and "Color Pop".

PRIVATE BY DESIGN
• Analysis runs on your device using Apple's Vision and Core Image frameworks. Photos are never uploaded.
• No account, no server, no analytics, no ads, no third-party code.
• Importing uses Apple's photo picker, so AuraFit only ever sees the single image you choose.
• Your scans, scores, and exports stay in the app's own storage. Delete any fit, or everything at once, from Settings.

HONEST ABOUT WHAT IT IS
Scores are subjective styling and photography guidance about the outfit and the photograph — not a measurement of you. The style match is a color-based estimate, not a verdict. AuraFit is here to help you make a great fit look great on camera.

Requires iOS 18 or later. iPhone only.
```

## Keywords (≤100, comma-separated)

```
outfit,fit check,style,fashion,ootd,photo coach,color palette,scorecard,wardrobe,pose,lookbook
```

## What's New in This Version

```
First release. Scan or import a full-body photo for a private, on-device Fit Score with a seven-signal breakdown, styling tips, photo tips, palette, three scorecard styles, and a reveal clip. Free, no account, nothing to buy.
```

## App Review information

- Sign-in required: **No** (no account exists — `AppEnvironment`, `SettingsView`).
- Demo account: **Not applicable.**
- Contact: Priyansh Chordia, priyansh.chordia@gmail.com, phone entered directly in App Store
  Connect (never stored in the repository).
- Notes: paste `docs/release/TESTFLIGHT_REVIEW_NOTES.md`. Summary: AuraFit analyzes a
  full-body photo locally; no login, no backend, no in-app purchases; all features are free.
  Fast path: Scan tab → Import from Library → pick a full-body photo → result screen shows the
  score, Breakdown, Glow-Up Tips, Sharper Shot Next Time, Palette, and all three Scorecard
  Styles; Share Scorecard and Reveal Clip both work for every user. Attach one rights-cleared
  full-body test image (`OWNER_REQUIRED_PUBLIC_TEST_IMAGE_URL`).

## App Privacy (Apple "App Privacy" questionnaire)

**Answer: "Data Not Collected."** Do not select any data type.

Derivation from the binary and source (2026-08-18):

| Check | Finding | Evidence |
|---|---|---|
| Privacy manifest | `NSPrivacyTracking = false`; `NSPrivacyTrackingDomains = []`; `NSPrivacyCollectedDataTypes = []`; one required-reason entry (`NSPrivacyAccessedAPICategoryFileTimestamp`, reason `C617.1`) | `AuraFit/Resources/PrivacyInfo.xcprivacy`; asserted by `ReleaseConfigurationTests.testPrivacyManifestDeclaresLocalFileTimestampReason` and `scripts/release_candidate_check.sh audit_privacy_manifest` |
| Networking | No `URLSession`, `Network`, `CFNetwork`, `WKWebView`, or socket use anywhere in the app target. The only outbound action is a SwiftUI `Link` to Apple's standard EULA page, opened by the system browser | `rg` over `AuraFit/` (2026-08-18); `SettingsView.swift:129` |
| Photos and camera | Camera capture (`CameraService`) and photo-picker import (`PhotoPickerService`) produce a `UIImage` that is analyzed by `AnalysisPipeline` (Vision pose/segmentation, Core Image, deterministic heuristics) on device and written only to the app's Documents directory by `ImageFileStore`. Nothing is uploaded | `AuraFit/Services/Analysis/*`, `AuraFit/Services/Camera/*`, `AuraFit/Data/Persistence/ImageFileStore.swift` |
| Photo library scope | Import uses `PhotosPicker` (no `NSPhotoLibraryUsageDescription`); saving uses add-only access (`NSPhotoLibraryAddUsageDescription`) | `ReleaseConfigurationTests.testInfoPlistMatchesCameraAndSystemPickerBehavior` |
| Identifiers, analytics, ads, crash reporting | None; no third-party SDKs or packages are linked | `AuraFit.xcodeproj` has no package or framework dependencies; `docs/REUSABLE_COMPONENTS.md` |
| Purchases / financial info | None; StoreKit is not linked | `FullFreeProductTests`, `otool -L` check in `scripts/release_candidate_check.sh` |
| Contact info, user content shared with the developer | None; no account, no form, no upload | `docs/PRIVACY_POLICY.md` |

Because no data leaves the device, no "collected" data type applies (Apple's definition of
collection is transmission off-device). Photos processed and stored locally are not
"collected." Tracking: **No.**

## Age rating (Apple questionnaire)

**Expected result: 4+.** Suggested answers, all "None" / "No" unless stated:

| Question | Answer | Why |
|---|---|---|
| Cartoon or Fantasy Violence, Realistic Violence, Prolonged Graphic Violence | None | The app renders scores, tips, and the user's own photo; no violent content is bundled or generated |
| Profanity or Crude Humor | None | All copy is fixed strings audited in source (`Enums.swift`, `TipsGenerator.swift`, `PhotoCoach.swift`) |
| Mature/Suggestive Themes, Sexual Content or Nudity | None | The app coaches clothing and photography; the disclaimer states scores rate the outfit and photo, not the person (`FitResultView.scoreDisclaimer`) |
| Horror/Fear Themes | None | — |
| Medical/Treatment Information | None | No health claims; copy explicitly disclaims health measurement |
| Alcohol, Tobacco, or Drug Use or References | None | — |
| Simulated Gambling, Contests | None | Challenges are local streak goals with no prize, entry, or third party (`SeedData.swift`) |
| Unrestricted Web Access | No | Only one fixed Apple link; no browser or web view |
| User-Generated Content / user interaction | No | Users never see other users' content; there is no sharing inside the app, only the system share sheet to destinations the user picks |
| Kids Category | No | Not directed at children; states this in the privacy policy |
| Made for Kids | No | — |
| Parental controls / in-app controls (2025 questionnaire) | Not applicable | Nothing to restrict; no purchases, chat, or web |

## Export compliance

**Answer: the app does not use non-exempt encryption.** In App Store Connect: "Does your app
use encryption?" → **No** (or, if the form insists on the two-step flow: uses only exempt
encryption / none beyond what iOS provides). No CCATS or annual self-classification report is
needed.

Evidence:

- `ITSAppUsesNonExemptEncryption = NO` is already set for both configurations via
  `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption` in `AuraFit.xcodeproj/project.pbxproj`
  (`Info.plist` is generated; there is no separate plist to edit). It is asserted by
  `ReleaseConfigurationTests.testInfoPlistMatchesCameraAndSystemPickerBehavior` and by
  `require_false_plist_value … ITSAppUsesNonExemptEncryption` in
  `scripts/release_candidate_check.sh`, and confirmed present in the exported IPA on
  2026-08-18 (`quality/evidence/release/1.0-3-full-free/README.md`).
- The app target contains no `CryptoKit`, `CommonCrypto`, `Security`-framework key, TLS, or
  custom cipher code (`rg` over `AuraFit/`, 2026-08-18), and makes no network connections at
  all, so it does not even rely on Apple's TLS. Nothing about the answer changed with DEC-006
  beyond removing StoreKit.
- Because the key is in the bundle, App Store Connect will not prompt for the answer on each
  upload; the value above is what the upload asserts.

## Content rights

The app bundles no third-party content: no learned model, no licensed images, no fonts beyond
the system fonts, no audio. The 1024-px app icon is original artwork
(`AuraFit/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`). Answer "No" to
"Does your app contain, show, or access third-party content?" — the only third-party content
is the user's own photos, which the user supplies.

## Screenshots (owner task)

Required sizes for iPhone 6.9" and 6.5" (or a 6.9" set with "use for all"). Suggested
sequence: Scan start screen; analysis result with score ring and Breakdown; Glow-Up Tips /
Sharper Shot Next Time; Scorecard Style with the three styles; History. Use rights-cleared
photos of a consenting adult only. Do not add badges, prices, or "free"/"pro" ribbons to the
screenshots — the listing already says the app is free.
