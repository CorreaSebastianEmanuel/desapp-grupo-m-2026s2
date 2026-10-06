"""Explicit acceptance and confirmed human-merge dependency boundaries."""
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from test.scripts import agentflow_branch_test as delivery
AGENTFLOW=delivery.AGENTFLOW
result=delivery.result
from test.scripts.agentflow_feature_test import Fixture, ASSOCIATION_CASES, REPORT_VALUES, poison

class AgentflowCompletionTest(delivery.DeliveryFixture):
    def test_explicit_complete_both_reports_required(self):
        self.task.write_text(self.task.read_text().replace('status: review','status: wip'))
        before=self.task.read_bytes()
        with self.assertRaises((ValueError,SystemExit)):AGENTFLOW.complete(self.args())
        self.assertEqual(self.task.read_bytes(),before)
        self.task.write_bytes(before.replace(b'status: wip',b'status: review'))
        for name in ('qa-report.md','review-report.md'):
            for data in REPORT_VALUES:
                path=self.feature/name
                if data is None:path.unlink()
                else:path.write_bytes(data)
                before=self.task.read_bytes()
                with self.assertRaises((ValueError,SystemExit)):AGENTFLOW.complete(self.args())
                self.assertEqual(self.task.read_bytes(),before)
            path.write_text('Verdict: PASS\n')
        AGENTFLOW.complete(self.args())
        self.assertIn(b'status: done',self.task.read_bytes());self.assertIn(b'active_run: none',self.task.read_bytes())
    def test_explicit_and_dependency_rejection_matrix_never_mutates(self):
        for case in ASSOCIATION_CASES:
            with self.subTest(case=case):
                f=Fixture();f.setUp()
                try:
                    poison(f,case)
                    dependant=f.make_task('TASK-054','Binding',extra='depends_on: TASK-017\n')
                    before={p:p.read_bytes() for p in (f.root/'backlog').glob('*.md')}
                    with patch.object(AGENTFLOW,'ROOT',f.root),patch.object(AGENTFLOW,'BACKLOG',f.root/'backlog'),patch.object(AGENTFLOW,'review_pr_merged',return_value=True):
                        with self.assertRaises((ValueError,SystemExit)):AGENTFLOW.complete(SimpleNamespace(task='TASK-017'))
                        self.assertEqual(AGENTFLOW.reconcile_merged_dependencies(dependant),[])
                    self.assertEqual({p:p.read_bytes() for p in before},before)
                finally:f.doCleanups()
    def test_dependency_only_after_confirmed_human_merge_and_only_dependencies(self):
        dependant=self.make_task('TASK-054','Binding',extra='depends_on: TASK-017\n')
        unrelated=self.make_task('TASK-099','Unrelated')
        before={p:p.read_bytes() for p in (dependant,self.task,unrelated)}
        with patch.object(AGENTFLOW,'review_pr_merged',return_value=False) as merged:
            self.assertEqual(AGENTFLOW.reconcile_merged_dependencies(dependant),[])
            merged.assert_called_once_with(self.task)
        self.assertEqual({p:p.read_bytes() for p in before},before)
        for name in ('qa-report.md','review-report.md'):
            for data in REPORT_VALUES:
                path=self.feature/name
                if data is None:path.unlink()
                else:path.write_bytes(data)
                with patch.object(AGENTFLOW,'review_pr_merged',return_value=True):
                    self.assertEqual(AGENTFLOW.reconcile_merged_dependencies(dependant),[])
                self.assertEqual({p:p.read_bytes() for p in before},before)
            path.write_text('Verdict: PASS\n')
        with patch.object(AGENTFLOW,'review_pr_merged',return_value=True):
            self.assertEqual(AGENTFLOW.reconcile_merged_dependencies(dependant),['TASK-017'])
        self.assertEqual(dependant.read_bytes(),before[dependant]);self.assertEqual(unrelated.read_bytes(),before[unrelated])
        self.assertIn(b'status: done',self.task.read_bytes())
    def test_merged_confirmation_requires_merged_state_date_and_base(self):
        import json
        for value,expected in [({'state':'MERGED','mergedAt':'today','baseRefName':'main'},True),({'state':'OPEN','mergedAt':'today','baseRefName':'main'},False),({'state':'MERGED','mergedAt':None,'baseRefName':'main'},False),({'state':'MERGED','mergedAt':'today','baseRefName':'other'},False)]:
            with patch.object(AGENTFLOW.shutil,'which',return_value='/captured/gh'),patch.object(AGENTFLOW.subprocess,'run',return_value=result(stdout=json.dumps(value))) as gh:
                self.assertEqual(AGENTFLOW.review_pr_merged(self.task),expected)
            self.assertEqual(gh.call_args.args[0][3],'017-football-data-api-adapter')
    def test_invalid_update_metadata_and_unreadable_reports_have_no_partial_write(self):
        original=self.task.read_bytes()
        for key in (b'status',b'active_run',b'id',b'title'):
            for data in (original.replace(key+b':',b'other_'+key+b':'),original.replace(b'---\n\n',key+b': duplicate\n---\n\n')):
                with self.subTest(key=key):
                    self.task.write_bytes(data)
                    with self.assertRaises((ValueError,SystemExit)):AGENTFLOW.complete(SimpleNamespace(task='TASK-017'))
                    self.assertEqual(self.task.read_bytes(),data)
        self.task.write_bytes(original)
        read=Path.read_bytes
        for name in ('qa-report.md','review-report.md'):
            target=self.feature/name
            def denied(path):
                if path==target:raise PermissionError('unreadable evidence')
                return read(path)
            with patch.object(Path,'read_bytes',denied):
                with self.assertRaises(SystemExit):AGENTFLOW.complete(self.args())
                dependant=self.make_task('TASK-054','Binding',extra='depends_on: TASK-017\n')
                with patch.object(AGENTFLOW,'review_pr_merged',return_value=True):
                    self.assertEqual(AGENTFLOW.reconcile_merged_dependencies(dependant),[])
            self.assertEqual(self.task.read_bytes(),original)

class StrictDependentMetadataTest(delivery.DeliveryFixture):
    def test_invalid_dependent_task_refuses_before_enumeration_or_completion(self):
        from test.scripts.agentflow_feature_test import METADATA_CASES
        dependency=self.task
        for case in METADATA_CASES:
            with self.subTest(case=case):
                poison(self,case)
                # Move the poisoned frontmatter onto the task asking to reconcile.
                data=self.task.read_text().replace('TASK-017','TASK-054').replace('title: Football data API adapter','title: Binding')
                dependent=self.make_task('TASK-054','Binding')
                dependent.write_text(data)
                dependency.write_text('---\nid: TASK-017\ntitle: Football data API adapter\nstatus: review\nactive_run: run-1\n---\n')
                self.task=dependency
                before={p:p.read_bytes() for p in (self.root/'backlog').glob('*.md')}
                with patch.object(AGENTFLOW,'review_pr_merged',return_value=True) as merged:
                    with self.assertRaises((ValueError,SystemExit)):AGENTFLOW.reconcile_merged_dependencies(dependent)
                    merged.assert_not_called()
                self.assertEqual({p:p.read_bytes() for p in before},before)

class MultipleDependencyMetadataTest(delivery.DeliveryFixture):
    def test_invalid_later_dependency_cannot_follow_an_earlier_write(self):
        invalid=self.make_task('TASK-099','Other',extra='status : blocked\n')
        dependent=self.make_task('TASK-054','Binding',extra='depends_on: TASK-017, TASK-099\n')
        before={p:p.read_bytes() for p in (self.root/'backlog').glob('*.md')}
        with patch.object(AGENTFLOW,'review_pr_merged',return_value=True) as merged:
            self.assertEqual(AGENTFLOW.reconcile_merged_dependencies(dependent),[])
            merged.assert_not_called()
        self.assertEqual({p:p.read_bytes() for p in before},before)
