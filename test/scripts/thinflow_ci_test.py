import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class ThinFlowCIContractTest(unittest.TestCase):
    def test_one_always_reporting_gate_aggregates_every_required_job(self):
        workflow = (ROOT / ".github/workflows/quality-baseline.yml").read_text()
        self.assertIn("name: ThinFlow required", workflow)
        self.assertIn("if: always()", workflow)
        self.assertIn("needs: [quality-baseline, end-to-end, sonarcloud]", workflow)
        self.assertIn('[[ "$QUALITY_RESULT" == success ]]', workflow)
        self.assertIn('[[ "$E2E_RESULT" == success ]]', workflow)
        self.assertIn('[[ "$SONAR_RESULT" == success ]]', workflow)

    def test_sonar_runs_inside_the_aggregate_dependency_graph(self):
        quality = (ROOT / ".github/workflows/quality-baseline.yml").read_text()
        sonar = (ROOT / ".github/workflows/sonarcloud.yml").read_text()
        self.assertIn("uses: ./.github/workflows/sonarcloud.yml", quality)
        self.assertIn("workflow_call:", sonar)
        self.assertNotRegex(sonar, r"(?m)^  pull_request:")
        self.assertNotRegex(sonar, r"(?m)^  push:")


if __name__ == "__main__":
    unittest.main()
