"""Require the real oracle probe to reject successful corrupted generation."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path.cwd()
evidence = root / "specs/059-balanced-valuation-strategy/qa-evidence"
original = evidence / "independent-20261013"
destination = evidence / "fresh-qa-cleanup-20261013"
with tempfile.TemporaryDirectory(prefix="balanced-qa-corruption-") as directory:
    temporary = Path(directory)
    probe = (original / "oracle_probe_test.exs").read_text()
    (temporary / "oracle_probe_test.exs").write_text(probe)
    (temporary / "oracle-summary.json").write_bytes(
        (original / "oracle-summary.json").read_bytes()
    )
    (temporary / "generate_oracle.py").write_text("print('[]')\n")
    result = subprocess.run(
        ["mix", "test", "--warnings-as-errors", str(temporary / "oracle_probe_test.exs")],
        cwd=root,
        env={**os.environ, "MIX_ENV": "test"},
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    (destination / "corrupted-generator.log").write_text(result.stdout)
    assert result.returncode == 2, "corrupted generator unexpectedly accepted"
    assert 'assert checksum == summary["canonical_vectors_sha256"]' in result.stdout
    assert "QA_ORACLE subsets=511" not in result.stdout
    assert not (original / "oracle-vectors.json").exists()
    print(json.dumps({"successful_corrupted_generator_rejected": True,
                      "probe_exit_code": result.returncode,
                      "failure_point": "checksum before fixture/scoring",
                      "expanded_dataset_written": False}))
