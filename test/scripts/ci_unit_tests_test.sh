#!/bin/sh
set -eu
PROFILE_SHELL_FILE=test/scripts/ci_unit_tests_test.sh
. "$(dirname "$0")/support/profile_events.sh"
repo_root=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
private=$(mktemp -d "${TMPDIR:-/tmp}/ci-contract.XXXXXX")
trap 'rm -rf "$private"' EXIT HUP INT TERM
mkdir -p "$private/scripts" "$private/config"
cp "$repo_root/scripts/ci_unit_tests.sh" "$repo_root/scripts/test_profile_components.py" "$private/scripts/"
cat >"$private/scripts/test_profile.sh" <<'CHILD'
#!/bin/sh
printf '%s\n' 'CP1_PROFILE_SECRET_SENTINEL password token api-key'
[ "${FAKE_CASE:-}" != browser-diagnostic ] || { printf '%s\n' 'PROFILE_BROWSER_DIAGNOSTIC cause=chromium-launch-failed stage=integration' 'BROWSER-RAW-CANARY private failure detail'; exit 7; }
[ "${FAKE_CASE:-}" != membership-diagnostic ] || { printf '%s\n' 'PROFILE_MEMBERSHIP_DIAGNOSTIC profile=unit phase=event-reconciliation reason=missing-events expected=69 observed=137 missing_started=0 missing_passed=1 extra=0 duplicate=0 invalid_state=0 wrong_nonce=0' 'MEMBERSHIP-RAW-CANARY private case id'; exit 7; }
[ "${FAKE_CASE:-}" != membership-extra-source ] || { printf '%s\n' 'PROFILE_MEMBERSHIP_EXTRA profile=unit runner=python file=test/scripts/example_test.py' 'PROFILE_MEMBERSHIP_EXTRA profile=unit runner=python file=private/secret_test.py' 'MEMBERSHIP-SOURCE-RAW-CANARY'; exit 7; }
[ "${FAKE_CASE:-}" != child-failure ] || { printf '%s\n' 'CP1_PROFILE_OUTCOME status=failed category=test-failure'; exit 7; }
[ "${FAKE_CASE:-}" != missing ] || exit 0
python3 - "$1" <<'PY'
import hashlib,json,os,sys
from pathlib import Path
profile=sys.argv[1]
result=dict(schema_version=1,nonce='a'*32,profile=profile,status='complete',inventory_digest=hashlib.sha256(Path('config/test_profiles.json').read_bytes()).hexdigest(),expected=1,discovered=1,executed=1,passed=1,components=dict(exunit=1,python=0,node=0,shell=0))
mode=os.environ.get('FAKE_CASE')
if mode=='partial': result['passed']=0
if mode=='wrong-profile': result['profile']='e2e'
if mode=='stale': result['inventory_digest']='old'
if mode=='empty': result.update(expected=0,discovered=0,executed=0,passed=0)
Path(os.environ['CP1_PROFILE_RECEIPT']).write_text(json.dumps(result))
PY
CHILD
printf '%s\n' '{"entries":[{"profile":"unit","runner":"exunit"},{"profile":"integration","runner":"exunit"}]}' >"$private/config/test_profiles.json"
run_case() {
  name=$1
  wanted=$2
  if (cd "$private" && FAKE_CASE="$name" sh scripts/ci_unit_tests.sh) >"$private/stdout" 2>"$private/stderr"; then actual=0; else actual=1; fi
  cat "$private/stdout" "$private/stderr" >"$private/output"
  [ "$actual" -eq "$wanted" ] || { echo 'CI contract failure' >&2; exit 1; }
  ! grep -q CP1_PROFILE_SECRET_SENTINEL "$private/output"
  if [ "$wanted" -eq 0 ]; then grep -Fxq FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL "$private/output"; else ! grep -q FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL "$private/output"; fi
  if [ "$wanted" -eq 0 ]; then
    python3 - "$private/stdout" <<'PY'
import json,sys
from pathlib import Path
assert json.loads(Path(sys.argv[1]).read_text()) == {
    'schema_version': 1, 'status': 'complete', 'profiles': ['unit', 'integration']}
PY
  else
    [ ! -s "$private/stdout" ] || { echo 'failed CI emitted success output' >&2; exit 1; }
  fi
}
profile_case_start 'complete'
run_case complete 0
profile_case_pass 'complete'
profile_case_start 'child-failure'
run_case child-failure 1
grep -Fxq 'CI_PROFILE_DIAGNOSTIC profile=unit category=test-failure' "$private/stderr" || { echo 'missing safe profile failure diagnostic' >&2; exit 1; }
profile_case_pass 'child-failure'
profile_case_start 'browser-diagnostic'
run_case browser-diagnostic 1
grep -Fxq 'PROFILE_BROWSER_DIAGNOSTIC cause=chromium-launch-failed stage=integration' "$private/stderr"
! grep -q BROWSER-RAW-CANARY "$private/output"
profile_case_pass 'browser-diagnostic'
profile_case_start 'membership-diagnostic'
run_case membership-diagnostic 1
grep -Fxq 'PROFILE_MEMBERSHIP_DIAGNOSTIC profile=unit phase=event-reconciliation reason=missing-events expected=69 observed=137 missing_started=0 missing_passed=1 extra=0 duplicate=0 invalid_state=0 wrong_nonce=0' "$private/stderr"
! grep -q MEMBERSHIP-RAW-CANARY "$private/output"
profile_case_pass 'membership-diagnostic'
profile_case_start 'membership-extra-source'
run_case membership-extra-source 1
grep -Fxq 'PROFILE_MEMBERSHIP_EXTRA profile=unit runner=python file=test/scripts/example_test.py' "$private/stderr"
! grep -q 'private/secret_test.py\|MEMBERSHIP-SOURCE-RAW-CANARY' "$private/output"
profile_case_pass 'membership-extra-source'
profile_case_start 'missing'
run_case missing 1
profile_case_pass 'missing'
profile_case_start 'partial'
run_case partial 1
profile_case_pass 'partial'
profile_case_start 'wrong-profile'
run_case wrong-profile 1
profile_case_pass 'wrong-profile'
profile_case_start 'stale'
run_case stale 1
profile_case_pass 'stale'
profile_case_start 'empty'
run_case empty 1
profile_case_pass 'empty'
