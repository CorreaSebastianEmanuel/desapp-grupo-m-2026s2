#!/usr/bin/env python3
import importlib.machinery
import importlib.util
import subprocess
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[2] / "agentflow"
LOADER = importlib.machinery.SourceFileLoader("agentflow_module", str(SCRIPT))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
AGENTFLOW = importlib.util.module_from_spec(SPEC)
LOADER.exec_module(AGENTFLOW)


def result(returncode=0, stdout="", stderr=""):
    return subprocess.CompletedProcess([], returncode, stdout, stderr)


class AgentflowBranchTest(unittest.TestCase):
    def setUp(self):
        self.task = Path("TASK.md")
        self.metadata = {"id": "TASK-003", "title": "Continuous integration quality baseline"}

    def test_task_branch_is_deterministic(self):
        with patch.object(AGENTFLOW, "meta", return_value=self.metadata):
            self.assertEqual(
                AGENTFLOW.task_branch(self.task),
                "003-continuous-integration-quality-baseline",
            )

    def test_starting_from_main_creates_and_switches_feature_branch(self):
        calls = []

        def fake_git(*args, **_kwargs):
            calls.append(args)
            if args == ("branch", "--show-current"):
                return result(stdout="main\n")
            if args[:3] == ("show-ref", "--verify", "--quiet"):
                return result(returncode=1)
            return result()

        with patch.object(AGENTFLOW, "meta", return_value=self.metadata), patch.object(
            AGENTFLOW, "git", side_effect=fake_git
        ):
            branch = AGENTFLOW.ensure_feature_branch(self.task)

        self.assertEqual(branch, "003-continuous-integration-quality-baseline")
        self.assertIn(("switch", "-c", branch), calls)

    def test_resume_switches_to_existing_feature_branch(self):
        calls = []

        def fake_git(*args, **_kwargs):
            calls.append(args)
            if args == ("branch", "--show-current"):
                return result(stdout="main\n")
            if args[:3] == ("show-ref", "--verify", "--quiet"):
                return result()
            return result()

        with patch.object(AGENTFLOW, "meta", return_value=self.metadata), patch.object(
            AGENTFLOW, "git", side_effect=fake_git
        ):
            AGENTFLOW.ensure_feature_branch(self.task)

        self.assertIn(("switch", "003-continuous-integration-quality-baseline"), calls)

    def test_publish_rejects_non_matching_branch(self):
        with patch.object(AGENTFLOW, "meta", return_value=self.metadata), patch.object(
            AGENTFLOW, "git", return_value=result(stdout="another-branch\n")
        ):
            with self.assertRaisesRegex(RuntimeError, "expected 003-continuous"):
                AGENTFLOW.publish(self.task, self.metadata, Path("specs/003-example"))


if __name__ == "__main__":
    unittest.main()
