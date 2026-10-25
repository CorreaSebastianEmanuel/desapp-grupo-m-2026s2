"""Provider selection, environment interposition, and flag shaping; no model calls."""
import json
import io
import os
import subprocess
import sys
import unittest
from unittest.mock import patch
from pathlib import Path
from types import SimpleNamespace
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture

ROOT = Path(__file__).resolve().parents[2]


def mk_cleanup(directory):
    def cleanup():
        import shutil
        shutil.rmtree(directory, ignore_errors=True)
    import atexit
    atexit.register(cleanup)
    return cleanup


class ProviderFixture(DeliveryFixture):
    def setUp(self):
        super().setUp()
        self.prerequisites = self.root / 'prerequisite-bin'
        self.prerequisites.mkdir()
        specify = self.prerequisites / 'specify'
        specify.write_text('#!/bin/sh\nexit 0\n')
        specify.chmod(0o700)
        self.preflight_path = str(self.prerequisites) + os.pathsep + os.environ.get('PATH', '')

    def config(self):
        self.write('.agentflow/providers.json', (ROOT/'.agentflow/providers.json').read_text())


class SelectionTest(ProviderFixture):

    def test_default_and_unknown_providers(self):
        from scripts import agentflow_providers as providers
        self.assertEqual(providers.normalize(None), 'codex')
        self.assertEqual(providers.normalize('auto'), 'codex')
        self.assertEqual(providers.normalize(' OpenCode '), 'opencode')
        with self.assertRaisesRegex(RuntimeError, 'Unknown execution provider'):
            providers.normalize('claude')

    def test_option_conflicts_refuse_before_any_dispatch(self):
        from scripts import agentflow_providers as providers
        self.assertEqual(providers.from_args(SimpleNamespace(provider=None, agent=None)), 'codex')
        self.assertEqual(providers.from_args(SimpleNamespace(provider='opencode', agent=None)), 'opencode')
        self.assertEqual(providers.from_args(SimpleNamespace(provider=None, agent='auto')), 'codex')
        self.assertEqual(providers.from_args(SimpleNamespace(provider='opencode', agent='opencode')), 'opencode')
        with self.assertRaisesRegex(RuntimeError, 'different execution providers'):
            providers.from_args(SimpleNamespace(provider='opencode', agent='codex'))

    def test_provider_configuration_is_external_and_validated(self):
        from scripts import agentflow_providers as providers
        self.config()
        opencode = providers.provider_config(self.root, 'opencode')
        self.assertIn('opencode-go/glm-5.3-flash', opencode['models'])
        self.assertEqual(opencode['stage_models']['*'], 'opencode-go/glm-5.3-flash')
        codex = providers.provider_config(self.root, 'codex')
        self.assertIn('gpt-6-luna', codex['models'])
        with self.assertRaisesRegex(RuntimeError, 'does not define provider'):
            providers.provider_config(self.root, 'claude')
        self.write('.agentflow/providers.json', '{"schema_version": 1, "providers": "broken"}')
        with self.assertRaisesRegex(RuntimeError, 'schema_version'):
            providers.provider_config(self.root, 'codex')
        self.write('.agentflow/providers.json', json.dumps({'schema_version': 1,
            'providers': {'opencode': {'models': []}}}))
        with self.assertRaisesRegex(RuntimeError, 'models'):
            providers.provider_config(self.root, 'opencode')

    def test_legacy_repository_without_provider_file_stays_codex(self):
        from scripts import agentflow_providers as providers
        from scripts.agentflow_models import pair
        self.assertIsNone(providers.provider_config(self.root, 'codex'))
        self.assertIsNone(providers.provider_config(self.root, 'opencode'))
        with self.assertRaisesRegex(RuntimeError, 'no repository configuration'):
            pair('develop', 'opencode-go/glm-5.3-flash', 'high', root=self.root, provider='opencode')


class EnvTest(ProviderFixture):
    def setUp(self):
        super().setUp()
        self.config()

    def test_each_provider_interposes_only_its_own_shim(self):
        from scripts import agentflow_providers as providers
        codex = providers.env_overrides({}, 'codex', self.root)
        self.assertEqual(codex['SPECKIT_INTEGRATION_CODEX_EXECUTABLE'], str(self.root/'scripts/agentflow_codex.py'))
        self.assertIn('AGENTFLOW_CODEX_REAL', codex)
        self.assertEqual(codex['SPECKIT_INTEGRATION_CODEX_EXTRA_ARGS'], '--approve-for-me')
        self.assertNotIn('SPECKIT_INTEGRATION_OPENCODE_EXECUTABLE', codex)
        opencode = providers.env_overrides({}, 'opencode', self.root)
        self.assertEqual(opencode['SPECKIT_INTEGRATION_OPENCODE_EXECUTABLE'], str(self.root/'scripts/agentflow_opencode.py'))
        self.assertIn('AGENTFLOW_OPENCODE_REAL', opencode)
        self.assertEqual(opencode['SPECKIT_INTEGRATION_OPENCODE_EXTRA_ARGS'], '--auto')
        self.assertNotIn('SPECKIT_INTEGRATION_CODEX_EXECUTABLE', opencode)

    def test_operator_shim_override_is_respected(self):
        from scripts import agentflow_providers as providers
        child_env = {'SPECKIT_INTEGRATION_OPENCODE_EXECUTABLE': '/operator/shim'}
        result = providers.env_overrides(child_env, 'opencode', self.root)
        self.assertEqual(result['SPECKIT_INTEGRATION_OPENCODE_EXECUTABLE'], '/operator/shim')
        self.assertNotIn('AGENTFLOW_OPENCODE_REAL', result)

    def test_flag_shapes_and_direct_commands_per_provider(self):
        from scripts import agentflow_providers as providers
        self.assertEqual(providers.model_flags('codex', 'gpt-6-luna', 'high'),
                         ['--model', 'gpt-6-luna', '-c', 'model_reasoning_effort="high"'])
        self.assertEqual(providers.model_flags('opencode', 'opencode-go/glm-5.3-flash'),
                         ['-m', 'opencode-go/glm-5.3-flash'])
        self.assertEqual(providers.command('codex', self.root, 'prompt'),
                         ['codex', 'exec', '-C', str(self.root), '--approve-for-me', '--ephemeral', 'prompt'])
        opencode = providers.command('opencode', self.root, 'prompt', model='opencode-go/glm-5.3-flash')
        self.assertEqual(opencode, ['opencode', 'run', '--auto', '-m', 'opencode-go/glm-5.3-flash', 'prompt'])
        self.assertEqual(providers.command('opencode', self.root, 'prompt'),
                         ['opencode', 'run', '--auto', 'prompt'])


class ShimTest(ProviderFixture):
    def setUp(self):
        super().setUp()
        self.config()
        self.copy('scripts/agentflow_opencode.py')
        self.copy('scripts/agentflow_preflight.py')
        self.copy('scripts/agentflow_runtime.py')
        self.copy('scripts/agentflow_models.py')
        self.copy('scripts/agentflow_feature.py')
        self.copy('scripts/agentflow_verification.py')
        self.copy('scripts/agentflow_providers.py')
        self.copy('scripts/workflow_artifact_probe.py')
        self.copy('scripts/agentflow_codex.py')
        (self.root/'scripts/__init__.py').write_text('')
        self.write('scripts/local_services.sh', '#!/bin/sh\n[ "$1" = ready ]\n')
        stage_prompt = 'Agentflow stage: develop'
        self.session = 'ses_fixed000000000000000000000000aa'
        self.fake = self.write('fake-opencode', f'''#!{sys.executable}
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
capture = Path("captured.jsonl")
with capture.open("a") as handle:
    handle.write(json.dumps(args) + "\\n")
if not any(arg == "--format" or arg.startswith("--format=") for arg in args):
    print(json.dumps({{"type": "error", "sessionID": "", "error": {{"message": "fixture: --format json missing"}}}}))
    sys.exit(3)
session = {json.dumps(self.session)}
if os.environ.get("AGENTFLOW_ASSIGNMENT") and "-m" not in args:
    print(json.dumps({{"type": "error", "sessionID": "", "error": {{"message": "fixture: frozen model flag missing"}}}}))
    sys.exit(4)
print(json.dumps({{"type": "step_start", "sessionID": session, "part": {{"type": "step-start"}}}}))
print(json.dumps({{"type": "text", "sessionID": session, "part": {{"type": "text", "text": {json.dumps(stage_prompt)}}}}}))
''')
        self.fake.chmod(0o755)

    def copy(self, name, destination=None):
        source = ROOT/name
        destination = destination or name
        path = self.root/destination
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(source.read_bytes())

    def run_shim(self, *args, assignment=None, new_session=False):
        environment = {key: value for key, value in os.environ.items() if not key.startswith('AGENTFLOW_')}
        environment.update(AGENTFLOW_OPENCODE_REAL=str(self.fake), AGENTFLOW_TASK_ID='TASK-003',
                           AGENTFLOW_METRICS_FILE=str(self.root/'events.jsonl'), PATH=self.preflight_path)
        if assignment:
            environment['AGENTFLOW_ASSIGNMENT'] = str(assignment)
            import hashlib
            environment['AGENTFLOW_ASSIGNMENT_SHA256'] = hashlib.sha256(assignment.read_bytes()).hexdigest()
        if new_session:
            environment['AGENTFLOW_NEW_SESSION'] = '1'
        return subprocess.run([sys.executable, str(self.root/'scripts/agentflow_opencode.py'), *args],
                              cwd=self.root, capture_output=True, text=True, timeout=30, env=environment)

    def events(self):
        return [json.loads(line) for line in (self.root/'events.jsonl').read_text().splitlines()]

    def test_stream_is_forced_to_json_and_session_is_recorded(self):
        result = self.run_shim('run', 'Agentflow stage: develop')
        self.assertEqual(result.returncode, 0, result.stdout+result.stderr)
        captured = json.loads((self.root/'captured.jsonl').read_text().splitlines()[0])
        self.assertEqual(captured[0], 'run')
        self.assertIn('--format=json', captured)
        events = self.events()
        self.assertEqual(events[0]['event'], 'agent_started')
        usage = [event for event in events if event['event'] == 'usage']
        self.assertEqual(len(usage), 1)
        self.assertIsNone(usage[0]['reported_usage'])
        self.assertTrue(all(value is None for value in usage[0]['incremental_usage'].values()))
        self.assertTrue(usage[0]['session_hash'])
        self.assertNotEqual(usage[0]['session_hash'], self.session)
        self.assertEqual(events[-1]['event'], 'agent_ended')
        self.assertEqual(events[-1]['exit_code'], 0)

    def test_preflight_refusal_precedes_provider_spawn_and_checks_final_context(self):
        from scripts import agentflow_opencode
        from scripts import agentflow_preflight
        env = {'AGENTFLOW_OPENCODE_REAL': str(self.fake), 'AGENTFLOW_TASK_ID': 'TASK-003',
               'AGENTFLOW_METRICS_FILE': str(self.root/'refused-metrics.jsonl')}
        clean_environment = {key: value for key, value in os.environ.items()
                             if not key.startswith('AGENTFLOW_')}
        clean_environment.update(env)
        captured = []
        def refuse(context):
            captured.append(context)
            return {'ready': False, 'stage': context.stage, 'provider': context.provider,
                    'prerequisites': []}
        with patch.dict(os.environ, clean_environment, clear=True), \
                patch.object(agentflow_preflight, 'evaluate', side_effect=refuse), \
                patch.object(agentflow_opencode.subprocess, 'Popen') as spawn:
            code = agentflow_opencode.main(['run', 'Agentflow stage: develop'])
        self.assertEqual(code, 2)
        spawn.assert_not_called()
        self.assertEqual(captured[0].argv[0], str(self.fake))
        self.assertEqual(captured[0].cwd, Path.cwd().resolve())
        self.assertEqual(captured[0].env['AGENTFLOW_TASK_ID'], 'TASK-003')
        self.assertTrue((self.root/'refused-metrics.jsonl').is_file())
        events = [json.loads(line) for line in (self.root/'refused-metrics.jsonl').read_text().splitlines()]
        self.assertEqual([event['event'] for event in events], ['agent_failed', 'agent_ended'])
        self.assertEqual(events[-1]['exit_code'], 2)

    def test_codex_preflight_refusal_precedes_spawn_and_checks_final_context(self):
        from scripts import agentflow_codex, agentflow_preflight
        env = {'AGENTFLOW_CODEX_REAL': str(self.root/'fake-codex'), 'AGENTFLOW_TASK_ID': 'TASK-003',
               'AGENTFLOW_METRICS_FILE': str(self.root/'codex-refused-metrics.jsonl')}
        fake = self.write('fake-codex', '#!/bin/sh\nexit 0\n')
        fake.chmod(0o755)
        env['AGENTFLOW_CODEX_REAL'] = str(fake)
        clean_environment = {key: value for key, value in os.environ.items()
                             if not key.startswith('AGENTFLOW_')}
        clean_environment.update(env)
        captured = []
        def refuse(context):
            captured.append(context)
            return {'ready': False, 'stage': context.stage, 'provider': context.provider,
                    'prerequisites': []}
        previous = Path.cwd()
        os.chdir(self.root)
        self.addCleanup(os.chdir, previous)
        with patch.dict(os.environ, clean_environment, clear=True), \
                patch.object(agentflow_preflight, 'evaluate', side_effect=refuse), \
                patch.object(agentflow_codex, 'node24_path', return_value=None), \
                patch.object(agentflow_codex.subprocess, 'Popen') as spawn:
            code = agentflow_codex.main(['exec', 'Agentflow stage: develop'])
        self.assertEqual(code, 2)
        spawn.assert_not_called()
        self.assertEqual(captured[0].argv[0], str(fake))
        self.assertEqual(captured[0].cwd, self.root.resolve())
        self.assertEqual(captured[0].env['AGENTFLOW_TASK_ID'], 'TASK-003')
        events = [json.loads(line) for line in (self.root/'codex-refused-metrics.jsonl').read_text().splitlines()]
        self.assertEqual([event['event'] for event in events], ['agent_failed', 'agent_ended'])
        self.assertEqual(events[-1]['exit_code'], 2)

    def test_both_provider_shims_spawn_the_exact_preflight_context(self):
        from scripts import agentflow_codex, agentflow_opencode, agentflow_preflight
        codex = self.write('fake-codex', '#!/bin/sh\nexit 0\n'); codex.chmod(0o755)
        provider_events = {
            'codex': ('scripts.agentflow_codex', agentflow_codex,
                      ['exec', 'Agentflow stage: develop'],
                      {'type': 'thread.started', 'thread_id': 'fixture-session'}),
            'opencode': ('scripts.agentflow_opencode', agentflow_opencode,
                         ['run', 'Agentflow stage: develop'],
                         {'type': 'step_start', 'sessionID': 'ses_fixture00000000000000000000000000',
                          'part': {'type': 'step-start'}}),
        }
        for provider, (_, module, args, event) in provider_events.items():
            with self.subTest(provider=provider):
                real = codex if provider == 'codex' else self.fake
                metrics = self.root / f'{provider}-equivalence.jsonl'
                environment = {key: value for key, value in os.environ.items()
                               if not key.startswith('AGENTFLOW_')}
                environment.update({
                    'AGENTFLOW_CODEX_REAL' if provider == 'codex' else 'AGENTFLOW_OPENCODE_REAL': str(real),
                    'AGENTFLOW_TASK_ID': 'TASK-003', 'AGENTFLOW_METRICS_FILE': str(metrics),
                    'AGENTFLOW_STAGE_ATTEMPT_TOKEN': 'c' * 32,
                })
                contexts = []; spawned = []
                def accept(context):
                    contexts.append(context)
                    return {'ready': True, 'stage': context.stage, 'provider': context.provider,
                            'prerequisites': []}
                def popen(argv, **kwargs):
                    spawned.append({'argv': tuple(argv), 'cwd': Path.cwd().resolve(),
                                    'env': dict(os.environ), 'kwargs': kwargs})
                    stdout = io.StringIO(json.dumps(event) + "\n")
                    if provider == 'codex':
                        stdout = io.StringIO(json.dumps(event) + "\n" + json.dumps(
                            {'type': 'turn.completed', 'usage': {'input_tokens': 1, 'output_tokens': 1}}) + "\n")
                    return type('Child', (), {'stdout': stdout, 'wait': lambda self: 0})()
                previous = Path.cwd()
                os.chdir(self.root)
                try:
                    with patch.dict(os.environ, environment, clear=True), \
                            patch.object(agentflow_preflight, 'evaluate', side_effect=accept), \
                            patch.object(agentflow_codex, 'node24_path', return_value=None), \
                            patch.object(module.subprocess, 'Popen', side_effect=popen):
                        code = module.main(args)
                finally:
                    os.chdir(previous)
                self.assertEqual(code, 0)
                self.assertEqual(len(contexts), 1)
                self.assertEqual(len(spawned), 1)
                self.assertEqual(contexts[0].provider, provider)
                self.assertEqual(contexts[0].argv, spawned[0]['argv'])
                self.assertEqual(contexts[0].cwd, spawned[0]['cwd'])
                self.assertEqual(contexts[0].env, spawned[0]['env'])
                self.assertEqual(spawned[0]['env']['AGENTFLOW_STAGE_ATTEMPT_TOKEN'], 'c' * 32)
                self.assertEqual(spawned[0]['kwargs']['stdin'], subprocess.DEVNULL)

    def test_missing_format_flag_fails_loudly_once(self):
        self.fake.write_text((self.fake.read_text().replace('--format=', '--fmt=')))
        self.fake.chmod(0o755)
        result = self.run_shim('run', 'Agentflow stage: develop')
        self.assertNotEqual(result.returncode, 0)
        events = self.events()
        self.assertEqual(sum(event['event'] == 'agent_failed' for event in events), 1)
        self.assertEqual(events[-1]['exit_code'], 3)

    def frozen_assignment(self, model='opencode-go/glm-5.3-flash'):
        from scripts.agentflow_models import STAGES
        selection = {'schema_version': 1, 'provider': 'opencode', 'task_id': 'TASK-003',
                     'stages': {stage: {'model': model, 'effort': 'high',
                                        'sources': {'model': 'fixture', 'effort': 'fixture'}} for stage in STAGES},
                     'assignment_id': 'fixture000', 'generation': 1, 'parent': None,
                     'created_at': '2026-10-17T00:00:00+00:00'}
        path = self.root/'.agentflow/runs/assignments/fixture000.json'
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(selection))
        return path

    def test_command_dispatch_maps_onto_native_slash_invocation(self):
        result = self.run_shim('run', '--auto', '--command', 'speckit.implement',
                               'Agentflow stage: develop\nDo the thing', assignment=self.frozen_assignment())
        self.assertEqual(result.returncode, 0, result.stdout+result.stderr)
        captured = json.loads((self.root/'captured.jsonl').read_text().splitlines()[-1])
        self.assertNotIn('--command', captured)
        self.assertTrue(captured[-1].startswith('/speckit.implement '))
        self.assertIn('Agentflow stage: develop', captured[-1])
        self.assertIn('--format=json', captured)

    def test_command_without_name_is_refused_loudly(self):
        result = self.run_shim('run', '--auto', 'Agentflow stage: develop', '--command', assignment=self.frozen_assignment())
        self.assertEqual(result.returncode, 127, result.stdout+result.stderr)
        self.assertIn('missing a command name', result.stdout+result.stderr)

    def test_frozen_selection_inserts_model_before_positional_message(self):
        assignment = self.frozen_assignment()
        result = self.run_shim('run', '--auto', 'Agentflow stage: develop', assignment=assignment)
        self.assertEqual(result.returncode, 0, result.stdout+result.stderr)
        captured = json.loads((self.root/'captured.jsonl').read_text().splitlines()[0])
        model_index = captured.index('-m')+1
        self.assertEqual(captured[model_index], 'opencode-go/glm-5.3-flash')
        self.assertLess(model_index-1, captured.index('Agentflow stage: develop'))
        self.assertNotIn('model_reasoning_effort', captured)


class OuterLaunchTest(ProviderFixture):
    def load_agentflow(self):
        import importlib.machinery
        import importlib.util
        loader = importlib.machinery.SourceFileLoader('agentflow_outer_fixture', str(ROOT/'agentflow'))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        module = importlib.util.module_from_spec(spec)
        loader.exec_module(module)
        module.ROOT = self.root
        module.BACKLOG = self.root/'backlog'
        module.FEEDBACK = self.root/'backlog/feedback'
        module.RUNS = self.root/'.agentflow/runs'
        module.SPEC_RUNS = self.root/'.specify/workflows/runs'
        module.WORKFLOW = self.root/'.agentflow/workflow.yml'
        self.write('.agentflow/models.json', (ROOT/'.agentflow/models.json').read_text())
        module.Path = __import__('pathlib').PosixPath
        return module

    def test_start_preflight_refusal_precedes_branch_assignment_and_stage_spawn(self):
        from scripts import agentflow_preflight
        module = self.load_agentflow(); self.config()
        task = self.root/'backlog/TASK-003-example.md'
        before = task.read_bytes()
        contexts = []
        def refuse(context):
            contexts.append(context)
            raise RuntimeError('fixture preflight refusal')
        real_which = module.shutil.which
        fixture_shutil = SimpleNamespace(which=lambda name, *args, **kwargs: '/fixture/specify' if name == 'specify' else real_which(name, *args, **kwargs))
        with patch.dict(os.environ, {'PATH': self.preflight_path}), \
                patch.object(module, 'shutil', fixture_shutil), \
                patch.object(fixture_shutil, 'which', side_effect=lambda name, *args, **kwargs: '/fixture/specify' if name == 'specify' else real_which(name, *args, **kwargs)), \
                patch.object(module, 'agent', return_value='codex'), \
                patch.object(module, 'node24_path', return_value=None), \
                patch.object(agentflow_preflight, 'preflight_or_raise', side_effect=refuse):
            with self.assertRaisesRegex(RuntimeError, 'fixture preflight refusal'):
                module.start(module.parser().parse_args(['start', 'TASK-003', '--no-pr']))
        self.assertEqual(len(contexts), 1)
        self.assertEqual(contexts[0].stage, 'product')
        self.assertEqual(contexts[0].argv[:3], ('specify', 'workflow', 'run'))
        self.assertEqual(task.read_bytes(), before)
        self.assertEqual(module.git('branch', '--show-current').stdout.strip(), '003-example')
        self.assertFalse((self.root/'.agentflow/runs/assignments').exists())

    def test_resume_preflight_refusal_precedes_recovery_and_saved_state_mutation(self):
        from scripts import agentflow_preflight
        module = self.load_agentflow(); self.config()
        task = self.root/'backlog/TASK-003-example.md'
        args = SimpleNamespace(model=None, effort=None, stage_model=[], stage_effort=[])
        selection = module.models.resolve(self.root, task, args, provider='codex')
        assignment = module.models.save(self.root, selection)
        module.models.bind(self.root, assignment, 'fixture-run')
        task.write_text(task.read_text().replace('active_run: none', 'active_run: fixture-run'))
        run_dir = self.root/'.specify/workflows/runs/fixture-run'
        run_dir.mkdir(parents=True)
        state = {'status': 'paused', 'current_step_id': 'develop', 'current_step_index': 2,
                 'step_results': {}}
        module.json_write = None
        (run_dir/'state.json').write_text(json.dumps(state))
        before_task = task.read_bytes(); before_state = (run_dir/'state.json').read_bytes()
        before_assignment = assignment.read_bytes()
        contexts = []
        def refuse(context):
            contexts.append(context)
            raise RuntimeError('fixture preflight refusal')
        with patch.dict(os.environ, {'PATH': self.preflight_path}), \
                patch.object(module, 'node24_path', return_value=None), \
                patch.object(agentflow_preflight, 'preflight_or_raise', side_effect=refuse):
            with self.assertRaisesRegex(RuntimeError, 'fixture preflight refusal'):
                module.resume(module.parser().parse_args(['resume', 'TASK-003']))
        self.assertEqual(len(contexts), 1)
        self.assertEqual(contexts[0].stage, 'develop')
        self.assertEqual(contexts[0].argv[:4], ('specify', 'workflow', 'resume', 'fixture-run'))
        self.assertEqual(task.read_bytes(), before_task)
        self.assertEqual((run_dir/'state.json').read_bytes(), before_state)
        self.assertEqual(assignment.read_bytes(), before_assignment)

    def test_legacy_ci_baseline_resume_uses_saved_workflow_once_without_snapshot_write(self):
        module = self.load_agentflow(); self.config()
        task = self.root/'backlog/TASK-003-example.md'
        task.write_text(task.read_text().replace('active_run: none', 'active_run: fixture-run'))
        run_dir = self.root/'.specify/workflows/runs/fixture-run'
        run_dir.mkdir(parents=True)
        saved_workflow = ('steps:\n  - id: ci_baseline\n'
                          '    type: shell\n'
                          '    run: "MIX_ENV=test scripts/ci_unit_tests.sh"\n'
                          '  - id: qa\n')
        snapshot = run_dir/'workflow.yml'; snapshot.write_text(saved_workflow)
        before = snapshot.read_bytes()
        state = {'status': 'paused', 'current_step_id': 'ci_baseline', 'current_step_index': 2,
                 'step_results': {}}
        args = module.parser().parse_args(['resume', 'TASK-003'])
        launches = []
        patches = [
            patch.object(module.models, 'resume_selection', return_value=({}, False)),
            patch.object(module, 'node24_path', return_value=None),
            patch('scripts.agentflow_preflight.preflight_or_raise'),
            patch.object(module, 'bind_run_provider'),
            patch.object(module, 'read_run_state', return_value=state),
            patch.object(module, 'session_feature', return_value=None),
            patch.object(module, 'recover_orphaned_run'),
            patch.object(module, 'field'),
            patch.object(module.models, 'save', return_value=self.root/'assignment.json'),
            patch.object(module.models, 'bind'),
            patch.object(module, 'feature_for_task', return_value=None),
            patch.object(module, 'monitor_process', side_effect=lambda command, *a, **kw:
                         (launches.append(tuple(command)) or (130, 'fixture-run'))),
        ]
        for item in patches: item.start()
        self.addCleanup(lambda: [item.stop() for item in reversed(patches)])
        self.assertEqual(module.resume(args), 130)
        self.assertEqual(launches, [('specify', 'workflow', 'resume', 'fixture-run')])
        self.assertEqual(snapshot.read_bytes(), before)
        self.assertIn('MIX_ENV=test scripts/ci_unit_tests.sh', snapshot.read_text())

    def test_mocked_windows_outer_spawn_uses_preflight_context_and_process_group(self):
        import importlib.machinery
        import importlib.util
        import pathlib
        import threading
        loader = importlib.machinery.SourceFileLoader('agentflow_windows_fixture', str(ROOT/'agentflow'))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        module = importlib.util.module_from_spec(spec)
        loader.exec_module(module)
        self.config()
        module.ROOT = self.root
        module.Path = pathlib.PosixPath
        module.RUNS = self.root/'.agentflow/runs'
        module.SPEC_RUNS = self.root/'.specify/workflows/runs'
        module.WORKFLOW = self.root/'.agentflow/workflow.yml'
        task = self.root/'backlog/TASK-003-example.md'
        command = ['specify', 'workflow', 'run', 'fixture.yml']
        contexts = []; launches = []
        def record_context(context):
            contexts.append(context)
        def fake_popen(argv, **kwargs):
            launches.append((tuple(argv), kwargs))
            return type('Child', (), {'pid': 12345, 'stdout': None, 'returncode': 0,
                                      'poll': lambda self: 0})()
        class WindowsOS:
            name = 'nt'
            def __getattr__(self, name):
                return getattr(os, name)
        class NoThread:
            def __init__(self, *args, **kwargs): pass
            def start(self): pass
            def join(self, timeout=None): pass
        with patch.object(module, 'os', WindowsOS()), \
                patch.object(module.subprocess, 'CREATE_NEW_PROCESS_GROUP', 512, create=True), \
                patch.object(module, 'node24_path', return_value=None), \
                patch.object(module.threading, 'Thread', NoThread), \
                patch('scripts.agentflow_preflight.preflight_or_raise', side_effect=record_context), \
                patch.object(module.subprocess, 'Popen', side_effect=fake_popen):
            code, _run = module.monitor_process(command, task, provider='codex')
        self.assertEqual(code, 0)
        self.assertEqual(len(contexts), 1)
        self.assertEqual(len(launches), 1)
        argv, kwargs = launches[0]
        self.assertEqual(contexts[0].argv, argv)
        self.assertEqual(contexts[0].cwd, kwargs['cwd'])
        self.assertEqual(contexts[0].env, kwargs['env'])
        self.assertFalse(kwargs['start_new_session'])
        self.assertEqual(kwargs['creationflags'], 512)


class ShimContinuationTest(ProviderFixture):
    def setUp(self):
        ProviderFixture.setUp(self)
        self.config()
        for name in ('scripts/agentflow_opencode.py', 'scripts/agentflow_preflight.py',
                     'scripts/agentflow_runtime.py', 'scripts/agentflow_models.py',
                     'scripts/agentflow_feature.py', 'scripts/agentflow_verification.py',
                     'scripts/agentflow_providers.py', 'scripts/workflow_artifact_probe.py',
                     'scripts/agentflow_codex.py'):
            self.copy(name)
        (self.root/'scripts/__init__.py').write_text('')
        self.write('scripts/local_services.sh', '#!/bin/sh\n[ "$1" = ready ]\n')
        self.session = 'ses_fixture000000000000000000000000'
        self.fake = self.write('fake-opencode', f'#!{sys.executable}\nraise SystemExit(0)\n')
        self.fake.chmod(0o755)
    run_shim = ShimTest.run_shim
    copy = ShimTest.copy
    frozen_assignment = ShimTest.frozen_assignment

    def test_frozen_selection_for_another_provider_is_refused(self):
        from scripts.agentflow_models import STAGES
        assignment = self.frozen_assignment()
        swapped = json.loads(assignment.read_text())
        swapped['provider'] = 'codex'
        assignment.write_text(json.dumps(swapped))
        result = self.run_shim('run', 'Agentflow stage: develop', assignment=assignment)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('another provider', result.stdout+result.stderr)

    def test_continuation_flags_are_refused_under_adoption(self):
        assignment = self.frozen_assignment()
        result = self.run_shim('run', '--continue', 'Agentflow stage: develop', assignment=assignment, new_session=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('session continuation', result.stdout+result.stderr)


class ConsoleTest(DeliveryFixture):
    def test_opencode_payloads_are_hidden_but_marker_events_show(self):
        from scripts.agentflow_runtime import Console, MARKER
        console = Console()
        self.assertEqual(console.feed(json.dumps({'type': 'step_start', 'sessionID': 'ses_x', 'part': {}})+"\n"), '')
        self.assertEqual(console.feed(json.dumps({'type': 'text', 'sessionID': 'ses_x',
                                                  'part': {'type': 'text', 'text': 'hi'}})+"\n"), '')
        started = console.feed(MARKER+json.dumps({'event': 'agent_started', 'stage': 'develop'})+"\n")
        self.assertEqual(started, '[agent] develop started\n')


class CliProviderTest(ProviderFixture):
    def setUp(self):
        super().setUp()
        import importlib.machinery
        import importlib.util
        loader = importlib.machinery.SourceFileLoader('agentflow_providers_cli_module', str(ROOT/'agentflow'))
        spec = importlib.util.spec_from_loader(loader.name, loader)
        self.module = importlib.util.module_from_spec(spec)
        loader.exec_module(self.module)

    def test_resume_refuses_access_provider_without_explicit_adoption(self):
        import os
        import copy
        saved = {'schema_version': 1, 'provider': 'opencode', 'task_id': 'TASK-003', 'stages': {},
                 'assignment_id': 'x', 'generation': 1}
        args = SimpleNamespace(provider='codex', agent=None, adopt_models=False)
        with self.assertRaisesRegex(RuntimeError, 'refusing to resume'):
            self.module.resolved_resume_provider(saved, args)
        args = SimpleNamespace(provider=None, agent='codex')
        with self.assertRaisesRegex(RuntimeError, 'refusing to resume'):
            self.module.resolved_resume_provider(saved, args)
        # no explicit provider request: the saved provider is authoritative
        self.assertEqual(self.module.resolved_resume_provider(saved, SimpleNamespace(provider=None, agent=None)), 'opencode')
        legacy = {key: value for key, value in saved.items() if key != 'provider'}
        self.assertEqual(self.module.resolved_resume_provider(legacy, SimpleNamespace(provider=None, agent=None)), 'codex')

    def test_resume_provider_guard_refuses_non_adopted_switch_without_spec_kit_state(self):
        module = self.module
        import tempfile
        runs = Path(tempfile.mkdtemp())
        self.addCleanup(mk_cleanup(runs))
        module.SPEC_RUNS = runs
        run = 'fixture-run'
        (runs/run).mkdir()
        (runs/run/'inputs.json').write_text(json.dumps({'inputs': {'spec': 'fixture', 'integration': 'codex'}}))
        with self.assertRaisesRegex(RuntimeError, 'refusing to resume'):
            module.bind_run_provider(run, 'opencode', False)
        module.bind_run_provider(run, 'codex', True)
        self.assertEqual(json.loads((runs/run/'inputs.json').read_text())['inputs']['integration'], 'codex')
        module.bind_run_provider(run, 'opencode', True)
        saved = json.loads((runs/run/'inputs.json').read_text())['inputs']['integration']
        self.assertEqual(saved, 'opencode')
        self.assertEqual(json.loads((runs/run/'log.jsonl').read_text().splitlines()[-1])['event'], 'provider_adoption')

    def test_start_passes_provider_input_and_fails_loudly_without_fake_cli(self):
        """Without a fake opencode binary the provider selection still names it."""
        args = self.module.parser().parse_args(['start', 'TASK-003', '--provider', 'opencode', '--dry-run'])
        self.assertEqual(self.module.providers.from_args(args), 'opencode')
        args = self.module.parser().parse_args(['start', 'TASK-003'])
        self.assertEqual(self.module.providers.from_args(args), 'codex')
        args = self.module.parser().parse_args(['resume', 'TASK-003', '--provider', 'opencode'])
        self.assertEqual(args.provider, 'opencode')


if __name__ == '__main__':
    unittest.main()
