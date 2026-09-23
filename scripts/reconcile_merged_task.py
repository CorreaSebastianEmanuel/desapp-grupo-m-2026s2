#!/usr/bin/env python3
"""Finalize a reviewed Agentflow task after its implementation PR is merged."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def terminal_verdict(path: Path) -> str:
    lines = [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    return lines[-1] if lines else ""


def task_id_from_head(head_ref: str) -> str:
    match = re.fullmatch(r"(\d{3})-[a-z0-9][a-z0-9-]*", head_ref)
    if not match:
        raise ValueError(f"Not an Agentflow feature branch: {head_ref}")
    return f"TASK-{match.group(1)}"


def replace_field(text: str, key: str, value: str) -> str:
    updated, count = re.subn(
        rf"(?m)^{re.escape(key)}:\s*.*$", f"{key}: {value}", text, count=1
    )
    if count != 1:
        raise ValueError(f"Task metadata is missing {key}")
    return updated


def reconcile(root: Path, head_ref: str) -> Path | None:
    task_id = task_id_from_head(head_ref)
    matches = list((root / "backlog").glob(f"{task_id}-*.md"))
    if len(matches) != 1:
        raise ValueError(f"Expected exactly one backlog file for {task_id}")

    task = matches[0]
    text = task.read_text(encoding="utf-8")
    status = re.search(r"(?m)^status:\s*(\S+)\s*$", text)
    if not status:
        raise ValueError(f"Task metadata is missing status: {task}")
    if status.group(1) == "done":
        return None
    if status.group(1) != "review":
        raise ValueError(f"Refusing to finalize {task_id} from {status.group(1)}")

    feature_matches = [path for path in (root / "specs").glob(f"{task_id[5:]}-*") if path.is_dir()]
    if len(feature_matches) != 1:
        raise ValueError(f"Expected exactly one feature directory for {task_id}")
    feature = feature_matches[0]
    for report in ("qa-report.md", "review-report.md"):
        path = feature / report
        if not path.is_file() or terminal_verdict(path) != "Verdict: PASS":
            raise ValueError(f"Refusing to finalize {task_id}: {report} has not passed")

    text = replace_field(text, "status", "done")
    text = replace_field(text, "active_run", "none")
    task.write_text(text, encoding="utf-8")
    return task


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--head-ref", required=True)
    parser.add_argument("--root", type=Path, default=ROOT)
    args = parser.parse_args()
    changed = reconcile(args.root.resolve(), args.head_ref)
    print(f"Finalized {changed.relative_to(args.root.resolve())}" if changed else "Task already finalized")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
