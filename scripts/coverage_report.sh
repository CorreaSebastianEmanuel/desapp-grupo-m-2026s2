#!/bin/sh
# Coverage artifacts are staged privately and only moved after stable-snapshot checks.
set -eu
umask 077

root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf '%s\n' 'CP1_COVERAGE_OUTCOME status=failed category=snapshot' >&2
  exit 1
}
cd "$root"

capture=$(mktemp "${TMPDIR:-/tmp}/football-market-cp1-coverage-capture.XXXXXX")
staging=$(mktemp -d "${TMPDIR:-/tmp}/football-market-cp1-coverage.XXXXXX")
trap 'rm -f "$capture"; rm -rf "$staging"' EXIT HUP INT TERM

safe_failure() {
  printf 'CP1_COVERAGE_OUTCOME status=failed category=%s\n' "$1" >&2
  exit "${2:-1}"
}

capture_command() {
  set +e
  "$@" >"$capture" 2>&1
  command_status=$?
  set -e
  return "$command_status"
}

snapshot_paths() {
  printf '%s\n' . \
    ':(glob,exclude)specs/*/qa-report.md' \
    ':(glob,exclude)specs/*/review-report.md' \
    ':(glob,exclude)specs/*/handoffs/**'
}

snapshot() {
  capture_command git rev-parse HEAD || return 1
  base_head=$(tr -d '\n' <"$capture")
  printf '%s' "$base_head" | grep -Eq '^[0-9a-f]{40}$' || return 1

  git diff --binary --full-index HEAD -- $(snapshot_paths) >"$staging/diff" 2>"$capture" || return 1
  diff_hash=$(sha256sum "$staging/diff" | awk '{print $1}')
  rm -f "$staging/diff"

  capture_command git ls-files --others --exclude-standard -- $(snapshot_paths) || return 1
  [ ! -s "$capture" ] || return 2
  return 0
}

inventory=config/cp1_coverage_inventory.exs
[ -f "$inventory" ] || safe_failure inventory
inventory_hash=$(sha256sum "$inventory" | awk '{print $1}')
snapshot_status=0
snapshot || snapshot_status=$?
[ "$snapshot_status" -eq 0 ] || {
  [ "$snapshot_status" -eq 2 ] && safe_failure non-generated-untracked-input
  safe_failure snapshot
}
initial_head=$base_head
initial_diff=$diff_hash
label='committed revision'
git diff --quiet HEAD -- $(snapshot_paths) 2>/dev/null || label='working-tree snapshot'

receipt_dir="$staging/receipts"
native_coverage="$staging/native"
CP1_COVERAGE_OUTPUT="$native_coverage" CP1_PROFILE_COVERAGE=1 CP1_PROFILE_RECEIPT="$receipt_dir/unit.json" scripts/test_profile.sh unit >"$capture" 2>&1 || safe_failure profile-unit
CP1_COVERAGE_OUTPUT="$native_coverage" CP1_PROFILE_COVERAGE=1 CP1_PROFILE_RECEIPT="$receipt_dir/integration.json" scripts/test_profile.sh integration >"$capture" 2>&1 || safe_failure profile-integration
[ -f "$receipt_dir/unit.json" ] && [ -f "$receipt_dir/integration.json" ] || safe_failure receipt

CP1_COVERAGE_PUBLISH_DIR="$staging" \
CP1_COVERAGE_BASE_HEAD="$initial_head" \
CP1_COVERAGE_DIFF_SHA256="$initial_diff" \
CP1_COVERAGE_INVENTORY_SHA256="$inventory_hash" \
CP1_COVERAGE_SNAPSHOT_LABEL="$label" \
CP1_COVERAGE_UNIT_RECEIPT="$receipt_dir/unit.json" \
CP1_COVERAGE_INTEGRATION_RECEIPT="$receipt_dir/integration.json" \
CP1_COVERAGE_OUTPUT="$native_coverage" \
MIX_ENV=test mix run -e '
  # Coverage must be imported and published by the same BEAM VM: :cover
  # state is process-local and is unavailable to a later `mix run` process.
  Mix.Tasks.Test.Coverage.run([])

  metadata = %{
    base_head: System.fetch_env!("CP1_COVERAGE_BASE_HEAD"),
    diff_sha256: System.fetch_env!("CP1_COVERAGE_DIFF_SHA256"),
    inventory_sha256: System.fetch_env!("CP1_COVERAGE_INVENTORY_SHA256"),
    snapshot_label: System.fetch_env!("CP1_COVERAGE_SNAPSHOT_LABEL"),
    profiles: [
      Jason.decode!(File.read!(System.fetch_env!("CP1_COVERAGE_UNIT_RECEIPT"))),
      Jason.decode!(File.read!(System.fetch_env!("CP1_COVERAGE_INTEGRATION_RECEIPT")))
    ]
  }
  FootballMarket.CP1CoveragePublisher.publish!(System.fetch_env!("CP1_COVERAGE_PUBLISH_DIR"), "config/cp1_coverage_inventory.exs", metadata)
' >"$capture" 2>&1 || safe_failure coverage-publication

[ -f "$staging/report.html" ] && [ -f "$staging/manifest.json" ] || safe_failure coverage-publication
! grep -R -E 'CP1_PROFILE_(SECRET|HASH)_SENTINEL' "$staging" >/dev/null 2>&1 || safe_failure artifact-safety

snapshot_status=0
snapshot || snapshot_status=$?
[ "$snapshot_status" -eq 0 ] || safe_failure snapshot-mutated
[ "$base_head" = "$initial_head" ] && [ "$diff_hash" = "$initial_diff" ] || safe_failure snapshot-mutated
[ "$(sha256sum "$inventory" | awk '{print $1}')" = "$inventory_hash" ] || safe_failure snapshot-mutated

run_id=$(date -u +%Y%m%dT%H%M%SZ)-$$
final="cover/cp1/${initial_head}-${run_id}"
mkdir -p cover/cp1
mv "$staging" "$final"
staging=''
printf 'CP1_COVERAGE_REPORT status=complete snapshot=%s report=%s/report.html\n' "$label" "$final"
