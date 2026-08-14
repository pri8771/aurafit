# AURA-MKT-004 evidence — privacy and support pages published

**Date:** 2026-08-13

## Host decision (supersedes the 2026-07-29 OpenAI Sites preference)

Host: `priyanshchordia.com` (GitHub Pages, repository
`pri8771/priyanshchordia.com`, deployed from `main`). This is the same host
already serving the published privacy/support routes for Mala, Anjali, Svara,
and Roam, so longevity ownership and the publication pipeline are shared with
the rest of the portfolio. The owner directed publication of AuraFit pages on
2026-08-13; formal owner sign-off of the hosted copy remains open below.

The AURA-R14 concerns about OpenAI Sites (workspace-gated access, preview
longevity) do not apply: GitHub Pages serves anonymous public HTTPS.

## Published URLs and anonymous-access checks (2026-08-13)

| URL | Anonymous HTTP status |
|---|---|
| https://priyanshchordia.com/apps/aurafit/privacy/ | 200 |
| https://priyanshchordia.com/apps/aurafit/support/ | 200 |
| https://priyanshchordia.com/products/aurafit/ | 200 |

Checks were performed with `curl` (no cookies or authentication).

## Content synchronization

The hosted privacy page was generated from a condensed adaptation of
`docs/PRIVACY_POLICY.md` (site source of truth:
`priyanshchordia.com` repository, `data/apps.json`, slug `aurafit`). It keeps
the policy's factual claims: no data collection, no account/server/analytics,
on-device Vision/Core Image analysis, deterministic style heuristic, sandbox
storage, camera/photo-picker/photo-add permissions, StoreKit purchases handled
by Apple, share-sheet-only egress, and Delete All Fits.

Support contact on the hosted support page: `support@priyanshchordia.com`.

## Remaining before this task is `done`

- Owner reads the hosted privacy page and records approval that it matches
  `docs/PRIVACY_POLICY.md` in legal meaning (line-by-line pass per ST-02).
- The site entry is marked `legal_approved: true` in the site repository once
  approved (currently served `noindex` pending that approval).
- Update `docs/PRIVACY_POLICY.md`'s contact section to cite the published
  URLs (done in this change set).
