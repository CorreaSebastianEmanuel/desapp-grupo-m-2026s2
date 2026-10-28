"""Mechanical route guard for the no-behavior fast lane (see docs/WORKFLOW_SPEED.md)."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from scripts import thinflow

REPO_ROOT = Path(__file__).resolve().parents[2]
SCRIPT = REPO_ROOT / "scripts" / "fast_lane_check.py"


def git(root, *args):
    return subprocess.run(
        ["git", "-C", str(root), *args], capture_output=True, text=True, check=True
    )


def init_repo(path: Path) -> None:
    git(path, "init", "--quiet", "--initial-branch=main")
    git(path, "config", "user.email", "test@example.com")
    git(path, "config", "user.name", "Fast Lane Test")


def write(path: Path, relative: str, content: str = "change\n") -> None:
    target = path / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")


def commit(path: Path, message: str) -> None:
    git(path, "add", "-A")
    git(path, "commit", "--quiet", "-m", message)


def run_guard(root: Path, base: str):
    return subprocess.run(
        [sys.executable, str(SCRIPT), "--base", base, "--root", str(root)],
        capture_output=True,
        text=True,
        check=False,
    )


class FastLaneCheckTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        init_repo(self.root)
        write(self.root, "README.md", "base\n")
        commit(self.root, "base")

    def test_all_no_behavior_paths_are_allowed(self):
        paths = [
            "docs/SPEED_NOTE.md",
            "AGENTS.md",
            "REVIEW.md",
            "specs/900-docs/spec.md",
            "specs/900-docs/assessment.md",
            "specs/900-docs/evaluation.md",
        ]
        selection = thinflow.select(REPO_ROOT, paths)
        self.assertEqual(selection["tier"], "low")
        self.assertEqual(selection["checks"], ["fast-lane"])
        for path in paths:
            write(self.root, path)
        commit(self.root, "docs only")
        result = run_guard(self.root, "HEAD~1")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("fast lane allowed", result.stdout)
        for path in paths:
            self.assertIn(path, result.stdout)

    def test_untracked_no_behavior_files_are_checked_without_commit(self):
        write(self.root, "backlog/feedback/TASK-900.md")
        result = run_guard(self.root, "HEAD")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("backlog/feedback/TASK-900.md", result.stdout)

    def test_application_paths_are_denied(self):
        write(self.root, "docs/CHANGES.md")
        write(self.root, "specs/900-docs/spec.md")
        write(self.root, "lib/football_market/domain/model.ex", "defmodule Changed\n")
        write(self.root, "config/test.exs", "import Config\n")
        commit(self.root, "mixed change")
        result = run_guard(self.root, "HEAD~1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("lib/football_market/domain/model.ex", result.stderr)
        self.assertIn("config/test.exs", result.stderr)
        self.assertNotIn("lib/football_market", result.stdout)

    def test_untracked_application_file_is_denied_without_commit(self):
        write(self.root, "lib/football_market/web/leak.ex")
        result = run_guard(self.root, "HEAD")
        self.assertEqual(result.returncode, 1)
        self.assertIn("lib/football_market/web/leak.ex", result.stderr)

    def test_root_level_application_files_are_denied(self):
        write(self.root, "mix.exs", "changed\n")
        commit(self.root, "mix change")
        result = run_guard(self.root, "HEAD~1")
        self.assertEqual(result.returncode, 1)
        self.assertIn("mix.exs", result.stderr)

    def test_clean_tree_reports_nothing(self):
        result = run_guard(self.root, "HEAD")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("no changes between HEAD and base", result.stdout)


if __name__ == "__main__":
    unittest.main()
