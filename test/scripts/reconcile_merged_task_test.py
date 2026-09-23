#!/usr/bin/env python3
import importlib.util
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[2] / "scripts" / "reconcile_merged_task.py"
SPEC = importlib.util.spec_from_file_location("reconcile_merged_task", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ReconcileMergedTaskTest(unittest.TestCase):
    def fixture(self, status="review", qa="PASS", review="PASS"):
        temporary = tempfile.TemporaryDirectory()
        root = Path(temporary.name)
        (root / "backlog").mkdir()
        task = root / "backlog" / "TASK-123-example.md"
        task.write_text(
            f"---\nid: TASK-123\nstatus: {status}\nactive_run: abc123\n---\n",
            encoding="utf-8",
        )
        feature = root / "specs" / "123-example"
        feature.mkdir(parents=True)
        (feature / "qa-report.md").write_text(f"QA\n\nVerdict: {qa}\n", encoding="utf-8")
        (feature / "review-report.md").write_text(
            f"Review\n\nVerdict: {review}\n", encoding="utf-8"
        )
        return temporary, root, task

    def test_merged_reviewed_task_with_both_passes_becomes_done(self):
        temporary, root, task = self.fixture()
        self.addCleanup(temporary.cleanup)

        self.assertEqual(MODULE.reconcile(root, "123-example"), task)
        contents = task.read_text(encoding="utf-8")
        self.assertIn("status: done", contents)
        self.assertIn("active_run: none", contents)

    def test_refuses_task_without_final_review_pass(self):
        temporary, root, task = self.fixture(review="FAIL")
        self.addCleanup(temporary.cleanup)

        with self.assertRaisesRegex(ValueError, "review-report.md has not passed"):
            MODULE.reconcile(root, "123-example")
        self.assertIn("status: review", task.read_text(encoding="utf-8"))

    def test_refuses_non_review_state(self):
        temporary, root, _task = self.fixture(status="wip")
        self.addCleanup(temporary.cleanup)

        with self.assertRaisesRegex(ValueError, "from wip"):
            MODULE.reconcile(root, "123-example")

    def test_ignores_non_agentflow_branch(self):
        with self.assertRaisesRegex(ValueError, "Not an Agentflow feature branch"):
            MODULE.task_id_from_head("fix/something")

    def test_merge_workflow_is_guarded_and_runs_reconciler(self):
        workflow = (SCRIPT.parents[1] / ".github" / "workflows" / "agentflow-finalize.yml").read_text(
            encoding="utf-8"
        )
        self.assertIn("types: [closed]", workflow)
        self.assertIn("pull_request.merged == true", workflow)
        self.assertIn("pull_request.base.ref == 'main'", workflow)
        self.assertIn("contents: write", workflow)
        self.assertIn("scripts/reconcile_merged_task.py", workflow)
        self.assertIn("git push origin HEAD:main", workflow)
        self.assertNotIn("pull_request_target", workflow)


if __name__ == "__main__":
    unittest.main()
