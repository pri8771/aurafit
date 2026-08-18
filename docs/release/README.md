# TestFlight Release Copy

These files are the repository-authoritative drafts for `AURA-LEG-008`. Review them against
the exact processed build, then paste the approved content into App Store Connect. App Store
Connect is a delivery copy, not the authoring source.

Fields prefixed `OWNER_REQUIRED` cannot be inferred from source code. The owner must replace
them before external TestFlight submission. Do not add passwords, private keys, tax/banking
data, tester personal data, or Apple session material to this directory.

Before external TestFlight submission, verify that:

1. the build offers no in-app purchases (AuraFit 1.0 is one full, free product — DEC-006), so
   App Store Connect must not list any products for it;
2. every test step works in the exact uploaded build;
3. privacy and support URLs are public without authentication;
4. contact fields reach a monitored person;
5. the version/build tokens are replaced with the processed build’s values; and
6. the required owner approval and the redacted reachability/rights evidence are indexed at
   `quality/evidence/testflight/AURA-LEG-008/README.md`.
