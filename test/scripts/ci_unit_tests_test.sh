#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
wrapper="$repo_root/scripts/ci_unit_tests.sh"
tmp_root=$(mktemp -d "${TMPDIR:-/tmp}/ci-unit-tests-test.XXXXXX")
trap 'rm -rf "$tmp_root"' EXIT HUP INT TERM

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_case() {
  case_name=$1
  fake_status=$2
  fake_output=$3
  expected_status=$4
  fake_bin="$tmp_root/$case_name/bin"
  invocation="$tmp_root/$case_name/invocation"
  mkdir -p "$fake_bin"
  cat >"$fake_bin/mix" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >'$invocation'
printf '%s\n' "\${MIX_ENV:-}" >'$invocation.env'
printf '%b\n' '$fake_output'
exit $fake_status
EOF
  chmod +x "$fake_bin/mix"

  set +e
  PATH="$fake_bin:$PATH" TMPDIR="$tmp_root/$case_name" "$wrapper" >"$tmp_root/$case_name/output" 2>&1
  actual_status=$?
  set -e

  [ "$actual_status" -eq "$expected_status" ] || fail "$case_name returned $actual_status, expected $expected_status"
  [ "$(cat "$invocation")" = "test --warnings-as-errors" ] || fail "$case_name invoked unexpected mix arguments"
  [ "$(cat "$invocation.env")" = "test" ] || fail "$case_name did not force MIX_ENV=test"
  first_diagnostic=$(printf '%b\n' "$fake_output" | sed -n '1p')
  grep -F "$first_diagnostic" "$tmp_root/$case_name/output" >/dev/null || fail "$case_name hid test diagnostics"
  leftovers=$(find "$tmp_root/$case_name" -maxdepth 1 -name 'football-market-ci-tests.*' -print)
  [ -z "$leftovers" ] || fail "$case_name left temporary output behind"
}

[ -x "$wrapper" ] || fail "wrapper is missing or not executable"
run_case failing_test 7 "assertion failed" 7
run_case missing_marker 0 "1 test, 0 failures" 1
run_case zero_count 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\n0 tests, 0 failures" 1
run_case missing_count 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL" 1
run_case marked_success 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\n1 test, 0 failures" 0
run_case pinned_result 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 527/527 passed, 4 excluded" 0
run_case pinned_all_passed 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 527 passed, 4 excluded" 0
run_case pinned_all_zero 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 0 passed, 4 excluded" 1
run_case pinned_all_failed_suffix 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 527 passed, 1 failed" 1
run_case pinned_zero 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 0/0 passed, 4 excluded" 1
run_case pinned_partial 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 526/527 passed, 4 excluded" 1
run_case pinned_failed 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 0/527 passed, 527 failed" 1
run_case pinned_failed_suffix 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 527/527 passed, 1 failed" 1
run_case pinned_overcount 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 528/527 passed" 1
run_case pinned_missing_marker 0 "Result: 527/527 passed, 4 excluded" 1
run_case pinned_child_failure 7 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 527/527 passed, 4 excluded" 7
run_case legacy_failed 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\n527 tests, 1 failure" 1
run_case final_partial 0 "FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\n1 test, 0 failures\nResult: 526/527 passed, 1 failed" 1

echo "ci_unit_tests wrapper contract: PASS"
