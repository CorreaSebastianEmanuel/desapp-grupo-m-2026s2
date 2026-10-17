"""Feedback ownership, pending impact and no-mutation conflicts."""
from types import SimpleNamespace
from unittest.mock import patch
from test.scripts.agentflow_branch_test import AGENTFLOW
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture


class FeedbackTest(DeliveryFixture):
    def setUp(self):
        super().setUp()
        self.task=self.root/'backlog/TASK-003-example.md'
        for name,value in {'ROOT':self.root,'BACKLOG':self.root/'backlog','FEEDBACK':self.root/'backlog/feedback','RUNS':self.root/'.agentflow/runs'}.items():
            patcher=patch.object(AGENTFLOW,name,value);patcher.start();self.addCleanup(patcher.stop)

    def test_requested_stage_conflict_leaves_feedback_and_task_untouched(self):
        before=self.task.read_bytes()
        with self.assertRaises((RuntimeError,SystemExit)):
            AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Changed behavior',stage='development',impact=['product']))
        self.assertEqual(self.task.read_bytes(),before)
        self.assertFalse((self.root/'backlog/feedback/TASK-003.md').exists())

    def test_all_categories_route_to_earliest_owner(self):
        for impacts,stage in ((['implementation'],'develop'),(['verification'],'architecture'),
                              (['architecture'],'architecture'),(['qa'],'qa'),(['review'],'review'),
                              (['review','implementation','product'],'product')):
            self.assertEqual(AGENTFLOW.feedback_stage(impacts,None),stage)

    def test_absent_impact_is_pending_and_blocks_resume(self):
        AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Ambiguous correction',stage=None,impact=[]))
        with self.assertRaisesRegex(RuntimeError,'pending|unclassified'):
            AGENTFLOW.guard_feedback(self.task)

    def test_implementation_feedback_preserves_settled_artifacts(self):
        before=(self.feature/'spec.md').read_bytes()
        AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Fix cited parser regression',stage=None,impact=['implementation']))
        AGENTFLOW.guard_feedback(self.task)
        self.assertEqual((self.feature/'spec.md').read_bytes(),before)

    REGRESSIONS='- Required regressions: cited discrepancy plus required manifest checks'

    def test_checks_option_scopes_remediation_after_regressions(self):
        AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Fix the two named checks',
            stage=None,impact=[],checks=['ci_unit','Fixture-Check','ci_unit']))
        path=self.root/'backlog/feedback/TASK-003.md'
        text=path.read_text(encoding='utf-8')
        # Repeats are de-duplicated and ids are normalized to upper case.
        self.assertIn(f'{self.REGRESSIONS}\n- Checks: CI_UNIT, FIXTURE-CHECK\n\nFix the two named checks\n\n',text)
        lines=text.splitlines()
        self.assertGreater(lines.index('- Checks: CI_UNIT, FIXTURE-CHECK'),
                           lines.index(self.REGRESSIONS))

    def test_without_checks_the_entry_format_is_byte_identical(self):
        AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Fix cited parser regression',stage=None,impact=[]))
        text=(self.root/'backlog/feedback/TASK-003.md').read_text(encoding='utf-8')
        self.assertIn(f'{self.REGRESSIONS}\n\nFix cited parser regression\n\n',text)
        self.assertNotIn('- Checks:',text)

    def test_checks_counter_resets_per_entry(self):
        AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='First scope',stage=None,impact=[],checks=['A']))
        AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Second without scope',stage=None,impact=[]))
        text=(self.root/'backlog/feedback/TASK-003.md').read_text(encoding='utf-8')
        self.assertEqual(text.count('- Checks:'),1)
        self.assertIn('- Checks: A\n',text)
        self.assertNotIn('- Checks',text.split('## Feedback 2',1)[1])

    def test_invalid_check_identifier_refuses_the_entry(self):
        path=self.root/'backlog/feedback/TASK-003.md'
        with self.assertRaises(SystemExit):
            AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Bad scope',stage=None,impact=[],checks=['not a check id']))
        self.assertFalse(path.exists())

    def test_check_scoped_entry_is_read_back_by_feedback_guard(self):
        AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003',message='Scoped regression',stage=None,impact=['implementation'],checks=['CI_UNIT']))
        AGENTFLOW.guard_feedback(self.task)

    def test_parser_accepts_and_rejects_check_ids(self):
        parsed=AGENTFLOW.parser().parse_args(['feedback','TASK-003','msg','--checks','ci-unit','--checks','Fixture1_2'])
        self.assertEqual(parsed.checks,['CI-UNIT','FIXTURE1_2'])
        with self.assertRaises(SystemExit):
            AGENTFLOW.parser().parse_args(['feedback','TASK-003','msg','--checks','fixture.check'])
