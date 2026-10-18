"""The workflow's ci_baseline gate mirrors exactly the CI unit-tests command."""
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


class CiBaselineGateTest(unittest.TestCase):
    def setUp(self):
        self.workflow = (ROOT/'.agentflow/workflow.yml').read_text()
        self.ci = (ROOT/'.github/workflows/quality-baseline.yml').read_text()

    def ids(self):
        return re.findall(r"(?m)^  - id: ([a-z_]+)\s*$", self.workflow)

    def test_gate_sits_between_develop_ready_and_qa(self):
        order = self.ids()
        self.assertEqual(order.index('ci_baseline'), order.index('develop_ready')+1)
        self.assertEqual(order.index('qa'), order.index('ci_baseline')+1)

    def test_gate_shape(self):
        block = self.workflow.split('  - id: ci_baseline', 1)[1].split('  - id: ', 1)[0]
        self.assertIn('type: shell', block)
        self.assertIn('timeout: 1800', block)
        self.assertIn('output_format: json', block)
        self.assertIn('MIX_ENV=test', block)
        # No duplicated implementation: the gate invokes the CI script itself.
        self.assertIn('scripts/ci_unit_tests.sh', block)
        self.assertNotIn('mix test', block)

    def test_gate_command_matches_the_ci_unit_tests_job(self):
        ci_match = re.search(r'- name: Unit tests\n\s*run: (\S+)\s*$', self.ci)
        self.assertIsNotNone(ci_match)
        gate = self.workflow.split('  - id: ci_baseline', 1)[1].split('  - id: ', 1)[0]
        run = re.search(r"run:\s*['\"]([^'\"]+)['\"]", gate)
        self.assertIsNotNone(run)
        self.assertTrue(run.group(1).startswith('MIX_ENV=test '))
        self.assertEqual(run.group(1)[len('MIX_ENV=test '):].strip(), ci_match.group(1).strip())

    def test_completed_check_pipeline_is_untouched(self):
        from test.scripts.agentflow_branch_test import AGENTFLOW
        order = AGENTFLOW.workflow_step_order(ROOT/'.agentflow/workflow.yml')
        self.assertEqual(order, ('product', 'product_challenge', 'product_decision', 'product_check',
                                 'architecture', 'plan_ready', 'tasks_ready', 'develop', 'develop_ready',
                                 'ci_baseline', 'qa', 'qa_ready', 'review', 'evidence_ready'))
