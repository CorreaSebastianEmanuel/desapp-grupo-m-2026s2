"""ThinFlow's executable proportional-delivery policy."""
import unittest
from pathlib import Path

from scripts import thinflow


class WorkflowSpeedPolicyTest(unittest.TestCase):
    def test_low_risk_procedure_keeps_preflight_ci_independent_gates_and_human_merge(self):
        root = Path.cwd()
        policy = thinflow.policy(root)
        selected = thinflow.select(root, ["REVIEW.md", "docs/example.md", "backlog/TASK-999-example.md"], policy)
        self.assertEqual(selected["tier"], "low")
        self.assertEqual(selected["checks"], ["fast-lane"])
        self.assertEqual(selected["blocked_paths"], [])
        docs = Path("docs/WORKFLOW_SPEED.md").read_text(encoding="utf-8")
        for phrase in ("ThinFlow required", "evaluador", "decisión humana"):
            self.assertIn(phrase, docs)

    def test_high_risk_and_workflow_changes_are_excluded_and_no_selector_added(self):
        root = Path.cwd()
        policy = thinflow.policy(root)
        selected = thinflow.select(root, ["agentflow", "docs/example.md"], policy)
        self.assertEqual(selected["tier"], "high")
        self.assertEqual(selected["checks"], ["ci-contracts", "harness-tests"])
        self.assertNotIn("fast-lane", selected["checks"])
        unknown = thinflow.select(root, ["unmapped.file"], policy)
        self.assertEqual(unknown["blocked_paths"], ["unmapped.file"])
        agentflow = Path("agentflow").read_text(encoding="utf-8")
        self.assertNotIn("--vibecode", agentflow)


if __name__ == "__main__":
    unittest.main()
