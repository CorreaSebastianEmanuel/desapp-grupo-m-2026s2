#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
file=$root/compose.yaml
[ "$(grep -c '^  [a-z].*:$' "$file")" -ge 2 ]
[ "$(grep -c 'image: .*@sha256:[0-9a-f]\{64\}' "$file")" -eq 2 ]
[ "$(grep -c '127.0.0.1:' "$file")" -eq 2 ]
grep -q '^name: football_market_local$' "$file"
grep -q 'healthcheck:' "$file"
echo "compose contract: PASS"
