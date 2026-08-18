# Decisions

## DEC-001 — Project registration

- **Status:** accepted
- **Context:** This repository is governed by the App Factory standards.
- **Decision:** Use `.factory/project-context.json` as the authoritative project classification marker.
- **Consequences:** Agents must read the registration and quality files before coding.

## DEC-002 — Product priority

- **Status:** accepted
- **Context:** The app shell is more complete than the verified value loop.
- **Decision:** Prioritize a credible scan/import-to-export outcome before challenges, templates, or paywall optimization.
- **Consequences:** Secondary features cannot be used as evidence that the MVP is complete.

## DEC-003 — Analysis honesty

- **Status:** accepted
- **Context:** A real classifier model is not bundled and fallback heuristics are active.
- **Decision:** Distinguish measured Vision/image signals, heuristic conclusions, and unavailable signals in product copy and QA.
- **Consequences:** “AI” claims must match the shipping analysis pipeline.

## DEC-004 — MobileCLIP cannot ship (resolves `AURA-LEG-002`)

- **Status:** accepted — 2026-07-28
- **Context:** CR-001 bundled Apple's MobileCLIP-S0 image encoder from
  `huggingface.co/apple/coreml-mobileclip`. The Hugging Face card declares
  `license: other`, `license_name: apple-ascl`. The linked file is stale; the governing text
  is `LICENSE_MODELS` in `github.com/apple/ml-mobileclip` — the **Apple Machine Learning
  Research Model License Agreement**.
- **Finding:** the licence grants use *"exclusively for Research Purposes"*, and defines the
  term explicitly:

  > "Research Purposes" means non-commercial scientific research and academic development
  > activities... **"Research Purposes" does not include any commercial exploitation, product
  > development or use in any commercial product or service.**

  AuraFit is a commercial product with a subscription. Shipping these weights would breach the
  licence. This is not a risk to weigh — it is a line not to cross. The same licence family
  (`apple-amlr`) covers MobileCLIP2, so a version bump does not solve it.
- **Decision:** **Remove MobileCLIP from the shipping app.** Replace it with a
  permissively-licensed encoder (see `AURA-ENG-038`) or ship v1.0 on the heuristic path.
- **Alternatives evaluated:** LAION OpenCLIP ViT-B-32 (**MIT**) — the leading candidate;
  Google SigLIP (**Apache-2.0**); OpenAI CLIP (repo is MIT but the weights carry no explicit
  licence on the model card — less clean). Existing third-party Core ML conversions of these
  exist but are unofficial and low-provenance; convert from source weights instead.
- **Consequences:** the CLIP work is not wasted — `CLIPZeroShotClassifier`, the label-embedding
  pipeline in `tools/clip/`, the person-crop, and the photo-issue label group are all
  encoder-agnostic. What must change is the bundled encoder and the regenerated embeddings
  (the text encoder must match the image encoder). Expect a bundle-size increase:
  MobileCLIP-S0's image encoder is 22MB; ViT-B-32 is ~175MB at fp16 and needs palettization to
  land near 45–65MB. `tools/clip/README.md`'s licence warning was correct and is now resolved
  against us.

## DEC-005 — VoiceOver deferred across the portfolio, not descoped

- **Status:** accepted
- **Date:** 2026-08-17
- **Context:** `AURA-QA-004`'s manual VoiceOver device pass has sat unexecuted (`blocked_external`). The owner made a portfolio-wide call to defer VoiceOver work across every app for now, to focus effort on the free/local-only real-world testing pass first.
- **Decision:** VoiceOver manual review is deferred, not descoped — this is a "come back to it later" call, not a permanent product decision to exclude VoiceOver support. Discrete, already-identified VoiceOver gaps found during code review (e.g. the two fixed-size fonts corrected 2026-08-17) are still fixed as found — this defers the *systematic device pass* (`AURA-QA-004`), not opportunistic fixes. Dynamic Type remains in scope and is not deferred.
- **Consequences:** `AURA-QA-004` is not launch-blocking until this is revisited. Do not claim VoiceOver support is verified or complete in any release notes, App Store copy, or accessibility nutrition labels while this stands.
- **Related Files:** `docs/testflight/tasks/AURA-QA-004.md`, `quality/evidence/testflight/AURA-QA-004/README.md`, `docs/BUGS.md`

## DEC-006 — AuraFit 1.0 ships as one full, free product; monetization deferred

- **Status:** accepted
- **Date:** 2026-08-18
- **Context:** Builds `1.0 (1)` and `1.0 (2)` carried a freemium model: a StoreKit 2 paywall
  (`AuraFit Pro` monthly/yearly subscriptions plus two one-time scorecard-style unlocks), a
  three-scans-per-day free quota, watermarked free exports, and Pro-only reveal clips. None of
  the commercial prerequisites (`AURA-MON-002` prices/offers, `AURA-MON-008` production
  catalog, `AURA-QA-010` sandbox matrix, `AURA-LEG-003` subscription legal links) had been
  completed, and the owner judged that a first release should read as a complete free app,
  not as the free version of a paid one.
- **Decision:** AuraFit 1.0 is **one full, free product**. Every capability the app has is
  available to everyone, always: unlimited scans, all three scorecard styles, reveal clips,
  and clean exports. There is no paywall, no "Pro"/"premium"/"free plan" language, no locked
  template, no scan quota, no StoreKit purchase surface, and no entitlement gating anywhere.
  The tier machinery is **deleted, not flagged off** — a flag would still be a tier. Build
  `1.0 (3)` is the first candidate under this decision.
- **Monetization is deferred, not descoped.** Any future paid offering is a new product
  decision for a later version and is not advertised in 1.0 ("coming soon" copy is not
  permitted in the UI or metadata).
- **Consequences:**
  - Removed from the app target: `Features/Paywall`, `Services/Store` (`StoreKitService`,
    `EntitlementManager`, `ProductCatalog`, `MockPurchaseProvider`), `Resources/AuraFit.storekit`
    and its scheme reference, `PaywallContext`, `EntitlementTier`, the daily-scan counters on
    `AppSettings`, the watermark flag on `ScorecardModel`/`FitSession`, and every
    Pro/upgrade/restore/quota string. `StoreKit` is no longer imported, so it is no longer
    linked.
  - `EntitlementManagerTests` is deleted; `FullFreeProductTests` guards the decision at source
    level (forbidden tier vocabulary in the app target fails the suite), proves every scorecard
    style renders without an ownership check, and proves scans are unlimited.
  - `AURA-MON-002`, `AURA-MON-008`, `AURA-QA-010`, and the subscription-link half of
    `AURA-LEG-003` are **N/A by decision** in `RELEASE_CHECKLIST.md`; the Paid Apps Agreement,
    banking, and tax sub-items of `AURA-OPS-009` are no longer required for this release.
  - The privacy policy, in-app policy screen, support page, reviewer notes, beta description,
    and App Store listing state plainly: no account, no purchases, all features free.
  - `docs/RELEASE_CHECKLIST.md`, `docs/FEATURES.md`, `docs/STATUS.md`,
    `docs/PRIVACY_POLICY.md`, `docs/release/*`, and `quality/feature-contracts/FEAT-004.json`
    are updated in the same change.
- **Related files:** `AuraFitTests/FullFreeProductTests.swift`,
  `AuraFitTests/ReleaseConfigurationTests.swift`, `scripts/release_candidate_check.sh`,
  `quality/evidence/release/1.0-3-full-free/README.md`
