"""ThinFlow is the new default while captured Agentflow 2.3 remains resumable."""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class VersionedWorkflowTest(unittest.TestCase):
    def setUp(self):
        self.thin = (ROOT / ".agentflow/workflow.yml").read_text()
        self.legacy = (ROOT / ".specify/workflows/desapp-delivery/workflow.yml").read_text()

    @staticmethod
    def ids(document):
        return tuple(re.findall(r"(?m)^  - id: ([a-z_]+)\s*$", document))

    def test_default_has_one_builder_one_evaluator_and_deterministic_gates(self):
        self.assertEqual(self.ids(self.thin),
                         ("outcome_ready", "develop", "candidate_ready", "qa", "qa_ready"))
        self.assertEqual(self.thin.count("integration: \"{{ inputs.integration }}\""), 2)
        self.assertIn("scripts/thinflow.py check", self.thin)
        self.assertIn("scripts/thinflow.py evaluate", self.thin)
        self.assertNotIn("product_challenge", self.thin)
        self.assertNotIn("plan_ready", self.thin)
        self.assertNotIn("review-report.md", self.thin)
        self.assertIn("REVIEW.md", self.thin)
        self.assertIn("Only blocking findings may produce `Verdict: FAIL`", self.thin)
        self.assertIn("review the repair delta and affected surfaces", self.thin)

    def test_legacy_snapshot_retains_full_agentflow_23_order(self):
        self.assertEqual(self.ids(self.legacy),
                         ("product", "product_challenge", "product_decision", "product_check",
                          "architecture", "plan_ready", "tasks_ready", "develop", "develop_ready",
                          "ci_baseline", "qa", "qa_ready", "review", "evidence_ready"))
        self.assertIn('version: "2.3.0"', self.legacy)

    def test_workflows_are_explicitly_versioned_and_not_synchronized(self):
        self.assertIn('version: "3.0.0"', self.thin)
        self.assertNotEqual(self.thin, self.legacy)
        self.assertIn("one independent evaluator", self.thin)


if __name__ == "__main__":
    unittest.main()
