# AURA-MON-002 evidence

- Status: `not_applicable` — closed by DEC-006 (2026-08-18): AuraFit 1.0 has no in-app
  purchases, so this task has no work product. Content below is retained for history.

- Status: `human_review_required` — the decision pack and source-backed product scope are ready,
  but no owner has approved prices, storefronts, territories, offers, Family Sharing, or a
  product-removal decision.
- Commit SHA: `OWNER_REQUIRED_COMMIT_SHA_AT_COMMERCIAL_DECISION`
- Version/build: `OWNER_REQUIRED_RELEASE_VERSION_AND_BUILD_AT_DECISION`
- Date/time and time zone: 2026-07-29, America/New_York
- Operator/reviewer role: repository agent prepared the pack; only the owner may approve the
  commercial policy.
- Environment/device: static source and official Apple-documentation review; no App Store
  Connect pricing, offer, or availability change was made.

## Product value verified in source

| Product ID | Proposed type/period | Delivered value | Static result |
|---|---|---|---|
| `com.aurafit.pro.monthly` | auto-renewable, one month | Pro: unlimited scans, unwatermarked scorecards, reveal clips, all scorecard styles | implemented; production catalog unverified |
| `com.aurafit.pro.yearly` | auto-renewable, one year | Same Pro entitlement as monthly | implemented; production catalog unverified |
| `com.aurafit.template.streetwear` | non-consumable | Streetwear scorecard style for a non-Pro owner | implemented; production catalog unverified |
| `com.aurafit.template.softluxury` | non-consumable | Soft Luxury scorecard style for a non-Pro owner | implemented; production catalog unverified |

The current source enforces three free scans per day and watermarked exports. StoreKit supplies
localized product name, description, and price; no price is hard-coded in the paywall. Pro
unlocks every scorecard style, so a template purchase has a distinct value only for a user who
does not have Pro. This is source consistency, not signed-device, sandbox, or catalog proof.

## Current Apple configuration concepts (research, not a recommendation)

- Apple lets the owner select IAP/subscription availability by country or region, price, and
  start/end dates. Subscription prices can be set per storefront; Apple documents up to 800
  standard price points and calculated comparable storefront prices. [Apple pricing and
  availability](https://developer.apple.com/help/app-store-connect/reference/pricing-and-availability/in-app-purchase-and-subscriptions-pricing-and-availability)
- For auto-renewable subscriptions, introductory offers can be **free**, **pay as you go**, or
  **pay up front**. A customer can redeem one introductory offer per subscription group; offer
  eligibility and duration must be chosen deliberately. [Apple introductory-offer
  guidance](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-introductory-offers-for-auto-renewable-subscriptions)
- Promotional offers target existing or previously subscribed users and require StoreKit offer
  implementation plus an In-App Purchase key; AuraFit does not currently implement that flow.
  Do not approve a promotional offer unless a separate implementation decision adds the required
  StoreKit/key handling. [Apple promotional-offer
  guidance](https://developer.apple.com/help/app-store-connect/manage-subscriptions/set-up-promotional-offers-for-auto-renewable-subscriptions)
- Family Sharing can apply to auto-renewable subscriptions and non-consumables, can reach up to
  five family members, and cannot be turned off after it is enabled in App Store Connect. The
  current entitlement code processes verified transactions but has no product-specific Family
  Sharing presentation or test evidence. [Apple Family Sharing
  guidance](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/turn-on-family-sharing-for-in-app-purchases)
- Metadata changes can take up to one hour to appear in Apple’s sandbox. Do not diagnose a
  product-load failure or mark a test passed before that documented window and a real sandbox
  observation. [Apple subscription-pricing
  guidance](https://developer.apple.com/help/app-store-connect/manage-subscriptions/manage-pricing-for-auto-renewable-subscriptions)

## Owner decision worksheet

Complete every field in `docs/DECISIONS.md` as one dated decision. `OWNER_REQUIRED_*` fields are
deliberately blank; no default or fixture value is approved.

| Decision field | Owner value | Required rationale/evidence |
|---|---|---|
| `OWNER_REQUIRED_COMMERCIAL_APPROVAL` |  | selected structure, approving owner, date |
| `OWNER_REQUIRED_BASE_STOREFRONT` |  | Apple storefront/country or region |
| `OWNER_REQUIRED_BASE_CURRENCY` |  | currency paired with the selected storefront |
| `OWNER_REQUIRED_TERRITORIES` |  | exact initial country/region list or explicit worldwide scope |
| `OWNER_REQUIRED_PRICE_PRO_MONTHLY` |  | StoreKit/App Store Connect price point, not a hand-formatted display string |
| `OWNER_REQUIRED_PRICE_PRO_YEARLY` |  | StoreKit/App Store Connect price point, not a hand-formatted display string |
| `OWNER_REQUIRED_PRICE_TEMPLATE_STREETWEAR` |  | price point or explicit removal from code/catalog scope |
| `OWNER_REQUIRED_PRICE_TEMPLATE_SOFT_LUXURY` |  | price point or explicit removal from code/catalog scope |
| `OWNER_REQUIRED_INTRO_OFFER_POLICY` |  | enabled/disabled; if enabled, product, type, duration, eligible storefronts, price/free terms |
| `OWNER_REQUIRED_FAMILY_SHARING_POLICY` |  | enabled/disabled per product; acknowledge Apple’s irreversible enablement |
| `OWNER_REQUIRED_LAUNCH_DISCOUNT_POLICY` |  | enabled/disabled; if enabled, exact offer mechanism and implementation owner |
| `OWNER_REQUIRED_SUBSCRIPTION_RANK` |  | monthly/yearly order and intended upgrade/downgrade behavior |

## Two unapproved subscription structures

| Structure | Monthly | Yearly | Effective yearly monthly price | Annual discount vs. 12 monthly payments | Owner must decide |
|---|---:|---:|---:|---:|---|
| A — standard monthly/yearly pair | `OWNER_REQUIRED_PRICE_PRO_MONTHLY_A` | `OWNER_REQUIRED_PRICE_PRO_YEARLY_A` | `YEARLY_A / 12` | `1 - (YEARLY_A / (12 × MONTHLY_A))` when both values exist | customer fit, value framing, territory coverage |
| B — alternative monthly/yearly pair | `OWNER_REQUIRED_PRICE_PRO_MONTHLY_B` | `OWNER_REQUIRED_PRICE_PRO_YEARLY_B` | `YEARLY_B / 12` | `1 - (YEARLY_B / (12 × MONTHLY_B))` when both values exist | customer fit, value framing, territory coverage |

Do not calculate, round, compare, or call either structure better until the owner supplies both
prices in the same selected storefront/currency. The local `AuraFit.storekit` fixture prices are
test data and cannot be copied into this table.

## Comparable-price evidence template

`docs/PLAN.md` contains historical market commentary, not current product-page evidence. Before
an owner chooses a price, add one row per comparable from that product’s official App Store or
publisher page. Exclude inaccessible, regional, trial-only, or ambiguous prices instead of
estimating or converting them.

| Comparable product | Official source URL | Storefront/currency | Product and billing period | Observed date/time | Observed price | Availability/notes |
|---|---|---|---|---|---|---|
| `OWNER_REQUIRED_COMPARABLE_1` | `OWNER_REQUIRED_OFFICIAL_URL_1` |  |  |  |  |  |
| `OWNER_REQUIRED_COMPARABLE_2` | `OWNER_REQUIRED_OFFICIAL_URL_2` |  |  |  |  |  |

## Propagation and catalog handoff checklist

After the owner records the decision and `AURA-MON-008` saves production catalog metadata:

1. Record the App Store Connect save date/time, operator role, affected product IDs, and the
   Apple propagation source/date above. Do not record sessions, financial data, or screenshots
   containing personal information.
2. Wait up to Apple’s documented one-hour sandbox-metadata window. Record the exact start and
   end time; do not repeatedly recreate a product during that window.
3. On signed hardware, set the Xcode Run scheme StoreKit Configuration to **None**, verify the
   local `.storekit` fixture is not injected, and install the intended Release candidate.
4. Load products through the real StoreKit path. For each ID, record actual localized name,
   price, duration/type, and availability, or the exact failure message. Compare only against
   approved App Store Connect metadata, not local fixture values.
5. Run `AURA-QA-010` for purchase, cancellation, pending, restore, template-only entitlement,
   offline entitlement, expiry/refund/revoke, and processed-TestFlight behavior. A successful
   local StoreKit configuration run is not sandbox evidence.
6. Record each Apple-visible product status exactly. The first auto-renewable subscription and
   first subscription group must be submitted with a new app version; do not claim approval from
   sandbox visibility alone. [Apple subscription submission
   guidance](https://developer.apple.com/help/app-store-connect/manage-subscriptions/offer-auto-renewable-subscriptions/)

## Subtask evidence

- [ ] `AURA-MON-002-ST-01` — Comparable-price collection is pending owner-selected comparables;
  the evidence template and exclusion rule are ready.
- [x] `AURA-MON-002-ST-02` — Static source audit maps all four proposed products to current
  entitlements and verifies the free three-scans/day scope. Signed-device/catalog verification
  remains pending.
- [x] `AURA-MON-002-ST-03` — Two unapproved, formula-only structures are ready. Prices remain
  explicit owner-required inputs.
- [ ] `AURA-MON-002-ST-04` — Owner must select storefront, currency, territories, and rationale.
- [ ] `AURA-MON-002-ST-05` — Owner must explicitly enable or disable introductory offers,
  Family Sharing, and any launch discount. No offer/sharing default is approved.
- [x] `AURA-MON-002-ST-06` — Static paywall reconciliation passed for product IDs, delivered
  benefits, StoreKit-sourced price/name/description, restore, renewal disclosure, and terms /
  privacy links. Hosted privacy URL and final EULA decision remain separate blockers.
- [ ] `AURA-MON-002-ST-07` — Blocked until all worksheet fields and current comparable evidence
  are owner-approved and recorded in `docs/DECISIONS.md`.

## Acceptance criteria

- [ ] Monthly, annual, Streetwear, and Soft Luxury prices or explicit removal decisions are owner-approved.
- [ ] Territory, offer, trial, and Family Sharing decisions are explicit.
- [ ] The decision identifies current comparable sources and observation dates.
- [x] Code, paywall, and catalog scope are statically internally consistent; production catalog
  consistency remains pending `AURA-MON-008` and `AURA-QA-010` evidence.

## Reverification trigger

Reopen this pack after any product ID/type/benefit, free limit, paywall claim, legal route,
commercial policy, or Apple pricing/offer rule change. Replace an official Apple concept link
when Apple changes it; do not treat this pack as approval.
