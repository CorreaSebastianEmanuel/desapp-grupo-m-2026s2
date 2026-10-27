"""Model precedence and actual child failure fixtures; no model calls."""
import json
import os
import subprocess
import sys
from pathlib import Path
from types import SimpleNamespace
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture

ROOT = Path(__file__).resolve().parents[2]


class ModelTest(DeliveryFixture):
    def config(self):
        self.write('.agentflow/models.json', (ROOT/'.agentflow/models.json').read_text())

    def test_provider_error_with_zero_exit_is_failed_once(self):
        environment = {key: value for key, value in os.environ.items()
                       if not key.startswith('AGENTFLOW_')}
        fake = self.write('fake-codex', '#!/bin/sh\necho \'{"type":"error","message":"selected model unavailable"}\'\nexit 0\n')
        fake.chmod(0o755)
        prerequisites = self.root/'prerequisite-bin'; prerequisites.mkdir()
        specify = prerequisites/'specify'; specify.write_text('#!/bin/sh\nexit 0\n'); specify.chmod(0o700)
        result = subprocess.run([sys.executable, str(ROOT/'scripts/agentflow_codex.py'), 'exec',
                                 'Agentflow stage: develop'], cwd=self.root, capture_output=True, text=True,
                                env={**environment, 'AGENTFLOW_CODEX_REAL': str(fake), 'AGENTFLOW_TASK_ID': 'TASK-003',
                                     'AGENTFLOW_METRICS_FILE': str(self.root/'events.jsonl'),
                                     'PATH': str(prerequisites) + os.pathsep + os.environ.get('PATH', '')})
        self.assertNotEqual(result.returncode, 0)
        events = [json.loads(line) for line in (self.root/'events.jsonl').read_text().splitlines()]
        self.assertEqual(sum(e['event']=='agent_started' for e in events), 1)
        self.assertNotEqual(events[-1]['exit_code'], 0)

    def test_defaults_precedence_and_development_isolation(self):
        from scripts.agentflow_models import resolve
        self.config()
        task = self.root/'backlog/TASK-003-example.md'
        self.write(task.relative_to(self.root), task.read_text().replace('status:', 'develop_model: gpt-6.1-sol\nstatus:'))
        args = SimpleNamespace(model=None, effort=None, stage_model=[], stage_effort=[])
        stages = resolve(self.root, task, args)['stages']
        self.assertEqual(stages['develop']['model'], 'gpt-6.1-sol')
        self.assertEqual(stages['develop']['sources']['model'], 'task.develop_model')
        self.assertEqual(stages['product']['model'], 'gpt-6-luna')
        self.assertEqual(stages['qa']['effort'], 'medium')
        args.model='gpt-6.1-sol'; args.effort='low'; args.stage_effort=['develop=medium']
        stages=resolve(self.root,task,args)['stages']
        self.assertEqual(stages['develop']['effort'],'medium')
        self.assertEqual(stages['product']['effort'],'low')

    def test_duplicate_unknown_and_unsupported_selections_fail(self):
        from scripts.agentflow_models import resolve
        self.config()
        task=self.root/'backlog/TASK-003-example.md'
        for flags in ({'stage_model':['develop=gpt-6-luna','develop=gpt-6.1-sol']},
                      {'stage_model':['unknown=gpt-6-luna']}, {'effort':'ultra'}, {'model':'unsupported'}):
            with self.subTest(flags=flags), self.assertRaises(RuntimeError):
                resolve(self.root,task,SimpleNamespace(**flags))

    def test_frozen_generation_ignores_repository_edits_and_cross_run_binding(self):
        from scripts.agentflow_models import resolve, save, bind, saved
        self.config()
        task=self.root/'backlog/TASK-003-example.md'
        selection=resolve(self.root,task,SimpleNamespace())
        path=save(self.root,selection)
        original=path.read_bytes()
        bind(self.root,path,'fixture-run')
        self.write('.agentflow/models.json','broken changed configuration')
        self.assertEqual(saved(self.root,'TASK-003','fixture-run')['stages'], selection['stages'])
        self.assertEqual(path.read_bytes(),original)
        with self.assertRaises(RuntimeError): bind(self.root,path,'different-run')


class LauncherTest(DeliveryFixture):
    def setUp(self):
        super().setUp()
        import shutil
        shutil.copy2(ROOT/'agentflow',self.root/'agentflow')
        shutil.copytree(ROOT/'scripts',self.root/'scripts',dirs_exist_ok=True,ignore=shutil.ignore_patterns('__pycache__'))
        self.write('scripts/local_services.sh','#!/bin/sh\n[ "$1" = ready ] && exit 0\nexit 0\n')
        self.write('.agentflow/models.json',(ROOT/'.agentflow/models.json').read_text())
        from test.scripts.support.agentflow_delivery_fixtures import verification
        manifest=verification([sys.executable,'-c',"print('fixture')"])
        manifest['toolchain_required']=False
        self.json('specs/003-example/verification.json',manifest)
        self.write('.agentflow/workflow.yml','steps:\n'+''.join(f'  - id: {stage}\n' for stage in ('product','architecture','develop','qa','review')))
        self.write('.gitignore','.agentflow/runs/\n.specify/feature.json\n.specify/workflows/runs/\n__pycache__/\n')
        task=self.root/'backlog/TASK-003-example.md'
        task.write_text(task.read_text().replace('status: wip','status: todo'))
        self.capture=self.root/'.agentflow/runs/captured.jsonl'
        fake=self.write('fixture-bin/codex', '#!'+sys.executable+'\nimport os,json,sys\nfrom pathlib import Path\np=Path(os.environ["CAPTURE"]);p.parent.mkdir(parents=True,exist_ok=True)\nwith p.open("a") as f:f.write(json.dumps(sys.argv[1:])+"\\n")\nprint(json.dumps({"type":"error","message":"fixture provider rejection"}))\n')
        fake.chmod(0o755)
        specify=self.write('fixture-bin/specify', '#!'+sys.executable+'\nimport os,subprocess,sys\ncode=subprocess.call([os.environ["SPECKIT_INTEGRATION_CODEX_EXECUTABLE"],"exec","Agentflow stage: develop"])\nsys.exit(code)\n')
        specify.chmod(0o755)
        base_environment={key:value for key,value in os.environ.items() if not key.startswith('AGENTFLOW_')}
        self.environment={**base_environment,'PATH':str(fake.parent)+os.pathsep+os.environ['PATH'],'CAPTURE':str(self.capture),
                          'AGENTFLOW_CODEX_REAL':str(fake),
                          'CODEX_HOME':str(self.root/'codex-home')}
        self.baseline()

    def invoke(self,*args):
        return subprocess.run([sys.executable,str(self.root/'agentflow'),*args],cwd=self.root,env=self.environment,
                              capture_output=True,text=True,timeout=30)

    def test_start_applies_frozen_override_and_propagates_one_child_rejection(self):
        self.git('switch','-q','-c','main')
        result=self.invoke('start','TASK-003','--no-pr','--stage-model','develop=gpt-6.1-sol','--stage-effort','develop=medium')
        self.assertNotEqual(result.returncode,0,result.stdout+result.stderr)
        launches=[json.loads(line) for line in self.capture.read_text().splitlines()]
        self.assertEqual(len(launches),1)
        self.assertIn('gpt-6.1-sol',launches[0])
        self.assertIn('model_reasoning_effort="medium"',launches[0])
        self.assertIn('status: blocked',(self.root/'backlog/TASK-003-example.md').read_text())

    def test_resume_preserves_saved_pair_after_repository_edit_and_fails_once(self):
        from scripts.agentflow_models import resolve,save,bind
        task=self.root/'backlog/TASK-003-example.md'
        path=save(self.root,resolve(self.root,task,SimpleNamespace()))
        bind(self.root,path,'fixture-run')
        original=path.read_bytes()
        task.write_text(task.read_text().replace('active_run: none','active_run: fixture-run'))
        self.json('.specify/workflows/runs/fixture-run/state.json',{'status':'paused','current_step_id':'develop','current_step_index':2,'step_results':{}})
        self.write('.specify/workflows/runs/fixture-run/workflow.yml',(self.root/'.agentflow/workflow.yml').read_text())
        self.write('.agentflow/models.json','repository edited after freezing')
        result=self.invoke('resume','TASK-003')
        self.assertNotEqual(result.returncode,0,result.stdout+result.stderr)
        launches=[json.loads(line) for line in self.capture.read_text().splitlines()]
        self.assertEqual(len(launches),1)
        self.assertIn('gpt-6-luna',launches[0])
        self.assertEqual(path.read_bytes(),original)

    def test_start_dry_run_does_not_mutate_or_launch(self):
        before={p.relative_to(self.root):p.read_bytes() for p in self.root.rglob('*') if p.is_file() and '.git' not in p.parts}
        result=self.invoke('start','TASK-003','--dry-run')
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        after={p.relative_to(self.root):p.read_bytes() for p in self.root.rglob('*') if p.is_file() and '.git' not in p.parts and '__pycache__' not in p.parts}
        self.assertEqual(before,after)
        self.assertFalse(self.capture.exists())

    def test_each_stage_materializes_approved_pair_in_actual_child_argv(self):
        import hashlib
        from scripts.agentflow_models import resolve,save,STAGES
        self.assertEqual({key for key in self.environment if key.startswith('AGENTFLOW_')},
                         {'AGENTFLOW_CODEX_REAL'})
        task=self.root/'backlog/TASK-003-example.md'
        selection=resolve(self.root,task,SimpleNamespace())
        path=save(self.root,selection)
        # Child succeeds and supplies a unique observable session, never an API call.
        fake=self.root/'fixture-bin/codex'
        fake.write_text('#!'+sys.executable+'\nimport json,sys,os\nfrom pathlib import Path\nargs=sys.argv[1:]\nstage=next(arg.split(": ",1)[1] for arg in args if arg.startswith("Agentflow stage: "))\np=Path(os.environ["CAPTURE"]);p.parent.mkdir(parents=True,exist_ok=True)\nwith p.open("a") as f:f.write(json.dumps(args)+"\\n")\nif stage in ("qa","review"):\n Path("specs/003-example/"+("qa-report.md" if stage=="qa" else "review-report.md")).write_text("Verdict: PASS\\n")\nprint(json.dumps({"type":"thread.started","thread_id":stage+"-session"}))\nprint(json.dumps({"type":"turn.completed","usage":{"input_tokens":1,"output_tokens":1}}))\n')
        env={**self.environment,'AGENTFLOW_ASSIGNMENT':str(path),
             'AGENTFLOW_ASSIGNMENT_SHA256':hashlib.sha256(path.read_bytes()).hexdigest(),
             'AGENTFLOW_TASK_ID':'TASK-003','AGENTFLOW_METRICS_FILE':str(self.root/'.agentflow/runs/model-events.jsonl')}
        for stage in STAGES:
            with self.subTest(stage=stage):
                result=subprocess.run([sys.executable,str(self.root/'scripts/agentflow_codex.py'),'exec','Agentflow stage: '+stage],
                                      cwd=self.root,env=env,capture_output=True,text=True,timeout=20)
                self.assertEqual(result.returncode,0,result.stdout+result.stderr)
                args=json.loads(self.capture.read_text().splitlines()[-1])
                self.assertEqual(args[args.index('--model')+1],selection['stages'][stage]['model'])
                self.assertIn('model_reasoning_effort='+json.dumps(selection['stages'][stage]['effort']),args)
        events=[json.loads(line) for line in Path(env['AGENTFLOW_METRICS_FILE']).read_text().splitlines()]
        self.assertEqual(len({e['attempt'] for e in events if e['event']=='agent_started'}),6)
        self.assertTrue(all(e['observed_model'] is None for e in events))

    def test_provider_selection_maps_models_and_freezes_provider(self):
        from scripts.agentflow_models import resolve, save, bind, saved
        self.write('.agentflow/providers.json', (ROOT/'.agentflow/providers.json').read_text())
        task=self.root/'backlog/TASK-003-example.md'
        codex=resolve(self.root,task,SimpleNamespace())
        self.assertEqual(codex['provider'], 'codex')
        self.assertEqual(codex['stages']['develop']['model'], 'gpt-6-luna')
        stages=resolve(self.root,task,SimpleNamespace(provider='opencode'))['stages']
        self.assertTrue(all(row['model']=='opencode-go/glm-5.3-flash' for row in stages.values()))
        self.assertTrue(all('provider.opencode' in row['sources']['model'] for row in stages.values()))
        selection=resolve(self.root,task,SimpleNamespace(provider='opencode'))
        path=save(self.root,selection)
        bind(self.root,path,'fixture-run')
        restored=saved(self.root,'TASK-003','fixture-run')
        self.assertEqual(restored['provider'], 'opencode')
        with self.assertRaisesRegex(RuntimeError, 'not available for provider opencode'):
            resolve(self.root,task,SimpleNamespace(provider='opencode', stage_model=['develop=unavailable-model']))

    def test_legacy_unknown_requires_explicit_adoption_without_default_backfill(self):
        from scripts.agentflow_models import resume_selection,STAGES
        task=self.root/'backlog/TASK-003-example.md'
        with self.assertRaisesRegex(RuntimeError,'unknown'):
            resume_selection(self.root,task,'legacy',SimpleNamespace(),{})
        with self.assertRaisesRegex(RuntimeError,'unknown'):
            resume_selection(self.root,task,'legacy',SimpleNamespace(adopt_models=True),{})
        chosen,adopt=resume_selection(self.root,task,'legacy',SimpleNamespace(adopt_models=True,model='gpt-6.1-sol',effort='medium'),{})
        self.assertTrue(adopt)
        self.assertTrue(all(chosen['stages'][stage]['model']=='gpt-6.1-sol' for stage in STAGES))

    def test_adoption_removes_old_child_session_and_conflicts_fail_before_spawn(self):
        from scripts.agentflow_models import fresh_session_args,launch_args
        self.assertEqual(fresh_session_args(['exec','resume','12345678-abcd','Agentflow stage: develop']),['exec','Agentflow stage: develop'])
        self.assertEqual(fresh_session_args(['exec','resume','--last','Agentflow stage: develop']),['exec','Agentflow stage: develop'])
        for args in (['exec','--profile','ambient'],['exec','--model','unsupported'],['exec','-c','model="other"'],['exec','-c','model_reasoning_effort="low"']):
            with self.subTest(args=args),self.assertRaises(RuntimeError):
                launch_args(args,{'model':'gpt-6-luna','effort':'high'},'develop')

    def test_sandbox_resolution_uses_configured_default_and_normalizes_explicit_selection(self):
        from scripts.agentflow_codex import resolve_approval_policy, resolve_sandbox_mode, sandbox_launch_args
        config_home = self.root/'codex-home'
        config_home.mkdir()
        config = config_home/'config.toml'
        config.write_text('sandbox_mode = "danger-full-access"\napproval_policy = "never"\n')
        env = {'CODEX_HOME': str(config_home), 'AGENTFLOW_CODEX_SANDBOX_MODE': 'stale'}
        self.assertEqual(resolve_sandbox_mode(['exec'], env=env, root=self.root), 'danger-full-access')
        cases = [
            (['exec', '--sandbox', 'read-only'], 'read-only'),
            (['exec', '--sandbox=workspace-write'], 'workspace-write'),
            (['exec', '-s', 'danger-full-access'], 'danger-full-access'),
            (['exec', '-sdanger-full-access'], 'danger-full-access'),
            (['exec', '-c', 'sandbox_mode="read-only"'], 'read-only'),
            (['exec', '--config=sandbox_mode="read-only"'], 'read-only'),
        ]
        for args, expected in cases:
            with self.subTest(args=args):
                self.assertEqual(resolve_sandbox_mode(args, env=env, root=self.root), expected)
                shaped = sandbox_launch_args(args, expected)
                self.assertEqual(sum(arg == '--sandbox' for arg in shaped), 1)
                self.assertEqual(shaped[shaped.index('--sandbox') + 1], expected)
                self.assertFalse(any(arg.startswith('-c') and 'sandbox_mode' in arg for arg in shaped))

        self.assertEqual(resolve_approval_policy(['exec'], env=env, root=self.root), 'never')
        full_access = sandbox_launch_args(['exec', '--approve-for-me', '--json'], 'danger-full-access', 'never')
        self.assertNotIn('--approve-for-me', full_access)
        self.assertEqual(full_access[full_access.index('--sandbox') + 1], 'danger-full-access')
        workspace_write = sandbox_launch_args(['exec', '--approve-for-me', '--json'], 'workspace-write', 'never')
        self.assertIn('--approve-for-me', workspace_write)
        for approval in ('on-request', 'untrusted', None):
            with self.subTest(approval=approval), self.assertRaisesRegex(RuntimeError, 'approval policy'):
                sandbox_launch_args(['exec', '--approve-for-me'], 'danger-full-access', approval)
        for approval in ('on-request', 'untrusted'):
            with self.subTest(preserved_approval=approval):
                shaped = sandbox_launch_args(['exec', '--approve-for-me'], 'workspace-write', approval)
                self.assertIn('--approve-for-me', shaped)

    def test_sandbox_cli_and_config_disagreement_refuses(self):
        from scripts.agentflow_codex import resolve_sandbox_mode
        conflicting = [
            ['exec', '--sandbox', 'danger-full-access', '-c', 'sandbox_mode="workspace-write"'],
            ['exec', '-sworkspace-write', '--config=sandbox_mode="read-only"'],
        ]
        for args in conflicting:
            with self.subTest(args=args), self.assertRaisesRegex(RuntimeError, 'sandbox policy'):
                resolve_sandbox_mode(args, env={}, root=self.root,
                                     config_path=self.root/'missing-config.toml')

    def test_sandbox_resolution_defaults_to_workspace_write_only_when_unconfigured(self):
        from scripts.agentflow_codex import resolve_sandbox_mode
        self.assertEqual(resolve_sandbox_mode(['exec'], env={}, root=self.root,
                                              config_path=self.root/'missing-config.toml'), 'workspace-write')

    def test_ambiguous_sandbox_policy_refuses_before_spawn_without_leaking_config(self):
        from scripts.agentflow_codex import resolve_sandbox_mode
        invalid = [
            ['exec', '--sandbox', 'workspace-write', '--sandbox', 'read-only'],
            ['exec', '--sandbox', 'workspace-write', '-s', 'read-only'],
            ['exec', '-c', 'sandbox_mode="workspace-write"', '-c', 'sandbox_mode="read-only"'],
            ['exec', '--sandbox', 'danger-full-access', '-c', 'sandbox_mode="workspace-write"'],
            ['exec', '--sandbox', 'unknown-secret-value'],
            ['exec', '-c', 'sandbox_mode = ["secret-sentinel"]'],
            ['exec', '--full-auto'],
            ['exec', '--dangerously-bypass-approvals-and-sandbox'],
        ]
        for args in invalid:
            with self.subTest(args=args), self.assertRaises(RuntimeError) as caught:
                resolve_sandbox_mode(args, env={}, root=self.root)
            self.assertNotIn('secret-sentinel', str(caught.exception))
        self.write('.codex/config.toml', 'sandbox_mode = "read-only"\n')
        with self.assertRaisesRegex(RuntimeError, 'Unable to resolve sandbox policy'):
            resolve_sandbox_mode(['exec'], env={}, root=self.root,
                                 config_path=self.root/'missing-config.toml')

    def test_approval_policy_resolution_requires_never_for_full_access_preset_removal(self):
        from scripts.agentflow_codex import resolve_approval_policy
        config = self.root/'approval.toml'
        for policy in ('never', 'on-request', 'untrusted'):
            config.write_text(f'approval_policy = "{policy}"\n')
            self.assertEqual(resolve_approval_policy(['exec'], env={}, root=self.root, config_path=config), policy)
        config.write_text('approval_policy = "on-request"\n')
        with self.assertRaisesRegex(RuntimeError, 'approval policy'):
            resolve_approval_policy(['exec', '-c', 'approval_policy="never"'], env={}, root=self.root,
                                    config_path=config)

    def test_launcher_forwards_resolved_mode_and_safe_metadata_overwrites_inherited_value(self):
        import os
        from unittest.mock import patch
        from scripts.agentflow_codex import main
        fake = self.root/'fake-codex'
        fake.write_text('#!/bin/sh\nexit 0\n')
        fake.chmod(0o755)
        metrics = self.root/'metrics.jsonl'
        config_home = self.root/'codex-home'
        config_home.mkdir()
        (config_home/'config.toml').write_text('approval_policy = "never"\n')
        env = {'AGENTFLOW_CODEX_REAL': str(fake), 'AGENTFLOW_TASK_ID': 'TASK-003',
               'CODEX_HOME': str(config_home),
               'AGENTFLOW_METRICS_FILE': str(metrics), 'AGENTFLOW_CODEX_SANDBOX_MODE': 'raw-secret'}
        captured = {}
        class Child:
            stdout = []
            def wait(self): return 0
        def popen(argv, **kwargs):
            captured.update(argv=argv, env=kwargs.get('env'))
            return Child()
        with patch.dict(os.environ, env, clear=True), \
                patch('scripts.agentflow_preflight.evaluate', return_value={'ready': True, 'prerequisites': []}), \
                patch('scripts.agentflow_codex.subprocess.Popen', side_effect=popen):
            self.assertEqual(main(['exec', '--approve-for-me', '-c', 'sandbox_mode="danger-full-access"']), 0)
        self.assertEqual(captured['env']['AGENTFLOW_CODEX_SANDBOX_MODE'], 'danger-full-access')
        self.assertEqual(captured['argv'].count('--sandbox'), 1)
        self.assertNotIn('--approve-for-me', captured['argv'])
        events = [json.loads(line) for line in metrics.read_text().splitlines()]
        self.assertEqual(events[0]['sandbox_mode'], 'danger-full-access')
        self.assertNotIn('raw-secret', metrics.read_text())

    def test_workspace_write_keeps_loopback_network_and_model_options(self):
        import os
        from unittest.mock import patch
        from scripts.agentflow_codex import main
        fake = self.root/'fake-codex'
        fake.write_text('#!/bin/sh\nexit 0\n')
        fake.chmod(0o755)
        metrics = self.root/'metrics.jsonl'
        captured = {}
        class Child:
            stdout = []
            def wait(self): return 0
        def popen(argv, **kwargs):
            captured.update(argv=argv, env=kwargs.get('env'))
            return Child()
        env = {'AGENTFLOW_CODEX_REAL': str(fake), 'AGENTFLOW_TASK_ID': 'TASK-003',
               'AGENTFLOW_METRICS_FILE': str(metrics), 'HOME': str(self.root),
               'CODEX_HOME': str(self.root/'empty-codex-home')}
        with patch.dict(os.environ, env, clear=True), \
                patch('scripts.agentflow_preflight.evaluate', return_value={'ready': True, 'prerequisites': []}), \
                patch('scripts.agentflow_codex.subprocess.Popen', side_effect=popen):
            self.assertEqual(main(['exec', '--model', 'gpt-6-luna', '-c',
                                   'model_reasoning_effort="high"', '-c',
                                   'sandbox_mode="workspace-write"']), 0)
        args = captured['argv']
        self.assertIn('sandbox_workspace_write.network_access=true', args)
        self.assertIn('--sandbox', args)
        self.assertEqual(args[args.index('--sandbox') + 1], 'workspace-write')
        self.assertIn('--model', args)
        self.assertEqual(args[args.index('--model') + 1], 'gpt-6-luna')
        self.assertIn('model_reasoning_effort="high"', args)
