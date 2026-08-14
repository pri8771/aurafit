# TestFlight App Review Notes

Version/build: `OWNER_REQUIRED_PROCESSED_VERSION_AND_BUILD`

AuraFit analyzes a full-body photo locally on the device. No login, demo account, or backend
is required. The app does not upload the selected photo for analysis. The guidance is produced
by deterministic on-device image, color, and pose heuristics; it is subjective guidance about
the outfit and photograph, not a health, attractiveness, identity, or personal-worth score.

## Fast review path

1. Launch AuraFit and complete or skip the three-page onboarding.
2. Tap the **Scan** tab, then **Import from Library**.
3. Select the supplied rights-cleared, full-body image with one visible person. The system
   photo picker grants AuraFit access only to the selected image; broad Photos read access is
   not requested.
4. Wait for analysis to finish. Confirm the result screen shows a score, **Breakdown**,
   **Glow-Up Tips**, **Sharper Shot Next Time**, **Palette**, and **Scorecard Style**.
5. Tap the heart to favorite the result. Tap **History** and verify the completed result
   appears. This data is saved locally on the device.
6. Return to **Scan** and tap **Go Pro**, or open **Settings** and tap **Upgrade to Pro**. The
   paywall title is **AuraFit Pro**; its top-right **Restore** button triggers StoreKit restore.

Supplied test-image URL: `OWNER_REQUIRED_PUBLIC_TEST_IMAGE_URL`

If the reviewer prefers Camera, photograph one consenting adult in ordinary clothing with
their full body visible in reasonable lighting. From **Scan**, tap **Open Camera**. The app
first explains the on-device use and then requests Camera access. If access was previously
denied, **Camera Access Needed** offers **Open Settings** or **Use Library**. Camera and Photos
prompts appear only when the matching action is selected.

## In-App Purchase behavior and identifiers

- Monthly auto-renewable Pro subscription: `com.aurafit.pro.monthly`
- Yearly auto-renewable Pro subscription: `com.aurafit.pro.yearly`
- One-time Streetwear scorecard-style unlock: `com.aurafit.template.streetwear`
- One-time Soft Luxury scorecard-style unlock: `com.aurafit.template.softluxury`

The production catalog must confirm these records, localized names, prices, durations, and
availability before submission. A Pro subscription enables unlimited scans, unwatermarked
exports, reveal clips, and all scorecard styles. A template-only purchase unlocks its matching
scorecard style. TestFlight purchases run in Apple’s sandbox.

## Review contact

- Name: `OWNER_REQUIRED_REVIEW_CONTACT_NAME`
- Email: `OWNER_REQUIRED_REVIEW_CONTACT_EMAIL`
- Phone: `OWNER_REQUIRED_REVIEW_CONTACT_PHONE`
- Feedback route: `OWNER_REQUIRED_FEEDBACK_EMAIL`
- Support URL: `OWNER_REQUIRED_PUBLIC_SUPPORT_URL`
- Privacy policy URL: `OWNER_REQUIRED_PUBLIC_PRIVACY_URL`

Do not submit this draft until every `OWNER_REQUIRED` field is replaced. Open the test-image,
support, and privacy URLs in a signed-out browser, and record their redacted reachability and
image-rights evidence under `quality/evidence/testflight/AURA-LEG-008/README.md`.
