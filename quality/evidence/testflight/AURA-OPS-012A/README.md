# AURA-OPS-012A evidence — physical Release install runbook

- **2026-08-18 update:** the archive half is complete for `1.0 (3)` (the signed archive was uploaded,
  processed, and submitted the same day). The **on-device install/launch/signing-inspection half
  was not run and was consciously waived by the owner for the 1.0 submission on 2026-08-18**
  (DEC-007, `quality/waivers/1.0-3-device-qa-owner-waiver-2026-08-18.md`). It remains open, not
  done, for any later build.

- Status: `blocked_external`; requires completed OPS-010/011, authorized signing, and a supported iPhone.
- Expected identity: team `796XH483R4`; application identifier `796XH483R4.com.pchordia.aurafit`; frozen version/build from OPS-011. Never commit UDID, certificate, profile, raw entitlement, or raw inspection output.

## Subtask checklist

- [ ] `AURA-OPS-012A-ST-01` — Xcode → AuraFit target → Signing & Capabilities: record team, exact bundle ID, automatic-signing state, and capability names. Compare to OPS-010; do not add a capability. Wrong team/ID: blocked; unknown capability: `human_review_required`.
- [ ] `AURA-OPS-012A-ST-02` — Cable-connect/unlock/trust supported iPhone; enable Developer Mode if iOS requests it. Xcode → Window → Devices and Simulators must show it. Record model, iOS, redacted label, not UDID. Untrusted/unregistered/unsupported: blocked; simulator is not substitution.
- [ ] `AURA-OPS-012A-ST-03` — From root run `xcodebuild build -project AuraFit.xcodeproj -scheme AuraFit -configuration Release -destination 'id=<OWNER_REQUIRED_PHYSICAL_DEVICE_UDID>' -derivedDataPath /tmp/AuraFit-DeviceRelease -allowProvisioningUpdates 2>&1 | tee /tmp/AuraFit-DeviceRelease/build.log`. Require exit 0; record Xcode/version/build/log path. Certificate/profile/device/team/App-ID error: blocked; do not alter identity.
- [ ] `AURA-OPS-012A-ST-04` — Deploy this product via Xcode, launch AuraFit, and record installed version/build and scheme name. Edit Scheme → Run → Options must show StoreKit Configuration empty; use a dedicated Release scheme if needed, without deleting Debug scheme. Debug install, injected StoreKit, or launch failure is not a pass.
- [ ] `AURA-OPS-012A-ST-05` — Inspect local signed product only; keep raw `codesign`/`security cms` results in `/tmp/AuraFit-DeviceRelease`. Record only team, application identifier, profile expiration, entitlement names. Wrong/missing value: blocked and rebuild after correction.

```text
device model / iOS / redacted label:
team / bundle / automatic signing / capabilities:
Release command / exit / build log:
installed version/build / scheme / StoreKit Configuration empty:
application identifier / profile expiration / entitlement names:
blocker:
```

Re-run after signing, entitlement, bundle, scheme, version/build, or source changes. Acceptance requires a real supported-iPhone Release launch, correct identifier, and no local StoreKit/DEBUG path.
