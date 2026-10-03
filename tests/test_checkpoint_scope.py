"""Repository regressions for the authorized withdrawal of checkpoint automation."""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class CheckpointScopeTest(unittest.TestCase):
    def test_no_checkpoint_acceptance_runtime_is_shipped(self):
        for folder, pattern in [(".github/workflows", "cp*-acceptance*"),
                                ("scripts", "cp[123]_acceptance*"),
                                ("scripts", "cp[123]_demo*"),
                                ("scripts", "cp[123]_hosted_receipts*")]:
            self.assertEqual([], list((ROOT / folder).glob(pattern)))
        self.assertFalse((ROOT / "config/cp1_acceptance.json").exists())
        self.assertNotIn("cp1-acceptance.yml", (ROOT / "README.md").read_text())

    def test_retained_quality_workflows_and_seed_regression_exist(self):
        for name in ["quality-baseline.yml", "sonarcloud.yml", "agentflow-finalize.yml"]:
            self.assertTrue((ROOT / ".github/workflows" / name).is_file())
        self.assertIn("a failed seed leaves no owned database workers logging after its error",
                      (ROOT / "test/mix/tasks/catalog.seed_test.exs").read_text())

    def test_removed_cp2_task_leaves_no_dangling_dependencies(self):
        self.assertEqual([], list((ROOT / "backlog").glob("TASK-035-*.md")))
        tasks = list((ROOT / "backlog").glob("TASK-*.md"))
        ids = {re.search(r"(?m)^id: (TASK-\d+)$", p.read_text()).group(1) for p in tasks}
        for task in tasks:
            dependency_line = re.search(r"(?m)^depends_on: (.+)$", task.read_text()).group(1)
            for dependency in dependency_line.split(","):
                if dependency.strip() != "none":
                    self.assertIn(dependency.strip(), ids, str(task))
        release = (ROOT / "backlog/TASK-052-final-quality-gate-and-release.md").read_text()
        self.assertIn("TASK-034", release)
        self.assertIn("manual demonstrations", release)


if __name__ == "__main__":
    unittest.main()
