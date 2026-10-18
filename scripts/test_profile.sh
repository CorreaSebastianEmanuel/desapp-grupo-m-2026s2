#!/bin/sh
# Child output is deliberately private: profile failures release only categories.
# Prerequisite for the integration profile: a Node v24 runtime (CI pins
# PATH=v24 via actions/setup-node; locally use
# ~/.nvm/versions/node/v24.21.0). preflight_integration enforces the v24 check.
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

profile=${1:-}
case "$profile" in
  unit|integration) ;;
  *) printf '%s\n' 'CP1_PROFILE_OUTCOME status=failed category=usage' >&2; exit 64 ;;
esac

audit_output=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-audit.XXXXXX")
test_output=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-${profile}.XXXXXX")
sentinel_file=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-sentinel.XXXXXX")
committed_file_list=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-committed.XXXXXX")
trap 'rm -f "$audit_output" "$test_output" "$sentinel_file" "$committed_file_list"' EXIT HUP INT TERM

safe_failure() {
  printf 'CP1_PROFILE_OUTCOME profile=%s status=failed category=%s\n' "$profile" "$1" >&2
  exit "${2:-1}"
}

safe_test_failure() {
  stage=$1
  printf 'CP1_PROFILE_STAGE %s\n' "$stage" >&2
  details=$(sed -n -E 's/^[[:space:]]*(test\/[^[:space:]]+\.exs:[0-9]+).*/\1/p' "$test_output" | sort -u | head -20)
  failures=$(sed -n -E 's/^[[:space:]]*[0-9]+ tests?, ([0-9]+) failures?.*/\1/p' "$test_output" | tail -1)
  [ -n "$failures" ] || failures=$(sed -n -E 's/^[[:space:]]*Failed: ([0-9]+) tests?.*/\1/p' "$test_output" | tail -1)
  [ -n "$failures" ] || failures=unknown
  printf 'CP1_PROFILE_FAILURES count=%s\n' "$failures" >&2
  if [ -n "$details" ]; then
    printf '%s\n' "$details" | while IFS= read -r location; do
      printf 'CP1_PROFILE_FAILURE_LOCATION %s\n' "$location" >&2
    done
  else
    printf '%s\n' 'CP1_PROFILE_FAILURE_LOCATION unavailable' >&2
  fi
  safe_failure test-failure "$2"
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
MIX_ENV=test mix run -e "result = FootballMarket.TestProfileAudit.audit!(\"$profile\"); IO.puts(\"CP1_PROFILE_AUDIT count=#{result.count}\"); Enum.each(result.files, &IO.puts(\"CP1_PROFILE_FILE \" <> &1)); Enum.each(result.committed_files, &IO.puts(\"CP1_PROFILE_COMMITTED_FILE \" <> &1))" >"$audit_output" 2>&1
audit_status=$?
set -e
[ "$audit_status" -eq 0 ] || safe_failure audit "$audit_status"

audit_count=$(sed -n 's/^CP1_PROFILE_AUDIT count=//p' "$audit_output")
files=$(sed -n 's/^CP1_PROFILE_FILE //p' "$audit_output")
sed -n 's/^CP1_PROFILE_COMMITTED_FILE //p' "$audit_output" >"$committed_file_list"
[ -n "$audit_count" ] && [ -n "$files" ] || safe_failure audit

regular_files=
for file in $files; do
  if ! grep -Fqx "$file" "$committed_file_list"; then
    regular_files="$regular_files $file"
  fi
done

set +e
if [ "${CP1_PROFILE_COVERAGE:-0}" = 1 ]; then
  CP1_PROFILE="$profile" CP1_PROFILE_SENTINEL_PATH="$sentinel_file" MIX_ENV=test mix test --warnings-as-errors --include performance --only "$profile" --cover --export-coverage "$profile" $files >"$test_output" 2>&1
  test_status=$?
  set -e
  [ "$test_status" -eq 0 ] || safe_test_failure transactional "$test_status"
else
  set +e
  CP1_PROFILE="$profile" CP1_PROFILE_SENTINEL_PATH="$sentinel_file" MIX_ENV=test mix test --warnings-as-errors --include performance --only "$profile" $regular_files >"$test_output" 2>&1
  test_status=$?
  set -e
  [ "$test_status" -eq 0 ] || safe_test_failure transactional "$test_status"

  fixture_index=0
  for file in $(cat "$committed_file_list"); do
    fixture_index=$((fixture_index + 1))
    fixture_partition="cp1$$_c${fixture_index}"
    printf 'CP1_PROFILE_STAGE committed-fixture=%s\n' "$file" >&2

    set +e
    MIX_TEST_PARTITION="$fixture_partition" MIX_ENV=test mix test.prepare >"$audit_output" 2>&1
    prepare_status=$?
    set -e
    [ "$prepare_status" -eq 0 ] || safe_failure fixture-database "$prepare_status"

    set +e
    CP1_PROFILE="$profile" MIX_TEST_PARTITION="$fixture_partition" MIX_ENV=test mix test --warnings-as-errors --include performance --only "$profile" "$file" >>"$test_output" 2>&1
    test_status=$?
    set -e
    [ "$test_status" -eq 0 ] || safe_test_failure "committed-fixture:$file" "$test_status"
  done
fi

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
