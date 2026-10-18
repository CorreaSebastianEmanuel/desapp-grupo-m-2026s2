#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/local_services_failure_test.sh
. "$(dirname "$0")/support/profile_events.sh"
. "$(dirname "$0")/support/local_services_test_helpers.sh"

docker_available || { echo "FAIL: Docker daemon unavailable"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "FAIL: python3 unavailable for bind-conflict fixture"; exit 1; }

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
blocker_pid=
cleanup() {
  [ -z "$blocker_pid" ] || kill "$blocker_pid" >/dev/null 2>&1 || true
  cd "$root"
  ./scripts/local_services.sh stop >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

profile_case_start 'reset-requires-confirmation'
output=$($root/scripts/local_services.sh reset 2>&1 || true)
printf '%s' "$output" | grep -q 'destructive'
grep -q 'unavailable or unready' "$root/scripts/local_services.sh"
profile_case_pass 'reset-requires-confirmation'

cd "$root"
./scripts/local_services.sh stop >/dev/null 2>&1 || true

for port in "${POSTGRES_PORT:-5432}" "${REDIS_PORT:-6379}"; do
  case "$port" in
    "${POSTGRES_PORT:-5432}")
      profile_case_start 'postgres-occupied'
      ;;
    *)
      profile_case_start 'redis-occupied'
      ;;
  esac
  python3 -m http.server "$port" --bind 127.0.0.1 >${TMPDIR:-/tmp}/task002-port-$port.out 2>&1 &
  blocker_pid=$!
  sleep 1
  kill -0 "$blocker_pid" 2>/dev/null || fail "could not reserve loopback port $port"

  if output=$(./scripts/local_services.sh start 2>&1); then
    fail "service startup succeeded while loopback port $port was occupied"
  fi
  printf '%s' "$output" | grep -Eq "($port|address already in use|port is already allocated)" ||
    fail "startup failure did not identify occupied port $port"

  kill "$blocker_pid"
  wait "$blocker_pid" 2>/dev/null || true
  blocker_pid=
  ./scripts/local_services.sh stop >/dev/null 2>&1 || true
  case "$port" in
    "${POSTGRES_PORT:-5432}") profile_case_pass 'postgres-occupied' ;;
    *) profile_case_pass 'redis-occupied' ;;
  esac
done

echo "failure diagnostics contract: PASS"
