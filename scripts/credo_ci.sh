#!/usr/bin/env bash
set -eu

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$root"
out="${CREDO_CI_OUTPUT_DIR:-tmp/credo-ci}"
python3 - "$out" <<'PY'
import pathlib
import re
import sys

output = pathlib.Path(sys.argv[1])
if (re.fullmatch(r"tmp/credo-ci(?:-[A-Za-z0-9_-]+)?", sys.argv[1]) is None
        or pathlib.Path("tmp").is_symlink() or output.is_symlink()):
    print("CREDO_CI_OUTPUT_DIR must be a nonsymlink tmp/credo-ci[-suffix] directory", file=sys.stderr)
    raise SystemExit(2)
PY
rm -rf "$out"
mkdir -p "$out"

log="$out/credo.log"
cli_output="$out/cli.log"
oracle_output="$out/oracle.json"
before="$out/snapshot-before.json"
after="$out/snapshot-after.json"

snapshot() {
  MIX_ENV=test mix run --no-start scripts/credo_inventory.exs --snapshot
}

if ! snapshot >"$before" 2>>"$log"; then
  echo "SNAPSHOT_FAILURE before" >>"$log"
  exit 1
fi

set +e
MIX_ENV=test mix credo --format flycheck >"$cli_output" 2>&1
cli_status=$?
MIX_ENV=test mix run --no-start scripts/credo_inventory.exs >"$oracle_output" 2>>"$log"
oracle_status=$?
snapshot >"$after" 2>>"$log"
snapshot_status=$?
set -e

cat "$cli_output" >>"$log"
printf '\n--- Credo effective-input oracle ---\n' >>"$log"
if test -f "$oracle_output"; then cat "$oracle_output" >>"$log"; fi

head_revision="$(git rev-parse HEAD 2>/dev/null || printf unknown)"
trigger_revision="${GITHUB_SHA:-$head_revision}"
if test -n "$(git status --porcelain --untracked-files=all 2>/dev/null)"; then dirty=true; else dirty=false; fi

python3 - "$before" "$after" "$oracle_output" "$out/evidence.json" "$head_revision" "$trigger_revision" "$dirty" "$cli_status" "$oracle_status" "$snapshot_status" <<'PY'
import json
import pathlib
import sys

before_path, after_path, oracle_path, evidence_path, revision, trigger, dirty, cli, oracle_status, snapshot_status = sys.argv[1:]
before_path, after_path, oracle_path = map(pathlib.Path, (before_path, after_path, oracle_path))

def read_json(path):
    try:
        contents = path.read_text()
    except (OSError, json.JSONDecodeError):
        return {}
    try:
        return json.loads(contents)
    except json.JSONDecodeError:
        start, end = contents.find("{"), contents.rfind("}")
        if start < 0 or end < start:
            return {}
        try:
            return json.loads(contents[start:end + 1])
        except json.JSONDecodeError:
            return {}

before = read_json(before_path)
after = read_json(after_path)
oracle = read_json(oracle_path)
cli_status, oracle_status, snapshot_status = int(cli), int(oracle_status), int(snapshot_status)
same_snapshot = snapshot_status == 0 and before.get("complete") and after.get("complete") and before.get("source_digest") == after.get("source_digest")
complete = bool(oracle.get("complete") and isinstance(oracle.get("maintained"), list) and isinstance(oracle.get("effective"), list))
errors = list(oracle.get("errors", [])) if isinstance(oracle.get("errors", []), list) else ["oracle-error"]
if cli_status != 0:
    errors.append("standard-credo-cli-failed")
if oracle_status != 0 and not errors:
    errors.append("inventory-oracle-failed")
if not same_snapshot:
    errors.append("source-snapshot-changed-or-unavailable")
if not complete:
    errors.append("oracle-incomplete")

try:
    version_text = pathlib.Path("deps/credo/mix.exs").read_text()
    import re
    match = re.search(r'@version\s+"([^"]+)"', version_text)
    version = match.group(1) if match else "unknown"
except OSError:
    version = "unknown"

evidence = {
    "schema_version": 1,
    "revision": revision,
    "trigger_revision": trigger,
    "dirty": dirty == "true",
    "source_digest": before.get("source_digest") if same_snapshot else None,
    "commands": ["MIX_ENV=test mix credo --format flycheck", "MIX_ENV=test mix run --no-start scripts/credo_inventory.exs"],
    "credo_version": version,
    "rule_level": "default-priority",
    "maintained": oracle.get("maintained", []),
    "effective": oracle.get("effective", []),
    "excluded": oracle.get("excluded", []),
    "cli_exit_status": cli_status,
    "oracle_exit_status": oracle_status,
    "complete": complete,
    "status": "passed" if not errors else "failed",
    "limitations": ["Zero findings do not establish absence of bugs.", "Credo results do not establish equivalence to SonarCloud native Java analysis."],
    "errors": sorted(set(errors)),
}

temp = pathlib.Path(str(evidence_path) + ".tmp")
temp.write_text(json.dumps(evidence, indent=2, sort_keys=True) + "\n")
temp.replace(evidence_path)
PY

if test "$cli_status" -ne 0 || test "$oracle_status" -ne 0 || test "$snapshot_status" -ne 0; then
  exit 1
fi
python3 - "$out/evidence.json" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as evidence:
    if json.load(evidence).get("status") != "passed":
        raise SystemExit(1)
PY
python3 - "$out/evidence.json" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as evidence_file:
    evidence = json.load(evidence_file)
print("CREDO_EVIDENCE status={status} complete={complete} maintained={maintained} effective={effective} excluded={excluded} revision={revision} trigger_revision={trigger_revision}".format(
    status=evidence["status"], complete=str(evidence["complete"]).lower(),
    maintained=len(evidence["maintained"]), effective=len(evidence["effective"]),
    excluded=len(evidence["excluded"]), revision=evidence["revision"],
    trigger_revision=evidence["trigger_revision"]))
PY
