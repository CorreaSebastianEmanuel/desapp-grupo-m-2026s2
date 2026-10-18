#!/usr/bin/env python3
"""Mechanical route guard for the no-behavior fast lane.

See docs/WORKFLOW_SPEED.md. Fails (exit 1) when the change set between the
base ref and HEAD (plus untracked files) contains any path outside the
documented no-behavior prefixes; exits 0 only when every path is allowed.
This is a path check, not a semantic classifier: anything not listed is
rejected by default (fail-closed).
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

ALLOWED_TOP_FILES = frozenset({"AGENTS.md", "CLAUDE.md", "README.md"})
ALLOWED_PREFIXES = ("docs/", "backlog/", ".agents/", ".opencode/")


def run_git(root: Path, *args: str) -> str:
    result = subprocess.run(
        ["git", "-C", str(root), *args],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise SystemExit(f"git {' '.join(args[:2])} failed: {result.stderr.strip()}")
    return result.stdout


def changed_paths(root: Path, base: str) -> list[str]:
    merge_base = run_git(root, "merge-base", "HEAD", base).strip()
    committed = run_git(root, "diff", "--name-only", merge_base).splitlines()
    untracked = run_git(root, "ls-files", "--others", "--exclude-standard").splitlines()
    return sorted({path.replace("\\", "/") for path in committed + untracked if path.strip()})


def violation(path: str) -> str | None:
    top = path.split("/", 1)[0]
    if "/" in path:
        if path.startswith(ALLOWED_PREFIXES):
            return None
    elif path in ALLOWED_TOP_FILES:
        return None
    return top if "/" in path else repr(path)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", default="origin/main", help="base ref to diff against")
    parser.add_argument("--root", default=".", help="repository root to operate on")
    arguments = parser.parse_args()

    root = Path(arguments.root).resolve()
    paths = changed_paths(root, arguments.base)
    if not paths:
        print("fast lane: no changes between HEAD and base; nothing to check")
        return
    offenders = [(path, violation(path)) for path in paths]
    failed = [(path, top) for path, top in offenders if top is not None]
    if failed:
        print("fast lane DENIED: changes outside the no-behavior scope:\n", file=sys.stderr)
        for path, top in failed:
            print(f"  {path} (top-level: {top})", file=sys.stderr)
        print("Run the full Agentflow flow for these changes.", file=sys.stderr)
        raise SystemExit(1)
    print(f"fast lane allowed: {len(paths)} no-behavior path(s)")
    for path in paths:
        print(f"  {path}")


if __name__ == "__main__":
    main()
