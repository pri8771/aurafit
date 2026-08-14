---
id: AURA-OPS-012A
title: Configure signing and install a Release build on a physical device
gate: TF-G1
status: human_review_required
ownerBoundary: Owner + agent + iPhone
dependsOn: [AURA-OPS-010, AURA-OPS-011]
evidence: quality/evidence/testflight/AURA-OPS-012A/README.md
lastVerified: 2026-08-13
parent: ../../TESTFLIGHT_READINESS.md
---

# AURA-OPS-012A — Configure signing and install a Release build on a physical device

## Task description

This task proves the real Release configuration signs, installs, and launches on hardware. We use the explicit App ID and team, a trusted Developer-Mode iPhone, and inspect the installed entitlement/profile metadata because simulator/Debug runs cannot establish signing or runtime parity. The expected result is a Release install with application identifier `796XH483R4.com.pchordia.aurafit`, no injected local StoreKit configuration, and redacted signing evidence.

## Preconditions and inputs

- AURA-OPS-010/011 complete; current version/build frozen.
- Owner-authorized Apple signing account, supported iPhone, `OWNER_REQUIRED_PHYSICAL_DEVICE_UDID`.
- No certificate, profile, device ID, or raw entitlement/profile output may enter Git.

## Subtasks

### AURA-OPS-012A-ST-01 — Confirm target signing configuration

Set the target to the correct team and automatic signing before device build, because mismatched identifiers/profiles fail install. In Xcode → AuraFit target → Signing & Capabilities, select team `796XH483R4`, automatic signing, and explicit `com.pchordia.aurafit`; do not add capabilities. Expected result: visible target configuration matches Apple evidence.

**Execution**

1. Open the target Signing & Capabilities pane and record team, bundle ID, automatic-signing state, and enabled capability names.
2. Compare capability names to AURA-OPS-010 evidence; request owner review instead of enabling unknown capabilities.

**Expected result and evidence:** Redacted settings checklist is recorded.

**Failure handling:** Wrong team/ID/capability mismatch is `blocked_external` or `human_review_required`; stop before build.

### AURA-OPS-012A-ST-02 — Prepare the physical iPhone

Prepare a trusted, supported device so Xcode can provision and deploy a real Release binary. Expected result: iPhone is connected, unlocked, trusts the Mac, has Developer Mode enabled, and appears in Xcode with the supplied UDID.

**Execution**

1. Connect via cable, unlock it, accept trust prompts, and enable Developer Mode in Settings → Privacy & Security → Developer Mode if required.
2. In Xcode → Window → Devices and Simulators, verify device availability; record model/iOS version and a redacted device label, not UDID.

**Expected result and evidence:** Hardware environment is recorded.

**Failure handling:** Unregistered/untrusted/unsupported device is `blocked_external`; do not substitute simulator evidence.

### AURA-OPS-012A-ST-03 — Build Release for the selected device

Build the Release configuration on the physical destination to prove actual signing. Expected result: command exits 0 and writes only derived products/logs under `/tmp/AuraFit-DeviceRelease`.

**Execution**

1. From repository root run `xcodebuild build -project AuraFit.xcodeproj -scheme AuraFit -configuration Release -destination 'id=<OWNER_REQUIRED_PHYSICAL_DEVICE_UDID>' -derivedDataPath /tmp/AuraFit-DeviceRelease -allowProvisioningUpdates`.
2. Capture output in `/tmp/AuraFit-DeviceRelease/build.log`; require exit 0 and record Xcode version and frozen tuple.

**Expected result and evidence:** Release build succeeds for physical device.

**Failure handling:** Certificate/profile/device/team/application-ID errors are `blocked_external`; resolve signing rather than changing bundle identity.

### AURA-OPS-012A-ST-04 — Install and launch without local StoreKit injection

Install and launch the Release product to prove it is not relying on Debug-only behavior. Expected result: app opens on iPhone with frozen version/build and the active Run action has no `AuraFit.storekit` injection; a dedicated Release run scheme may be used without deleting the Debug developer scheme.

**Execution**

1. Deploy the successful build through Xcode, open AuraFit, and inspect in-app version/build or installed app metadata.
2. In Edit Scheme → Run → Options, verify StoreKit Configuration is empty for this Release run; if not, create/use a dedicated Release scheme with no StoreKit file.

**Expected result and evidence:** Install/launch result, version/build, scheme name, and StoreKit-disabled state are recorded.

**Failure handling:** Debug build, injected StoreKit, or launch failure is `source_failure`/`blocked_external`; do not treat a Debug install as a pass.

### AURA-OPS-012A-ST-05 — Inspect signing and embedded profile safely

Inspect installed/build product signing metadata to prove the application identifier and entitlement set are correct without leaking provisioning data. Expected result: team `796XH483R4`, application identifier `796XH483R4.com.pchordia.aurafit`, profile expiration, and entitlement names are recorded.

**Execution**

1. Copy any raw profile/entitlement inspection output to `/tmp/AuraFit-DeviceRelease/`; use Xcode/`codesign`/`security cms` only against local artifacts and do not commit output.
2. Record only team ID, application identifier, profile expiration date, and entitlement names in `quality/evidence/testflight/AURA-OPS-012A/README.md`.

**Expected result and evidence:** Redacted signing proof is present.

**Failure handling:** Wrong identifier/profile or missing entitlement is `blocked_external`; resolve signing/capability mismatch and rebuild.

## Acceptance criteria

- [ ] Release build signed by team `796XH483R4` installs and launches on supported iPhone.
- [ ] Embedded application identifier is `796XH483R4.com.pchordia.aurafit`.
- [ ] No local StoreKit configuration or DEBUG-only path is active.

## Completion and evidence

Evidence belongs at `quality/evidence/testflight/AURA-OPS-012A/README.md`.

## Stop and reverification conditions

Expired/missing certificate, profile mismatch, unregistered device, wrong team/identifier, or capability mismatch blocks the task. Any signing, entitlement, bundle, scheme, version/build, or source change requires a new Release install.
