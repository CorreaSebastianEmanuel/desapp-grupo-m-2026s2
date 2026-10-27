#!/usr/bin/env python3
"""ThinFlow's deterministic contract, risk selection, checks and readiness.

Agent sessions may implement or evaluate a candidate. This module owns the
parts that must not depend on an LLM: path classification, check execution,
retry limits, evidence freshness and terminal verdict parsing.
"""
from __future__ import annotations

import argparse
import fnmatch
import hashlib
import json
import os
import re
import subprocess
import time
from pathlib import Path

try:
    from scripts.agentflow_feature import expected_branch, metadata, resolve_feature, task_for_id, terminal_verdict
    from scripts.agentflow_verification import atomic_json, load_json
except ModuleNotFoundError:
    from agentflow_feature import expected_branch, metadata, resolve_feature, task_for_id, terminal_verdict
    from agentflow_verification import atomic_json, load_json

TIERS = {"low": 0, "standard": 1, "high": 2}
REQUIRED_SPEC_SECTIONS = ("Outcome", "Acceptance", "Scope", "Non-goals", "Risk")
LOCAL_ROOT = Path(".agentflow/runs/thinflow")


def policy(root: Path) -> dict:
    root = root.resolve()
    path = root / ".agentflow" / "thinflow.json"
    data = load_json(path)
    if not isinstance(data, dict) or set(data) != {"schema_version", "base_ref", "checks", "rules"}:
        raise RuntimeError("ThinFlow policy has unsupported fields")
    if type(data["schema_version"]) is not int or data["schema_version"] != 1 or not isinstance(data["base_ref"], str):
        raise RuntimeError("ThinFlow policy requires schema_version 1 and a base_ref")
    checks = data["checks"]
    if not isinstance(checks, dict) or not checks:
        raise RuntimeError("ThinFlow policy requires checks")
    for ident, check in checks.items():
        if not re.fullmatch(r"[a-z][a-z0-9-]*", ident) or not isinstance(check, dict):
            raise RuntimeError("ThinFlow check identifiers are invalid")
        if set(check) - {"argv", "env", "timeout_seconds"}:
            raise RuntimeError(f"ThinFlow check {ident} has unsupported fields")
        argv = check.get("argv")
        env = check.get("env", {})
        timeout = check.get("timeout_seconds")
        if not isinstance(argv, list) or not argv or not all(isinstance(value, str) and value and "\0" not in value for value in argv):
            raise RuntimeError(f"ThinFlow check {ident} requires a safe argv")
        if not isinstance(env, dict) or not all(re.fullmatch(r"[A-Z][A-Z0-9_]*", key) and isinstance(value, str) for key, value in env.items()):
            raise RuntimeError(f"ThinFlow check {ident} has an invalid environment")
        if type(timeout) is not int or timeout < 1 or timeout > 3600:
            raise RuntimeError(f"ThinFlow check {ident} has an invalid timeout")
    rules = data["rules"]
    if not isinstance(rules, list) or not rules:
        raise RuntimeError("ThinFlow policy requires path rules")
    seen = set()
    for rule in rules:
        if not isinstance(rule, dict) or set(rule) != {"id", "patterns", "tier", "checks"}:
            raise RuntimeError("ThinFlow path rule is invalid")
        if not re.fullmatch(r"[a-z][a-z0-9-]*", rule["id"]) or rule["id"] in seen:
            raise RuntimeError("ThinFlow path rule identifiers are invalid or duplicated")
        seen.add(rule["id"])
        if rule["tier"] not in TIERS or not isinstance(rule["patterns"], list) or not rule["patterns"]:
            raise RuntimeError(f"ThinFlow rule {rule['id']} has an invalid tier or patterns")
        if not all(isinstance(pattern, str) and pattern and not pattern.startswith("/") for pattern in rule["patterns"]):
            raise RuntimeError(f"ThinFlow rule {rule['id']} has unsafe patterns")
        if not isinstance(rule["checks"], list) or not rule["checks"] or not set(rule["checks"]).issubset(checks):
            raise RuntimeError(f"ThinFlow rule {rule['id']} references unknown checks")
    return data


def git(root: Path, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    result = subprocess.run(["git", *args], cwd=root, capture_output=True, text=True)
    if check and result.returncode:
        raise RuntimeError(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result


def changed_paths(root: Path, base: str) -> list[str]:
    merge_base = git(root, "merge-base", "HEAD", base).stdout.strip()
    committed = git(root, "diff", "--name-only", merge_base).stdout.splitlines()
    working = git(root, "diff", "--name-only").stdout.splitlines()
    staged = git(root, "diff", "--cached", "--name-only").stdout.splitlines()
    untracked = git(root, "ls-files", "--others", "--exclude-standard").stdout.splitlines()
    paths = {path.replace("\\", "/") for path in committed + working + staged + untracked if path.strip()}
    return sorted(path for path in paths if path != ".specify/feature.json" and
                  not re.fullmatch(r"specs/[^/]+/evaluation\.md", path) and
                  not path.startswith((".agentflow/runs/", ".specify/workflows/runs/")))


def select(root: Path, paths: list[str], data: dict | None = None) -> dict:
    data = data or policy(root)
    matched, blocked, selected_checks, all_hits = [], [], [], []
    tier = "low"
    for path in paths:
        hits = [rule for rule in data["rules"] if any(fnmatch.fnmatchcase(path, pattern) for pattern in rule["patterns"])]
        if not hits:
            blocked.append(path)
            tier = "high"
            continue
        for rule in hits:
            all_hits.append(rule)
            if TIERS[rule["tier"]] > TIERS[tier]:
                tier = rule["tier"]
            if rule["id"] not in matched:
                matched.append(rule["id"])
    if not paths:
        blocked.append("<empty-change-set>")
    if not blocked:
        # Lower-tier checks are alternatives, not additive overhead. A docs
        # guard must not fail a legitimate high-risk code change merely
        # because the same PR also updates its documentation.
        for rule in all_hits:
            if rule["tier"] != tier:
                continue
            for ident in rule["checks"]:
                if ident not in selected_checks:
                    selected_checks.append(ident)
    return {
        "schema_version": 1,
        "tier": tier,
        "paths": paths,
        "matched_rules": matched,
        "checks": selected_checks,
        "blocked_paths": blocked,
        "policy_sha256": hashlib.sha256((root / ".agentflow" / "thinflow.json").read_bytes()).hexdigest(),
    }


def task_outcome(task: Path) -> str:
    text = task.read_text(encoding="utf-8")
    match = re.search(r"(?ms)^## Outcome\s*\n+(.*?)(?=^## |\Z)", text)
    if not match or not match.group(1).strip():
        raise RuntimeError("ThinFlow task requires a nonempty Outcome section")
    return match.group(1).strip()


def prepare(root: Path, task_id: str) -> Path:
    root = root.resolve()
    task = task_for_id(root, task_id)
    fields = metadata(task)
    if fields.get("workflow") != "thinflow-v1":
        raise RuntimeError(f"{task_id} is not a ThinFlow task")
    branch = git(root, "branch", "--show-current").stdout.strip()
    if branch != expected_branch(task):
        raise RuntimeError(f"ThinFlow requires branch {expected_branch(task)}, found {branch}")
    association = resolve_feature(root, task, head_ref=branch, allow_missing=True)
    if association is None:
        feature = root / "specs" / branch
        feature.mkdir(parents=True, exist_ok=False)
        title = fields["title"]
        outcome = task_outcome(task)
        (feature / "spec.md").write_text(
            f"# Outcome specification: {title}\n\n"
            f"**Feature Branch**: `{branch}`\n\n"
            f"**Task**: `{task_id}`\n\n"
            "## Outcome\n\n" + outcome + "\n\n"
            "## Acceptance\n\n- [ ] The outcome is demonstrated by observable evidence.\n\n"
            "## Scope\n\n- Implement only the outcome and directly required tests or documentation.\n\n"
            "## Non-goals\n\n- Unrelated product behavior and opportunistic refactors.\n\n"
            "## Risk\n\n- Declared: pending; deterministic path classification is authoritative.\n\n"
            "## Decisions\n\n- None recorded.\n",
            encoding="utf-8",
        )
    else:
        feature = association.feature
    pointer = root / ".specify" / "feature.json"
    pointer.parent.mkdir(parents=True, exist_ok=True)
    pointer.write_text(json.dumps({"feature_directory": feature.relative_to(root).as_posix()}) + "\n", encoding="utf-8")
    validate_spec(feature)
    return feature


def validate_spec(feature: Path) -> None:
    text = (feature / "spec.md").read_text(encoding="utf-8")
    missing = [section for section in REQUIRED_SPEC_SECTIONS if not re.search(rf"(?m)^## {re.escape(section)}\s*$", text)]
    if missing:
        raise RuntimeError("ThinFlow spec is missing sections: " + ", ".join(missing))
    acceptance = re.search(r"(?ms)^## Acceptance\s*\n+(.*?)(?=^## |\Z)", text)
    if not acceptance or not re.search(r"(?m)^\s*- \[[ xX]\] \S", acceptance.group(1)):
        raise RuntimeError("ThinFlow spec requires at least one acceptance example")


def material_digest(root: Path, selection: dict, feature: Path) -> str:
    h = hashlib.sha256(json.dumps(selection, sort_keys=True).encode())
    excluded = {feature.joinpath("evaluation.md").relative_to(root).as_posix()}
    for name in selection["paths"]:
        if name in excluded or name.startswith((".agentflow/runs/", ".specify/workflows/runs/")) or name == ".specify/feature.json":
            continue
        path = root / name
        content = os.fsencode(os.readlink(path)) if path.is_symlink() else path.read_bytes() if path.is_file() else b"<deleted>"
        if name.startswith("backlog/TASK-"):
            content = re.sub(rb"(?m)^(status|active_run):.*$", rb"\1:<lifecycle>", content)
        h.update(name.encode() + b"\0" + hashlib.sha256(content).digest())
    return h.hexdigest()


def local_dir(root: Path, task_id: str) -> Path:
    if not re.fullmatch(r"TASK-\d{3}", task_id):
        raise RuntimeError("Invalid ThinFlow task identity")
    path = root / LOCAL_ROOT / task_id
    if not path.resolve().is_relative_to((root / LOCAL_ROOT).resolve()):
        raise RuntimeError("Unsafe ThinFlow evidence path")
    return path


def captured_text(value: str | bytes | None) -> str:
    """Normalize subprocess output without letting a timeout escape accounting."""
    if isinstance(value, bytes):
        return value.decode("utf-8", errors="replace")
    return value if isinstance(value, str) else ""


def run_checks(root: Path, task_id: str) -> dict:
    root = root.resolve()
    task = task_for_id(root, task_id)
    branch = git(root, "branch", "--show-current").stdout.strip()
    feature = resolve_feature(root, task, head_ref=branch).feature
    validate_spec(feature)
    data = policy(root)
    selection = select(root, changed_paths(root, data["base_ref"]), data)
    if selection["blocked_paths"]:
        raise RuntimeError("ThinFlow has unmapped changed paths: " + ", ".join(selection["blocked_paths"]))
    evidence = local_dir(root, task_id)
    evidence.mkdir(parents=True, exist_ok=True)
    digest = material_digest(root, selection, feature)
    attempts_path = evidence / "attempts.json"
    attempts = load_json(attempts_path) if attempts_path.exists() else {"schema_version": 1, "attempts": []}
    if attempts.get("schema_version") != 1 or not isinstance(attempts.get("attempts"), list):
        raise RuntimeError("ThinFlow attempt history is invalid")
    unchanged_failures = [row for row in attempts["attempts"] if row.get("digest") == digest and row.get("result") != "passed"]
    if len(unchanged_failures) >= 2:
        raise RuntimeError("ThinFlow retry limit reached: repair a relevant input or split the task")
    started = time.monotonic()
    results = []
    base = data["base_ref"]
    for ident in selection["checks"]:
        definition = data["checks"][ident]
        argv = [part.replace("{base}", base) for part in definition["argv"]]
        env = os.environ.copy(); env.update(definition.get("env", {}))
        check_started = time.monotonic()
        try:
            result = subprocess.run(argv, cwd=root, env=env, capture_output=True, text=True, timeout=definition["timeout_seconds"])
            status = "passed" if result.returncode == 0 else "failed"
            output = result.stdout + result.stderr
            code = result.returncode
        except subprocess.TimeoutExpired as error:
            status, code = "interrupted", None
            output = captured_text(error.stdout) + captured_text(error.stderr)
        log = evidence / f"{ident}.log"
        log.write_text(output[-200000:], encoding="utf-8", errors="replace")
        results.append({"id": ident, "status": status, "exit_code": code,
                        "elapsed_ms": int((time.monotonic() - check_started) * 1000),
                        "evidence": log.relative_to(root).as_posix(),
                        "evidence_sha256": hashlib.sha256(log.read_bytes()).hexdigest()})
        if status != "passed":
            break
    result = "passed" if len(results) == len(selection["checks"]) and all(row["status"] == "passed" for row in results) else "failed"
    attempt = {"digest": digest, "result": result, "elapsed_ms": int((time.monotonic() - started) * 1000), "checks": results}
    attempts["attempts"].append(attempt)
    atomic_json(attempts_path, attempts)
    receipt = {"schema_version": 1, "task": task_id, "branch": branch, "digest": digest,
               "selection": selection, "result": result, "checks": results}
    atomic_json(evidence / "candidate.json", receipt)
    if result != "passed":
        failed = next((row for row in results if row["status"] != "passed"), None)
        raise RuntimeError(f"ThinFlow required check failed: {failed['id'] if failed else 'unknown'}")
    print(json.dumps({"task": task_id, "tier": selection["tier"], "checks": selection["checks"], "ready": True}))
    return receipt


def readiness(root: Path, task_id: str, require_evaluation: bool = True) -> dict:
    root = root.resolve()
    task = task_for_id(root, task_id)
    branch = git(root, "branch", "--show-current").stdout.strip()
    feature = resolve_feature(root, task, head_ref=branch).feature
    validate_spec(feature)
    receipt = load_json(local_dir(root, task_id) / "candidate.json")
    data = policy(root)
    selection = select(root, changed_paths(root, data["base_ref"]), data)
    digest = material_digest(root, selection, feature)
    if receipt.get("schema_version") != 1 or receipt.get("task") != task_id or receipt.get("branch") != branch:
        raise RuntimeError("ThinFlow candidate evidence belongs to another task or branch")
    if receipt.get("result") != "passed" or receipt.get("selection") != selection or receipt.get("digest") != digest:
        raise RuntimeError("ThinFlow candidate evidence is failed, stale or incomplete")
    rows = receipt.get("checks")
    if not isinstance(rows, list) or [row.get("id") for row in rows if isinstance(row, dict)] != selection["checks"]:
        raise RuntimeError("ThinFlow candidate has missing or unexpected required checks")
    if any(row.get("status") != "passed" or row.get("exit_code") != 0 for row in rows):
        raise RuntimeError("ThinFlow candidate has a missing or failed required check")
    evidence_root = local_dir(root, task_id).resolve()
    for row in rows:
        relative = row.get("evidence")
        if not isinstance(relative, str) or Path(relative).is_absolute():
            raise RuntimeError("ThinFlow candidate has invalid check evidence")
        path = (root / relative).resolve()
        if not path.is_relative_to(evidence_root) or not path.is_file() or row.get("evidence_sha256") != hashlib.sha256(path.read_bytes()).hexdigest():
            raise RuntimeError("ThinFlow candidate check evidence is missing or altered")
    if require_evaluation:
        evaluation = feature / "evaluation.md"
        if not evaluation.is_file() or terminal_verdict(evaluation) != "Verdict: PASS":
            raise RuntimeError("ThinFlow independent evaluation has not passed")
    return {"task": task_id, "tier": selection["tier"], "checks": selection["checks"], "ready": True}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".")
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("prepare", "select", "check", "evaluate"):
        command = sub.add_parser(name)
        command.add_argument("task")
    args = parser.parse_args()
    root = Path(args.root).resolve()
    if args.command == "prepare":
        print(json.dumps({"feature": prepare(root, args.task).relative_to(root).as_posix(), "ready": True}))
    elif args.command == "select":
        data = policy(root)
        result = select(root, changed_paths(root, data["base_ref"]), data)
        print(json.dumps(result, indent=2))
        if result["blocked_paths"]:
            return 1
    elif args.command == "check":
        run_checks(root, args.task)
    else:
        print(json.dumps(readiness(root, args.task), indent=2))
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        raise SystemExit(str(error)) from error
