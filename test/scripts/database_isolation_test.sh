#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/database_isolation_test.sh
. "$(dirname "$0")/support/profile_events.sh"
profile_case_start 'database_isolation'
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
if MIX_ENV=test TEST_DATABASE_NAME=football_market_dev mix infrastructure.database.test_prepare > ${TMPDIR:-/tmp}/task002-isolation.out 2>&1; then
  echo "unsafe database was accepted" >&2; exit 1
fi
grep -q 'unsafe test database identity' ${TMPDIR:-/tmp}/task002-isolation.out
echo "database isolation guard: PASS"
profile_case_pass 'database_isolation'
