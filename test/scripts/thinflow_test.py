import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from scripts import thinflow
from scripts import agentflow_runtime


def run(root, *args):
    return subprocess.run(args, cwd=root, check=True, capture_output=True, text=True)


class ThinFlowFixture(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "backlog").mkdir()
        (self.root / "specs").mkdir()
        (self.root / ".agentflow").mkdir()
        run(self.root, "git", "init", "-q", "-b", "main")
        run(self.root, "git", "config", "user.email", "thinflow@example.test")
        run(self.root, "git", "config", "user.name", "ThinFlow Fixture")
        (self.root / "README.md").write_text("baseline\n")
        self.write_policy(["python3", "-c", "print('ok')"])
        run(self.root, "git", "add", ".")
        run(self.root, "git", "commit", "-qm", "baseline")
        run(self.root, "git", "switch", "-qc", "001-thin-task")
        self.task = self.root / "backlog" / "TASK-001-thin-task.md"
        self.task.write_text(
            "---\nid: TASK-001\ntitle: Thin task\ntype: task\ncheckpoint: CP1\n"
            "priority: medium\nworkflow: thinflow-v1\nstatus: todo\ndepends_on: none\n"
            "active_run: none\n---\n\n## Outcome\n\nShip one bounded change.\n"
        )

    def write_policy(self, argv, timeout=10):
        data = {
            "schema_version": 1,
            "base_ref": "main",
            "checks": {"smoke": {"argv": argv, "timeout_seconds": timeout}},
            "rules": [{"id": "delivery", "patterns": ["backlog/**", "specs/**", "docs/**", ".agentflow/**"],
                       "tier": "low", "checks": ["smoke"]}],
        }
        (self.root / ".agentflow" / "thinflow.json").write_text(json.dumps(data))


class PolicyTest(ThinFlowFixture):
    def test_selection_is_deterministic_and_unmapped_paths_fail_closed(self):
        data = thinflow.policy(self.root)
        selected = thinflow.select(self.root, ["docs/guide.md", "specs/001-thin-task/spec.md"], data)
        self.assertEqual(selected["tier"], "low")
        self.assertEqual(selected["checks"], ["smoke"])
        self.assertEqual(selected["blocked_paths"], [])
        blocked = thinflow.select(self.root, ["mystery.bin"], data)
        self.assertEqual(blocked["tier"], "high")
        self.assertEqual(blocked["checks"], [])
        self.assertEqual(blocked["blocked_paths"], ["mystery.bin"])

    def test_invalid_policy_is_rejected(self):
        data = json.loads((self.root / ".agentflow" / "thinflow.json").read_text())
        data["rules"][0]["checks"] = ["missing"]
        (self.root / ".agentflow" / "thinflow.json").write_text(json.dumps(data))
        with self.assertRaisesRegex(RuntimeError, "unknown checks"):
            thinflow.policy(self.root)


class CandidateTest(ThinFlowFixture):
    def test_prepare_check_evaluate_and_freshness(self):
        feature = thinflow.prepare(self.root, "TASK-001")
        self.assertEqual(feature.name, "001-thin-task")
        self.assertIn("## Acceptance", (feature / "spec.md").read_text())
        receipt = thinflow.run_checks(self.root, "TASK-001")
        self.assertEqual(receipt["result"], "passed")
        self.assertEqual(receipt["selection"]["checks"], ["smoke"])
        with self.assertRaisesRegex(RuntimeError, "evaluation has not passed"):
            thinflow.readiness(self.root, "TASK-001")
        (feature / "evaluation.md").write_text("# Evaluation\n\nVerdict: PASS\n")
        self.assertTrue(thinflow.readiness(self.root, "TASK-001")["ready"])
        evidence = self.root / receipt["checks"][0]["evidence"]
        original = evidence.read_bytes()
        evidence.write_bytes(original + b"tampered")
        with self.assertRaisesRegex(RuntimeError, "missing or altered"):
            thinflow.readiness(self.root, "TASK-001")
        evidence.write_bytes(original)
        self.assertTrue(thinflow.readiness(self.root, "TASK-001")["ready"])
        (self.root / "docs").mkdir()
        (self.root / "docs" / "changed.md").write_text("new input\n")
        with self.assertRaisesRegex(RuntimeError, "stale"):
            thinflow.readiness(self.root, "TASK-001")

    def test_third_unchanged_failure_is_refused(self):
        self.write_policy(["python3", "-c", "raise SystemExit(7)"])
        thinflow.prepare(self.root, "TASK-001")
        for _ in range(2):
            with self.assertRaisesRegex(RuntimeError, "required check failed"):
                thinflow.run_checks(self.root, "TASK-001")
        with self.assertRaisesRegex(RuntimeError, "retry limit"):
            thinflow.run_checks(self.root, "TASK-001")

    def test_timed_out_checks_are_recorded_and_third_unchanged_attempt_is_refused(self):
        self.write_policy(
            ["python3", "-c", "import time; print('started', flush=True); time.sleep(2)"],
            timeout=1,
        )
        thinflow.prepare(self.root, "TASK-001")
        for _ in range(2):
            with self.assertRaisesRegex(RuntimeError, "required check failed"):
                thinflow.run_checks(self.root, "TASK-001")
        attempts = json.loads(
            (self.root / ".agentflow/runs/thinflow/TASK-001/attempts.json").read_text()
        )["attempts"]
        self.assertEqual([row["result"] for row in attempts], ["failed", "failed"])
        self.assertEqual([row["checks"][0]["status"] for row in attempts],
                         ["interrupted", "interrupted"])
        self.assertIn("started", (self.root / ".agentflow/runs/thinflow/TASK-001/smoke.log").read_text())
        with self.assertRaisesRegex(RuntimeError, "retry limit"):
            thinflow.run_checks(self.root, "TASK-001")

    def test_evaluation_requires_exact_terminal_pass(self):
        feature = thinflow.prepare(self.root, "TASK-001")
        thinflow.run_checks(self.root, "TASK-001")
        (feature / "evaluation.md").write_text("Verdict: PASS\nMore text\n")
        with self.assertRaisesRegex(RuntimeError, "has not passed"):
            thinflow.readiness(self.root, "TASK-001")

    def test_provider_failure_uses_thinflow_evaluation_not_legacy_manifest(self):
        feature = thinflow.prepare(self.root, "TASK-001")
        self.assertEqual(agentflow_runtime.independent_report_name(self.root.resolve(), "qa"), "evaluation.md")
        path = agentflow_runtime.write_partial_qa_report(self.root.resolve(), "qa", "provider-ended")
        self.assertEqual(path, feature / "evaluation.md")
        self.assertTrue(path.read_text().rstrip().endswith("Verdict: FAIL"))
        self.assertFalse((feature / "qa-report.md").exists())


if __name__ == "__main__":
    unittest.main()
