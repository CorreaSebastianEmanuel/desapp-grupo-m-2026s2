#!/usr/bin/env python3
"""Execute a canonical verification check with bounded console output."""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import time
import uuid
from pathlib import Path

try:
    from .agentflow_verification import check_identity, current_receipt, digest, input_fingerprint, load_json, manifest, source_fingerprint
    from .workflow_artifact_probe import active_feature
except ImportError:
    from agentflow_verification import check_identity, current_receipt, digest, input_fingerprint, load_json, manifest, source_fingerprint
    from workflow_artifact_probe import active_feature


def execute_check(check: dict, root: Path, evidence: Path) -> int:
    env = {**os.environ, **check.get("env", {})}
    with evidence.open("w", encoding="utf-8") as output:
        try:
            return subprocess.run(check["argv"], cwd=root, env=env, stdout=output, stderr=subprocess.STDOUT).returncode
        except OSError:
            output.write("Required executable could not be started.\n")
            return 127
        except KeyboardInterrupt:
            output.write("Check interrupted.\n")
            return 130


def run_check(root: Path, feature: Path, ident: str, *, reuse: bool = False, stage: str = "develop") -> int:
    if stage not in ("develop", "qa", "review"):
        raise RuntimeError("Unknown verification stage")
    if reuse and stage != "develop":
        raise RuntimeError("Receipt reuse is allowed only in development; QA must execute independently")
    data = manifest(feature)
    check = next((c for c in data["checks"] if c["id"] == ident), None)
    if check is None:
        raise RuntimeError("Unknown required check")
    handoffs = feature / "handoffs"
    handoffs.mkdir(exist_ok=True)
    receipt_path = handoffs / f"check-{ident}.json"
    before = source_fingerprint(root)
    inputs = input_fingerprint(feature)
    identity = check_identity(check)
    if reuse and check.get("reuse", True) and not check.get("runtime", False):
        try:
            receipt = current_receipt(root, feature, check, before, inputs)
        except RuntimeError:
            receipt = None
        if receipt and receipt.get("stage", "develop") == "develop":
            print(json.dumps({"check": ident, "exit_code": 0, "reused": True,
                              "evidence": receipt["evidence"]}))
            return 0
    history_path = handoffs / f"check-attempts-{stage}-{ident}.json"
    scope = {"source": before, "inputs": inputs, "check_identity": identity}
    history = load_json(history_path) if history_path.exists() else {}
    if not isinstance(history, dict):
        raise RuntimeError("Invalid check attempt history")
    if history.get("scope") != scope:
        history = {"scope": scope, "consecutive_failures": 0, "elapsed_seconds": 0}
    failures = history.get("consecutive_failures")
    elapsed = history.get("elapsed_seconds")
    if type(failures) is not int or failures < 0 or type(elapsed) not in (int, float) or elapsed < 0:
        raise RuntimeError("Invalid check attempt history")
    if failures >= 2:
        print(json.dumps({"check": ident, "exit_code": 2, "retry_limit_reached": True,
                          "consecutive_failures": failures, "elapsed_seconds": elapsed,
                          "evidence": history.get("evidence"),
                          "action": "Stop and diagnose the failure; do not repeat unchanged checks."}))
        return 2
    # Invalidate prior success before spawning anything, including on cancellation.
    receipt_path.write_text(json.dumps({"exit_code": None, "check_identity": check_identity(check)}) + "\n")
    directory = root / ".agentflow/runs/checks"
    directory.mkdir(parents=True, exist_ok=True)
    evidence = directory / f"{uuid.uuid4().hex}.log"
    started = time.monotonic()
    code = execute_check(check, root, evidence)
    duration = round(time.monotonic() - started, 3)
    after = source_fingerprint(root)
    changed = before != after or inputs != input_fingerprint(feature)
    receipt = {"exit_code": code, "check_identity": check_identity(check), "source_before": before,
               "source_after": after, "inputs": inputs, "evidence": evidence.relative_to(root).as_posix(),
               "evidence_sha256": digest(evidence.read_bytes()), "stage": stage,
               "elapsed_seconds": duration}
    receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
    history.update(consecutive_failures=failures + 1 if code or changed else 0,
                   elapsed_seconds=round(elapsed + duration, 3), evidence=receipt["evidence"])
    history_path.write_text(json.dumps(history, indent=2) + "\n")
    print(json.dumps({"check": ident, "exit_code": code, "source_changed": before != after,
                      "inputs_changed": changed, "reused": False, "elapsed_seconds": duration,
                      "consecutive_failures": history["consecutive_failures"],
                      "retry_limit_reached": history["consecutive_failures"] >= 2,
                      "evidence": receipt["evidence"]}))
    return code or (1 if changed else 0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("check")
    parser.add_argument("--reuse", action="store_true", help="reuse valid same-stage development evidence")
    parser.add_argument("--stage", choices=("develop", "qa", "review"), default="develop")
    args = parser.parse_args()
    try:
        root = Path.cwd()
        raise SystemExit(run_check(root, active_feature(root), args.check, reuse=args.reuse, stage=args.stage))
    except RuntimeError as error:
        raise SystemExit(str(error)) from error
