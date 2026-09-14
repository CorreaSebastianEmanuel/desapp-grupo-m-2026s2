#!/bin/sh
set -eu
. "$(dirname "$0")/../scripts/support/local_services_test_helpers.sh"
docker_available || { echo "SKIP: Docker daemon unavailable"; exit 0; }
root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
cd "$root"
trap './scripts/local_services.sh stop >/dev/null 2>&1 || true' EXIT
./scripts/local_services.sh start
./scripts/local_services.sh ready
mix infrastructure.database.setup
mix infrastructure.verify

assert_failed_probe() {
  dependency=$1
  env_name=$2
  env_value=$3
  category=$4
  other_dependency=$5
  output_file=$(mktemp "${TMPDIR:-/tmp}/task002-verify.XXXXXX")

  ./scripts/local_services.sh ready >/dev/null

  secret_name=
  if [ "$category" = invalid_configuration ]; then
    if [ "$dependency" = PostgreSQL ]; then
      secret_name=POSTGRES_PASSWORD
    else
      secret_name=REDIS_PASSWORD
    fi
  fi

  if [ -n "$secret_name" ]; then
    env "$env_name=$env_value" "$secret_name=malformed-port-secret" \
      mix infrastructure.verify >"$output_file" 2>&1 && result=0 || result=$?
  else
    env "$env_name=$env_value" mix infrastructure.verify >"$output_file" 2>&1 && result=0 || result=$?
  fi

  if [ "$result" -eq 0 ]; then
    fail "$dependency verification unexpectedly succeeded"
  fi

  grep -q "$dependency: ERROR $category" "$output_file" ||
    fail "$dependency did not report $category"
  grep -q "$other_dependency: OK" "$output_file" ||
    fail "$other_dependency was not independently probed"
  ! grep -q 'malformed-port-secret' "$output_file" || fail "verification exposed credentials"
  rm -f "$output_file"
}

assert_failed_probe PostgreSQL POSTGRES_PORT malformed-postgres-port invalid_configuration Redis
assert_failed_probe Redis REDIS_PORT malformed-redis-port invalid_configuration PostgreSQL
assert_failed_probe PostgreSQL POSTGRES_PORT 5499 unavailable_or_authentication_failure Redis
assert_failed_probe Redis REDIS_PORT 6399 unavailable_or_authentication_failure PostgreSQL
echo "independent verification: PASS"
