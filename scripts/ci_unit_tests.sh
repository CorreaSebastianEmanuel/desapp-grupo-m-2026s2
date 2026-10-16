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

if ! awk '
  /^[[:space:]]*(Result:|[0-9]+ tests?([,[:space:]]|$))/ {
    line = $0
    sub(/^[[:space:]]*/, "", line)
    sub(/[[:space:]]*$/, "", line)
    valid = 0
    if (line ~ /^Result: [0-9]+\/[0-9]+ passed(, [0-9]+ excluded)?$/) {
      split(line, fields, /[[:space:]\/,]+/)
      valid = (fields[2] + 0 > 0 && fields[2] + 0 == fields[3] + 0)
    } else if (line ~ /^Result: [0-9]+ passed(, [0-9]+ excluded)?$/) {
      split(line, fields, /[[:space:]]+/)
      valid = (fields[2] + 0 > 0)
    } else if (line ~ /^[0-9]+ tests?, 0 failures?(, [0-9]+ (excluded|skipped))*$/) {
      valid = (line + 0 > 0)
    }
  }
  END { exit !valid }
' "$output"; then
  echo "error: nonzero successful unit-test collection was not observed (empty, partial or failed summary)" >&2
  exit 1
fi
