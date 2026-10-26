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
        self.assertIn('timeout: 300', block)
        # Text output by design: the gate streams plain CI output instead of a JSON envelope.
        self.assertNotIn('output_format: json', block)
        # The local gate compares obligations without executing native profiles.
        self.assertIn('scripts/agentflow_stage_checks.py --ci-parity', block)
        self.assertNotIn('MIX_ENV=test', block)
        self.assertNotIn('scripts/ci_unit_tests.sh', block)
        self.assertNotIn('mix test', block)

    def test_gate_command_invokes_read_only_wrapper_parity(self):
        gate = self.workflow.split('  - id: ci_baseline', 1)[1].split('  - id: ', 1)[0]
        run = re.search(r"run:\s*['\"]([^'\"]+)['\"]", gate)
        self.assertIsNotNone(run)
        self.assertEqual(run.group(1), 'python3 scripts/agentflow_stage_checks.py --ci-parity')
        parity_source = (ROOT/'scripts/agentflow_stage_checks.py').read_text()
        self.assertIn('scripts/ci_unit_tests.sh', parity_source)
        self.assertIn('quality-baseline.yml', parity_source)

    def test_completed_check_pipeline_is_untouched(self):
        from test.scripts.agentflow_branch_test import AGENTFLOW
        order = AGENTFLOW.workflow_step_order(ROOT/'.agentflow/workflow.yml')
        self.assertEqual(order, ('product', 'product_challenge', 'product_decision', 'product_check',
                                 'architecture', 'plan_ready', 'tasks_ready', 'develop', 'develop_ready',
                                 'ci_baseline', 'qa', 'qa_ready', 'review', 'evidence_ready'))
