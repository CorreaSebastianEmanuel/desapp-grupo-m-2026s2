"""Reproduce CI discovery on an owned empty database, then run exact prepared CI."""
import json
import os
from pathlib import Path
import subprocess
import uuid

partition = "task066cold" + uuid.uuid4().hex[:12]
env = {**os.environ, "MIX_ENV": "test", "MIX_TEST_PARTITION": partition}
env.pop("TEST_DATABASE_NAME", None)
output = Path("tmp/task066/cold-ci") / partition
output.mkdir(parents=True)
env["CI_PROFILE_RECEIPTS"] = str(output / "receipts")


def run(name, argv):
    with (output / (name + ".log")).open("w") as log:
        result = subprocess.run(argv, env=env, stdout=log, stderr=subprocess.STDOUT,
                                timeout=1800)
    return result.returncode


assert run("create", ["mix", "ecto.create"]) == 0
assert run("empty-unit", ["sh", "scripts/test_profile.sh", "unit"]) != 0
assert "category=inventory-or-service-prerequisite" in (output / "empty-unit.log").read_text()
assert run("prepare", ["mix", "test.prepare"]) == 0
with (output / "ci.stdout").open("w") as stdout, (output / "ci.stderr").open("w") as stderr:
    result = subprocess.run(["scripts/ci_unit_tests.sh"], env=env, stdout=stdout,
                            stderr=stderr, timeout=1800)
assert result.returncode == 0, "prepared CI failed; inspect " + str(output)
assert json.loads((output / "ci.stdout").read_text()) == {
    "schema_version": 1, "status": "complete", "profiles": ["unit", "integration"]}
for profile in ("unit", "integration"):
    receipt = json.loads((output / "receipts" / (profile + ".json")).read_text())
    assert receipt["status"] == "complete"
    assert receipt["expected"] == receipt["discovered"] == receipt["executed"] == receipt["passed"] > 0
print(json.dumps({"empty_database_failure": "confirmed", "prepared_exact_ci": "passed",
                  "partition": partition, "evidence": str(output)}))
