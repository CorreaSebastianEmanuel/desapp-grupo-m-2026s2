import json
import runpy
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace


class FeedbackLoopTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        root = Path(self.tmp.name)
        self.task = root / "backlog" / "TASK-001-example.md"
        self.task.parent.mkdir(parents=True)
        self.task.write_text(
            "---\nid: TASK-001\ntitle: Example\ntype: task\ncheckpoint: CP1\n"
            "priority: high\nstatus: blocked\ndepends_on: none\nactive_run: run-1\n"
            "---\n\n## Outcome\n\nExample outcome.\n",
            encoding="utf-8",
        )
        self.api = runpy.run_path(str(Path(__file__).parents[1] / "agentflow"))
        globals_ = self.api["add_feedback"].__globals__
        globals_["ROOT"] = root
        globals_["BACKLOG"] = root / "backlog"
        globals_["FEEDBACK"] = root / "backlog" / "feedback"
        globals_["RUNS"] = root / ".agentflow" / "runs"
        globals_["WORKFLOW"] = root / ".agentflow" / "workflow.yml"
        globals_["SPEC_RUNS"] = root / ".specify" / "workflows" / "runs"
        self.run_dir = globals_["SPEC_RUNS"] / "run-1"
        self.run_dir.mkdir(parents=True)
        globals_["RUNS"].mkdir(parents=True)
        state = {
            "run_id": "run-1", "status": "completed", "current_step_index": 12,
            "current_step_id": "review", "step_results": {
                "product": {"status": "completed"},
                "product_challenge": {"status": "completed"},
                "product_decision": {"status": "completed"},
                "product_check": {"status": "completed"},
                "architecture": {"status": "completed"},
                "plan_ready": {"status": "completed"},
                "tasks": {"status": "completed"},
                "tasks_ready": {"status": "completed"},
                "develop": {"status": "completed"},
                "develop_ready": {"status": "completed"},
                "qa": {"status": "completed"},
                "qa_ready": {"status": "completed"},
                "review": {"status": "completed"},
            }, "inputs": {"spec": "old"},
        }
        (self.run_dir / "state.json").write_text(json.dumps(state), encoding="utf-8")
        (self.run_dir / "inputs.json").write_text(json.dumps({"inputs": {"spec": "old"}}), encoding="utf-8")
        (self.run_dir / "log.jsonl").write_text("", encoding="utf-8")

    def tearDown(self):
        self.tmp.cleanup()

    def test_feedback_rewinds_and_is_added_to_context(self):
        self.api["add_feedback"](SimpleNamespace(
            task="TASK-001", message="Keep adapters outside the domain.", stage="architecture"
        ))

        state = json.loads((self.run_dir / "state.json").read_text(encoding="utf-8"))
        inputs = json.loads((self.run_dir / "inputs.json").read_text(encoding="utf-8"))
        feedback = (self.task.parent / "feedback" / "TASK-001.md").read_text(encoding="utf-8")
        task_text = self.task.read_text(encoding="utf-8")

        self.assertEqual("paused", state["status"])
        self.assertEqual("architecture", state["current_step_id"])
        self.assertEqual(4, state["current_step_index"])
        self.assertEqual(
            {"product", "product_challenge", "product_decision", "product_check"},
            set(state["step_results"]),
        )
        self.assertIn("Keep adapters outside the domain.", feedback)
        self.assertIn("Keep adapters outside the domain.", inputs["inputs"]["spec"])
        self.assertIn("status: wip", task_text)
        self.assertTrue(list(self.run_dir.glob("state.before-feedback-*.json")))


class ProductDecisionProbeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.feature = self.root / "specs" / "001-example"
        (self.feature / "handoffs").mkdir(parents=True)
        (self.root / ".specify").mkdir()
        (self.root / ".specify" / "feature.json").write_text(
            json.dumps({"feature_directory": "specs/001-example"}), encoding="utf-8"
        )
        for relative in ("spec.md", "handoffs/product.md", "handoffs/product-challenge.md"):
            (self.feature / relative).write_text("Evidence.\n", encoding="utf-8")
        self.probe = runpy.run_path(
            str(Path(__file__).parents[1] / "scripts" / "product_decision_probe.py")
        )["probe"]

    def tearDown(self):
        self.tmp.cleanup()

    def write_decision(self, marker):
        (self.feature / "handoffs" / "product-decision.md").write_text(
            marker + "\n\nRationale.\n", encoding="utf-8"
        )

    def test_reads_required_human_check(self):
        self.write_decision("human_check_required: true")
        result = self.probe(self.root)
        self.assertTrue(result["required"])
        self.assertEqual(
            (self.feature / "handoffs" / "product-decision.md").resolve(),
            Path(result["file"]).resolve(),
        )

    def test_reads_automatic_continuation(self):
        self.write_decision("human_check_required: false")
        self.assertFalse(self.probe(self.root)["required"])

    def test_rejects_missing_or_ambiguous_marker(self):
        self.write_decision("human_check_required: maybe")
        with self.assertRaisesRegex(RuntimeError, "must start exactly"):
            self.probe(self.root)


class WorkflowArtifactProbeTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.feature = self.root / "specs" / "001-example"
        (self.feature / "handoffs").mkdir(parents=True)
        (self.root / ".specify").mkdir()
        (self.root / ".specify" / "feature.json").write_text(
            json.dumps({"feature_directory": "specs/001-example"}), encoding="utf-8"
        )
        self.probe = runpy.run_path(
            str(Path(__file__).parents[1] / "scripts" / "workflow_artifact_probe.py")
        )["probe"]

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, relative, content="Evidence.\n"):
        (self.feature / relative).write_text(content, encoding="utf-8")

    def test_accepts_complete_plan_artifacts(self):
        for relative in ("spec.md", "plan.md", "handoffs/architecture.md"):
            self.write(relative)
        self.assertTrue(self.probe(self.root, "plan")["valid"])

    def test_rejects_missing_canonical_tasks_before_development(self):
        for relative in ("spec.md", "plan.md", "handoffs/tasks.md"):
            self.write(relative)
        with self.assertRaisesRegex(RuntimeError, "tasks.md"):
            self.probe(self.root, "tasks")

    def test_rejects_empty_artifact(self):
        for relative in ("spec.md", "plan.md", "handoffs/architecture.md"):
            self.write(relative)
        self.write("plan.md", "   \n")
        with self.assertRaisesRegex(RuntimeError, "plan.md"):
            self.probe(self.root, "plan")

    def test_accepts_passing_qa_report(self):
        self.write("qa-report.md", "Evidence.\n\nVerdict: PASS\n")
        self.write("handoffs/qa.md")
        self.assertTrue(self.probe(self.root, "qa")["valid"])

    def test_rejects_failed_qa_before_final_review(self):
        self.write("qa-report.md", "Blocker.\n\nVerdict: FAIL\n")
        self.write("handoffs/qa.md")
        with self.assertRaisesRegex(RuntimeError, "Final review will not run"):
            self.probe(self.root, "qa")


if __name__ == "__main__":
    unittest.main()
