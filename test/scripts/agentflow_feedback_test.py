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
