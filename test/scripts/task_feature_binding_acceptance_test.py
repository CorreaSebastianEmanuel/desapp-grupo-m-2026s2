"""Portable acceptance checks for the delivery tooling only."""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
FIXTURE = ROOT / 'test/scripts/fixtures/task_feature_binding/provider'
COMMIT = '1aa2731f048efcb1056a589b3b2ea938b843edd4'
PINNED = {
    'backlog/TASK-017-football-data-api-adapter.md': (262, 'fa36022776fccf0228b8bff58d41cf9fd4bce39606b3fea3c57799fee52dc13c'),
    'specs/055-football-data-api-adapter/spec.md': (23308, '36d29071eaf11739503e289b9d7f842ab6f5c1f7473561e79569252f03618386'),
    'specs/055-football-data-api-adapter/qa-report.md': (5949, 'b80d21e503597d65390774f962f3ec0ad7367a49d74ac258f20e77092016a462'),
    'specs/055-football-data-api-adapter/review-report.md': (3668, '03578ff095635a889f4f10c21a91295687bea5052a2dfe60ac54e12e5eea5b48'),
}

class ToolingPreflightTest(unittest.TestCase):
    def test_tools_and_exact_provenance(self):
        self.assertGreaterEqual(sys.version_info[:2], (3,10))
        git = subprocess.run(['git','--version'],capture_output=True,text=True)
        self.assertEqual(git.returncode,0); self.assertIn('git version',git.stdout)
        provenance=json.loads((FIXTURE/'provenance.json').read_text())
        self.assertEqual(provenance['commit'],COMMIT)
        self.assertEqual(provenance['branch'],'017-football-data-api-adapter')
        self.assertEqual(provenance['pr'],28)
        self.assertEqual(set(provenance['files']),set(PINNED))
        self.assertEqual({p.relative_to(FIXTURE).as_posix() for p in FIXTURE.rglob('*') if p.is_file()}, set(PINNED)|{'provenance.json'})
        for path,(length,sha) in PINNED.items():
            data=(FIXTURE/path).read_bytes()
            self.assertEqual(len(data),length,path)
            self.assertEqual(hashlib.sha256(data).hexdigest(),sha,path)
            self.assertEqual(provenance['files'][path],{'bytes':length,'sha256':sha})

class ActualProviderFixtureTest(ToolingPreflightTest):
    def test_actual_command_two_value_delta_retry_and_source_preservation(self):
        import tempfile
        import shutil
        def snapshot(directory):
            return {p.relative_to(directory).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in directory.rglob('*') if p.is_file()}
        fixture_before=snapshot(FIXTURE)
        real_before={path:(ROOT/path).read_bytes() if (ROOT/path).is_file() else None for path in PINNED}
        refs_before=subprocess.check_output(['git','show-ref'],cwd=ROOT)
        available=subprocess.run(['git','cat-file','-e',COMMIT],cwd=ROOT,capture_output=True).returncode==0
        source_before={path:subprocess.check_output(['git','show',f'{COMMIT}:{path}'],cwd=ROOT) for path in PINNED} if available else {}
        for path,data in source_before.items():self.assertEqual(data,(FIXTURE/path).read_bytes(),path)
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory)
            for path in PINNED:
                target=root/path;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(FIXTURE/path,target)
            unrelated=root/'backlog/TASK-099-unrelated.md';unrelated.write_text('---\nid: TASK-099\ntitle: Unrelated\nstatus: review\nactive_run: other\n---\n')
            distraction=root/'specs/017-unrelated';distraction.mkdir();(distraction/'spec.md').write_text('**Feature Branch**: `099-unrelated`\n')
            (distraction/'qa-report.md').write_text('Verdict: FAIL\n');(distraction/'review-report.md').write_text('Verdict: FAIL\n')
            before={p.relative_to(root).as_posix():p.read_bytes() for p in root.rglob('*') if p.is_file()}
            cmd=[sys.executable,str(ROOT/'scripts/reconcile_merged_task.py'),'--head-ref','017-football-data-api-adapter','--root',str(root)]
            first=subprocess.run(cmd,capture_output=True,text=True)
            self.assertEqual(first.returncode,0,first.stderr);self.assertIn('Finalized backlog/TASK-017-football-data-api-adapter.md',first.stdout)
            expected=dict(before);task='backlog/TASK-017-football-data-api-adapter.md'
            self.assertIn(b'status: review',before[task]);self.assertNotIn(b'active_run: none',before[task])
            expected[task]=before[task].replace(b'status: review',b'status: done').replace(next(line for line in before[task].splitlines() if line.startswith(b'active_run:')),b'active_run: none')
            after={p.relative_to(root).as_posix():p.read_bytes() for p in root.rglob('*') if p.is_file()}
            self.assertEqual(after,expected)
            second=subprocess.run(cmd,capture_output=True,text=True)
            self.assertEqual(second.returncode,0,second.stderr);self.assertIn('already finalized',second.stdout)
            self.assertEqual(snapshot(root),{p:hashlib.sha256(data).hexdigest() for p,data in expected.items()})
        self.assertEqual(snapshot(FIXTURE),fixture_before)
        self.assertEqual({path:(ROOT/path).read_bytes() if (ROOT/path).is_file() else None for path in PINNED},real_before)
        self.assertEqual(subprocess.check_output(['git','show-ref'],cwd=ROOT),refs_before)
        for path,data in source_before.items():self.assertEqual(subprocess.check_output(['git','show',f'{COMMIT}:{path}'],cwd=ROOT),data)

class WorkflowScopeTest(unittest.TestCase):
    def test_finalize_workflow_safeguards_and_no_changes(self):
        path='.github/workflows/agentflow-finalize.yml'
        current=(ROOT/path).read_bytes()
        self.assertEqual(current,subprocess.check_output(['git','show',f'dbddd6f:{path}'],cwd=ROOT))
        text=current.decode()
        for guard in ('types: [closed]',"if: github.event.pull_request.merged == true && github.event.pull_request.base.ref == 'main'",'permissions:\n  contents: write','group: agentflow-backlog-finalization','cancel-in-progress: false','actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683','ref: main','fetch-depth: 0','^[0-9]{3}-[a-z0-9][a-z0-9-]*$','Not an Agentflow delivery branch; no backlog state changed.','python3 scripts/reconcile_merged_task.py --head-ref "$HEAD_REF"'):
            self.assertIn(guard,text)
        self.assertNotIn('pull_request_target',text)
        self.assertNotIn('gh pr merge',text)
        self.assertNotIn('gh pr merge',(ROOT/'agentflow').read_text())
    def test_changed_file_allowlist_and_readme_boundary(self):
        tracked=subprocess.check_output(['git','diff','--name-only','dbddd6f','-z'],cwd=ROOT).decode().split('\0')
        untracked=subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=ROOT).decode().split('\0')
        exact={'agentflow','scripts/agentflow_feature.py','scripts/reconcile_merged_task.py','scripts/workflow_artifact_probe.py','scripts/agentflow_check.py','README.md','docs/adr/0014-durable-agentflow-feature-ownership.md','backlog/TASK-054-agentflow-task-feature-directory-binding.md','backlog/feedback/TASK-054.md'}
        exact.update('test/scripts/'+name for name in ('agentflow_feature_test.py','agentflow_branch_test.py','agentflow_completion_test.py','reconcile_merged_task_test.py','workflow_artifact_probe_test.py','task_feature_binding_acceptance_test.py'))
        exact.update('test/scripts/fixtures/task_feature_binding/provider/'+name for name in set(PINNED)|{'provenance.json'})
        illegal=[p for p in set(tracked+untracked)-{''} if p not in exact and not p.startswith('specs/055-task-feature-binding/')]
        self.assertEqual(illegal,[],f'Changes outside tooling/active-feature scope: {illegal}')
        readme=(ROOT/'README.md').read_text()
        baseline=subprocess.check_output(['git','show','dbddd6f:README.md'],cwd=ROOT).decode()
        # Scope is bounded by the actual existing Agentflow section heading.
        import re
        headings=re.findall(r'^## .+$',baseline,re.M)
        marker=next(h for h in headings if 'agent' in h.lower() or 'workflow' in h.lower())
        self.assertEqual(readme.split(marker)[0],baseline.split(marker)[0])
        end='### Windows PowerShell'
        self.assertEqual(readme.split(end)[1],baseline.split(end)[1])
    def test_separate_correction_merge_order_is_versioned(self):
        task=(ROOT/'backlog/TASK-054-agentflow-task-feature-directory-binding.md').read_text()
        self.assertIn('Create a separate PR intended to be merged before PR #28.',task)
        plan=(ROOT/'specs/055-task-feature-binding/plan.md').read_text()
        self.assertIn('Retain separate TASK-054 publication',plan)
        self.assertIn('Humans retain merge authority and merge TASK-054 before PR #28',(ROOT/'specs/055-task-feature-binding/tasks.md').read_text())
        spec=(ROOT/'specs/055-task-feature-binding/spec.md').read_text()
        self.assertIn('Delivery MUST be a separate TASK-054 PR intended to merge before PR #28',spec)
