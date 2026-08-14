# AuraFit Privacy Policy

**App:** AuraFit (`com.pchordia.aurafit`)
**Effective:** 2026-07-29
**Last updated:** 2026-07-29

> **Keep in sync.** This document and the in-app policy screen
> (`AuraFit/Features/Settings/PrivacyPolicyView.swift`) are the same policy in two places.
> Change one, change the other. A hosted copy at a public URL is still required for App Store
> Connect metadata (tracked as `AURA-MKT-004`); until it exists, the in-app screen is what
> Settings and the paywall link to.

## The short version

AuraFit does not collect your data. There is no account, no server, and no analytics. Every
photo you scan is analyzed on your iPhone and stored only on your iPhone. The app has no
networking code of its own, so there is nowhere for your photos or scores to go.

## What the app stores, and where

Everything below lives in AuraFit's private app sandbox on your device. Deleting the app
deletes all of it.

| What | Where | Leaves your device? |
|---|---|---|
| Photos you capture or import for a scan | App's Documents directory (JPEG files) | No |
| Scores, tips, style match, and color palette | Local SwiftData database | No |
| Scorecard images and reveal clips you generate | App's Documents directory | Only if you share or save them yourself |
| Your preferences (haptics, sound, auto-save) | Local SwiftData database | No |
| Purchase status | Managed by Apple's on-device StoreKit | See "Purchases" |

## How photos are analyzed

Analysis runs entirely on your device. Apple's Vision framework estimates body pose and person
segmentation, Core Image measures image and color signals, and AuraFit uses a deterministic
color-based heuristic for the closest style match. No learned outfit-classifier model is
bundled in this release. Nothing is uploaded for processing.

Scores are subjective guidance about an outfit and a photograph. They are not a measurement of
any person, and the app does not identify, recognize, or profile anyone.

## What we do not do

- We do not collect, transmit, sell, or share your personal data.
- We do not use analytics, advertising, attribution, or crash-reporting SDKs.
- We do not track you across apps or websites. AuraFit does not use App Tracking Transparency
  because it has nothing to track.
- We do not create accounts, and we never ask for your name, email, or phone number.
- We include no third-party libraries or code.

The app's privacy manifest (`PrivacyInfo.xcprivacy`) declares no collected data types, no
tracking, and no tracking domains. It also declares the approved file-timestamp reason used to
remove old, unreferenced media from AuraFit's own app container.

## Permissions the app asks for

- **Camera** — only to capture the photo you are about to scan. Frames are analyzed on device
  and the camera is not used in the background.
- **Import from Photos** — uses Apple's system photo picker. AuraFit receives only the image
  you select and does not request broad Photo Library read access.
- **Photo Library (add)** — only when you tap Save or turn on auto-save, so scorecards and
  reveal clips can be written to your library.

You can revoke any of these in iOS Settings. Declining camera access does not block the app;
you can still import from your library.

## Sharing is always your choice

Scorecards and reveal clips are shared only when you tap Share or Save and choose a
destination in the iOS share sheet. Whatever you send then travels under the privacy policy of
the app or service you sent it to, not this one.

## Purchases

AuraFit Pro subscriptions and one-time template unlocks are processed by Apple through
StoreKit. Apple handles the payment and tells the app which products you own; AuraFit never
sees your payment details and stores no purchase records of its own beyond what StoreKit
provides on device. Apple's handling of purchase data is governed by
[Apple's Privacy Policy](https://www.apple.com/legal/privacy/).

## Links that leave the app

Manage Subscription and Terms of Use open Apple's own pages in your system browser. Apple's
privacy policy is linked from this document for the StoreKit explanation. Opening a link sends
no AuraFit data along with it.

## Children

AuraFit is not directed at children and collects no data from anyone, including children.

## Your rights

Because no data ever reaches us, there is nothing for us to look up, export, correct, or
delete on your behalf. You hold the only copy. Settings → Delete All Fits removes every saved
scan and its images immediately, and deleting the app removes everything else.

## Changes to this policy

If the app's data practices ever change, this policy and the in-app screen will be updated
before the change ships, and the "Last updated" date will move.

## Contact

Questions about this policy can be sent to **support@priyanshchordia.com** or through the
public support page at **https://priyanshchordia.com/apps/aurafit/support/**. The hosted
policy copy lives at **https://priyanshchordia.com/apps/aurafit/privacy/** (published
2026-08-13; owner line-by-line approval tracked by `AURA-MKT-004`).
