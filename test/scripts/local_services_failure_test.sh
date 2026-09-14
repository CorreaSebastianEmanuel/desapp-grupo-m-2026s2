#!/bin/sh
set -eu
. "$(dirname "$0")/support/local_services_test_helpers.sh"

docker_available || { echo "SKIP: Docker daemon unavailable"; exit 0; }
command -v python3 >/dev/null 2>&1 || { echo "SKIP: python3 unavailable for bind-conflict fixture"; exit 0; }

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
blocker_pid=
cleanup() {
  [ -z "$blocker_pid" ] || kill "$blocker_pid" >/dev/null 2>&1 || true
  cd "$root"
  ./scripts/local_services.sh stop >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

output=$($root/scripts/local_services.sh reset 2>&1 || true)
printf '%s' "$output" | grep -q 'destructive'
grep -q 'unavailable or unready' "$root/scripts/local_services.sh"

cd "$root"
./scripts/local_services.sh stop >/dev/null 2>&1 || true

for port in 5432 6379; do
  python3 -m http.server "$port" --bind 127.0.0.1 >/tmp/task002-port-$port.out 2>&1 &
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
done

echo "failure diagnostics contract: PASS"
