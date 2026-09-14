#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
if MIX_ENV=test TEST_DATABASE_NAME=football_market_dev mix infrastructure.database.test_prepare > /tmp/task002-isolation.out 2>&1; then
  echo "unsafe database was accepted" >&2; exit 1
fi
grep -q 'unsafe test database identity' /tmp/task002-isolation.out
echo "database isolation guard: PASS"
