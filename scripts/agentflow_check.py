#!/usr/bin/env python3
"""Execute a canonical verification check with bounded console output."""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import time
import uuid
from glob import glob
from pathlib import Path

try:
    from .agentflow_verification import check_identity, current_receipt, digest, input_fingerprint, load_json, manifest, source_fingerprint, receipt_path, workspace, atomic_json, retry_fingerprint
    from .workflow_artifact_probe import active_feature
except ImportError:
    from agentflow_verification import check_identity, current_receipt, digest, input_fingerprint, load_json, manifest, source_fingerprint, receipt_path, workspace, atomic_json, retry_fingerprint
    from workflow_artifact_probe import active_feature


def node24_path() -> str | None:
    """Local integration preflight requires Node v24 (CI pins it explicitly);
    sandboxed agents inherit a PATH that lacks the nvm install."""
    from shutil import which

    candidates = sorted(glob(str(Path.home() / ".nvm/versions/node/v24*/bin")), reverse=True)
    hit = next((entry for entry in candidates if Path(entry, "node").is_file()), None)
    if not hit:
        return None
    current = which("node")
    if current:
        try:
            probe = subprocess.run([current, "--version"], capture_output=True, text=True, timeout=5)
            if probe.stdout.strip().startswith("v24"):
                return None
        except OSError:
            pass
    return hit


def execute_check(check: dict, root: Path, evidence: Path) -> int:
    # Mix's OS concurrency lock falls back to TCP sockets that agent sandboxes
    # intermittently deny (:eperm); disable it by default for local checks.
    # The integration profile preflight additionally requires Node v24.
    env = {
        **os.environ,
        "MIX_OS_CONCURRENCY_LOCK": os.environ.get("MIX_OS_CONCURRENCY_LOCK", "0"),
        **check.get("env", {}),
    }
    node_path = node24_path()
    if node_path:
        env["PATH"] = node_path + os.pathsep + env.get("PATH", "")
    with evidence.open("w", encoding="utf-8") as output:
        try:
            return subprocess.run(check["argv"], cwd=root, env=env, stdout=output, stderr=subprocess.STDOUT).returncode
        except OSError:
            output.write("Required executable could not be started.\n")
            return 127
        except KeyboardInterrupt:
            output.write("Check interrupted.\n")
            return 130


def safe_failure_diagnostics(evidence: Path) -> dict:
    """Expose only the location summary emitted by test_profile.sh."""
    stages = []
    failures = []
    locations = []
    for line in evidence.read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if re.fullmatch(r"CP1_PROFILE_STAGE (?:transactional|committed-fixture:[A-Za-z0-9_./-]+)", line):
            stages.append(line.removeprefix("CP1_PROFILE_STAGE "))
        elif re.fullmatch(r"CP1_PROFILE_FAILURES count=(?:[0-9]+|unknown)", line):
            failures.append(line.removeprefix("CP1_PROFILE_FAILURES count="))
        elif re.fullmatch(r"CP1_PROFILE_FAILURE_LOCATION (?:test/[A-Za-z0-9_./-]+\.exs:[0-9]+|unavailable)", line):
            locations.append(line.removeprefix("CP1_PROFILE_FAILURE_LOCATION "))
    if not (stages or failures or locations):
        return {}
    return {
        "stages": stages,
        "failure_counts": failures,
        "locations": locations,
    }


def run_check(root: Path, feature: Path, ident: str, *, reuse: bool = False, stage: str = "develop") -> int:
    if stage not in ("develop", "qa", "review"):
        raise RuntimeError("Unknown verification stage")
    if reuse and stage != "develop":
        raise RuntimeError("Receipt reuse is allowed only in development; QA must execute independently")
    data = manifest(feature)
    check = next((c for c in data["checks"] if c["id"] == ident), None)
    if check is None:
        raise RuntimeError("Unknown required check")
    local_receipt = receipt_path(root, feature, check, stage, create=True)
    local_receipt.parent.mkdir(parents=True, exist_ok=True)
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
    scope = {"source": retry_fingerprint(root, feature, check), "inputs": inputs, "check_identity": identity}
    history_path = local_receipt.parent / ('history-' + digest(json.dumps(scope, sort_keys=True).encode()) + '.json')
    history = load_json(history_path) if history_path.exists() else {}
    if not isinstance(history, dict):
        raise RuntimeError("Invalid check attempt history")
    if history.get("scope") != scope:
        history = {"scope": scope, "consecutive_failures": 0, "elapsed_seconds": 0}
    # A killed process leaves running state. Recover it once in the same budget.
    if local_receipt.exists():
        previous = load_json(local_receipt)
        if previous.get('state') == 'running' and previous.get('scope') == scope:
            history['consecutive_failures'] += 1
            previous['state'] = 'interrupted'
            atomic_json(local_receipt, previous)
            atomic_json(history_path, history)
    failures = history.get("consecutive_failures")
    elapsed = history.get("elapsed_seconds")
    if type(failures) is not int or failures < 0 or type(elapsed) not in (int, float) or elapsed < 0:
        raise RuntimeError("Invalid check attempt history")
    if failures >= 2:
        print(json.dumps({"check": ident, "exit_code": 2, "retry_limit_reached": True,
                          "consecutive_failures": failures, "elapsed_seconds": elapsed,
                          "evidence": history.get("evidence"), "cause": history.get("cause", "interrupted or failed check"),
                          "action": "Stop and diagnose the failure; do not repeat unchanged checks."}))
        return 2
    # Invalidate prior success before spawning anything, including on cancellation.
    atomic_json(local_receipt, {"schema_version": 2, "state": "running", "scope": scope,
                               "exit_code": None, "check_identity": check_identity(check)})
    directory = local_receipt.parent
    directory.mkdir(parents=True, exist_ok=True)
    evidence = directory / f"{uuid.uuid4().hex}.log"
    evidence.touch()
    started = time.monotonic()
    code = execute_check(check, root, evidence)
    duration = round(time.monotonic() - started, 3)
    after = source_fingerprint(root)
    changed = before != after or inputs != input_fingerprint(feature)
    receipt = {"schema_version": 2, "workspace": workspace(root), "feature": feature.name,
               "state": "failed" if code or changed else "passed", "exit_code": code, "check_identity": check_identity(check), "source_before": before,
               "source_after": after, "inputs": inputs, "evidence": evidence.relative_to(root).as_posix(),
               "evidence_sha256": digest(evidence.read_bytes()), "stage": stage,
               "elapsed_seconds": duration}
    atomic_json(local_receipt, receipt)
    history.update(consecutive_failures=failures + 1 if code or changed else 0,
                   elapsed_seconds=round(elapsed + duration, 3), evidence=receipt["evidence"],
                   cause=f"child exit {code}" if code else "inputs changed during execution" if changed else None)
    atomic_json(history_path, history)
    result = {"check": ident, "exit_code": code, "source_changed": before != after,
              "inputs_changed": changed, "reused": False, "elapsed_seconds": duration,
              "consecutive_failures": history["consecutive_failures"],
              "retry_limit_reached": history["consecutive_failures"] >= 2,
              "evidence": receipt["evidence"]}
    if code:
        diagnostics = safe_failure_diagnostics(evidence)
        if diagnostics:
            result["failure_diagnostics"] = diagnostics
    print(json.dumps(result))
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
