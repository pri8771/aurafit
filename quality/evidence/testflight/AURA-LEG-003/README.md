# AURA-LEG-003 evidence — Terms/EULA and subscription legal links

- Status: `human_review_required` — repository audit complete; owner EULA decision, public-policy URL, Release link test, and App Store configuration remain unverified.
- Canonical plan: [`docs/testflight/tasks/AURA-LEG-003.md`](../../../../docs/testflight/tasks/AURA-LEG-003.md)
- Current repository facts: Settings and paywall link to Apple’s standard EULA at `https://www.apple.com/legal/internet-services/itunes/dev/stdeula/`; paywall shows Apple-ID charge, auto-renewal, cancellation, and an in-app AuraFit Privacy route. Source facts are not owner approval or a Release-device result.
- Apple reference checked 2026-07-29: [custom license agreement procedure](https://developer.apple.com/help/app-store-connect/manage-app-information/provide-a-custom-license-agreement). Apple’s standard EULA applies when no custom EULA is provided; custom text is entered in App Store Connect, not inferred by an agent.

## Run header and external prerequisites

| Field | Required value |
| --- | --- |
| Candidate identity | Commit SHA, signed Release/TestFlight version/build, date/time-zone, operator role. |
| EULA decision | `OWNER_REQUIRED_EULA_CHOICE` = `standard_apple` or `custom`; approver/date/rationale reference. |
| Public URLs | `AURA-MKT-004` logged-out HTTPS evidence for support/privacy and, if custom, terms. |
| Commercial source | `AURA-MON-002` approved prices/offers and `AURA-MON-008` catalog status. |
| Artifact handling | Redacted device/browser captures only; legal review text, contacts, credentials, and account data stay outside Git. |

## Matrix

| Done | Subtask | What to do and evidence required | Expected result | Actual / artifact / defect / status |
| --- | --- | --- | --- | --- |
| [ ] | `AURA-LEG-003-ST-01` EULA choice | Present only standard Apple EULA vs human-reviewed custom terms; owner records choice, approver, date, rationale in `docs/DECISIONS.md`; link redacted record. | One governing agreement decision; existing standard links are not approval. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-LEG-003-ST-02` standard path | Only if ST-01=`standard_apple`: tap both Release Terms links, confirm final official Apple URL in logged-out browser, check no custom terms claims exist. | Both links reach the official EULA and no competing agreement exists. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-003-ST-03` custom path | Only if ST-01=`custom`: obtain `OWNER_REQUIRED_LEGAL_REVIEW_RECORD`; publish approved public text; authorized user enters it in Apps → AuraFit → General → App Information → License Agreement; retest app/public links. | One reviewed public custom agreement matches app and App Store Connect. | Actual: ; Artifact: ; Defect: ; Status: `human_review_required` |
| [ ] | `AURA-LEG-003-ST-04` paywall/catalog comparison | On signed Release, inspect title, StoreKit-supplied price/duration, renewal/cancellation, Restore, Manage Subscription, Privacy, Terms; compare against approved catalog and URLs. | No hard-coded, missing, broken, or contradictory purchase/legal claim. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |
| [ ] | `AURA-LEG-003-ST-05` reviewer purchase routes | Locate entry points for monthly, yearly, Streetwear, Soft Luxury. Document any unavailable IAP path factually in `AURA-LEG-008` notes and link catalog state; do not call this StoreKit QA. | Every visible IAP is reachable or explicitly explained to reviewers. | Actual: ; Artifact: ; Defect: ; Status: `blocked_external` |

## Acceptance and invalidation

- [ ] Owner/legal EULA decision is recorded.
- [ ] Terms and AuraFit privacy links work from the signed Release build.
- [ ] Paywall claims agree with approved catalog; reviewer paths cover all four product IDs.
- Missing choice, legal review, public URL, signed build, or link test remains `human_review_required`/`blocked_external`.
- Reopen after EULA, product/catalog, paywall, support/privacy URL, or legal-link change.
