#!/bin/sh
set +x
set -eu
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
python3 scripts/test_profile_components.py verify-receipts "$receipts"
printf '%s\n' FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL
