#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/task_002_acceptance_test.sh
. "$(dirname "$0")/support/profile_events.sh"
profile_case_start 'task_002_acceptance'
. "$(dirname "$0")/support/local_services_test_helpers.sh"
docker_available || { echo "FAIL: Docker daemon unavailable"; exit 1; }
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
trap 'cd "$root"; ./scripts/local_services.sh stop >/dev/null 2>&1 || true' EXIT
cd "$root"
./scripts/local_services.sh start
./scripts/local_services.sh ready
mix infrastructure.database.setup
for cycle in 1 2 3; do
  ./scripts/local_services.sh restart
  ./scripts/local_services.sh ready
  mix infrastructure.database.migrate
  mix infrastructure.verify
done
echo "three-cycle acceptance: PASS"
profile_case_pass 'task_002_acceptance'
