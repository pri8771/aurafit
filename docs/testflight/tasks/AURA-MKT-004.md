---
id: AURA-MKT-004
title: Publish durable privacy and support pages
gate: TF-G3
status: human_review_required
ownerBoundary: Owner + hosting access
dependsOn: []
evidence: quality/evidence/testflight/AURA-MKT-004/README.md
lastVerified: 2026-08-13
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-MKT-004 — Publish durable privacy and support pages

## Task description

This task publishes public, anonymous-access privacy and support pages that users and App Review can reach for the life of AuraFit. It is necessary because the in-app and repository policy alone cannot satisfy public App Store metadata; the observable result is stable HTTPS URLs returning public 2xx responses with matching policy and a real support route. Use an owner-approved host only—OpenAI Sites is the current program preference but is not valid if it requires workspace access.

## Preconditions and inputs

- Read `docs/PRIVACY_POLICY.md`, `docs/PLAN.md` risk AURA-R14, and the current Release in-app policy.
- Obtain `OWNER_REQUIRED_HOSTING_AUTHORIZATION` and `OWNER_REQUIRED_SUPPORT_CONTACT_METHOD`; neither may be invented.
- Do not publish custom terms unless `AURA-LEG-003` records an owner custom-EULA decision.

## Subtasks

### AURA-MKT-004-ST-01 — Select and validate the owner-approved host

This step chooses the host that will keep the policy reachable after beta. Obtain owner authorization for the host and its longevity owner, then verify anonymous access is technically possible; the expected result is a documented host decision, not merely a preview link.

**Execution**

1. Ask for `OWNER_REQUIRED_HOSTING_AUTHORIZATION` and the responsible owner for ongoing availability.
2. If OpenAI Sites is proposed, verify its public-sharing behavior in a logged-out browser before treating it as suitable.
3. Record selected host, canonical-domain plan, and owner approval in evidence.

**Expected result and evidence:** An approved host can serve anonymous public pages.

**Failure handling:** Keep `blocked_external` if the host is workspace-gated, preview-only, or unapproved; do not submit it to Apple.

### AURA-MKT-004-ST-02 — Publish a policy copy synchronized with the repository

This step makes the hosted `/privacy` page state the same data practices as the canonical policy. Copy `docs/PRIVACY_POLICY.md` exactly or record a durable synchronization procedure; the expected result is no legal-meaning difference between hosted, repository, and in-app policy.

**Execution**

1. Build the public `/privacy` page from `docs/PRIVACY_POLICY.md`.
2. Compare headings, collection/local-storage claims, permissions, purchase explanation, and contact wording line-by-line.
3. If a necessary hosted-only change affects meaning, update the canonical policy first through appropriate human review; do not silently diverge.

**Expected result and evidence:** Hosted policy matches canonical policy at its final public URL.

**Failure handling:** Stop publication evidence for any mismatch; record the exact text discrepancy.

### AURA-MKT-004-ST-03 — Publish a usable support page

This step gives users a real way to obtain help and follow common recovery paths. Publish `/support` with AuraFit name, an owner-approved contact method, expected response path, troubleshooting, restore-purchase help, permission recovery, and Delete All Fits/delete-data instructions; the expected result is an actionable public support route.

**Execution**

1. Obtain `OWNER_REQUIRED_SUPPORT_CONTACT_METHOD` and `OWNER_REQUIRED_SUPPORT_RESPONSE_PATH`.
2. Create the listed content using behavior verified in the current app and privacy policy.
3. Test the contact route without storing a tester's personal message or address in Git.

**Expected result and evidence:** `/support` renders public help and an actual monitored contact route.

**Failure handling:** Do not use a placeholder email/contact form; remain `blocked_external` until the owner supplies one.

### AURA-MKT-004-ST-04 — Handle the terms route without conflicting EULA text

This step prevents a public terms page from contradicting the purchase agreement. Publish `/terms` only if the owner has selected custom terms; otherwise link Apple’s official standard EULA from relevant UI/pages, and record the selection for `AURA-LEG-003`.

**Execution**

1. Read the EULA choice in `docs/DECISIONS.md` when available.
2. If custom terms are approved, publish the human-reviewed text at `/terms`.
3. If standard EULA is approved, do not create competing custom terms; use the official URL.

**Expected result and evidence:** Terms routing is consistent with the owner’s EULA choice.

**Failure handling:** Stop for `human_review_required` when EULA choice or legal review is missing.

### AURA-MKT-004-ST-05 — Test every final URL while logged out

This step proves users and App Review—not just the publishing workspace—can reach the pages. Open each final URL in a logged-out private browser on desktop and physical phone; the expected result is public content without login/workspace authorization and with readable mobile layout.

**Execution**

1. Open a fresh private/incognito desktop window and load `/privacy`, `/support`, and `/terms` only when applicable.
2. Repeat on a phone not authenticated to the host workspace.
3. Check HTTPS, no redirects to sign-in, no workspace authorization, no broken assets, readable layout, and canonical URL.

**Expected result and evidence:** Each required URL renders anonymously on desktop and phone.

**Failure handling:** Record failed URL, final redirect, and environment; a logged-in success is not a pass.

### AURA-MKT-004-ST-06 — Capture HTTP and fallback-host evidence

This step creates reproducible reachability evidence and avoids a single-host failure. From repository root, run `curl -I -L '<FINAL_URL>'` for each required URL, save only headers/command/date to the evidence README, and document an owner-approved fallback host; the expected result is public 2xx, final URL, redirect chain, and content type.

**Execution**

1. Replace `<FINAL_URL>` only with a published owner-approved URL; do not run against a placeholder.
2. Run the command from `/Users/pchordia/Documents/other/ios_apps/aurafit`; expect exit code 0 and a final 2xx response.
3. Record status, redirects, final URL, content type, date/time, and fallback plan without access tokens.

**Expected result and evidence:** The evidence index proves anonymous HTTP reachability and documents a replacement route.

**Failure handling:** Non-2xx, auth redirect, or unavailable fallback keeps task `blocked_external`.

### AURA-MKT-004-ST-07 — Record final URLs in canonical release inputs

This step makes subsequent privacy/legal/reviewer work use real URLs rather than placeholders. After all public tests pass, record final URLs in task evidence and update `docs/PRIVACY_POLICY.md`, TestFlight readiness inputs, and App Store Connect tasks through the canonical documentation workflow; the expected result is one consistent set of non-placeholder URLs.

**Execution**

1. Confirm ST-02–06 evidence is complete.
2. Update canonical policy/contact references only with final URLs.
3. Link the evidence index from downstream tasks; do not place preview URLs in release documents.

**Expected result and evidence:** Downstream tasks can use tested, durable URLs.

**Failure handling:** Stop if any URL is transient or mismatched; do not update App Store Connect with it.

## Acceptance criteria

- [ ] Privacy and support pages return public 2xx responses and render logged out.
- [ ] Hosted policy matches in-app/repository policy.
- [ ] Support page has an actual contact route.
- [ ] Owner accepts the longevity and fallback plan.

## Completion and evidence

Use `quality/evidence/testflight/AURA-MKT-004/README.md`; record public URL tests and redacted headers only.

## Stop and reverification conditions

Missing hosting authorization/contact method, login-gated URLs, or no fallback plan keep this task `blocked_external`. Reverify after policy, host, domain, contact route, or terms choice changes.
