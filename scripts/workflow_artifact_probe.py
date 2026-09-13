#!/usr/bin/env python3
"""Fail cheaply when a canonical SDD artifact is absent or empty."""

from __future__ import annotations

import json
import sys
from pathlib import Path


STAGES = {
    "plan": ("spec.md", "plan.md", "handoffs/architecture.md"),
    "tasks": ("spec.md", "plan.md", "tasks.md", "handoffs/tasks.md"),
    "develop": ("spec.md", "plan.md", "tasks.md", "handoffs/develop.md"),
    "qa": ("qa-report.md", "handoffs/qa.md"),
}


def active_feature(root: Path) -> Path:
    try:
        value = json.loads(
            (root / ".specify" / "feature.json").read_text(encoding="utf-8")
        )["feature_directory"]
    except (OSError, KeyError, TypeError, json.JSONDecodeError) as error:
        raise RuntimeError("Cannot resolve the active feature from .specify/feature.json") from error
    feature = Path(value)
    if not feature.is_absolute():
        feature = root / feature
    feature = feature.resolve()
    if feature.parent != (root / "specs").resolve():
        raise RuntimeError("Active feature must be an immediate child of specs/")
    return feature


def probe(root: Path, stage: str) -> dict[str, object]:
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
        if len(sys.argv) != 2:
            raise RuntimeError("Usage: workflow_artifact_probe.py <plan|tasks|develop|qa>")
        print(json.dumps(probe(Path.cwd(), sys.argv[1])))
    except RuntimeError as error:
        raise SystemExit(str(error)) from error
