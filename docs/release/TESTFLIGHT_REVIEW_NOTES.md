# App Review Notes (TestFlight and App Store)

Version/build: `1.0 (3)` — replace with the processed build if a later candidate is uploaded.

AuraFit analyzes a full-body photo locally on the device. **No account, no login, no demo
credentials, no backend, and no in-app purchases: every feature is free and available to
everyone.** The app does not upload the selected photo for analysis. The guidance is produced
by deterministic on-device image, color, and pose heuristics; it is subjective guidance about
the outfit and photograph, not a health, attractiveness, identity, or personal-worth score.

## Fast review path

1. Launch AuraFit and complete or skip the three-page onboarding.
2. Tap the **Scan** tab, then **Import from Library**.
3. Select a rights-cleared, full-body image with one visible person. The system photo picker
   grants AuraFit access only to the selected image; broad Photos read access is not requested.
4. Wait for analysis to finish. Confirm the result screen shows a score, **Breakdown**,
   **Glow-Up Tips**, **Sharper Shot Next Time**, **Palette**, and **Scorecard Style** with all
   three styles (Classic, Streetwear, Soft Luxury) selectable.
5. Tap **Share Scorecard** to open the share sheet, and **Reveal Clip** to render a short
   video of the score animating in. Both are available to every user.
6. Tap the heart to favorite the result. Tap **History** and verify the completed result
   appears. This data is saved locally on the device.
7. Open **Settings**: preferences, the privacy explanation, **Delete All Fits**, the in-app
   **Privacy Policy**, and **Terms of Use** (Apple's standard EULA). There is no purchase,
   restore, or membership screen.

Supplied test-image URL: `OWNER_REQUIRED_PUBLIC_TEST_IMAGE_URL`

If the reviewer prefers Camera, photograph one consenting adult in ordinary clothing with
their full body visible in reasonable lighting. From **Scan**, tap **Open Camera**. The app
first explains the on-device use and then requests Camera access. If access was previously
denied, **Camera Access Needed** offers **Open Settings** or **Use Library**. Camera and Photos
prompts appear only when the matching action is selected.

## In-App Purchases

None. AuraFit 1.0 ships without StoreKit: no subscriptions, consumables, non-consumables, or
paid unlocks exist in the binary or in App Store Connect (`DEC-006`, 2026-08-18).

## Review contact

- Name: Priyansh Chordia
- Email: priyansh.chordia@gmail.com
- Phone: `OWNER_REQUIRED_REVIEW_CONTACT_PHONE` (entered directly in App Store Connect; never
  stored in this repository)
- Support URL: https://priyanshchordia.com/apps/aurafit/support/
- Privacy policy URL: https://priyanshchordia.com/apps/aurafit/privacy/

Open the test-image, support, and privacy URLs in a signed-out browser before submission and
record their redacted reachability and image-rights evidence under
`quality/evidence/testflight/AURA-LEG-008/README.md`.
