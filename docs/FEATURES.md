# Features

## Product outcome

AuraFit gives a private, understandable assessment of an outfit photo and produces
specific coaching plus a result worth saving or sharing.

## MVP boundary

### Included

- Camera and Photos input with permission and failure handling.
- On-device normalization, Vision signals, scoring, and honest fallback behavior.
- Explainable result categories, history, and image/reveal-clip export with three scorecard
  styles, all available to everyone (DEC-006).
- Local persistence, deletion, and truthful privacy controls.

### Excluded

- Cloud inference, accounts, social feed, undisclosed analytics, or unsupported AI claims.
- Any paid tier, paywall, in-app purchase, quota, or locked feature — 1.0 is one full, free
  product; monetization is deferred to a future version (DEC-006).
- Unimplemented model capabilities presented as measured facts.

## Feature inventory

| ID | Feature | Status | Contract |
|---|---|---|---|
| AURA-CORE-001 | Scan/import to result | verification_pending | `quality/feature-contracts/FEAT-001.json` |
| AURA-CORE-002 | Result explanation and credibility | verification_pending | `quality/feature-contracts/FEAT-002.json` |
| AURA-EXPORT-001 | Save/share image and reveal media | verification_pending | `quality/feature-contracts/FEAT-002.json` |
| AURA-DATA-001 | History, persistence, deletion | verification_pending | `quality/feature-contracts/FEAT-003.json` |
| AURA-STORE-001 | Free limits and Pro entitlement | retired (DEC-006, 2026-08-18) | `quality/feature-contracts/FEAT-004.json` |
| AURA-PRIV-001 | Privacy release artifacts | human_review_required | `quality/feature-contracts/FEAT-005.json` |
| AURA-REL-001 | TestFlight beta distribution | human_review_required | `quality/feature-contracts/FEAT-006.json` |
