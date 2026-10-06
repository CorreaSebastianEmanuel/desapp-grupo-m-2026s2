"""Exercise post-merge validation and byte-preserving completion."""
import importlib.util
from pathlib import Path
import shutil
import subprocess
import sys
from unittest.mock import patch

from test.scripts.agentflow_feature_test import Fixture

SCRIPT=Path(__file__).resolve().parents[2]/'scripts/reconcile_merged_task.py'
SPEC=importlib.util.spec_from_file_location('reconcile_merged_task',SCRIPT)
MODULE=importlib.util.module_from_spec(SPEC);SPEC.loader.exec_module(MODULE)

class ReconcileMergedTaskTest(Fixture):
    def test_unequal_examples_command_and_function(self):
        unrelated=self.make_task('TASK-099','Unrelated')
        before=unrelated.read_bytes()
        self.assertEqual(MODULE.reconcile(self.root,'017-football-data-api-adapter'),self.task)
        self.assertIn(b'status: done',self.task.read_bytes())
        self.assertIn(b'active_run: none',self.task.read_bytes())
        self.assertEqual(unrelated.read_bytes(),before)
        self.task=self.make_task('TASK-020','Player match statistics model')
        self.feature=self.make_feature('054-player-match-statistics','020-player-match-statistics-model')
        p=subprocess.run([sys.executable,str(SCRIPT),'--head-ref','020-player-match-statistics-model','--root',str(self.root)],capture_output=True,text=True)
        self.assertEqual(p.returncode,0,p.stderr);self.assertIn('Finalized backlog/TASK-020',p.stdout)
        self.assertIn(b'status: done',self.task.read_bytes());self.assertEqual(unrelated.read_bytes(),before)
    def test_byte_preservation_crlf_and_idempotent_done_without_feature(self):
        self.task.write_bytes(self.task.read_bytes().replace(b'\n',b'\r\n').replace(b'status: review',b'status:  review  '))
        before=self.task.read_bytes()
        MODULE.reconcile(self.root,'017-football-data-api-adapter')
        self.assertEqual(self.task.read_bytes(),before.replace(b'status:  review  ',b'status:  done  ').replace(b'active_run: run-1',b'active_run: none'))
        shutil.rmtree(self.feature)
        self.task.write_bytes(self.task.read_bytes().replace(b'active_run: none\r\n',b''))
        done=self.task.read_bytes()
        self.assertIsNone(MODULE.reconcile(self.root,'017-football-data-api-adapter'))
        self.assertEqual(self.task.read_bytes(),done)
        with self.assertRaises(ValueError):MODULE.reconcile(self.root,'017-wrong')
        self.assertEqual(self.task.read_bytes(),done)
    def test_review_and_unique_update_fields_before_any_write(self):
        before=self.task.read_bytes()
        variants=[before.replace(b'status: review',b'status: '+s) for s in (b'wip',b'todo',b'blocked',b'')]
        for key in (b'status',b'active_run',b'id',b'title'):
            variants += [before.replace(key+b':',b'other_'+key+b':'),before.replace(b'---\n\n',key+b': duplicate\n---\n\n')]
        variants.append(before.replace(b'TASK-017',b'TASK-020'))
        for data in variants:
            with self.subTest(data=data):
                self.task.write_bytes(data)
                with self.assertRaises(ValueError):MODULE.reconcile(self.root,'017-football-data-api-adapter')
                self.assertEqual(self.task.read_bytes(),data)
    def test_both_report_gates_preserve_all_files(self):
        before=self.task.read_bytes()
        for name in ('qa-report.md','review-report.md'):
            for data in (None,b'',b'Verdict: FAIL\n',b'Verdict: PASS\ncommentary\n',b'Verdict: pass\n',b'\xff'):
                p=self.feature/name
                if data is None:p.unlink()
                else:p.write_bytes(data)
                with self.assertRaises(ValueError):MODULE.reconcile(self.root,'017-football-data-api-adapter')
                self.assertEqual(self.task.read_bytes(),before)
            p.write_text('Verdict: PASS\n')
    def test_wrong_branch_rejected_for_legacy_and_metadata_only(self):
        (self.feature/'spec.md').write_text('# legacy\n')
        self.feature.rename(self.feature.with_name('017-legacy'));self.feature=self.feature.with_name('017-legacy')
        before=self.task.read_bytes()
        with self.assertRaises(ValueError):MODULE.reconcile(self.root,'017-wrong')
        self.assertEqual(self.task.read_bytes(),before)
        self.task=self.make_task(extra='feature_directory: specs/017-legacy\n')
        with self.assertRaises(ValueError):MODULE.reconcile(self.root,'017-wrong')
    def test_invalid_branch(self):
        for value in ('fix/something','main','017-','17-example'):
            with self.assertRaisesRegex(ValueError,'Not an Agentflow'):MODULE.task_id_from_head(value)
    def test_atomic_write_failure_leaves_task_unchanged(self):
        before=self.task.read_bytes()
        with patch('scripts.agentflow_feature.os.replace',side_effect=OSError('disk failure')):
            with self.assertRaises((ValueError,OSError)):MODULE.reconcile(self.root,'017-football-data-api-adapter')
        self.assertEqual(self.task.read_bytes(),before)
        self.assertEqual(list(self.task.parent.glob('*.tmp')),[])

class PostMergeRejectionMatrixTest(Fixture):
    def test_shared_ownership_matrix_has_no_writes(self):
        from test.scripts.agentflow_feature_test import ASSOCIATION_CASES,poison
        for case in ASSOCIATION_CASES:
            with self.subTest(case=case):
                f=Fixture();f.setUp()
                try:
                    poison(f,case)
                    before={p:p.read_bytes() for p in (f.root/'backlog').glob('*.md')}
                    with self.assertRaises(ValueError):MODULE.reconcile(f.root,'017-football-data-api-adapter')
                    self.assertEqual({p:p.read_bytes() for p in before},before)
                finally:f.doCleanups()

class StrictPostMergeCLIRegressionTest(Fixture):
    def test_cross_file_claims_refuse_actual_command_even_done_retry(self):
        from test.scripts.agentflow_feature_test import COMPETING_ID_CASES,poison
        for case in COMPETING_ID_CASES:
            for done in (False,True):
                with self.subTest(case=case,done=done):
                    f=Fixture();f.setUp()
                    try:
                        poison(f,case)
                        if done:f.task.write_bytes(f.task.read_bytes().replace(b'status: review',b'status: done'))
                        before={p:p.read_bytes() for p in (f.root/'backlog').glob('*.md')}
                        command=subprocess.run([sys.executable,str(SCRIPT),'--head-ref','017-football-data-api-adapter','--root',str(f.root)],capture_output=True,text=True)
                        self.assertNotEqual(command.returncode,0,command.stdout)
                        self.assertIn('TASK-017',command.stderr);self.assertIn('TASK-099-other.md',command.stderr)
                        self.assertEqual({p:p.read_bytes() for p in before},before)
                    finally:f.doCleanups()
    def test_actual_command_rejects_all_hidden_metadata_even_done_retry(self):
        from test.scripts.agentflow_feature_test import METADATA_CASES,poison
        for case in METADATA_CASES:
            for done in (False,True):
                with self.subTest(case=case,done=done):
                    f=Fixture();f.setUp()
                    try:
                        poison(f,case);f.make_task('TASK-099','Unrelated')
                        if done:f.task.write_bytes(f.task.read_bytes().replace(b'status: review',b'status: done'))
                        before={p:p.read_bytes() for p in (f.root/'backlog').glob('*.md')}
                        command=subprocess.run([sys.executable,str(SCRIPT),'--head-ref','017-football-data-api-adapter','--root',str(f.root)],capture_output=True,text=True)
                        self.assertNotEqual(command.returncode,0,command.stdout)
                        self.assertIn('metadata at line',command.stderr)
                        self.assertIn(str(f.task),command.stderr)
                        self.assertEqual({p:p.read_bytes() for p in before},before)
                    finally:f.doCleanups()
    def test_quoted_crlf_completion_preserves_all_other_bytes(self):
        self.task.write_bytes(self.task.read_bytes().replace(b'status: review',b'status:  "review"  ').replace(b'active_run: run-1',b"active_run: 'run-1'").replace(b'\n',b'\r\n'))
        before=self.task.read_bytes()
        MODULE.reconcile(self.root,'017-football-data-api-adapter')
        self.assertEqual(self.task.read_bytes(),before.replace(b'"review"',b'"done"').replace(b"'run-1'",b"'none'"))
