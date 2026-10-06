#!/usr/bin/env python3
"""Fail cheaply when a canonical SDD artifact is absent or empty."""

from __future__ import annotations

import json
import glob
import re
import sys
import subprocess
from pathlib import Path

try:
    from scripts.agentflow_feature import task_id_from_head, task_for_id, resolve_feature
except ModuleNotFoundError:
    from agentflow_feature import task_id_from_head, task_for_id, resolve_feature


STAGES = {
    "plan": ("spec.md", "plan.md", "handoffs/architecture.md"),
    "tasks": ("spec.md", "plan.md", "tasks.md", "handoffs/tasks.md"),
    "develop": ("spec.md", "plan.md", "tasks.md", "handoffs/develop.md"),
    "qa": ("qa-report.md", "handoffs/qa.md"),
}

COMPLETED_TASK = re.compile(r"^\s*- \[[xX]\]\s+T\d+\b")
BACKTICK_VALUE = re.compile(r"`([^`]+)`")
ARTIFACT_SUFFIXES = {".ex", ".exs", ".json", ".md", ".sh", ".toml", ".yaml", ".yml"}


def active_feature(root: Path) -> Path:
    branch=subprocess.run(["git","branch","--show-current"],cwd=root,text=True,capture_output=True)
    if branch.returncode:
        raise RuntimeError("Cannot read current Git delivery branch")
    head=branch.stdout.strip()
    task=task_for_id(root,task_id_from_head(head))
    return resolve_feature(root,task,head_ref=head).feature


def completed_task_artifacts(root: Path, feature: Path) -> list[str]:
    """Return missing files explicitly named by completed checklist tasks."""
    tasks = (feature / "tasks.md").read_text(encoding="utf-8")
    missing: set[str] = set()
    for line in tasks.splitlines():
        if not COMPLETED_TASK.match(line):
            continue
        for value in BACKTICK_VALUE.findall(line):
            if any(character.isspace() for character in value):
                continue
            candidate = Path(value.rstrip(".,;:"))
            if candidate.suffix not in ARTIFACT_SUFFIXES:
                continue
            if candidate.is_absolute() and not candidate.is_relative_to(root):
                # Documentation routes such as `/openapi.json` are not files.
                continue
            paths = [candidate] if candidate.is_absolute() else [root / candidate]
            if len(candidate.parts) == 1:
                paths.append(feature / candidate)
            matches: list[Path] = []
            for path in paths:
                expanded = (
                    [Path(match) for match in glob.glob(str(path))]
                    if glob.has_magic(str(path))
                    else [path]
                )
                for match in expanded:
                    try:
                        match.resolve().relative_to(root.resolve())
                    except ValueError:
                        continue
                    if match.is_file():
                        matches.append(match)
            if not matches:
                missing.add(value)
    return sorted(missing)


def probe(root: Path, stage: str, require_readiness=False) -> dict[str, object]:
    if stage not in STAGES:
        raise RuntimeError(f"Unknown artifact stage: {stage}")
    feature = active_feature(root)
    missing = []
    for relative in STAGES[stage]:
        path = feature / relative
        try:
            if not path.is_file() or not path.read_text(encoding="utf-8").strip():
                missing.append(relative)
        except (OSError, UnicodeError):
            missing.append(relative)
    if missing:
        raise RuntimeError(f"Missing or empty {stage} artifact(s): {', '.join(missing)}")
    if require_readiness:
        try:
            from scripts.agentflow_verification import manifest, readiness
        except ModuleNotFoundError:
            from agentflow_verification import manifest, readiness
        manifest(feature)
        if stage == "develop":
            readiness(root, feature)
    if stage == "develop":
        missing_outputs = completed_task_artifacts(root, feature)
        if missing_outputs:
            raise RuntimeError(
                "Completed tasks reference missing artifact(s): "
                + ", ".join(missing_outputs)
                + ". Create them or leave the tasks incomplete before QA."
            )
    if stage == "qa":
        lines = [
            line.strip()
            for line in (feature / "qa-report.md").read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        verdict = lines[-1] if lines else ""
        if verdict != "Verdict: PASS":
            raise RuntimeError(
                f"QA did not pass; final line was {verdict!r}. Final review will not run."
            )
    return {"stage": stage, "valid": True, "feature": str(feature)}


if __name__ == "__main__":
    try:
        if len(sys.argv) not in (2, 3) or (len(sys.argv) == 3 and sys.argv[2] != "--readiness"):
            raise RuntimeError("Usage: workflow_artifact_probe.py <plan|tasks|develop|qa> [--readiness]")
        print(json.dumps(probe(Path.cwd(), sys.argv[1], len(sys.argv) == 3)))
    except RuntimeError as error:
        raise SystemExit(str(error)) from error
