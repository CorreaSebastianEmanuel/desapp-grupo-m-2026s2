#!/bin/sh
set -eu
. "$(dirname "$0")/../scripts/support/local_services_test_helpers.sh"

docker_available || { echo "SKIP: Docker daemon unavailable"; exit 0; }
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
compose="docker compose --project-name football_market_local"
marker=redis-disposability-sentinel

cleanup() {
  cd "$root"
  $compose exec -T postgres psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-football_market_dev}" \
    -c "UPDATE infrastructure_probe SET marker = 'ready' WHERE key = 'migration'" >/dev/null 2>&1 || true
  ./scripts/local_services.sh stop >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

cd "$root"
./scripts/local_services.sh start
./scripts/local_services.sh ready
mix infrastructure.database.setup

$compose exec -T postgres psql -U "${POSTGRES_USER:-postgres}" -d "${POSTGRES_DB:-football_market_dev}" \
  -c "UPDATE infrastructure_probe SET marker = '$marker' WHERE key = 'migration'" >/dev/null
$compose exec -T redis redis-cli SET disposable-probe cached >/dev/null
$compose exec -T redis redis-cli FLUSHALL >/dev/null

[ "$($compose exec -T redis redis-cli EXISTS disposable-probe | tr -d '\r')" = "0" ] ||
  fail "Redis reset retained disposable data"
postgres_marker=$($compose exec -T postgres psql -U "${POSTGRES_USER:-postgres}" \
  -d "${POSTGRES_DB:-football_market_dev}" -Atc \
  "SELECT marker FROM infrastructure_probe WHERE key = 'migration'" | tr -d '\r')
[ "$postgres_marker" = "$marker" ] || fail "Redis reset changed authoritative PostgreSQL data"
echo "Redis disposability boundary: PASS"
