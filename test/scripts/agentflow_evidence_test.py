"""Real subprocess receipt lifecycle, integrity, retry and stage isolation."""
import json
import sys
from unittest.mock import patch
from scripts.agentflow_check import run_check, safe_failure_diagnostics
from scripts import agentflow_verification as v
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture, applicability, verification


class EvidenceTest(DeliveryFixture):
    def setUp(self):
        super().setUp()
        self.data = verification([sys.executable, '-c', "print('fixture check')"])
        self.json('specs/003-example/verification.json', self.data)
        self.baseline()

    def test_failure_diagnostics_expose_only_allowlisted_profile_locations(self):
        evidence = self.root/'profile.log'
        evidence.write_text(
            'CP1_PROFILE_STAGE committed-fixture:test/example_test.exs\n'
            'CP1_PROFILE_FAILURES count=2\n'
            'CP1_PROFILE_FAILURE_LOCATION test/example_test.exs:41\n'
            'expected secret payload and exception details\n'
        )

        self.assertEqual(safe_failure_diagnostics(evidence), {
            'stages': ['committed-fixture:test/example_test.exs'],
            'failure_counts': ['2'],
            'locations': ['test/example_test.exs:41'],
        })

    def receipt(self, stage='develop'):
        return v.current_receipt(self.root, self.feature, self.data['checks'][0],
                                 v.source_fingerprint(self.root), v.input_fingerprint(self.feature), stage=stage)

    def test_schema_two_local_receipts_leave_no_feature_attempt_files(self):
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 0)
        self.assertEqual(self.receipt()['schema_version'], 2)
        self.assertFalse((self.feature/'handoffs/check-fixture.json').exists())

    def test_required_artifacts_block_real_receipt_resume_and_finalization(self):
        from contextlib import ExitStack
        from types import SimpleNamespace
        from scripts.agentflow_evidence import finalize
        from scripts.agentflow_artifacts import validate
        from test.scripts.agentflow_branch_test import AGENTFLOW
        self.write('specs/003-example/plan.md', '```json artifact-applicability\n' +
                   json.dumps(applicability(True)) + '\n```\n')
        self.write('specs/003-example/tasks.md', '- [X] T001 Build behavior\n')
        for name in ('qa-report.md', 'review-report.md'):
            self.write('specs/003-example/'+name, 'Verdict: PASS\n')
        # All except research exist before execution: refusal must be shared artifact
        # enforcement, not stale proof caused by deleting a file after the check.
        for name in ('data-model.md', 'contracts/interface.md', 'quickstart.md'):
            self.write('specs/003-example/'+name, 'Required fixture design\n')
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 0)
        self.assertEqual(self.receipt()['state'], 'passed')
        with self.assertRaisesRegex(RuntimeError, 'research.md'):
            validate(self.feature, stage='develop')
        with self.assertRaisesRegex(RuntimeError, 'research.md'):
            v.readiness(self.root, self.feature)
        with self.assertRaisesRegex(RuntimeError, 'research.md'):
            finalize(self.root, 'TASK-003')
        task = self.root/'backlog/TASK-003-example.md'
        task.write_text(task.read_text().replace('active_run: none', 'active_run: saved'))
        # Exercise the actual resume consumer for current and legacy snapshots.
        for state in ({'current_step_id':'qa'},
                      {'current_step_id':'qa', 'steps':[{'id':'develop'},{'id':'qa'}]}):
            with ExitStack() as stack:
                for name, value in {'ROOT':self.root, 'BACKLOG':self.root/'backlog'}.items():
                    stack.enter_context(patch.object(AGENTFLOW, name, value))
                for name, value in {'read_run_state':state, 'ensure_feature_branch':'003-example',
                                    'session_feature':None, 'recover_orphaned_run':None,
                                    'field':None}.items():
                    stack.enter_context(patch.object(AGENTFLOW, name, return_value=value))
                stack.enter_context(patch.object(AGENTFLOW.models, 'resume_selection', return_value=({}, False)))
                stack.enter_context(patch.object(AGENTFLOW.models, 'save', return_value=self.root/'assignment.json'))
                stack.enter_context(patch.object(AGENTFLOW.models, 'bind'))
                monitor = stack.enter_context(patch.object(AGENTFLOW, 'monitor_process'))
                with self.assertRaisesRegex(RuntimeError, 'research.md'):
                    AGENTFLOW.resume(SimpleNamespace(task='TASK-003', dry_run=False))
                monitor.assert_not_called()

    def test_qa_cannot_replace_development_or_be_reused(self):
        run_check(self.root, self.feature, 'fixture')
        original = self.receipt()
        run_check(self.root, self.feature, 'fixture', stage='qa')
        self.assertEqual(self.receipt(), original)
        self.assertEqual(self.receipt('qa')['stage'], 'qa')
        with self.assertRaises(RuntimeError):
            run_check(self.root, self.feature, 'fixture', reuse=True, stage='qa')

    def test_tampering_and_source_edits_block_reuse(self):
        run_check(self.root, self.feature, 'fixture')
        receipt = self.receipt()
        (self.root/receipt['evidence']).write_text('altered')
        with self.assertRaises(RuntimeError): self.receipt()
        run_check(self.root, self.feature, 'fixture')
        self.write('new_source.py', 'new input')
        with self.assertRaises(RuntimeError): self.receipt()

    def test_irrelevant_edit_cannot_reset_two_failure_budget(self):
        self.data['checks'][0].update(argv=[sys.executable, '-c', 'raise SystemExit(9)'], retry_inputs=['source.py'])
        self.json('specs/003-example/verification.json', self.data)
        self.write('source.py', 'affected')
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 9)
        self.write('unrelated.txt', 'irrelevant')
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 9)
        self.write('unrelated.txt', 'still irrelevant')
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 2)
        self.write('source.py', 'actual repair')
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 9)

    def test_pass_then_failure_invalidates_pass_and_preserves_legacy_files(self):
        self.write('specs/003-example/handoffs/check-fixture.json', 'historical bytes')
        run_check(self.root, self.feature, 'fixture')
        with patch('scripts.agentflow_check.execute_check', return_value=7):
            self.assertEqual(run_check(self.root, self.feature, 'fixture'), 7)
        with self.assertRaises(RuntimeError): self.receipt()
        self.assertEqual((self.feature/'handoffs/check-fixture.json').read_text(), 'historical bytes')

    def test_checklist_and_implementation_tasks_still_block(self):
        with self.assertRaisesRegex(RuntimeError, 'Incomplete implementation task'):
            v.readiness(self.root, self.feature)

    def test_interrupted_receipt_counts_once_and_blocks_third_unchanged_attempt(self):
        import hashlib
        from scripts.agentflow_verification import receipt_path,atomic_json,check_identity,retry_fingerprint,digest
        self.data['checks'][0].update(argv=[sys.executable,'-c','raise SystemExit(8)'],retry_inputs=['affected.py'])
        self.json('specs/003-example/verification.json',self.data)
        self.write('affected.py','actual input')
        run_check(self.root,self.feature,'fixture')
        check=self.data['checks'][0]
        local=receipt_path(self.root,self.feature,check)
        scope={'source':retry_fingerprint(self.root,self.feature,check),'inputs':v.input_fingerprint(self.feature),'check_identity':check_identity(check)}
        atomic_json(local,{'state':'running','scope':scope})
        self.assertEqual(run_check(self.root,self.feature,'fixture'),2)
        self.assertEqual(run_check(self.root,self.feature,'fixture'),2)

    def test_explicit_reuse_does_not_spawn_and_changed_command_forces_execution(self):
        run_check(self.root,self.feature,'fixture')
        with patch('scripts.agentflow_check.execute_check',side_effect=AssertionError('reused check spawned')):
            self.assertEqual(run_check(self.root,self.feature,'fixture',reuse=True),0)
        self.data['checks'][0]['argv']=[sys.executable,'-c',"print('different actual command')"]
        self.json('specs/003-example/verification.json',self.data)
        self.assertEqual(run_check(self.root,self.feature,'fixture',reuse=True),0)

    def test_output_path_escape_and_wrong_workspace_fail(self):
        run_check(self.root,self.feature,'fixture')
        local=v.receipt_path(self.root,self.feature,self.data['checks'][0])
        original=json.loads(local.read_text())
        for update in ({'workspace':'wrong'}, {'stage':'qa'}, {'evidence':'../../outside.log'}):
            v.atomic_json(local,{**original,**update})
            with self.assertRaises(RuntimeError): self.receipt()

    def test_summary_is_bounded_idempotent_and_requires_independent_provenance(self):
        from scripts.agentflow_evidence import finalize
        self.write('specs/003-example/tasks.md','- [X] T001 Build behavior\n')
        for name in ('qa-report.md','review-report.md'):
            self.write('specs/003-example/'+name,'Verdict: PASS\n')
        run_check(self.root,self.feature,'fixture')
        run_check(self.root,self.feature,'fixture',stage='qa')
        with self.assertRaises(RuntimeError): finalize(self.root,'TASK-003')
        source,inputs=v.source_fingerprint(self.root),v.input_fingerprint(self.feature)
        for stage in ('qa','review'):
            name='qa-report.md' if stage=='qa' else 'review-report.md'
            self.json(f'.agentflow/runs/attestations/TASK-003/{stage}.json',
                      {'stage':stage,'attempt':stage+'-attempt','session_hash':stage+'-session',
                       'source':source,'inputs':inputs,'exit_code':0,
                       'report_sha256':v.digest((self.feature/name).read_bytes())})
        first=finalize(self.root,'TASK-003')
        output=self.feature/'evidence-summary.json'
        original=output.read_bytes()
        self.assertEqual(finalize(self.root,'TASK-003'),first)
        self.assertEqual(output.read_bytes(),original)
        for _ in range(3):
            run_check(self.root,self.feature,'fixture')
            final=finalize(self.root,'TASK-003')
            self.assertEqual(len(final['checks']),2)
            self.assertLess(len(output.read_bytes()),len(original)+200)
        (self.root/v.current_receipt(self.root,self.feature,self.data['checks'][0],source,inputs)['evidence']).unlink()
        with self.assertRaises(RuntimeError): finalize(self.root,'TASK-003')
