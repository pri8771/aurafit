# App Store screenshots — AuraFit 1.0 (3)

Captured 2026-08-18 from the `release/1.0-3-full-free` branch @ `356e13f` (no source changes).
The listing copy these accompany is `docs/release/APP_STORE_LISTING.md`.

## Capture environment

| Item | Value |
|---|---|
| Simulator device | iPhone 14 Plus (`com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus`), created for this run as `AuraFit-Shots-14Plus`, UDID `0425E56C-79CD-4D83-B1D3-1050B2E58A0A` |
| iOS runtime | iOS 26.5 (26.5 - 23F77), `com.apple.CoreSimulator.SimRuntime.iOS-26-5` |
| Xcode | 26.6 |
| Native screen resolution | 1284 × 2778 px (428 × 926 pt @3x) — this is exactly the App Store Connect "iPhone 6.5" Display" size, so **no resize or crop was applied** |
| Build | `AuraFit` scheme, Debug configuration, `xcodebuild build-for-testing`, `CODE_SIGNING_ALLOWED=NO`, installed with `xcrun simctl install` |
| Launch | `xcrun simctl launch <udid> com.pchordia.aurafit -UITestStubVision` — the DEBUG-only stub that replaces the Vision pose/segmentation requests the Simulator cannot run (see `AuraFit/Services/Analysis/UITestVisionStub.swift`, AURA-QA-001). Everything else (colour, quality, heuristic outfit classifier, scoring, tips, persistence, scorecard render) is the real code path. Persistent (on-disk) SwiftData store, i.e. `-UITestInMemoryStore` was **not** passed, so History/Home show real saved sessions |
| Appearance | The app forces `preferredColorScheme(.dark)` (`AuraFit/App/AuraFitApp.swift`), so there is no light-mode variant to capture |
| Status bar | `xcrun simctl status_bar override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3` |
| Capture command | `xcrun simctl io <udid> screenshot <file>` |
| Post-processing | Alpha channel removed (RGBA → RGB) with Pillow 12.2.0 because App Store Connect rejects PNGs with an alpha channel. Every source alpha plane was verified to be uniformly 255 and the RGB planes were verified byte-identical before/after, so this is lossless. PNG re-encoded with `optimize=True`. No scaling, cropping, framing, badges, or text overlays |
| Photo used for the scan | `AuraFitUITests/Fixtures/QAFitPhoto.jpg`, seeded with `xcrun simctl addmedia` and imported through the app's own PhotosPicker ("Import from Library"). This is the repo's rights-clean **synthetic silhouette fixture** — not a real person. See "Owner follow-ups" |

## iPhone 6.5" set — `iphone-6.5/` (1284 × 2778, portrait, RGB PNG)

| # | File | What is on screen |
|---|---|---|
| 01 | `01-scan-start.png` | Scan tab start screen: silhouette frame, "Capture your fit", Open Camera / Import from Library, "Tips for a great scan" |
| 02 | `02-fit-result-score.png` | Fit Result top: score ring 69/100, "✨ Clean" label + blurb, Closest Style Match card (Minimalist, "Estimated from your color palette, without a model confidence."), start of Breakdown |
| 03 | `03-fit-result-breakdown.png` | Full Breakdown card: all seven signals (Outfit Cohesion 91, Color Harmony 99, Pose / Posture 90, Lighting 66, Framing 93, Background 78, Confidence Energy 90) plus the "These scores rate the outfit and the photograph, not you" disclaimer; start of Glow-Up Tips |
| 04 | `04-fit-result-tips-palette.png` | Glow-Up Tips (3 tips), Sharper Shot Next Time (2 photo tips), Palette (5 hex swatches), start of Scorecard Style |
| 05 | `05-fit-result-scorecard-style.png` | Sharper Shot Next Time, Palette, Scorecard Style chips (Classic / Streetwear / Soft Luxury, Classic selected), Share Scorecard, Save, Reveal Clip, Scan Another Fit |
| 06 | `06-history.png` | History tab with All / Favorites / Top Scores segments and three saved fits (score badge, label, persona, relative time) |
| 07 | `07-home.png` | Home tab after scans: greeting, "Scan Today's Fit" CTA, Last Fit Score card, Weekly Avg / Streak / Best stat tiles, Recent Fits row |
| 08 | `08-settings.png` | Settings tab: Preferences (Haptics, Sound Effects, Auto-save exports), Privacy ("Your data stays on-device"), Data (Saved Fits 3, Delete All Fits), About (Version 1.0 (3), Privacy Policy, Terms) |

### `iphone-6.5/extras/` — same device/size, optional

| # | File | What is on screen |
|---|---|---|
| 09 | `extras/09-onboarding.png` | First-launch onboarding page 1 ("Scan Your Fit") |
| 10 | `extras/10-challenges.png` | Challenges tab: Active (Main Character Moment, 7-Day Glow Up, Monochrome Mastery 3/5) and Completed (Color Pop 3/3) |
| 11 | `extras/11-fit-result-scorecard-style-soft-luxury.png` | Same view as 05 with the Soft Luxury chip selected |

## `scorecard-exports/` — the three scorecard styles (NOT App Store screenshots)

These are the actual PNGs the app rendered when "Save" was tapped once per style on the result
screen (`ScorecardRenderer`, 1080 × 1920, copied out of the app's Documents/scorecards folder in
the simulator container). They are the product's own share/export output and are included so
the three styles can be seen side by side; App Store Connect will not accept them in the 6.5"
slot at this size. If you want a per-style store screenshot, either composite one of these
into a device frame or capture the share sheet on a device with real share targets.

| File | Style |
|---|---|
| `scorecard-classic.png` | Classic (indigo/navy gradient) |
| `scorecard-streetwear.png` | Streetwear (warm red/brown gradient) |
| `scorecard-soft-luxury.png` | Soft Luxury (plum/dark-purple gradient) |

## Not captured, and why

- **Analysis progress screen** (`AnalysisProgressView`): with the stubbed Vision requests the
  pipeline completes in well under a second on the simulator, so the progress screen is not
  on screen long enough to grab with `simctl io screenshot`.
- **Camera capture flow**: the Simulator has no camera; the permission primer / camera UI
  were not screenshotted.
- **Share sheet / Reveal Clip**: the simulator share sheet shows a bare UUID filename and only
  Reminders/Preview targets, so it does not make a useful store image.
- **6.9" (1320 × 2868) set**: not captured; the owner asked for the 6.5" size, and the 6.5"
  set here is native (no downscale) so App Store Connect can be told to reuse it.
- **Light mode**: not applicable — the app is dark-only by design.

## Owner follow-ups

1. The scan subject is the synthetic QA silhouette, which is the only rights-clean full-body
   image in the repository. Screens 02–07 and the scorecard exports show that silhouette.
   Before publishing, re-shoot 02–07 with a real, consenting adult's photo (App Store
   guidelines require screenshots to reflect real use). The recipe above reproduces the run:
   create an iPhone 14 Plus / iOS 26.x simulator, build Debug, `simctl addmedia` the photo,
   launch with `-UITestStubVision`, and import from library. On a physical device the stub is
   not needed (Vision runs natively) and the same screens apply.
2. Upload order suggested by `docs/release/APP_STORE_LISTING.md`: 01, 02, 03, 04, 05, 06
   (History), then 07/08 as desired. Do not add "free"/price badges.
