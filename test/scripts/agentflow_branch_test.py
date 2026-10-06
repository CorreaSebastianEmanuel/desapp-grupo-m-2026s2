"""Capture delivery adapters; never commit, push, create PRs or run agents."""
import importlib.machinery
import importlib.util
import json
import os
from pathlib import Path
import subprocess
from types import SimpleNamespace
from unittest.mock import patch

from test.scripts.agentflow_feature_test import Fixture

SCRIPT=Path(__file__).resolve().parents[2]/'agentflow'
LOADER=importlib.machinery.SourceFileLoader('agentflow_module',str(SCRIPT))
SPEC=importlib.util.spec_from_loader(LOADER.name,LOADER)
AGENTFLOW=importlib.util.module_from_spec(SPEC);LOADER.exec_module(AGENTFLOW)

def result(returncode=0,stdout='',stderr=''):
    return subprocess.CompletedProcess([],returncode,stdout,stderr)

class DeliveryFixture(Fixture):
    def setUp(self):
        super().setUp()
        for name,value in {'ROOT':self.root,'BACKLOG':self.root/'backlog','FEEDBACK':self.root/'backlog/feedback','RUNS':self.root/'tmp'}.items():
            p=patch.object(AGENTFLOW,name,value);p.start();self.addCleanup(p.stop)
        AGENTFLOW.RUNS.mkdir()
        self.calls=[];self.branch='017-football-data-api-adapter'
        p=patch.object(AGENTFLOW,'git',side_effect=self.git);p.start();self.addCleanup(p.stop)
    def git(self,*args,**kwargs):
        self.calls.append(args)
        if args==('branch','--show-current'):return result(stdout=self.branch+'\n')
        if args==('log','-1','--format=%s'):
            m=AGENTFLOW.meta(self.task);return result(stdout=f"Implement {m['id']}: {m['title']}\n")
        return result()
    def args(self,**kwargs):
        return SimpleNamespace(task=AGENTFLOW.meta(self.task)['id'],agent='auto',dry_run=False,no_pr=False,**kwargs)
class AgentflowBranchTest(DeliveryFixture):
    def test_task_branch_and_switching(self):
        self.assertEqual(AGENTFLOW.task_branch(self.task),self.branch)
        self.branch='main'
        with patch.object(AGENTFLOW,'git',side_effect=lambda *a,**k: result(stdout='main\n') if a[0]=='branch' else result(returncode=1) if a[0]=='show-ref' else self.git(*a,**k)):
            self.assertEqual(AGENTFLOW.ensure_feature_branch(self.task),'017-football-data-api-adapter')
        self.assertIn(('switch','-c','017-football-data-api-adapter'),self.calls)
        self.calls.clear();AGENTFLOW.ensure_feature_branch(self.task)
        self.assertIn(('switch','017-football-data-api-adapter'),self.calls)
    def test_discovery_unequal_examples_legacy_pointer_and_mtime(self):
        distraction=self.make_feature('017-incidental','099-other')
        os.utime(distraction,(2000000000,2000000000))
        (self.root/'.specify').mkdir();(self.root/'.specify/feature.json').write_text(json.dumps({'feature_directory':'specs/017-incidental'}))
        self.assertEqual(AGENTFLOW.feature_for_task(self.task),self.feature)
        self.task=self.make_task('TASK-020','Player match statistics model')
        expected=self.make_feature('054-player-match-statistics','020-player-match-statistics-model')
        self.assertEqual(AGENTFLOW.feature_for_task(self.task),expected)
        (expected/'spec.md').write_text('legacy\n');expected.rename(expected.with_name('020-legacy'))
        self.assertEqual(AGENTFLOW.feature_for_task(self.task),self.root/'specs/020-legacy')
    def test_verify_resolves_before_dispatch_and_does_not_recurse(self):
        with patch.object(AGENTFLOW,'agent',return_value='codex'),patch.object(AGENTFLOW.subprocess,'run',return_value=result()) as dispatch:
            self.assertEqual(AGENTFLOW.verify(self.args()),0)
        prompt=dispatch.call_args.args[0][-1]
        self.assertIn('specs/055-football-data-api-adapter',prompt)
        self.assertIn('Do not invoke `./agentflow verify`',prompt)
        self.assertEqual(AGENTFLOW.meta(self.task)['status'],'review')
        self.assertEqual(json.loads((self.root/'.specify/feature.json').read_text())['feature_directory'],'specs/055-football-data-api-adapter')
    def test_publication_and_clean_retry_use_owned_links_and_outcome(self):
        with patch.object(AGENTFLOW.subprocess,'run',return_value=result(stdout='https://example.test/pr/1\n')) as gh:
            self.assertEqual(AGENTFLOW.publish(self.task,AGENTFLOW.meta(self.task),self.feature),'https://example.test/pr/1')
        self.assertIn(('push','-u','origin',self.branch),self.calls)
        self.assertFalse(any(c[0] in ('commit','add') for c in self.calls))
        body=Path(gh.call_args.args[0][-1]).read_text()
        for name in ('spec.md','plan.md','tasks.md','qa-report.md','review-report.md'):self.assertIn('specs/055-football-data-api-adapter/'+name,body)
        self.assertIn('merge before PR #28',body)
    def test_finalize_no_pr_and_failed_workflow(self):
        with patch.object(AGENTFLOW,'publish') as publish:
            self.assertEqual(AGENTFLOW.finalize(self.task,AGENTFLOW.meta(self.task),0,True),0)
            publish.assert_not_called()
        self.assertEqual(AGENTFLOW.meta(self.task)['status'],'review')
        self.assertEqual(AGENTFLOW.finalize(self.task,AGENTFLOW.meta(self.task),7,True),7)
        self.assertEqual(AGENTFLOW.meta(self.task)['status'],'blocked')
    def test_start_preproduct_clears_stale_pointer_without_other_feature(self):
        import shutil
        shutil.rmtree(self.feature);self.make_feature('099-other','099-other')
        (self.root/'.specify').mkdir();(self.root/'.specify/feature.json').write_text('{"feature_directory":"specs/099-other"}')
        self.branch='main'
        with patch.object(AGENTFLOW.shutil,'which',return_value='/captured/tool'),patch.object(AGENTFLOW,'ensure_feature_branch',return_value='017-football-data-api-adapter'),patch.object(AGENTFLOW,'monitor_process',return_value=(130,'run')) as monitor,patch.object(AGENTFLOW,'reconcile_merged_dependencies'):
            args=self.args();args.no_pr=True
            self.assertEqual(AGENTFLOW.start(args),130)
        monitor.assert_called_once();self.assertFalse((self.root/'.specify/feature.json').exists())
    def test_resume_sets_pointer_from_owned_feature(self):
        with patch.object(AGENTFLOW,'recover_orphaned_run'),patch.object(AGENTFLOW,'read_run_state',return_value={'status':'paused'}),patch.object(AGENTFLOW,'monitor_process',return_value=(130,'run')):
            self.assertEqual(AGENTFLOW.resume(self.args()),130)
        self.assertEqual(json.loads((self.root/'.specify/feature.json').read_text())['feature_directory'],'specs/055-football-data-api-adapter')
    def test_publish_wrong_branch_and_foreign_feature_have_no_side_effects(self):
        for branch,feature in [('main',self.feature),('017-wrong',self.feature),(self.branch,self.make_feature('099-other','099-other'))]:
            self.branch=branch;self.calls.clear()
            with patch.object(AGENTFLOW.subprocess,'run') as gh:
                with self.assertRaises(RuntimeError):AGENTFLOW.publish(self.task,AGENTFLOW.meta(self.task),feature)
                gh.assert_not_called()
            self.assertEqual(self.calls,[('branch','--show-current')])

class ConsumerRejectionTest(DeliveryFixture):
    def test_same_association_matrix_blocks_verifier_and_publication(self):
        from test.scripts.agentflow_feature_test import ASSOCIATION_CASES,METADATA_CASES,COMPETING_ID_CASES,poison
        for case in ASSOCIATION_CASES:
            if case in METADATA_CASES + COMPETING_ID_CASES or case in ('metadata-duplicate','duplicate-task'):continue # stronger byte-preservation entrypoint matrix below
            report_case=case=='foreign-reports' or case.startswith(('foreign-qa-','foreign-review-','outside-'))
            with self.subTest(case=case):
                f=Fixture();f.setUp()
                try:
                    poison(f,case)
                    with patch.object(AGENTFLOW,'ROOT',f.root),patch.object(AGENTFLOW,'BACKLOG',f.root/'backlog'),patch.object(AGENTFLOW,'agent',return_value='codex'),patch.object(AGENTFLOW.subprocess,'run') as dispatch:
                        if not report_case:
                            with self.assertRaises((ValueError,SystemExit)):AGENTFLOW.verify(SimpleNamespace(task='TASK-017',agent='auto',dry_run=False))
                            dispatch.assert_not_called()
                        with self.assertRaises(RuntimeError):AGENTFLOW.publish(f.task,AGENTFLOW.meta(f.task),f.feature)
                        dispatch.assert_not_called()
                        # Publication failures retain existing blocked handling in finalize.
                        self.assertNotEqual(AGENTFLOW.finalize(f.task,AGENTFLOW.meta(f.task),0),0)
                        self.assertNotEqual(AGENTFLOW.meta(f.task)['status'],'review')
                    self.assertFalse(any(c[0] in ('push','add','commit') for c in self.calls))
                finally:f.doCleanups()
    def test_both_reports_and_required_artifacts_gate_direct_and_no_pr(self):
        from test.scripts.agentflow_feature_test import REPORT_VALUES
        original=self.task.read_bytes()
        for name in ('qa-report.md','review-report.md','spec.md','plan.md','tasks.md'):
            saved=(self.feature/name).read_bytes()
            values=REPORT_VALUES if name.endswith('report.md') else (None,b'\xff')
            for data in values:
                with self.subTest(name=name,data=data):
                    self.task.write_bytes(original);path=self.feature/name
                    if data is None:path.unlink()
                    else:path.write_bytes(data)
                    self.calls.clear()
                    with patch.object(AGENTFLOW.subprocess,'run') as gh:
                        with self.assertRaises(RuntimeError):AGENTFLOW.publish(self.task,AGENTFLOW.meta(self.task),self.feature)
                        self.assertNotEqual(AGENTFLOW.finalize(self.task,AGENTFLOW.meta(self.task),0,True),0)
                        gh.assert_not_called()
                    self.assertFalse(any(c[0] in ('push','add','commit') for c in self.calls))
                    self.assertEqual(AGENTFLOW.meta(self.task)['status'],'blocked')
            path.write_bytes(saved)
    def test_task054_pr_carries_actual_merge_order_and_separate_branch(self):
        original_task=SCRIPT.parent/'backlog/TASK-054-agentflow-task-feature-directory-binding.md'
        self.task=self.make_task('TASK-054','Agentflow task feature directory binding')
        self.task.write_text(original_task.read_text())
        self.branch='054-agentflow-task-feature-directory-binding'
        self.feature=self.make_feature('055-task-feature-binding',self.branch)
        with patch.object(AGENTFLOW.subprocess,'run',return_value=result(stdout='https://example.test/pr/54\n')) as gh:
            AGENTFLOW.publish(self.task,AGENTFLOW.meta(self.task),self.feature)
        body=Path(gh.call_args.args[0][-1]).read_text()
        self.assertIn('PR #28',body);self.assertIn('before',body);self.assertIn('separate',body.lower())
        self.assertIn('specs/055-task-feature-binding/spec.md',body)
        self.assertIn('054-agentflow-task-feature-directory-binding',gh.call_args.args[0])
        self.assertNotIn('017-football-data-api-adapter',gh.call_args.args[0])

class DeliveryAdapterSafeguardsTest(DeliveryFixture):
    def test_start_existing_feature_populates_pointer(self):
        self.branch='main'
        with patch.object(AGENTFLOW.shutil,'which',return_value='/captured/tool'),patch.object(AGENTFLOW,'ensure_feature_branch',return_value='017-football-data-api-adapter'),patch.object(AGENTFLOW,'monitor_process',return_value=(130,'run')) as monitor,patch.object(AGENTFLOW,'reconcile_merged_dependencies'):
            args=self.args();args.no_pr=True
            self.assertEqual(AGENTFLOW.start(args),130)
        monitor.assert_called_once()
        self.assertEqual(json.loads((self.root/'.specify/feature.json').read_text())['feature_directory'],'specs/055-football-data-api-adapter')
    def test_dirty_publication_stages_and_commits_before_push(self):
        def dirty(*args,**kwargs):
            if args==('status','--porcelain'):
                self.calls.append(args);return result(stdout=' M implementation.py\n')
            return self.git(*args,**kwargs)
        with patch.object(AGENTFLOW,'git',side_effect=dirty),patch.object(AGENTFLOW.subprocess,'run',return_value=result(stdout='https://example.test/pr/17')):
            AGENTFLOW.publish(self.task,AGENTFLOW.meta(self.task),self.feature)
        actions=[call[0] for call in self.calls]
        self.assertLess(actions.index('add'),actions.index('commit'));self.assertLess(actions.index('commit'),actions.index('push'))
    def test_clean_branch_without_verified_commit_refuses_push(self):
        def unverified(*args,**kwargs):
            if args==('log','-1','--format=%s'):
                self.calls.append(args);return result(stdout='Unrelated commit\n')
            return self.git(*args,**kwargs)
        with patch.object(AGENTFLOW,'git',side_effect=unverified),patch.object(AGENTFLOW.subprocess,'run') as gh:
            self.assertEqual(AGENTFLOW.finalize(self.task,AGENTFLOW.meta(self.task),0),1)
            gh.assert_not_called()
        self.assertFalse(any(c[0]=='push' for c in self.calls));self.assertEqual(AGENTFLOW.meta(self.task)['status'],'blocked')

class VerificationRevalidationTest(DeliveryFixture):
    def test_verifier_cannot_promote_reports_after_ownership_changes(self):
        def changed(*args,**kwargs):
            (self.feature/'spec.md').write_text('**Feature Branch**: `099-foreign`\n')
            return result()
        with patch.object(AGENTFLOW,'agent',return_value='codex'),patch.object(AGENTFLOW.subprocess,'run',side_effect=changed):
            self.assertNotEqual(AGENTFLOW.verify(self.args()),0)
        self.assertEqual(AGENTFLOW.meta(self.task)['status'],'blocked')
        self.assertFalse(any(call[0] in ('push','add','commit') for call in self.calls))

class StrictConsumerMetadataTest(DeliveryFixture):
    def test_cross_file_claims_refuse_all_entrypoints_without_side_effects(self):
        from test.scripts.agentflow_feature_test import COMPETING_ID_CASES,poison
        for case in COMPETING_ID_CASES:
            with self.subTest(case=case):
                f=StrictConsumerMetadataTest();f.setUp()
                try:
                    poison(f,case)
                    f.assert_entrypoints_refuse()
                finally:f.doCleanups()
    def assert_entrypoints_refuse(self):
        valid=AGENTFLOW.meta(self.task)
        pointer=self.root/'.specify/feature.json';pointer.parent.mkdir(exist_ok=True)
        pointer.write_text('{"feature_directory":"specs/099-other"}')
        before={p:p.read_bytes() for p in self.root.rglob('*.md')};pointer_before=pointer.read_bytes()
        args=SimpleNamespace(task='TASK-017',agent='auto',dry_run=False,no_pr=True)
        actions=(lambda:AGENTFLOW.feature_for_task(self.task),lambda:AGENTFLOW.verify(args),
                 lambda:AGENTFLOW.publish(self.task,valid,self.feature),lambda:AGENTFLOW.finalize(self.task,valid,0),
                 lambda:AGENTFLOW.finalize(self.task,valid,9,True),lambda:AGENTFLOW.finalize(self.task,valid,0,True),
                 lambda:AGENTFLOW.start(args),lambda:AGENTFLOW.resume(args),lambda:AGENTFLOW.ready_tasks())
        with patch.object(AGENTFLOW.shutil,'which',return_value='/captured/tool'),patch.object(AGENTFLOW.subprocess,'run') as dispatch,patch.object(AGENTFLOW,'monitor_process') as monitor:
            for action in actions:
                self.calls.clear()
                with self.assertRaises((ValueError,SystemExit)):action()
                self.assertEqual({p:p.read_bytes() for p in before},before)
                self.assertEqual(pointer.read_bytes(),pointer_before)
                self.assertFalse(any(c[0] in ('push','add','commit','switch') for c in self.calls))
                dispatch.assert_not_called();monitor.assert_not_called()
    def test_all_entrypoints_refuse_before_any_write_or_dispatch(self):
        from test.scripts.agentflow_feature_test import METADATA_CASES,poison
        valid=AGENTFLOW.meta(self.task)
        (self.root/'.specify').mkdir();pointer=self.root/'.specify/feature.json'
        pointer.write_text('{"feature_directory":"specs/099-other"}')
        for case in (*METADATA_CASES,'metadata-duplicate','duplicate-task'):
            with self.subTest(case=case):
                poison(self,case)
                before={p:p.read_bytes() for p in self.root.rglob('*.md')};pointer_before=pointer.read_bytes()
                args=SimpleNamespace(task='TASK-017',agent='auto',dry_run=False,no_pr=True)
                actions=(lambda:AGENTFLOW.feature_for_task(self.task),lambda:AGENTFLOW.verify(args),
                         lambda:AGENTFLOW.publish(self.task,valid,self.feature),
                         lambda:AGENTFLOW.finalize(self.task,valid,0),lambda:AGENTFLOW.finalize(self.task,valid,9,True),
                         lambda:AGENTFLOW.finalize(self.task,valid,0,True),lambda:AGENTFLOW.start(args),lambda:AGENTFLOW.resume(args))
                with patch.object(AGENTFLOW.shutil,'which',return_value='/captured/tool'),patch.object(AGENTFLOW.subprocess,'run') as dispatch,patch.object(AGENTFLOW,'monitor_process') as monitor:
                    for action in actions:
                        self.calls.clear()
                        try:
                            code=action()
                        except (ValueError,SystemExit):pass
                        else:self.assertNotEqual(code,0)
                        self.assertEqual({p:p.read_bytes() for p in before},before)
                        self.assertEqual(pointer.read_bytes(),pointer_before)
                        self.assertFalse(any(c[0] in ('push','add','commit','switch') for c in self.calls))
                        dispatch.assert_not_called();monitor.assert_not_called()

class RealStartPreproductTest(Fixture):
    def exercise_start(self, count=1, pointer=False, invalid=None):
        self.task=self.make_task('TASK-055','New work',status='todo',extra='depends_on: none\n')
        if count==2:self.make_feature('055-task-feature-binding','054-agentflow-task-feature-directory-binding')
        if invalid=='headerless':self.make_feature('055-legacy',None)
        elif invalid=='two-headerless':
            self.make_feature('055-legacy',None);self.make_feature('055-second',None)
        elif invalid=='malformed':self.make_feature('055-bad',None).joinpath('spec.md').write_text('**Feature Branch**: 055-new-work\n')
        elif invalid=='duplicate':self.make_feature('055-bad','017-other').joinpath('spec.md').write_text('**Feature Branch**: `017-other`\n**Feature Branch**: `054-other`\n')
        elif invalid=='wrong':self.make_feature('055-bad','055-wrong')
        elif invalid=='unreadable':self.make_feature('055-bad',None).joinpath('spec.md').unlink()
        elif invalid=='escape':
            candidate=self.make_feature('055-unsafe',None);outside=self.root/'outside';candidate.rename(outside);candidate.symlink_to(outside,target_is_directory=True)
        elif invalid=='metadata':self.task=self.make_task('TASK-055','New work',status='todo',extra='feature_directory: specs/055-football-data-api-adapter\n')
        elif invalid and invalid.startswith('competing-id:'):
            from test.scripts.agentflow_feature_test import COMPETING_ID_FORMS
            claim=COMPETING_ID_FORMS[int(invalid.split(':')[1])].replace('017','055')
            self.make_task('TASK-099','Other',extra=claim+'\n')
        session=self.root/'.specify/feature.json';session.parent.mkdir()
        if pointer:session.write_text('{"feature_directory":"specs/055-football-data-api-adapter"}')
        (self.root/'.gitignore').write_text('.specify/\n')
        def git(*args):return subprocess.run(['git',*args],cwd=self.root,text=True,capture_output=True,check=True)
        git('init','-q','-b','main');git('add','.');git('-c','user.name=Fixture','-c','user.email=fixture@example.test','commit','-qm','Fixture')
        unchanged={p:p.read_bytes() for p in self.root.rglob('*.md') if p!=self.task}
        before=self.task.read_bytes();pointer_before=session.read_bytes() if session.exists() else None
        args=SimpleNamespace(task='TASK-055',agent='auto',dry_run=False,no_pr=True)
        with patch.object(AGENTFLOW,'ROOT',self.root),patch.object(AGENTFLOW,'BACKLOG',self.root/'backlog'),patch.object(AGENTFLOW,'FEEDBACK',self.root/'backlog/feedback'),patch.object(AGENTFLOW.shutil,'which',return_value='/captured/tool'),patch.object(AGENTFLOW,'monitor_process',return_value=(130,'captured-run')) as launch:
            if invalid and invalid!='headerless':
                with self.assertRaises((ValueError,SystemExit)):AGENTFLOW.start(args)
                launch.assert_not_called();self.assertEqual(self.task.read_bytes(),before)
                self.assertEqual(session.read_bytes() if session.exists() else None,pointer_before)
                if invalid.startswith('competing-id:'):
                    self.assertEqual(git('branch','--show-current').stdout.strip(),'main')
            else:
                self.assertEqual(AGENTFLOW.start(args),130)
                launch.assert_called_once()
                cmd=launch.call_args.args[0]
                self.assertEqual(cmd[:3],['specify','workflow','run'])
                self.assertIn('TASK-055',cmd[-1]);self.assertIn('New work',cmd[-1])
                if invalid=='headerless':self.assertEqual(json.loads(session.read_text())['feature_directory'],'specs/055-legacy')
                else:self.assertFalse(session.exists())
                self.assertEqual(git('branch','--show-current').stdout.strip(),'055-new-work')
                self.assertEqual(AGENTFLOW.meta(self.task)['id'],'TASK-055')
        self.assertEqual({p:p.read_bytes() for p in unchanged},unchanged)
    def test_actual_start_one_two_foreign_with_absent_stale_pointer(self):
        for count in (1,2):
            for pointer in (False,True):
                with self.subTest(count=count,pointer=pointer):
                    f=RealStartPreproductTest();f.setUp()
                    try:f.exercise_start(count,pointer)
                    finally:f.doCleanups()
    def test_actual_start_retains_legacy_and_rejects_invalid_candidates(self):
        from test.scripts.agentflow_feature_test import COMPETING_ID_CASES
        for case in ('headerless','two-headerless','malformed','duplicate','wrong','unreadable','escape','metadata',*COMPETING_ID_CASES):
            with self.subTest(case=case):
                f=RealStartPreproductTest();f.setUp()
                try:f.exercise_start(2,True,case)
                finally:f.doCleanups()
