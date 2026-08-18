#!/usr/bin/env bash
# Validates an AuraFit release candidate before signing or upload.
#
# Required environment:
#   AURAFIT_RULES_PATH             checkout of iOS_app_factory_rules
#   AURAFIT_SIMULATOR_DESTINATION  xcodebuild destination, for example "id=<simulator-id>"
#   AURAFIT_DERIVED_DATA_PATH      empty, caller-owned directory below /tmp
#
# Optional release identity overrides (update after AURA-OPS-011 freezes a new tuple):
#   AURAFIT_EXPECTED_VERSION (default: 1.0)
#   AURAFIT_EXPECTED_BUILD   (default: 3)
#
# Output: release-candidate-{test,build}.log, AuraFit-tests.xcresult, test-summary.json,
# and an unsigned Release AuraFit.app below AURAFIT_DERIVED_DATA_PATH.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
readonly REPO_ROOT
readonly EXPECTED_BUNDLE_ID="com.pchordia.aurafit"
readonly EXPECTED_DISPLAY_NAME="AuraFit"
readonly EXPECTED_MINIMUM_OS="18.0"
readonly EXPECTED_CATEGORY="public.app-category.lifestyle"
readonly EXPECTED_CAMERA_USAGE="AuraFit uses the camera to capture your full-body fit photo for on-device analysis. Photos never leave your device."
readonly EXPECTED_PHOTOS_ADD_USAGE="AuraFit saves your generated scorecards and reveal clips to your photo library."
readonly EXPECTED_VERSION="${AURAFIT_EXPECTED_VERSION:-1.0}"
readonly EXPECTED_BUILD="${AURAFIT_EXPECTED_BUILD:-3}"
readonly EXPECTED_TEST_COUNT=94

usage() {
  cat <<'USAGE'
Usage:
  AURAFIT_RULES_PATH=/absolute/path/to/iOS_app_factory_rules \
  AURAFIT_SIMULATOR_DESTINATION='id=<simulator-id>' \
  AURAFIT_DERIVED_DATA_PATH=/tmp/aurafit-release-candidate \
  bash scripts/release_candidate_check.sh

Required inputs are deliberately explicit: the command never chooses a rules checkout,
simulator, device UDID, signing identity, or derived-data location. The supplied derived-data
directory must be an empty directory under /tmp; it is preserved on success and failure.

Optional identity inputs:
  AURAFIT_EXPECTED_VERSION  frozen CFBundleShortVersionString (default: 1.0)
  AURAFIT_EXPECTED_BUILD    frozen CFBundleVersion (default: 3)

Success marker: RELEASE_CANDIDATE_GATE=PASS
Failure classes: source_failure, verification_pending, or configuration_failure.
USAGE
}

die() {
  local classification="$1"
  shift
  printf 'RELEASE_CANDIDATE_GATE=%s: %s\n' "$classification" "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die configuration_failure "Required command is unavailable: $1"
}

require_nonempty_environment() {
  local name="$1"
  [[ -n "${!name:-}" ]] || die configuration_failure "Required environment variable is empty: $name"
}

relative_path() {
  local path="$1"
  printf '%s\n' "${path#"$REPO_ROOT"/}"
}

run_logged() {
  local log_path="$1"
  shift
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  if ! "$@" 2>&1 | tee "$log_path"; then
    die source_failure "Command failed; inspect $log_path"
  fi
}

run_xcodebuild_logged() {
  local log_path="$1"
  shift
  printf '+ '
  printf '%q ' "$@"
  printf '\n'
  if "$@" 2>&1 | tee "$log_path"; then
    return
  fi
  if rg -q 'CoreSimulatorService|Simulator services will no longer be available|simdiskimaged|Unable to discover any Simulator runtimes' "$log_path"; then
    die verification_pending "Xcode infrastructure failed; inspect $log_path"
  fi
  die source_failure "xcodebuild failed; inspect $log_path"
}

find_rules_verifier() {
  local -a matches=()
  while IFS= read -r path; do
    matches+=("$path")
  done < <(find "$AURAFIT_RULES_PATH" -maxdepth 5 -type f \( \
    -name 'verify_project_registration.rb' -o \
    -name 'verify-project-registration.rb' -o \
    -name 'verify_project_registration.sh' -o \
    -name 'verify-project-registration.sh' \
  \) -print | sort)

  [[ ${#matches[@]} -eq 1 ]] || die verification_pending \
    "Expected exactly one canonical project-registration verifier under AURAFIT_RULES_PATH; found ${#matches[@]}. Set AURAFIT_RULES_PATH to the rules checkout containing verify_project_registration."
  printf '%s\n' "${matches[0]}"
}

validate_json() {
  local -a json_paths=(
    "$REPO_ROOT/.factory"/*.json
    "$REPO_ROOT/quality/quality-manifest.json"
  )
  while IFS= read -r path; do
    json_paths+=("$path")
  done < <(find "$REPO_ROOT/quality/feature-contracts" "$REPO_ROOT/quality/completion-reports" -type f -name '*.json' -print | sort)

  local count=0 path
  for path in "${json_paths[@]}"; do
    [[ -f "$path" ]] || die source_failure "Governed JSON input is missing: $(relative_path "$path")"
    if ! python3 -c 'import json, pathlib, sys; json.load(pathlib.Path(sys.argv[1]).open())' "$path"; then
      die source_failure "Invalid governed JSON: $(relative_path "$path")"
    fi
    ((count += 1))
  done
  printf 'GOVERNED_JSON=PASS count=%d\n' "$count"
}

find_single_privacy_manifest() {
  local -a manifests=()
  while IFS= read -r path; do
    manifests+=("$path")
  done < <(find "$REPO_ROOT/AuraFit" -type f -name 'PrivacyInfo.xcprivacy' -print | sort)
  [[ ${#manifests[@]} -eq 1 ]] || die source_failure \
    "Expected exactly one release PrivacyInfo.xcprivacy under AuraFit; found ${#manifests[@]}"
  printf '%s\n' "${manifests[0]}"
}

plist_value() {
  /usr/libexec/PlistBuddy -c "Print :$2" "$1" 2>/dev/null || true
}

require_plist_value() {
  local plist="$1" key="$2" expected="$3"
  local actual
  actual="$(plist_value "$plist" "$key")"
  [[ "$actual" == "$expected" ]] || die source_failure \
    "Bundle Info.plist $key must be '$expected'; found '${actual:-<missing>}'"
  printf 'BUNDLE_CHECK=PASS %s=%s\n' "$key" "$actual"
}

require_false_plist_value() {
  local plist="$1" key="$2"
  local actual
  actual="$(plist_value "$plist" "$key")"
  case "$actual" in
    0|NO|false) printf 'BUNDLE_CHECK=PASS %s=%s\n' "$key" "$actual" ;;
    *) die source_failure "Bundle Info.plist $key must be false; found '${actual:-<missing>}'" ;;
  esac
}

audit_privacy_manifest() {
  local manifest="$1"
  if ! plutil -lint "$manifest"; then
    die source_failure "Privacy manifest does not parse: $manifest"
  fi
  python3 - "$manifest" <<'PY'
import plistlib
import sys

with open(sys.argv[1], "rb") as source:
    manifest = plistlib.load(source)
entries = manifest.get("NSPrivacyAccessedAPITypes", [])
if not any(
    entry.get("NSPrivacyAccessedAPIType") == "NSPrivacyAccessedAPICategoryFileTimestamp"
    and "C617.1" in entry.get("NSPrivacyAccessedAPITypeReasons", [])
    for entry in entries
):
    raise SystemExit("Missing required NSPrivacyAccessedAPICategoryFileTimestamp reason C617.1")
PY
  printf 'PRIVACY_MANIFEST=PASS path=%s required_reason=C617.1\n' "$manifest"
}

find_single_release_app() {
  local -a apps=()
  while IFS= read -r path; do
    apps+=("$path")
  done < <(find "$AURAFIT_DERIVED_DATA_PATH/Build/Products" -type d -path '*/Release-iphoneos/AuraFit.app' -print | sort)
  [[ ${#apps[@]} -eq 1 ]] || die source_failure \
    "Expected exactly one Release AuraFit.app under derived data; found ${#apps[@]}"
  printf '%s\n' "${apps[0]}"
}

# DEC-006 (2026-08-18): AuraFit 1.0 is one full, free product. The app target may not carry
# tier vocabulary or any StoreKit surface. Mirrors `FullFreeProductTests` so the gate fails
# even when the test target is not the thing being edited.
audit_no_tier_source() {
  local -a forbidden_paths=(
    "$REPO_ROOT/AuraFit/Features/Paywall"
    "$REPO_ROOT/AuraFit/Services/Store"
    "$REPO_ROOT/AuraFit/Resources/AuraFit.storekit"
  )
  local path
  for path in "${forbidden_paths[@]}"; do
    [[ ! -e "$path" ]] || die source_failure "Tier surface must not exist: $(relative_path "$path")"
  done
  if rg -q -i 'storekit' "$REPO_ROOT/AuraFit.xcodeproj/project.pbxproj" "$REPO_ROOT/AuraFit.xcodeproj/xcshareddata/xcschemes/AuraFit.xcscheme"; then
    die source_failure "Xcode project or scheme still references StoreKit"
  fi
  local matches
  matches="$(rg -n -i \
    -e 'paywall' -e 'premium' -e 'upgrade' -e 'subscription' -e 'subscribe' -e 'purchase' \
    -e 'entitlement' -e 'quota' -e 'storekit' -e 'freemium' -e 'watermark' -e 'free plan' \
    -e 'free scan' -e 'in-app purchase' -e 'unlock all' -e 'go pro' -e 'restore purchases' \
    --glob '*.swift' --glob '*.xcprivacy' --glob '*.json' --glob '*.plist' --glob '*.strings' --glob '*.xcstrings' \
    "$REPO_ROOT/AuraFit" || true)"
  local pro_matches
  pro_matches="$(rg -n -w 'Pro' --glob '*.swift' --glob '*.xcprivacy' "$REPO_ROOT/AuraFit" || true)"
  if [[ -n "$matches$pro_matches" ]]; then
    printf 'FORBIDDEN_TIER_VOCABULARY:\n%s\n%s\n' "$matches" "$pro_matches" >&2
    die source_failure "App target contains tier vocabulary (DEC-006)"
  fi
  printf 'NO_TIER_SOURCE=PASS\n'
}

audit_forbidden_bundle_content() {
  local app_path="$1"
  local -a forbidden_paths=()
  while IFS= read -r path; do
    forbidden_paths+=("$path")
  done < <(find "$app_path" \( \
    -name '*.storekit' -o -name '*.mlmodel' -o -name '*.mlmodelc' -o -name '*.mlpackage' -o \
    -name '*.tflite' -o -name '*.onnx' -o -name '*.xctest' -o -path '*/Preview Content/*' \
  \) -print | sort)
  if [[ ${#forbidden_paths[@]} -gt 0 ]]; then
    printf 'FORBIDDEN_BUNDLE_PATHS:\n' >&2
    for path in "${forbidden_paths[@]}"; do
      relative_path "$path" >&2
    done
    die source_failure "Release bundle contains forbidden StoreKit, model, preview, or test content"
  fi

  local debug_matches
  debug_matches="$(rg -a -n -- '-UITestStubVision|UITestVisionStub' "$app_path" || true)"
  if [[ -n "$debug_matches" ]]; then
    printf 'FORBIDDEN_DEBUG_CONTENT:\n%s\n' "$debug_matches" >&2
    die source_failure "Release bundle contains DEBUG launch arguments or stub strings"
  fi

  # DEC-006: no StoreKit linkage and no tier symbols/strings may reach the shipped binary.
  local binary="$app_path/AuraFit"
  [[ -f "$binary" ]] || die source_failure "Release bundle has no main executable: $binary"
  if otool -L "$binary" | rg -q -i 'StoreKit'; then
    die source_failure "Release binary links StoreKit"
  fi
  local tier_matches
  tier_matches="$(rg -a -n -i -- 'PaywallView|PaywallContext|EntitlementManager|StoreKitService|ProductCatalog|PurchaseProviding|com\.aurafit\.pro\.|com\.aurafit\.template\.|freeDailyScanLimit|AuraFit Pro|Upgrade to Pro|Restore Purchases' "$app_path" || true)"
  if [[ -n "$tier_matches" ]]; then
    printf 'FORBIDDEN_TIER_CONTENT:\n%s\n' "$tier_matches" >&2
    die source_failure "Release bundle contains tier/StoreKit strings (DEC-006)"
  fi
  printf 'BUNDLE_EXCLUSIONS=PASS no_storekit_link=1 no_tier_strings=1\n'
}

classify_build_warnings() {
  local build_log="$1"
  local warnings_file="$AURAFIT_DERIVED_DATA_PATH/build-warnings.txt"
  grep -E 'warning:|WARNING:' "$build_log" > "$warnings_file" || true
  if [[ ! -s "$warnings_file" ]]; then
    printf 'SOURCE_WARNINGS=PASS count=0\n'
    printf 'INFRASTRUCTURE_WARNINGS=none\n'
    return
  fi

  local source_file="$AURAFIT_DERIVED_DATA_PATH/source-warnings.txt"
  local infrastructure_file="$AURAFIT_DERIVED_DATA_PATH/infrastructure-warnings.txt"
  local unclassified_file="$AURAFIT_DERIVED_DATA_PATH/unclassified-warnings.txt"
  : > "$source_file"
  : > "$infrastructure_file"
  : > "$unclassified_file"

  local line
  while IFS= read -r line; do
    if [[ "$line" =~ (AuraFit|AuraFitTests|AuraFitUITests)/.*:[0-9]+:[0-9]+:.*warning: ]]; then
      printf '%s\n' "$line" >> "$source_file"
    elif [[ "$line" =~ CoreSimulatorService|simdiskimaged|DVT|ProvisioningProfile|xcodebuild.*(connection\ invalid|Simulator\ services\ will\ no\ longer\ be\ available) ]]; then
      printf '%s\n' "$line" >> "$infrastructure_file"
    elif [[ "$line" =~ appintentsmetadataprocessor.*No\ AppIntents\.framework\ dependency\ found ]]; then
      # Xcode 26 toolchain notice emitted for every app that does not adopt App Intents; it is
      # not a compiler diagnostic and does not originate from repository source.
      printf '%s\n' "$line" >> "$infrastructure_file"
    else
      printf '%s\n' "$line" >> "$unclassified_file"
    fi
  done < "$warnings_file"

  if [[ -s "$infrastructure_file" ]]; then
    printf 'INFRASTRUCTURE_WARNINGS:\n'
    cat "$infrastructure_file"
  else
    printf 'INFRASTRUCTURE_WARNINGS=none\n'
  fi
  if [[ -s "$source_file" ]]; then
    printf 'SOURCE_WARNINGS:\n' >&2
    cat "$source_file" >&2
    die source_failure "Compiler warnings originated from repository source paths"
  fi
  if [[ -s "$unclassified_file" ]]; then
    printf 'UNCLASSIFIED_WARNINGS:\n' >&2
    cat "$unclassified_file" >&2
    die verification_pending "Warnings require classification before this gate can pass"
  fi
  printf 'SOURCE_WARNINGS=PASS count=0\n'
}

validate_inputs() {
  require_nonempty_environment AURAFIT_RULES_PATH
  require_nonempty_environment AURAFIT_SIMULATOR_DESTINATION
  require_nonempty_environment AURAFIT_DERIVED_DATA_PATH
  [[ -d "$AURAFIT_RULES_PATH" ]] || die configuration_failure "AURAFIT_RULES_PATH is not a directory: $AURAFIT_RULES_PATH"
  [[ "$AURAFIT_DERIVED_DATA_PATH" == /tmp/* ]] || die configuration_failure \
    "AURAFIT_DERIVED_DATA_PATH must be a caller-owned path below /tmp: $AURAFIT_DERIVED_DATA_PATH"
  [[ "$AURAFIT_DERIVED_DATA_PATH" != /tmp/ ]] || die configuration_failure "Refusing to use /tmp itself as derived data"
  if [[ -e "$AURAFIT_DERIVED_DATA_PATH" ]] && [[ -n "$(find "$AURAFIT_DERIVED_DATA_PATH" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    die configuration_failure "AURAFIT_DERIVED_DATA_PATH must be empty to preserve prior artifacts: $AURAFIT_DERIVED_DATA_PATH"
  fi
  mkdir -p "$AURAFIT_DERIVED_DATA_PATH"
  require_command find
  require_command otool
  require_command plutil
  require_command python3
  require_command rg
  require_command tee
  require_command xcodebuild
  require_command xcrun
}

main() {
  case "${1:-}" in
    -h|--help) usage; exit 0 ;;
    '') ;;
    *) usage >&2; die configuration_failure "Unknown argument: $1" ;;
  esac

  validate_inputs
  cd "$REPO_ROOT"
  printf 'RELEASE_CANDIDATE_GATE=START repo=%s derived_data=%s\n' "$REPO_ROOT" "$AURAFIT_DERIVED_DATA_PATH"

  local verifier privacy_manifest test_log build_log result_path summary_path app_path
  verifier="$(find_rules_verifier)"
  printf 'APP_FACTORY_VERIFIER=%s\n' "$verifier"
  case "$verifier" in
    *.rb) run_logged "$AURAFIT_DERIVED_DATA_PATH/app-factory-verifier.log" ruby "$verifier" "$REPO_ROOT" ;;
    *) run_logged "$AURAFIT_DERIVED_DATA_PATH/app-factory-verifier.log" "$verifier" "$REPO_ROOT" ;;
  esac
  printf 'APP_FACTORY=PASS\n'
  validate_json

  privacy_manifest="$(find_single_privacy_manifest)"
  audit_privacy_manifest "$privacy_manifest"
  audit_no_tier_source

  test_log="$AURAFIT_DERIVED_DATA_PATH/release-candidate-test.log"
  result_path="$AURAFIT_DERIVED_DATA_PATH/AuraFit-tests.xcresult"
  summary_path="$AURAFIT_DERIVED_DATA_PATH/test-summary.json"
  [[ ! -e "$result_path" ]] || die configuration_failure "Result bundle already exists: $result_path"
  run_xcodebuild_logged "$test_log" xcodebuild test \
    -project AuraFit.xcodeproj \
    -scheme AuraFit \
    -configuration Debug \
    -destination "$AURAFIT_SIMULATOR_DESTINATION" \
    -derivedDataPath "$AURAFIT_DERIVED_DATA_PATH" \
    -resultBundlePath "$result_path"
  if ! xcrun xcresulttool get test-results summary --path "$result_path" --compact > "$summary_path"; then
    die verification_pending "Unable to read the test result bundle: $result_path"
  fi
  if ! python3 - "$summary_path" "$EXPECTED_TEST_COUNT" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as source:
    result = json.load(source)
expected = int(sys.argv[2])
actual = (result.get("totalTestCount"), result.get("passedTests"), result.get("failedTests"), result.get("skippedTests"))
required = (expected, expected, 0, 0)
if actual != required:
    raise SystemExit(f"Expected total/passed/failed/skipped {required}; got {actual}")
PY
  then
    die source_failure "Test summary did not report the required ${EXPECTED_TEST_COUNT}/0/0 result; inspect $summary_path"
  fi
  printf 'TESTS=PASS total=%s passed=%s failed=0 skipped=0 xcresult=%s\n' \
    "$EXPECTED_TEST_COUNT" "$EXPECTED_TEST_COUNT" "$result_path"

  build_log="$AURAFIT_DERIVED_DATA_PATH/release-candidate-build.log"
  run_xcodebuild_logged "$build_log" xcodebuild build \
    -project AuraFit.xcodeproj \
    -scheme AuraFit \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$AURAFIT_DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO
  classify_build_warnings "$build_log"
  app_path="$(find_single_release_app)"
  printf 'RELEASE_APP=%s\n' "$app_path"

  local app_info app_privacy_manifest
  app_info="$app_path/Info.plist"
  app_privacy_manifest="$app_path/PrivacyInfo.xcprivacy"
  [[ -f "$app_info" ]] || die source_failure "Release bundle has no Info.plist: $app_info"
  [[ -f "$app_privacy_manifest" ]] || die source_failure "Release bundle has no root PrivacyInfo.xcprivacy: $app_privacy_manifest"
  require_plist_value "$app_info" CFBundleIdentifier "$EXPECTED_BUNDLE_ID"
  require_plist_value "$app_info" CFBundleDisplayName "$EXPECTED_DISPLAY_NAME"
  require_plist_value "$app_info" CFBundleShortVersionString "$EXPECTED_VERSION"
  require_plist_value "$app_info" CFBundleVersion "$EXPECTED_BUILD"
  require_plist_value "$app_info" MinimumOSVersion "$EXPECTED_MINIMUM_OS"
  require_plist_value "$app_info" LSApplicationCategoryType "$EXPECTED_CATEGORY"
  require_plist_value "$app_info" NSCameraUsageDescription "$EXPECTED_CAMERA_USAGE"
  require_plist_value "$app_info" NSPhotoLibraryAddUsageDescription "$EXPECTED_PHOTOS_ADD_USAGE"
  require_false_plist_value "$app_info" ITSAppUsesNonExemptEncryption
  audit_privacy_manifest "$app_privacy_manifest"
  audit_forbidden_bundle_content "$app_path"

  printf 'RELEASE_CANDIDATE_GATE=PASS test_log=%s build_log=%s xcresult=%s app=%s\n' \
    "$test_log" "$build_log" "$result_path" "$app_path"
}

main "$@"
