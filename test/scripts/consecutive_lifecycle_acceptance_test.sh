#!/bin/sh
set -eu
. "$(dirname "$0")/support/local_services_test_helpers.sh"
docker_available || { echo "SKIP: Docker daemon unavailable"; exit 0; }

root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
lock_dir="${TMPDIR:-/tmp}/football_market_local_services.lock"
cd "$root"

# A dead owner must not wedge every future lifecycle operation.
mkdir "$lock_dir"
printf '%s\n' 99999999 >"$lock_dir/pid"
./scripts/local_services.sh start

# Overlap a cleanup with a subsequent start. Serialization must converge to running.
./scripts/local_services.sh stop &
stop_pid=$!
sleep 1
./scripts/local_services.sh start &
start_pid=$!
wait "$stop_pid"
wait "$start_pid"

./scripts/local_services.sh ready
mix infrastructure.database.setup
mix infrastructure.verify
./test/scripts/task_002_acceptance_test.sh

echo "consecutive lifecycle and three-cycle acceptance: PASS"
