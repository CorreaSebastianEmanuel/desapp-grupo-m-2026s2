#!/bin/sh
set -eu
. "$(dirname "$0")/support/local_services_test_helpers.sh"
docker_available || { echo "SKIP: Docker daemon unavailable"; exit 0; }
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
