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
            "run_id": "run-1", "status": "completed", "current_step_index": 6,
            "current_step_id": "review", "step_results": {
                "product": {"status": "completed"},
                "product_challenge": {"status": "completed"},
                "architecture": {"status": "completed"},
                "develop": {"status": "completed"},
                "qa": {"status": "completed"},
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
        self.assertEqual(2, state["current_step_index"])
        self.assertEqual({"product", "product_challenge"}, set(state["step_results"]))
        self.assertIn("Keep adapters outside the domain.", feedback)
        self.assertIn("Keep adapters outside the domain.", inputs["inputs"]["spec"])
        self.assertIn("status: wip", task_text)
        self.assertTrue(list(self.run_dir.glob("state.before-feedback-*.json")))


if __name__ == "__main__":
    unittest.main()
