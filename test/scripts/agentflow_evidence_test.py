"""Real subprocess receipt lifecycle, integrity, retry and stage isolation."""
import json
import hashlib
import os
import signal
import sys
from pathlib import Path
from unittest.mock import patch
from scripts.agentflow_check import run_check, safe_failure_diagnostics
from scripts import agentflow_verification as v
from scripts.agentflow_verification import check_identity
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture, applicability, verification


class EvidenceTest(DeliveryFixture):
    def setUp(self):
        super().setUp()
        self.data = verification([sys.executable, '-c', "print('fixture check')"])
        self.json('specs/003-example/verification.json', self.data)
        self.baseline()

    def test_provider_early_exit_writes_complete_nonpass_qa_inventory(self):
        from scripts.agentflow_runtime import write_partial_qa_report
        with patch('scripts.workflow_artifact_probe.active_feature', return_value=self.feature):
            report = write_partial_qa_report(self.root, 'qa', 'provider-ended')
        text = report.read_text()
        self.assertIn('Verdict: FAIL', text)
        self.assertIn('`fixture` | unexecuted', text)

    def test_early_exit_lists_every_manifest_check_without_reflecting_private_cause(self):
        from scripts.agentflow_runtime import write_partial_qa_report
        self.data['checks'].append({**self.data['checks'][0], 'id': 'second-fixture'})
        self.data['coverage'] = {'FR-001': ['fixture', 'second-fixture'],
                                 'SC-001': ['fixture', 'second-fixture']}
        self.json('specs/003-example/verification.json', self.data)
        with patch('scripts.workflow_artifact_probe.active_feature', return_value=self.feature):
            report = write_partial_qa_report(self.root, 'qa', 'private-token-never-print')
        text = report.read_text()
        self.assertIn('`fixture` | unexecuted', text)
        self.assertIn('`second-fixture` | unexecuted', text)
        self.assertIn('Verdict: FAIL', text)
        self.assertNotIn('private-token-never-print', text)

    def test_abrupt_qa_exit_projects_partial_journal_as_nonpass_once(self):
        from scripts.agentflow_runtime import write_partial_qa_report
        self.data['checks'].append({**self.data['checks'][0], 'id': 'second-fixture'})
        self.data['coverage'] = {'FR-001': ['fixture', 'second-fixture'],
                                 'SC-001': ['fixture', 'second-fixture']}
        self.json('specs/003-example/verification.json', self.data)
        journal = self.root/'.agentflow/runs/checks/stage-journals/003-example/qa.json'
        journal.parent.mkdir(parents=True)
        journal.write_text(json.dumps({'checks': [
            {'id': 'fixture', 'status': 'passed', 'evidence': '.agentflow/runs/checks/fixture.log'},
            {'id': 'second-fixture', 'status': 'running', 'evidence': None}]}))
        with patch('scripts.workflow_artifact_probe.active_feature', return_value=self.feature):
            report = write_partial_qa_report(self.root, 'qa', 'secret-abrupt-token')
        text = report.read_text()
        self.assertIn('`fixture` | passed', text)
        self.assertIn('`second-fixture` | running', text)
        self.assertIn('Verdict: FAIL', text)
        self.assertNotIn('secret-abrupt-token', text)

    def test_handled_signal_inventory_stays_nonpass_and_retains_completed_rows(self):
        from scripts.agentflow_runtime import write_partial_qa_report
        self.data['checks'].append({**self.data['checks'][0], 'id': 'second-fixture'})
        self.data['coverage'] = {'FR-001': ['fixture', 'second-fixture'],
                                 'SC-001': ['fixture', 'second-fixture']}
        self.json('specs/003-example/verification.json', self.data)
        journal = self.root/'.agentflow/runs/checks/stage-journals/003-example/qa.json'
        journal.parent.mkdir(parents=True)
        journal.write_text(json.dumps({'checks': [
            {'id': 'fixture', 'status': 'passed', 'evidence': '.agentflow/runs/checks/fixture.log'},
            {'id': 'second-fixture', 'status': 'interrupted', 'evidence': None}]}))
        with patch('scripts.workflow_artifact_probe.active_feature', return_value=self.feature):
            report = write_partial_qa_report(self.root, 'qa', 'signal-private-data')
        text = report.read_text()
        self.assertIn('`fixture` | passed', text)
        self.assertIn('`second-fixture` | interrupted', text)
        self.assertIn('Verdict: FAIL', text)
        self.assertNotIn('signal-private-data', text)

    def test_sigkill_recovery_demotes_historical_qa_pass(self):
        import subprocess
        if os.name != 'posix':
            self.skipTest('SIGKILL process fixtures require POSIX')
        from scripts.agentflow_runtime import write_partial_qa_report
        report = self.feature/'qa-report.md'
        report.write_text('# QA\n\n| Check | Outcome | Evidence |\n|---|---|---|\n'
                          '| `fixture` | passed | old.log |\n\nVerdict: PASS\n')
        child = subprocess.Popen([sys.executable, '-c', 'import time; time.sleep(30)'])
        try:
            os.kill(child.pid, signal.SIGKILL)
            self.assertEqual(child.wait(timeout=5), -signal.SIGKILL)
        finally:
            if child.poll() is None:
                child.kill(); child.wait(timeout=5)
        with patch('scripts.workflow_artifact_probe.active_feature', return_value=self.feature):
            recovered = write_partial_qa_report(self.root, 'qa', 'kill-private-detail')
        text = recovered.read_text()
        self.assertIn('Verdict: FAIL', text)
        self.assertNotIn('Verdict: PASS', text)

    def test_failure_diagnostics_expose_only_allowlisted_profile_locations(self):
        evidence = self.root/'profile.log'
        evidence.write_text(
            'CP1_PROFILE_STAGE committed-fixture:test/example_test.exs\n'
            'CP1_PROFILE_FAILURES count=2\n'
            'CP1_PROFILE_FAILURE_LOCATION test/example_test.exs:41\n'
            'PROFILE_DISCREPANCY id=0123456789abcdef01234567 line=41\n'
            'PROFILE_DISCREPANCY id=0123456789abcdef01234567 line=41 secret=sentinel\n'
            'expected secret payload and exception details\n'
        )

        self.assertEqual(safe_failure_diagnostics(evidence), {
            'stages': ['committed-fixture:test/example_test.exs'],
            'failure_counts': ['2'],
            'locations': ['test/example_test.exs:41'],
            'profile_discrepancies': [{'id': '0123456789abcdef01234567', 'line': 41}],
        })

    def test_declared_retry_environment_changes_hashed_check_identity_without_leaking_value(self):
        check = {'argv': [sys.executable, '-c', 'pass'], 'env': {}, 'retry_env': ['CHROMIUM_PATH']}
        first_path = '/private/browser/one'
        second_path = '/private/browser/two'
        with patch.dict('os.environ', {'CHROMIUM_PATH': first_path}):
            first = check_identity(check)
        with patch.dict('os.environ', {'CHROMIUM_PATH': second_path}):
            second = check_identity(check)
        self.assertNotEqual(first, second)
        self.assertNotIn(first_path, first)
        self.assertNotIn(second_path, second)

    def test_sandbox_mode_changes_hashed_identity_without_exposing_value(self):
        check = {'argv': [sys.executable, '-c', 'pass'], 'env': {},
                 'retry_env': ['CHROMIUM_PATH', 'AGENTFLOW_CODEX_SANDBOX_MODE']}
        with patch.dict('os.environ', {'CHROMIUM_PATH': '/private/browser/chrome',
                                       'AGENTFLOW_CODEX_SANDBOX_MODE': 'workspace-write'}):
            workspace_write = check_identity(check)
        with patch.dict('os.environ', {'CHROMIUM_PATH': '/private/browser/chrome',
                                       'AGENTFLOW_CODEX_SANDBOX_MODE': 'danger-full-access'}):
            danger_full = check_identity(check)
        self.assertNotEqual(workspace_write, danger_full)
        self.assertNotIn('workspace-write', workspace_write)
        self.assertNotIn('danger-full-access', danger_full)

    def test_sandbox_mode_is_required_and_closed_before_profile_spawn(self):
        self.data['checks'][0]['retry_env'] = ['AGENTFLOW_CODEX_SANDBOX_MODE']
        self.json('specs/003-example/verification.json', self.data)
        for selected in (None, 'arbitrary-secret-value'):
            with self.subTest(selected=selected), patch.dict('os.environ', {}, clear=True):
                if selected is not None:
                    import os
                    os.environ['AGENTFLOW_CODEX_SANDBOX_MODE'] = selected
                with patch('scripts.agentflow_check.execute_check', return_value=0) as execute:
                    with self.assertRaisesRegex(RuntimeError, 'sandbox mode'):
                        run_check(self.root, self.feature, 'fixture')
                    execute.assert_not_called()

    def test_sandbox_mode_change_starts_new_retry_scope_but_same_mode_stays_blocked(self):
        import os
        self.data['checks'][0].update(
            argv=[sys.executable, '-c', 'raise SystemExit(9)'],
            retry_env=['AGENTFLOW_CODEX_SANDBOX_MODE'])
        self.json('specs/003-example/verification.json', self.data)
        with patch.dict('os.environ', {'AGENTFLOW_CODEX_SANDBOX_MODE': 'workspace-write'}):
            self.assertEqual(run_check(self.root, self.feature, 'fixture'), 9)
            self.assertEqual(run_check(self.root, self.feature, 'fixture'), 9)
            with patch.dict('os.environ', {'UNRELATED_SANDBOX_NOTE': 'cannot-reset'}):
                self.assertEqual(run_check(self.root, self.feature, 'fixture'), 2)
        with patch.dict('os.environ', {'AGENTFLOW_CODEX_SANDBOX_MODE': 'danger-full-access'}):
            self.assertEqual(run_check(self.root, self.feature, 'fixture'), 9)

    def test_manifest_rejects_invalid_retry_environment_names(self):
        self.data['checks'][0]['retry_env'] = ['CHROMIUM-PATH']
        self.json('specs/003-example/verification.json', self.data)
        with self.assertRaisesRegex(RuntimeError, 'retry_env'):
            v.manifest(self.feature)

    def test_safe_diagnostics_accept_only_closed_browser_cause_records(self):
        evidence = self.root/'browser.log'
        evidence.write_text(
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=executable-missing\n'
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=dependency-missing\n'
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=permission-denied\n'
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-timeout\n'
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed\n'
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed secret=sentinel\n'
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=forged\n'
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed\x1b[31m\n'
            'secret-sentinel /private/browser/path\n'
        )

        self.assertEqual(safe_failure_diagnostics(evidence), {
            'browser_prerequisite_causes': [
                'executable-missing', 'dependency-missing', 'permission-denied',
                'launch-timeout', 'launch-failed'
            ]
        })

    def test_profile_discrepancy_is_reported_without_legacy_profile_markers(self):
        from scripts.test_inventory import entry
        case_id = 'test.scripts.application_coverage_test.CoverageAccountingTest.test_fixture'
        case = entry('python', 'test/scripts/application_coverage_test.py', case_id, 'unit')
        self.json('config/test_profiles.json', {'schema_version': 1, 'entries': [case],
                                                'helpers': {}, 'excluded_roots': []})
        evidence = self.root/'.agentflow/runs/checks/discrepancy.log'
        evidence.parent.mkdir(parents=True)
        evidence.write_text(
            f'PROFILE_DISCREPANCY id={case["id"]} line=41\n'
            f'PROFILE_CASE_DIAGNOSTIC id={case["id"]} runner=python '
            'file=test/scripts/application_coverage_test.py '
            f'case={case_id} state=failed cause=assertion line=41 started=1 passed=0 failed=1 skipped=0\n'
            f'PROFILE_CASE_DIAGNOSTIC id={case["id"]} runner=python '
            'file=test/scripts/application_coverage_test.py case=invalid secret=sentinel\n'
        )
        self.assertEqual(safe_failure_diagnostics(evidence, self.root), {
            'profile_discrepancies': [{
                **case,
                'runner': 'python',
                'file': 'test/scripts/application_coverage_test.py',
                'state': 'failed',
                'cause': 'assertion',
                'failure_line': 41,
                'started': 1,
                'passed': 0,
                'failed': 1,
                'skipped': 0,
            }],
        })

    def test_profile_event_summary_accepts_only_bounded_aggregate_counts(self):
        evidence = self.root/'.agentflow/runs/checks/events.log'
        evidence.parent.mkdir(parents=True)
        evidence.write_text(
            'PROFILE_EVENT_SUMMARY profile=integration step=tests started=21 passed=20 failed=1 skipped=0\n'
            'PROFILE_EVENT_SUMMARY profile=integration step=tests started=21 passed=20 failed=1 skipped=0 secret=sentinel\n'
            'PROFILE_EVENT_SUMMARY profile=integration step=tests started=1000001 passed=0 failed=0 skipped=0\n'
            'PROFILE_EVENT_SUMMARY profile=other step=tests started=1 passed=0 failed=1 skipped=0\n'
            'secret-sentinel /private/test/path\n'
        )
        self.assertEqual(safe_failure_diagnostics(evidence, self.root), {
            'profile_event_summaries': [{
                'profile': 'integration', 'step': 'tests',
                'started': 21, 'passed': 20, 'failed': 1, 'skipped': 0,
            }]
        })

    def test_safe_consumer_redacts_registered_nonconventional_case_id(self):
        from scripts.profile_safe_diagnostics import parse_profile_diagnostics

        label = 'unusual synthetic QA sentinel'
        case = {
            'runner': 'python',
            'file': 'test/qa_probe.py',
            'case_id': label,
            'profile': 'unit',
        }
        case['id'] = hashlib.sha256(
            '\0'.join((case['runner'], case['file'], label)).encode()
        ).hexdigest()[:24]
        self.json('config/test_profiles.json', {'schema_version': 1, 'entries': [case]})
        evidence = self.root / '.agentflow/runs/checks/profile-diagnostic.log'
        evidence.parent.mkdir(parents=True, exist_ok=True)
        evidence.write_text(
            f"PROFILE_CASE_DIAGNOSTIC id={case['id']} runner=python "
            "file=test/qa_probe.py case=redacted state=failed cause=assertion "
            "line=1 started=1 passed=0 failed=1 skipped=0\n"
        )

        result = parse_profile_diagnostics(self.root, evidence)

        self.assertNotIn(label, json.dumps(result))
        self.assertEqual(result['profile_discrepancies'][0]['case_id'], 'redacted')

    def test_safe_consumer_preserves_aggregate_summary_step(self):
        from scripts.profile_safe_diagnostics import parse_profile_diagnostics

        self.json('config/test_profiles.json', {'schema_version': 1, 'entries': []})
        evidence = self.root / '.agentflow/runs/checks/profile-summary.log'
        evidence.parent.mkdir(parents=True, exist_ok=True)
        evidence.write_text(
            'PROFILE_EVENT_SUMMARY profile=integration step=tests started=2 '
            'passed=1 failed=1 skipped=0\n'
        )

        result = parse_profile_diagnostics(self.root, evidence)

        self.assertEqual(
            result['profile_event_summaries'],
            [{'profile': 'integration', 'step': 'tests', 'started': 2,
              'passed': 1, 'failed': 1, 'skipped': 0}],
        )

    def receipt(self, stage='develop'):
        return v.current_receipt(self.root, self.feature, self.data['checks'][0],
                                 v.source_fingerprint(self.root), v.input_fingerprint(self.feature), stage=stage)

    def test_schema_two_local_receipts_leave_no_feature_attempt_files(self):
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 0)
        self.assertEqual(self.receipt()['schema_version'], 2)
        self.assertFalse((self.feature/'handoffs/check-fixture.json').exists())

    def test_stage_attempt_token_is_bound_to_check_receipt(self):
        token = 'a' * 32
        with patch.dict('os.environ', {'AGENTFLOW_STAGE_ATTEMPT_TOKEN': token}):
            self.assertEqual(run_check(self.root, self.feature, 'fixture'), 0)
        self.assertEqual(self.receipt()['stage_attempt_token'], token)

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
                stack.enter_context(patch('scripts.agentflow_preflight.preflight_or_raise'))
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
