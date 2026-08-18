# `1.0 (3)` — upload, App Store Connect listing, and App Review submission — 2026-08-18

- Status: **submitted for App Review** (App Store Connect "Waiting for Review"). Release status in
  `docs/STATUS.md` stays `human_review_required` until Apple's decision and the automatic release;
  no `done` claim.
- Actor: owner's assistant on the owner's Mac; upload via `xcodebuild`, everything else via the
  App Store Connect web UI; **owner-approved**.
- Source: branch `release/1.0-3-full-free @ c5fd46b` (the archive is the one produced 2026-08-18
  and recorded in `README.md`; no source change between archive and upload).
- Date/time and time zone: 2026-08-18, 13:34–13:41 America/New_York.
- Continues `README.md` (gate, tests, archive, local export) in this directory.

## 1. Upload (`AURA-OPS-013`)

```
xcodebuild -exportArchive \
  -archivePath /private/tmp/AuraFit-1.0-3-export/AuraFit-1.0-3.xcarchive \
  -exportOptionsPlist <ExportOptions.plist with method app-store-connect, destination upload> \
  -allowProvisioningUpdates
→ Upload succeeded
→ ** EXPORT SUCCEEDED **
```

| Field | Value |
|---|---|
| Archive | `/private/tmp/AuraFit-1.0-3-export/AuraFit-1.0-3.xcarchive` (same archive as `README.md`) |
| Upload completed | **2026-08-18 13:34:57** local (America/New_York) |
| Tuple | `com.pchordia.aurafit` `1.0 (3)`, team `796XH483R4` |
| Local export IPA SHA-256 (from `README.md`, `destination export` of the same archive) | `d5300abd3b31a1b1d11692d0d55b072a28736625d052efef8445fbf02e606664` |
| Apple processing | Completed within ~6 minutes; build `3` appeared and was selectable in the version 1.0 build picker |
| Uploader role | Owner's signed-in developer account session; role and account details not recorded |
| Consumed tuples | Builds `1` (uploaded 2026-08-13) and `2` (uploaded earlier) remain in App Store Connect **unused**; build `3` is now consumed. Next build must be `≥ 4`. |

Delivery ID and the exact processing first-seen/final timestamps were not captured from the ASC
UI; the times above are the `xcodebuild` completion time and wall-clock observation.

## 2. Listing entered (`docs/release/APP_STORE_LISTING.md`)

| ASC area | Entered | Result |
|---|---|---|
| App Information | Name `AuraFit: Scan Your Fit`, subtitle "Private on-device outfit coach", primary Lifestyle, secondary Photo & Video, content rights: no third-party content | Saved |
| App Privacy (`AURA-LEG-004`) | "Data Not Collected"; privacy-policy URL `https://priyanshchordia.com/apps/aurafit/privacy/` | **Published** |
| Age rating (`AURA-LEG-005`) | Questionnaire answered per the listing pack | Computed **4+** |
| Pricing and Availability | Free; 175 territories | Saved |
| Version 1.0 | Promotional text, description, keywords, support URL `…/apps/aurafit/support/`, marketing URL `…/products/aurafit/`, copyright `2026 Priyansh Chordia` | Saved |
| Screenshots | 8 × iPhone 6.5" from `quality/store-assets/1.0-3/iphone-6.5/` (1284×2778, commit `c5fd46b`; provenance in `quality/store-assets/1.0-3/README.md`). Subject is the **synthetic silhouette fixture**; the owner may re-shoot with a real outfit later | Uploaded |
| Build | `1.0 (3)` attached | Attached |
| App Review Information | Review contact and review notes entered (per `docs/release/APP_STORE_LISTING.md` "App Review information"); sign-in **not** required | Saved |
| Version release | Automatic after approval | Saved |

## 3. Submission

- Version 1.0 (build 3) **submitted for App Review at ~13:41 local** on 2026-08-18. App Store
  Connect status: **"Waiting for Review"**.
- Submitted directly as an App Store version; no TestFlight internal/external beta round was run
  for build 3 before submission (`AURA-QA-006/007/008/009` remain not run).

## 4. Hosted pages (`AURA-MKT-004`)

`priyanshchordia.com` `main @ 4372f22` was pushed on 2026-08-18. The hosted AuraFit privacy,
support, and product pages were regenerated with **0 tier words** (no purchase / Pro / subscription
language, matching DEC-006). Verified live by `curl` on 2026-08-18: HTTP `200`, `0` tier-word
hits, for `https://priyanshchordia.com/apps/aurafit/privacy/`, `…/apps/aurafit/support/`, and
`…/products/aurafit/`. These are the URLs entered in ASC above.

## 5. Not evidenced by this record

- Apple App Review approval, release, or App Store availability (open; see `docs/STATUS.md`).
- Physical-device install/launch/QA of build 3 (`AURA-OPS-012A` on-device half, `AURA-QA-002`,
  `AURA-QA-004`, `AURA-QA-005`): **not run**. The owner consciously waived these gates for the
  1.0 submission on 2026-08-18; they stay open, not done — see
  `quality/waivers/1.0-3-device-qa-owner-waiver-2026-08-18.md` and `docs/DECISIONS.md` DEC-007.
- TestFlight internal/external smoke for build 3 (`AURA-QA-006/007`).
- A separately recorded owner/legal export-compliance determination (`AURA-OPS-014`); the binary
  carries `ITSAppUsesNonExemptEncryption = NO`, and neither upload nor submission raised a
  Missing Compliance prompt.
- The `legal_approved` flag state for the AuraFit entry in the site repository was not re-checked
  as part of this record.

## Reverification trigger

Any resubmission after an App Review rejection, or any change to the app target, requires a new
build (`CURRENT_PROJECT_VERSION ≥ 4`), a fresh gate run, and a new record; do not reuse build 3.
