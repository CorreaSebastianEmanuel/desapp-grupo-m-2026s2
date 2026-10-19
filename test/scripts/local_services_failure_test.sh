#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/local_services_failure_test.sh
. "$(dirname "$0")/support/profile_events.sh"
. "$(dirname "$0")/support/local_services_test_helpers.sh"

docker_available || { echo "FAIL: Docker daemon unavailable"; exit 1; }

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
fixture=$(mktemp -d "${TMPDIR:-/tmp}/task002-port.XXXXXX")
blocker_cid=$fixture/blocker.cid
release_blocker() {
  if [ -s "$blocker_cid" ]; then
    docker stop --time 1 "$(cat "$blocker_cid")" >/dev/null 2>&1 || true
    rm -f "$blocker_cid"
  fi
}
cleanup() {
  release_blocker
  rmdir "$fixture" 2>/dev/null || true
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
blocker_image=$(docker compose --project-name football_market_local config --images | grep '^redis:')
[ -n "$blocker_image" ] || fail "could not resolve pinned Redis fixture image"

for port in "${POSTGRES_PORT:-5432}" "${REDIS_PORT:-6379}"; do
  # Recreate stopped peers left by the previous intentionally failed startup so
  # every case must allocate its published ports again on the daemon.
  docker compose --project-name football_market_local rm -f postgres redis >/dev/null 2>&1
  case "$port" in
    "${POSTGRES_PORT:-5432}")
      profile_case_start 'postgres-occupied'
      ;;
    *)
      profile_case_start 'redis-occupied'
      ;;
  esac
  # Reserve on the same Docker daemon as Compose. A WSL-local listener need not
  # conflict with a Docker Desktop host publication.
  docker run --detach --rm --cidfile "$blocker_cid" \
    --publish "127.0.0.1:$port:6379" "$blocker_image" \
    redis-server --save '' --appendonly no >/dev/null ||
    fail "could not reserve loopback port $port"
  blocker_id=$(cat "$blocker_cid")
  [ "$(docker inspect --format '{{.State.Running}}' "$blocker_id")" = true ] ||
    fail "port blocker stopped before conflict check for $port"
  [ "$(docker port "$blocker_id" 6379/tcp)" = "127.0.0.1:$port" ] ||
    fail "port blocker did not publish loopback port $port"

  if output=$(./scripts/local_services.sh start 2>&1); then
    fail "service startup succeeded while loopback port $port was occupied"
  fi
  printf '%s' "$output" | grep -Eq "($port|address already in use|port is already allocated)" ||
    fail "startup failure did not identify occupied port $port"

  release_blocker
  ./scripts/local_services.sh stop >/dev/null 2>&1 || true
  case "$port" in
    "${POSTGRES_PORT:-5432}") profile_case_pass 'postgres-occupied' ;;
    *) profile_case_pass 'redis-occupied' ;;
  esac
done

echo "failure diagnostics contract: PASS"
