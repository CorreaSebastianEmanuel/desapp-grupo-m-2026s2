#!/bin/sh
set +x
set -eu
# Local toolchain bootstrap for non-interactive agent shells:
# - disable Mix's TCP filesystem lock (fails with :eperm in sandboxes)
# - resolve Node v24 from nvm when it is not already on PATH
export MIX_OS_CONCURRENCY_LOCK="${MIX_OS_CONCURRENCY_LOCK:-0}"
# Coverage/authority tests (TASK-067) require a flat, non-symlinked TMPDIR;
# the macOS default (/var/folders/...) resolves through /private/var.
if [ -z "${CI_KEEP_TMPDIR:-}" ]; then
  mkdir -p "$(pwd)/tmp" 2>/dev/null && TMPDIR="$(pwd)/tmp"
  export TMPDIR
fi
if ! command -v node >/dev/null 2>&1 || ! node --version 2>/dev/null | grep -Eq '^v24\.'; then
  for d in "$HOME"/.nvm/versions/node/v24*/bin; do
    if [ -d "$d" ]; then PATH="$d:$PATH"; break; fi
  done
fi
export PATH
umask 077
private=$(mktemp -d "${TMPDIR:-/tmp}/profile-ci.XXXXXX")
trap 'rm -rf "$private"' EXIT HUP INT TERM
receipts=${CI_PROFILE_RECEIPTS:-$private/receipts}
mkdir -p "$receipts"
profile_filter=${1:-}
case "$profile_filter" in
  '') ;;
  unit|integration) ;;
  *) printf '%s\n' 'usage: ci_unit_tests.sh [unit|integration]' >&2; exit 64 ;;
esac
for profile in unit integration; do
  if [ -n "$profile_filter" ] && [ "$profile_filter" != "$profile" ]; then
    continue
  fi
  rm -f "$receipts/$profile.json"
  if ! CP1_PROFILE_RECEIPT="$receipts/$profile.json" sh scripts/test_profile.sh "$profile" >"$private/output" 2>&1; then
    # Surface only fail-closed profile metadata; never print raw child output.
    python3 - "$private/output" "$profile" <<'PY'
import pathlib
import re
import sys

profile = sys.argv[2]

for line in pathlib.Path(sys.argv[1]).read_text(errors="replace").splitlines():
    if re.fullmatch(r"PROFILE_DISCREPANCY id=[0-9a-f]{24}(?: line=[0-9]+)?", line):
        print(line, file=sys.stderr)
    elif re.fullmatch(r"PROFILE_CASE_DIAGNOSTIC id=[0-9a-f]{24} runner=(?:python|node|shell|exunit) file=test/[A-Za-z0-9_./-]{1,220} case=(?:test(?:\.[A-Za-z0-9_]+)+|redacted) state=(?:failed|skipped|incomplete) cause=(?:assertion|error|skipped|incomplete) line=[0-9]{1,8} exception=(?:none|unknown|[A-Za-z][A-Za-z0-9]{0,39}) comparison=(?:none|-?[0-9]{1,9}:-?[0-9]{1,9}) started=[0-9]{1,8} passed=[0-9]{1,8} failed=[0-9]{1,8} skipped=[0-9]{1,8}", line) and '..' not in pathlib.PurePosixPath(line.split(' file=', 1)[1].split(' case=', 1)[0]).parts:
        print(line, file=sys.stderr)
    elif re.fullmatch(r"PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=[a-z-]+", line):
        print(line, file=sys.stderr)
    elif re.fullmatch(r"PROFILE_BROWSER_DIAGNOSTIC cause=(?:node-unavailable|node-incompatible|playwright-missing|bundled-chromium-missing|chromium-launch-failed|chromium-launch-timeout) stage=(?:integration|e2e)", line):
        print(line, file=sys.stderr)
    elif re.fullmatch(r"PROFILE_MEMBERSHIP_DIAGNOSTIC profile=(?:unit|integration|e2e) phase=(?:committed-file-audit|nonce-validation|event-reconciliation|coverage-audit) reason=(?:invalid-shape|duplicate-files|outside-profile|nonce-mismatch|empty-expected|extra-events|unexpected-state|missing-events|duplicate-events|missing-sidecar|missing-partition|partition-mismatch|missing-export) expected=[0-9]{1,8} observed=[0-9]{1,8} missing_started=[0-9]{1,8} missing_passed=[0-9]{1,8} extra=[0-9]{1,8} duplicate=[0-9]{1,8} invalid_state=[0-9]{1,8} wrong_nonce=[0-9]{1,8}", line):
        print(line, file=sys.stderr)
    elif re.fullmatch(r"PROFILE_MEMBERSHIP_EXTRA profile=(?:unit|integration|e2e) runner=(?:exunit|python|node|shell) file=(?:test|tools)/[A-Za-z0-9_./-]{1,220}", line) and '..' not in pathlib.PurePosixPath(line.split(' file=', 1)[1]).parts:
        print(line, file=sys.stderr)
    elif re.fullmatch(r"CP1_PROFILE_OUTCOME status=failed category=[a-z-]+", line):
        category = line.split("category=", 1)[1]
        print(f"CI_PROFILE_DIAGNOSTIC profile={profile} category={category}", file=sys.stderr)
        print(line, file=sys.stderr)
    elif re.fullmatch(r"PROFILE_STEP_DIAGNOSTIC profile=(?:unit|integration|e2e) step=(?:prepare|tests|audit|cleanup|component) partition=(?:regular|committed-[0-9]{1,3}|unknown)", line):
        print(line, file=sys.stderr)
PY
    # Durable, opt-in capture so workflow-runner failures keep their profile evidence.
    if [ -n "${CI_PROFILE_LOG_DIR:-}" ]; then
      mkdir -p "$CI_PROFILE_LOG_DIR" && cp "$private/output" "$CI_PROFILE_LOG_DIR/$profile.log"
    fi
    printf 'CI_PROFILE_DIAGNOSTIC profile=%s category=profile\n' "$profile" >&2
    printf '%s\n' 'CI_PROFILE status=failed category=profile' >&2
    exit 1
  fi
done
profiles='unit integration'
if [ -n "$profile_filter" ]; then
  profiles="$profile_filter"
fi

profiles_json=$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1:]))' $profiles)

python3 scripts/test_profile_components.py verify-receipts "$receipts" $profiles >&2
printf '%s\n' FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL >&2
printf '%s\n' "{\"schema_version\":1,\"status\":\"complete\",\"profiles\":$profiles_json}"
