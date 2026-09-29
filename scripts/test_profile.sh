#!/bin/sh
# Child output is deliberately private: profile failures release only categories.
set -eu
umask 077

profile=${1:-}
case "$profile" in
  unit|integration) ;;
  *) printf '%s\n' 'CP1_PROFILE_OUTCOME status=failed category=usage' >&2; exit 64 ;;
esac

audit_output=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-audit.XXXXXX")
test_output=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-${profile}.XXXXXX")
sentinel_file=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-sentinel.XXXXXX")
trap 'rm -f "$audit_output" "$test_output" "$sentinel_file"' EXIT HUP INT TERM

safe_failure() {
  printf 'CP1_PROFILE_OUTCOME profile=%s status=failed category=%s\n' "$profile" "$1" >&2
  exit "${2:-1}"
}

preflight_integration() {
  set +e
  node --version >"$audit_output" 2>&1
  node_status=$?
  set -e
  [ "$node_status" -eq 0 ] || safe_failure node-runtime "$node_status"
  grep -Eq '^v24\.' "$audit_output" || safe_failure node-runtime
  [ -f tools/openapi/package-lock.json ] && [ -d tools/openapi/node_modules ] || safe_failure browser-prerequisite

  set +e
  node -e 'const {chromium} = require("./tools/openapi/node_modules/playwright-core"); const fs = require("fs"); const path = chromium.executablePath(); if (!path || !fs.existsSync(path)) process.exit(1); chromium.launch({headless: true, args: ["--no-sandbox"]}).then(browser => browser.close()).catch(() => process.exit(1))' >"$audit_output" 2>&1
  browser_status=$?
  set -e
  [ "$browser_status" -eq 0 ] || safe_failure browser-prerequisite "$browser_status"
}

[ "$profile" = integration ] && preflight_integration

set +e
MIX_ENV=test mix run -e "result = FootballMarket.TestProfileAudit.audit!(\"$profile\"); IO.puts(\"CP1_PROFILE_AUDIT count=#{result.count}\"); Enum.each(result.files, &IO.puts(\"CP1_PROFILE_FILE \" <> &1))" >"$audit_output" 2>&1
audit_status=$?
set -e
[ "$audit_status" -eq 0 ] || safe_failure audit "$audit_status"

audit_count=$(sed -n 's/^CP1_PROFILE_AUDIT count=//p' "$audit_output")
files=$(sed -n 's/^CP1_PROFILE_FILE //p' "$audit_output")
[ -n "$audit_count" ] && [ -n "$files" ] || safe_failure audit

set +e
if [ "${CP1_PROFILE_COVERAGE:-0}" = 1 ]; then
  CP1_PROFILE="$profile" CP1_PROFILE_SENTINEL_PATH="$sentinel_file" MIX_ENV=test mix test --warnings-as-errors --include performance --only "$profile" --cover --export-coverage "$profile" $files >"$test_output" 2>&1
else
  CP1_PROFILE="$profile" CP1_PROFILE_SENTINEL_PATH="$sentinel_file" MIX_ENV=test mix test --warnings-as-errors --include performance --only "$profile" $files >"$test_output" 2>&1
fi
test_status=$?
set -e
[ "$test_status" -eq 0 ] || safe_failure test-failure "$test_status"

grep -Fqx "$profile" "$sentinel_file" || safe_failure incomplete
grep -Eq '([1-9][0-9]* tests|Result: [1-9][0-9]* passed)' "$test_output" || safe_failure incomplete
! grep -Eq '[1-9][0-9]* skipped' "$test_output" || safe_failure skipped
! grep -Fq 'CP1_PROFILE_SECRET_SENTINEL' "$test_output" || safe_failure safe-capture-failure
! grep -Fq 'CP1_PROFILE_HASH_SENTINEL' "$test_output" || safe_failure safe-capture-failure

if [ -n "${CP1_PROFILE_RECEIPT:-}" ]; then
  mkdir -p "$(dirname "$CP1_PROFILE_RECEIPT")"
  printf '{"profile":"%s","audit_count":%s,"status":"complete"}\n' "$profile" "$audit_count" >"$CP1_PROFILE_RECEIPT"
fi

printf 'CP1_PROFILE_RECEIPT profile=%s audit_count=%s status=complete\n' "$profile" "$audit_count"
