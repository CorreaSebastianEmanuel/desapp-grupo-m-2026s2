#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMPOSE_FILE="$ROOT/docs/observability/compose.sonarqube.yaml"
PORT="${SONARQUBE_PORT:-9000}"
HOST_URL="http://127.0.0.1:${PORT}"
PROJECT_KEY="${SONAR_LOCAL_PROJECT_KEY:-football-market-local}"

usage() {
  cat <<EOF
Usage: ./scripts/sonarqube_local.sh <start|status|scan|stop> [--reuse-coverage]

  start   Start local SonarQube Community Build with the sonar-elixir plugin on ${HOST_URL}
  status  Check local SonarQube server status
  scan    Generate Elixir coverage/issues + JS LCOV and scan into local SonarQube
          Requires SONAR_LOCAL_TOKEN in the environment (default login: admin / admin)
  stop    Stop the local SonarQube container (preserves volumes and history)
EOF
}

wait_ready() {
  i=0
  while [ "$i" -lt 90 ]; do
    if curl -fsS "${HOST_URL}/api/system/status" 2>/dev/null | grep -q '"status":"UP"'; then
      echo "SonarQube with sonar-elixir is UP at ${HOST_URL}"
      return 0
    fi
    i=$((i + 1))
    sleep 2
  done
  echo "Timed out waiting for SonarQube at ${HOST_URL}" >&2
  return 1
}

run_scan() {
  reuse_coverage=0
  if [ "${1:-}" = "--reuse-coverage" ]; then
    reuse_coverage=1
  fi

  if [ -z "${SONAR_LOCAL_TOKEN:-}" ]; then
    echo "Set SONAR_LOCAL_TOKEN before scanning (create a token at ${HOST_URL}/account/security)." >&2
    exit 1
  fi

  cd "$ROOT"
  echo "1/4 Generating Elixir Credo + Sobelow generic issues..."
  python3 scripts/sonar_elixir_reports.py issues --output tmp/sonar-elixir

  if [ "$reuse_coverage" -eq 0 ] || [ ! -f cover/application/status.json ]; then
    echo "2/4 Collecting fresh Elixir application coverage..."
    MIX_ENV=test mix test.prepare
    python3 scripts/application_coverage.py run
  else
    echo "2/4 Reusing existing Elixir application coverage..."
  fi
  python3 scripts/sonar_elixir_reports.py coverage --output tmp/sonar-elixir

  echo "3/4 Generating workspace JavaScript LCOV..."
  node scripts/openapi/workspace_coverage.mjs

  echo "4/4 Running SonarScanner against ${HOST_URL} (project: ${PROJECT_KEY})..."
  if command -v sonar-scanner >/dev/null 2>&1; then
    sonar-scanner \
      "-Dsonar.host.url=${HOST_URL}" \
      "-Dsonar.token=${SONAR_LOCAL_TOKEN}" \
      "-Dsonar.projectKey=${PROJECT_KEY}" \
      "-Dsonar.projectName=Football Player Market (Elixir)" \
      "-Dsonar.sources=lib,assets/js" \
      "-Dsonar.tests=test" \
      "-Dsonar.coverageReportPaths=tmp/sonar-elixir/coverage.xml" \
      "-Dsonar.javascript.lcov.reportPaths=cover/workspace/lcov.info" \
      "-Dsonar.externalIssuesReportPaths=tmp/sonar-elixir/external-issues.json"
  else
    docker run --rm --network=host \
      -e "SONAR_HOST_URL=${HOST_URL}" \
      -e "SONAR_TOKEN=${SONAR_LOCAL_TOKEN}" \
      -v "${ROOT}:/usr/src" \
      sonarsource/sonar-scanner-cli:11 \
      "-Dsonar.projectKey=${PROJECT_KEY}" \
      "-Dsonar.projectName=Football Player Market (Elixir)" \
      "-Dsonar.sources=lib,assets/js" \
      "-Dsonar.tests=test" \
      "-Dsonar.coverageReportPaths=tmp/sonar-elixir/coverage.xml" \
      "-Dsonar.javascript.lcov.reportPaths=cover/workspace/lcov.info" \
      "-Dsonar.externalIssuesReportPaths=tmp/sonar-elixir/external-issues.json"
  fi
  echo "Dashboard ready at ${HOST_URL}/dashboard?id=${PROJECT_KEY}"
}

case "${1:-}" in
  start)
    docker compose -f "$COMPOSE_FILE" up -d
    wait_ready
    ;;
  status)
    curl -fsS "${HOST_URL}/api/system/status" && echo ""
    ;;
  scan)
    shift
    run_scan "$@"
    ;;
  stop)
    docker compose -f "$COMPOSE_FILE" stop
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
