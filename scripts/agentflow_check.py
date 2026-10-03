#!/usr/bin/env python3
"""Execute a canonical verification check with bounded console output."""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import uuid
from pathlib import Path

try:
    from .agentflow_verification import check_identity, digest, input_fingerprint, manifest, source_fingerprint
    from .workflow_artifact_probe import active_feature
except ImportError:
    from agentflow_verification import check_identity, digest, input_fingerprint, manifest, source_fingerprint
    from workflow_artifact_probe import active_feature


def run_check(root: Path, feature: Path, ident: str) -> int:
    data = manifest(feature)
    check = next((c for c in data["checks"] if c["id"] == ident), None)
    if check is None:
        raise RuntimeError("Unknown required check")
    handoffs = feature / "handoffs"
    handoffs.mkdir(exist_ok=True)
    receipt_path = handoffs / f"check-{ident}.json"
    # Invalidate prior success before spawning anything, including on cancellation.
    receipt_path.write_text(json.dumps({"exit_code": None, "check_identity": check_identity(check)}) + "\n")
    before = source_fingerprint(root)
    inputs = input_fingerprint(feature)
    directory = root / ".agentflow/runs/checks"
    directory.mkdir(parents=True, exist_ok=True)
    evidence = directory / f"{uuid.uuid4().hex}.log"
    env = {**os.environ, **check.get("env", {})}
    with evidence.open("w", encoding="utf-8") as output:
        try:
            code = subprocess.run(check["argv"], cwd=root, env=env, stdout=output, stderr=subprocess.STDOUT).returncode
        except OSError:
            code = 127
            output.write("Required executable could not be started.\n")
        except KeyboardInterrupt:
            code = 130
            output.write("Check interrupted.\n")
    after = source_fingerprint(root)
    receipt = {"exit_code": code, "check_identity": check_identity(check), "source_before": before,
               "source_after": after, "inputs": inputs, "evidence": evidence.relative_to(root).as_posix(),
               "evidence_sha256": digest(evidence.read_bytes())}
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({"check": ident, "exit_code": code, "source_changed": before != after,
                      "evidence": receipt["evidence"]}))
    return code or (1 if before != after else 0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("check")
    args = parser.parse_args()
    try:
        root = Path.cwd()
        raise SystemExit(run_check(root, active_feature(root), args.check))
    except RuntimeError as error:
        raise SystemExit(str(error)) from error
