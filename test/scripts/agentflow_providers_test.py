"""Provider selection, environment interposition, and flag shaping; no model calls."""
import json
import os
import subprocess
import sys
import unittest
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
        self.copy('scripts/agentflow_runtime.py')
        self.copy('scripts/agentflow_models.py')
        self.copy('scripts/agentflow_feature.py')
        self.copy('scripts/agentflow_verification.py')
        self.copy('scripts/agentflow_providers.py')
        self.copy('scripts/workflow_artifact_probe.py')
        self.copy('scripts/agentflow_codex.py')
        (self.root/'scripts/__init__.py').write_text('')
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
                           AGENTFLOW_METRICS_FILE=str(self.root/'events.jsonl'))
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
        self.assertFalse(any(arg.startswith('-m') for arg in captured))
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
