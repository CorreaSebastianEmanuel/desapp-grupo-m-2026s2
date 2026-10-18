#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/verify_foundation_test.sh
. "$(dirname "$0")/support/profile_events.sh"

repo_root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
fixture=$(mktemp -d "${TMPDIR:-/tmp}/football-market-oracle.XXXXXX")
trap 'rm -rf "$fixture"' EXIT HUP INT TERM

cat >"$fixture/curl" <<'EOF'
#!/bin/sh
body=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --output) body=$2; shift 2 ;;
    *) shift ;;
  esac
done
case "${FAKE_CURL_MODE:-success}" in
  success) printf '<h1>Football Player Market</h1>' >"$body"; printf 200 ;;
  bad_status) printf 'unavailable' >"$body"; printf 503 ;;
  missing_marker) printf '<h1>Phoenix</h1>' >"$body"; printf 200 ;;
  connection_failure) exit 7 ;;
esac
EOF
chmod +x "$fixture/curl"

run_success() {
  name=$1
  mode=$2
  if PATH="$fixture:$PATH" FAKE_CURL_MODE="$mode" VERIFY_TIMEOUT_SECONDS=0 "$repo_root/scripts/verify_foundation.sh" >/dev/null 2>&1; then
    printf 'ok - %s\n' "$name"
  else
    printf 'not ok - %s\n' "$name" >&2
    exit 1
  fi
}

run_failure() {
  name=$1
  mode=$2
  if PATH="$fixture:$PATH" FAKE_CURL_MODE="$mode" VERIFY_TIMEOUT_SECONDS=0 "$repo_root/scripts/verify_foundation.sh" >/dev/null 2>&1; then
    printf 'not ok - %s unexpectedly passed\n' "$name" >&2
    exit 1
  fi
  printf 'ok - %s\n' "$name"
}

profile_case_start 'readiness-1'
run_success 'successful readiness' success
profile_case_pass 'readiness-1'
profile_case_start 'readiness-2'
run_failure 'bad HTTP status' bad_status
profile_case_pass 'readiness-2'
profile_case_start 'readiness-3'
run_failure 'missing marker (including an occupied port serving another app)' missing_marker
profile_case_pass 'readiness-3'
profile_case_start 'readiness-4'
run_failure 'connection failure after stop' connection_failure
profile_case_pass 'readiness-4'

# A connection that never satisfies the contract exercises the bounded timeout path.
profile_case_start 'readiness-5'
run_failure 'bounded readiness timeout' connection_failure
profile_case_pass 'readiness-5'

printf '5 verification tests passed\n'
