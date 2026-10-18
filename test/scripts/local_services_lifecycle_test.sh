#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/local_services_lifecycle_test.sh
. "$(dirname "$0")/support/profile_events.sh"
profile_case_start 'local_services_lifecycle'
. "$(dirname "$0")/support/local_services_test_helpers.sh"
docker_available || { echo "FAIL: Docker daemon unavailable"; exit 1; }
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
trap 'cd "$root"; ./scripts/local_services.sh stop >/dev/null 2>&1 || true' EXIT
cd "$root"
./scripts/local_services.sh start
./scripts/local_services.sh ready
./scripts/local_services.sh inspect
./scripts/local_services.sh restart
./scripts/local_services.sh stop
echo "local lifecycle: PASS"
profile_case_pass 'local_services_lifecycle'
