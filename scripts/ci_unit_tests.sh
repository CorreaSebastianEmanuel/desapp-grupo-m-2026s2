#!/bin/sh
set +x
set -eu
# Local toolchain bootstrap for non-interactive agent shells:
# - disable Mix's TCP filesystem lock (fails with :eperm in sandboxes)
# - resolve Node v24 from nvm when it is not already on PATH
export MIX_OS_CONCURRENCY_LOCK="${MIX_OS_CONCURRENCY_LOCK:-0}"
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
for profile in unit integration; do
  rm -f "$receipts/$profile.json"
  if ! CP1_PROFILE_RECEIPT="$receipts/$profile.json" sh scripts/test_profile.sh "$profile" >"$private/output" 2>&1; then
    printf '%s\n' 'CI_PROFILE status=failed category=profile' >&2
    exit 1
  fi
done
python3 scripts/test_profile_components.py verify-receipts "$receipts" >&2
printf '%s\n' FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL >&2
printf '%s\n' '{"schema_version":1,"status":"complete","profiles":["unit","integration"]}'
