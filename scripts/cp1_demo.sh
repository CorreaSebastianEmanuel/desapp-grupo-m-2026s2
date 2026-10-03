#!/bin/sh
set -eu
set +x
umask 077

fail() { printf '%s\n' "cp1-demo: NOT PASSING ($1)" >&2; exit 1; }

[ "${CP1_DEMO_CONFIRM_DISPOSABLE:-}" = "yes" ] || fail disposable-database-not-confirmed
[ -n "${CP1_DEMO_DATABASE_URL:-}" ] || fail disposable-database-missing
case "$CP1_DEMO_DATABASE_URL" in
  */football_market_test_cp1_demo) ;;
  *) fail disposable-database-unsafe ;;
esac

# Test configuration consumes POSTGRES_* rather than DATABASE_URL. Reject any
# mismatch so this guard cannot accidentally authorize another database server.
python3 - <<'PYDATABASE' || fail disposable-database-configuration
import os, sys
from urllib.parse import urlparse, unquote
try:
    u = urlparse(os.environ["CP1_DEMO_DATABASE_URL"])
    expected_host = os.environ.get("POSTGRES_HOST", "127.0.0.1")
    assert u.scheme in {"ecto", "postgres", "postgresql"}
    assert u.hostname in {"localhost", "127.0.0.1"} and expected_host in {"localhost", "127.0.0.1"}
    assert (u.port or 5432) == int(os.environ.get("POSTGRES_PORT", "5432"))
    assert unquote(u.username or "") == os.environ.get("POSTGRES_USER", "postgres")
    assert unquote(u.password or "") == os.environ.get("POSTGRES_PASSWORD", "postgres")
    assert not u.query and not u.fragment
except Exception:
    sys.exit(1)
PYDATABASE

candidate=${CP1_CANDIDATE_SHA:-}
printf '%s\n' "$candidate" | grep -Eq '^[0-9a-f]{40}$' || fail invalid-candidate

output=tmp/cp1-demo-receipt.json
if [ "${1:-}" = "--receipt" ]; then [ -n "${2:-}" ] || fail receipt-path-missing; output=$2; elif [ -n "${1:-}" ]; then output=$1; fi
owned=$(mktemp -d "${TMPDIR:-/tmp}/cp1-demo-owned.XXXXXX")
private="$owned/private-child-output"
seed_first="$owned/seed-first"
seed_second="$owned/seed-second"
cleanup() { rm -rf "$owned"; }
trap cleanup EXIT HUP INT TERM

rm -f "$output"
python3 - "$owned/source.json" "$candidate" <<'PYSOURCE' || fail source-provenance
import json, sys
sys.path.insert(0, "scripts")
from cp1_acceptance import git_snapshot
source = git_snapshot()
if source["candidate_sha"] != sys.argv[2]:
    sys.exit(1)
with open(sys.argv[1], "w") as handle:
    json.dump(source, handle)
PYSOURCE
started=$(date +%s)
export DATABASE_URL="$CP1_DEMO_DATABASE_URL"
export MIX_ENV=test
export MIX_TEST_PARTITION=_cp1_demo
export LOG_LEVEL=error

# Child streams stay private and are destroyed on every exit. Only fixed failure
# categories and allowlisted behavior IDs may reach the retained receipt.
mix infrastructure.database.test_prepare >"$private" 2>&1 || fail database-preparation
# The private runner exercises account commands and real loopback HTTP/browser
# requests against the twice-seeded disposable database, asserting every result.
export CP1_DEMO_OBSERVATIONS="$owned/observations.json"
mix run scripts/cp1_demo.exs >"$private" 2>&1 || {
  failed_line=$(sed -n 's/^CP1_DEMO_FAILURE line=\([0-9][0-9]*\)$/\1/p' "$private")
  fail "journey-line-${failed_line:-unavailable}"
}
[ -s "$CP1_DEMO_OBSERVATIONS" ] || fail seed-relationship-observations

elapsed=$(( $(date +%s) - started ))
[ "$elapsed" -le 1200 ] || fail elapsed-time-boundary

behaviors='["SEED_FIRST","SEED_SECOND","SEED_RELATIONSHIPS","USER_CREATE","USER_DUPLICATE","JWT_VALID_LOGIN","JWT_INVALID_LOGIN","JWT_PROTECTED_ACCESS","API_KEY_ISSUE","API_KEY_VERIFY","API_KEY_PROTECTED_ACCESS","API_KEY_REVOKE","API_KEY_REVOKED_REJECTED","CATALOG_LIST","CATALOG_DETAIL","CATALOG_CONTINUATION","CATALOG_FILTER_LEAGUE","CATALOG_FILTER_TEAM","CATALOG_FILTER_POSITION","CATALOG_FILTER_COMBINED","CATALOG_EMPTY","CATALOG_INVALID","OPENAPI_JSON_PUBLIC","OPENAPI_UI_PUBLIC","OPENAPI_JWT_REQUEST","OPENAPI_API_KEY_REQUEST"]'
mkdir -p "$(dirname "$output")"
stage="$owned/receipt.json"
printf '{"schema_version":1,"kind":"demo","status":"PASS","candidate_sha":"%s","observed":"all behavior IDs passed","reference":"specs/015-cp1-acceptance-evidence/quickstart.md","provider_access":false,"seed_assertions":[{"leagues":5,"seasons":5,"teams":10,"positions":4,"players":20,"total":44},{"leagues":5,"seasons":5,"teams":10,"positions":4,"players":20,"total":44}],"elapsed_seconds":%s,"behaviors":%s}\n' "$candidate" "$elapsed" "$behaviors" >"$stage"
python3 - "$stage" "$candidate" "$owned/source.json" <<'PYSAFE' || fail unsafe-staging
import sys
from pathlib import Path
sys.path.insert(0, str(Path("scripts").resolve()))
from cp1_acceptance import load_json, validate_demo, git_snapshot
import json
try:
    source = load_json(sys.argv[3])
    if source != git_snapshot():
        sys.exit(1)
    receipt = load_json(sys.argv[1])
    receipt.update(source)
    validate_demo(receipt, sys.argv[2], require_committed=False)
    Path(sys.argv[1]).write_text(json.dumps(receipt) + "\n")
except Exception:
    sys.exit(1)
PYSAFE
mv "$stage" "$output"
printf '%s\n' 'cp1-demo: PASS'
