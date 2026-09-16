#!/bin/sh
set -eu

marker=FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL
output=$(mktemp "${TMPDIR:-/tmp}/football-market-ci-tests.XXXXXX")
trap 'rm -f "$output"' EXIT HUP INT TERM

set +e
MIX_ENV=test mix test --warnings-as-errors >"$output" 2>&1
test_status=$?
set -e

cat "$output"

if [ "$test_status" -ne 0 ]; then
  exit "$test_status"
fi

if ! grep -Fqx "$marker" "$output"; then
  echo "error: complete unit-test discovery marker was not observed" >&2
  exit 1
fi
