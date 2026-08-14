# What to Test

Build: `OWNER_REQUIRED_PROCESSED_VERSION_AND_BUILD`

Use only ordinary, non-sensitive photos you have the right to use. Do not send a source photo
with feedback.

## Core loop

1. Complete onboarding, then open the **Scan** tab.
2. Tap **Open Camera**. Allow Camera access when prompted, take a clear full-body photo of
   one person, and confirm a result appears. If you prefer not to grant Camera access, tap
   **Import from Library** and select the same kind of image instead.
3. On the result, confirm **Breakdown**, **Glow-Up Tips**, **Sharper Shot Next Time**,
   **Palette**, and **Scorecard Style** are understandable and respectful. Results should be
   described as subjective guidance about the outfit and photo, not the person.
4. Tap **Share Scorecard** and complete or cancel the iOS share sheet. Tap **Save** only if
   you want to grant Photos add access and save an export.
5. Tap the heart to favorite the result. Open **History**, find the result, then use its
   context menu to favorite/unfavorite and delete it. Relaunch AuraFit and confirm completed,
   undeleted results remain in History.

## Recovery and privacy

1. Deny Camera access when prompted. Confirm **Camera Access Needed** offers **Open
   Settings**, **Use Library**, and **Cancel**; choose **Use Library** and complete a scan.
2. Start another analysis, send the app to the background, return, and report whether the
   analysis completes, cancels, or shows an error.
3. Open **Settings** and read the privacy explanation. It should state that analysis and saved
   data remain on device and that sharing happens only after you choose a destination.

## Premium

1. Open **Go Pro** on the Scan tab or **Upgrade to Pro** in Settings. On **AuraFit Pro**, wait
   for plans to load. Record the localized product name, price, and duration actually shown;
   do not assume a price from this document.
2. The candidate requests two subscriptions (`com.aurafit.pro.monthly` and
   `com.aurafit.pro.yearly`) and two one-time scorecard-style unlocks
   (`com.aurafit.template.streetwear` and `com.aurafit.template.softluxury`). Verify only
   products available in this processed build; report missing or extra products.
3. If you are authorized to use Apple’s TestFlight sandbox, purchase one available product.
   A Pro subscription should enable unlimited scans, unwatermarked exports, reveal clips, and
   all scorecard styles. A template-only purchase should unlock only its corresponding style.
4. In **Settings**, tap **Restore Purchases**. Report the exact result. Test expiry, refund,
   revoke, or a second-device restore only when the test account and scenario are available.

## Accessibility

Try the Scan-to-result path with VoiceOver, an accessibility Dynamic Type size, dark
appearance, and Reduce Motion. Report the screen, action, expected result, actual result,
device, iOS version, app version/build, and whether it reproduces.

## Known beta boundaries

- Results are deterministic creative guidance and can be subjective.
- AuraFit is iPhone-only and requires iOS 18 or later.
- There is no account or cross-device cloud sync.
- StoreKit products use Apple’s TestFlight sandbox and do not create real charges. Product
  availability, price, and lifecycle scenarios remain verification-pending until the
  production catalog and sandbox evidence exist.

## What to include with feedback

For any issue, send the screen and action, expected and actual result, app version/build,
iPhone model, iOS version, whether it repeats (`once`, `sometimes`, or `every time`), and
network/permission state when relevant. Screenshots or recordings are optional; do not include
source photos, Apple IDs, receipts, payment details, or other sensitive information.
