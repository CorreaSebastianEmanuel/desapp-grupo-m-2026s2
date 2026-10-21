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
    # Durable, opt-in capture so workflow-runner failures keep their profile evidence.
    if [ -n "${CI_PROFILE_LOG_DIR:-}" ]; then
      mkdir -p "$CI_PROFILE_LOG_DIR" && cp "$private/output" "$CI_PROFILE_LOG_DIR/$profile.log"
    fi
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
