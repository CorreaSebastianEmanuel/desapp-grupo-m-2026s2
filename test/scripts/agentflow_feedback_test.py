"""Feedback ownership, pending impact and no-mutation conflicts."""
import json
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

    def native_run(self, *, stage='qa_ready', feedback=False):
        run='native-feedback'
        runs=self.root/'.specify/workflows/runs'
        directory=runs/run
        directory.mkdir(parents=True)
        patcher=patch.object(AGENTFLOW,'SPEC_RUNS',runs)
        patcher.start();self.addCleanup(patcher.stop)
        text=self.task.read_text()
        text=text.replace('active_run: none',f'active_run: {run}')
        if 'workflow:' not in text:
            text=text.replace('active_run:', 'workflow: thinflow-v1\nactive_run:')
        else:
            text=text.replace('workflow: agentflow-v2','workflow: thinflow-v1')
        self.task.write_text(text)
        order=['outcome_ready','develop','candidate_ready','qa','qa_ready']
        source=''.join(f'- id: {step}\n  type: shell\n  run: "true"\n' for step in order)
        (directory/'workflow.yml').write_text('steps:\n'+source)
        state={'status':'completed','current_step_id':stage,'current_step_index':order.index(stage),
               'step_results':{step:{'status':'completed','output':step} for step in order},
               'inputs':{'spec':'old'},
               'execution':{'version':2,'offset':0,'initial':{},'sequence':{
                   'source':source,'nodes':[{'phase':'done','active':False} for _ in order]}}}
        (directory/'state.json').write_text(json.dumps(state))
        (directory/'inputs.json').write_text(json.dumps({'inputs':{'spec':'old'}}))
        (directory/'log.jsonl').write_text('')
        if feedback:
            path=AGENTFLOW.feedback_path(self.task)
            path.parent.mkdir(parents=True,exist_ok=True)
            path.write_text('# Feedback\n\n## Feedback 1\n\n- Restart from: develop\n- Impact: implementation\n\nRepair the cited regression.\n')
        return run,directory,state

    def test_feedback_rewind_invalidates_native_tree_and_preserves_checkpoint_backup(self):
        run,directory,state=self.native_run()
        original=(directory/'workflow.yml').read_bytes()
        self.assertTrue(AGENTFLOW.rewind_run(self.task,run,'develop'))
        after=json.loads((directory/'state.json').read_text())
        self.assertNotIn('execution',after)
        self.assertEqual(after['status'],'paused')
        self.assertEqual(after['current_step_index'],1)
        self.assertEqual(after['step_results'],{'outcome_ready':state['step_results']['outcome_ready']})
        backup=next(directory.glob('state.before-feedback-*.json'))
        self.assertEqual(json.loads(backup.read_text())['execution'],state['execution'])
        self.assertEqual((directory/'workflow.yml').read_bytes(),original)

    def test_replayed_feedback_recovery_is_idempotent_without_another_feedback_entry(self):
        run,directory,_=self.native_run(stage='develop',feedback=True)
        feedback=AGENTFLOW.feedback_path(self.task).read_bytes()
        self.assertTrue(AGENTFLOW.recover_completed_feedback_rewind(self.task,run))
        self.assertFalse(AGENTFLOW.recover_completed_feedback_rewind(self.task,run))
        self.assertEqual(AGENTFLOW.feedback_path(self.task).read_bytes(),feedback)
        after=json.loads((directory/'state.json').read_text())
        self.assertEqual(after['status'],'paused')
        self.assertNotIn('execution',after)

    def test_completed_final_stage_preserves_publication_retry(self):
        run,directory,_=self.native_run(feedback=True)
        before=(directory/'state.json').read_bytes()
        self.assertFalse(AGENTFLOW.recover_completed_feedback_rewind(self.task,run))
        self.assertEqual((directory/'state.json').read_bytes(),before)

    def test_completed_pointer_without_feedback_does_not_implicitly_rewind(self):
        run,directory,_=self.native_run(stage='develop')
        before=(directory/'state.json').read_bytes()
        self.assertFalse(AGENTFLOW.recover_completed_feedback_rewind(self.task,run))
        self.assertEqual((directory/'state.json').read_bytes(),before)

    def test_unknown_execution_schema_refuses_rewind_without_mutation(self):
        run,directory,state=self.native_run()
        for version in [3,2.0,True]:
            with self.subTest(version=version):
                state['execution']['version']=version
                (directory/'state.json').write_text(json.dumps(state))
                before=(directory/'state.json').read_bytes()
                with self.assertRaisesRegex(SystemExit,'Unsupported Spec Kit execution checkpoint'):
                    AGENTFLOW.rewind_run(self.task,run,'develop')
                self.assertEqual((directory/'state.json').read_bytes(),before)
                self.assertEqual(list(directory.glob('state.before-feedback-*.json')),[])

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

    def test_third_feedback_cycle_is_allowed_and_fourth_preserves_history(self):
        for index in range(3):
            AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003', message=f'Cycle {index+1}',
                                                   stage=None, impact=['implementation']))
        path=self.root/'backlog/feedback/TASK-003.md'
        before=path.read_bytes()
        with self.assertRaisesRegex(SystemExit, 'Feedback limit reached'):
            AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003', message='Fourth cycle',
                                                   stage=None, impact=['implementation']))
        self.assertEqual(path.read_bytes(),before)
        self.assertEqual(before.count(b'## Feedback '),3)

    def test_preexisting_cycle_count_uses_configured_cap_without_resetting_history(self):
        path=self.root/'backlog/feedback/TASK-003.md'
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('# Feedback — TASK-003\n\n' +
                        ''.join(f'## Feedback {index}\n\nPrior cycle {index}\n\n' for index in (1, 2)))
        before=path.read_bytes()
        with patch.object(AGENTFLOW, 'MAX_FEEDBACK_CYCLES', 2):
            with self.assertRaisesRegex(SystemExit, 'Feedback limit reached'):
                AGENTFLOW.add_feedback(SimpleNamespace(task='TASK-003', message='Must not reset cap',
                                                       stage=None, impact=['implementation']))
        self.assertEqual(path.read_bytes(), before)
        config_path=self.root/'.agentflow/config.toml'
        config_path.parent.mkdir(parents=True, exist_ok=True)
        config_path.write_text('max_feedback_cycles = 3\n')
        config=config_path.read_text()
        self.assertIn('max_feedback_cycles = 3', config)

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
