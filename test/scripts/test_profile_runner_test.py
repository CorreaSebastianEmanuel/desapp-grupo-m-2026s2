import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import signal
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'scripts'))
import test_profile_runner as runner
from test_inventory import entry


class RunnerTest(unittest.TestCase):
    def test_profile_timeouts_bound_runtime_without_truncating_full_integration_suite(self):
        self.assertEqual(runner.PROFILE_TIMEOUTS, {
            'unit': 600, 'integration': 1500, 'e2e': 180
        })

    def test_profile_environment_bounds_default_scheduler_count_and_preserves_explicit_choice(self):
        default = runner.profile_environment('integration', '/tmp/events.jsonl', 'nonce', {
            'PATH': '/bin', 'APPLICATION_COVERAGE_DIR': '/private/coverage', 'DEBUG': '1'
        })
        self.assertEqual(default['ERL_FLAGS'], '+S 4:4')
        self.assertEqual(default['MIX_ENV'], 'test')
        self.assertNotIn('APPLICATION_COVERAGE_DIR', default)
        self.assertNotIn('DEBUG', default)

        explicit = runner.profile_environment('integration', '/tmp/events.jsonl', 'nonce', {
            'PATH': '/bin', 'ERL_FLAGS': '+S 2:2'
        })
        self.assertEqual(explicit['ERL_FLAGS'], '+S 2:2')

    def test_browser_preflight_classifies_only_closed_causes_and_keeps_raw_errors_private(self):
        node = shutil.which('node')
        if not node:
            self.skipTest('Node is required by the existing unit toolchain')
        with tempfile.TemporaryDirectory() as directory:
            preload = Path(directory) / 'preload.cjs'
            preload.write_text("""
const Module = require('node:module');
const original = Module._load;
Module._load = function(request, parent, isMain) {
  if (request === './tools/openapi/node_modules/playwright-core') {
    return {chromium: {launch: (options) => {
      if (process.env.PREFLIGHT_MODE === 'success') {
        console.log(JSON.stringify(options));
        return Promise.resolve({close: () => Promise.resolve()});
      }
      return Promise.reject(new Error(process.env.PREFLIGHT_ERROR));
    }}};
  }
  return original.call(this, request, parent, isMain);
};
""")
            argv = runner.browser_preflight_command()
            scenarios = [
                ('executable-missing', 'browser executable missing'),
                ('dependency-missing', 'shared library missing'),
                ('dependency-missing', "Error: Cannot find module 'playwright-core'\nRequire stack:\n- /private/path/preflight.cjs"),
                ('dependency-missing', "code: 'MODULE_NOT_FOUND'"),
                ('permission-denied', 'permission denied'),
                ('launch-timeout', 'timeout while launching'),
                ('launch-failed', 'opaque-secret-sentinel unknown browser error'),
            ]
            for cause, message in scenarios:
                with self.subTest(cause=cause):
                    completed = subprocess.run(
                        argv, env={**os.environ, 'NODE_OPTIONS': '--require=' + str(preload),
                                   'PREFLIGHT_ERROR': message}, text=True,
                        capture_output=True, timeout=15)
                    self.assertNotEqual(completed.returncode, 0)
                    self.assertEqual(completed.stderr.strip(),
                                     f'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause={cause}')
                    self.assertNotIn('opaque-secret-sentinel', completed.stderr)
            default_env = {**os.environ, 'NODE_OPTIONS': '--require=' + str(preload),
                           'PREFLIGHT_MODE': 'success'}
            default_env.pop('CHROMIUM_PATH', None)
            success = subprocess.run(argv, env=default_env, text=True, capture_output=True, timeout=15)
            self.assertEqual(success.returncode, 0)
            self.assertNotIn('PROFILE_SAFE_DIAGNOSTIC', success.stderr)
            self.assertNotIn('executablePath', json.loads(success.stdout))

            configured = subprocess.run(
                argv, env={**default_env, 'CHROMIUM_PATH': '/verified/chrome/chrome'}, text=True,
                capture_output=True, timeout=15)
            self.assertEqual(configured.returncode, 0)
            self.assertEqual(json.loads(configured.stdout)['executablePath'], '/verified/chrome/chrome')

    def test_supervisor_forwards_only_complete_safe_browser_records(self):
        lines = [
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed',
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=forged',
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-timeout extra=secret',
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed\x1b[31m',
            'PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=location',
            'raw-secret-sentinel /private/browser/path',
        ]
        code = 'import sys;sys.stderr.write(' + repr('\n'.join(lines) + '\n') + ');raise SystemExit(1)'
        captured = io.StringIO()
        with contextlib.redirect_stderr(captured), self.assertRaises(ValueError):
            runner.run([sys.executable, '-c', code], os.environ.copy(), 5)
        self.assertEqual(captured.getvalue().splitlines(), [lines[0], lines[4]])
        self.assertNotIn('secret', captured.getvalue())
        self.assertNotIn('/private', captured.getvalue())

    def test_browser_preflight_supervisor_timeout_emits_safe_timeout_cause(self):
        node = shutil.which('node')
        if not node:
            self.skipTest('Node is required by the existing unit toolchain')
        with tempfile.TemporaryDirectory() as directory:
            preload = Path(directory) / 'preload.cjs'
            preload.write_text("""
const Module = require('node:module');
const original = Module._load;
Module._load = function(request, parent, isMain) {
  if (request === './tools/openapi/node_modules/playwright-core') {
    return {chromium: {launch: () => new Promise(() => setInterval(() => {}, 1000))}};
  }
  return original.call(this, request, parent, isMain);
};
""")
            captured = io.StringIO()
            with contextlib.redirect_stderr(captured), self.assertRaises(ValueError):
                runner.run(runner.browser_preflight_command(),
                           {**os.environ, 'NODE_OPTIONS': '--require=' + str(preload)}, .05)
            self.assertIn('cause=launch-timeout', captured.getvalue())

    def test_resource_cleanup_runs_after_child_exit_and_failure_propagates(self):
        import re
        code = "import os;from pathlib import Path;Path(os.environ['PROFILE_RESOURCES']).write_text('[]');print('cleanup-secret-sentinel')"
        for fails in (False, True):
            def cleanup(env):
                self.assertIsNone(runner.child)
                self.assertTrue(Path(env['PROFILE_RESOURCES']).exists())
                self.assertIsNotNone(re.fullmatch(r'[a-f0-9]{32}', env['PROFILE_RESOURCE_NONCE']))
                if fails:
                    raise ValueError('resource-cleanup')
            output = io.StringIO()
            with contextlib.redirect_stdout(output), patch.object(runner, 'cleanup_resources', side_effect=cleanup) as callback:
                if fails:
                    with self.assertRaisesRegex(ValueError, 'resource-cleanup'):
                        runner.run([sys.executable, '-c', code], os.environ.copy(), 5)
                else:
                    runner.run([sys.executable, '-c', code], os.environ.copy(), 5)
                callback.assert_called_once()
            self.assertNotIn('cleanup-secret-sentinel', output.getvalue())

    def test_child_failure_and_timeout_never_publish_raw_secrets(self):
        with tempfile.TemporaryDirectory() as directory:
            for code in ["print('password-token-key-hash');raise SystemExit(9)",
                         "import time;print('password-token-key-hash');time.sleep(30)"]:
                capture = io.StringIO()
                with contextlib.redirect_stdout(capture), self.assertRaises(ValueError):
                    runner.run([sys.executable, '-c', code], os.environ.copy(), .1)
                self.assertNotIn('password-token-key-hash', capture.getvalue())
                self.assertIsNone(runner.child)
                self.assertEqual(list(Path(directory).iterdir()), [])

    def test_stale_receipt_removed_before_discovery_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            receipt = Path(directory) / 'receipt.json'
            receipt.write_text('{"status":"complete"}')
            with patch.dict(os.environ, CP1_PROFILE_RECEIPT=str(receipt)), patch.object(runner, 'check', side_effect=ValueError('discovery')):
                with self.assertRaises(ValueError):
                    runner.main('unit')
            self.assertFalse(receipt.exists())

    def test_equal_count_substitution_and_partial_execution_cannot_complete(self):
        case = entry('exunit', 'test/fake_test.exs', 'Fake:test a', 'unit')
        for states in [[], ['started'], ['passed'], ['started','skipped'],
                       ['started','passed','passed'], ['started','failed']]:
            with self.subTest(states=states), tempfile.TemporaryDirectory() as directory:
                receipt = Path(directory) / 'receipt'
                def fake(argv, env, timeout):
                    if argv[0] == 'mix':
                        with open(env['PROFILE_EVENTS'], 'a') as stream:
                            for state in states:
                                stream.write(json.dumps(dict(nonce=env['PROFILE_NONCE'],runner='exunit', file=case['file'], case_id=case['case_id'], state=state))+'\n')
                with patch.dict(os.environ, CP1_PROFILE_RECEIPT=str(receipt)), patch.object(runner, 'check', return_value={'entries':[case]}), patch.object(runner, 'run', side_effect=fake):
                    with self.assertRaises(ValueError):
                        runner.main('unit')
                self.assertFalse(receipt.exists())

    def test_signals_terminate_owned_children_and_return_failure(self):
        for sig in (signal.SIGINT, signal.SIGTERM):
            with patch.object(runner, 'terminate') as terminate, self.assertRaises(SystemExit) as result:
                runner.interrupted(sig, None)
            self.assertEqual(result.exception.code, 128 + sig)
            terminate.assert_called_once()

    def test_missing_native_runner_is_failure(self):
        with self.assertRaises(OSError):
            runner.run(['/definitely-missing-profile-runner'], os.environ.copy(), .1)
        self.assertIsNone(runner.child)

    def test_browser_prerequisite_reports_only_closed_causes(self):
        def completed(code=0, stdout='v24.1.0'):
            return subprocess.CompletedProcess([], code, stdout, '')
        with patch.object(runner.shutil, 'which', return_value=None):
            self.assertEqual(runner.browser_prerequisite({'PATH': ''}, lambda *_: None), 'node-unavailable')
        with patch.object(runner.shutil, 'which', return_value='/node'), \
                patch.object(runner.subprocess, 'run', return_value=completed(stdout='v20.1.0')):
            self.assertEqual(runner.browser_prerequisite({'PATH': '/bin'}, lambda *_: None), 'node-incompatible')
        for cause, results in (
            ('playwright-missing', [completed(), completed(code=1, stdout='')]),
            ('bundled-chromium-missing', [completed(), completed(), completed(code=1, stdout='')]),
        ):
            with self.subTest(cause=cause), patch.object(runner.shutil, 'which', return_value='/node'), \
                    patch.object(runner.subprocess, 'run', side_effect=results):
                self.assertEqual(runner.browser_prerequisite({'PATH': '/bin'}, lambda *_: None), cause)
        with patch.object(runner.shutil, 'which', return_value='/node'), \
                patch.object(runner.subprocess, 'run', side_effect=[completed(), completed(), completed()]):
            self.assertEqual(runner.browser_prerequisite(
                {'PATH': '/bin'}, lambda *_: (_ for _ in ()).throw(ValueError('child-failure'))),
                'chromium-launch-failed')
        with patch.object(runner.shutil, 'which', return_value='/node'), \
                patch.object(runner.subprocess, 'run', side_effect=[completed(), completed(), completed()]):
            self.assertIsNone(runner.browser_prerequisite({'PATH': '/bin'}, lambda *_: None))

    def test_hard_kill_cannot_retain_a_previous_complete_receipt(self):
        import time
        with tempfile.TemporaryDirectory() as directory:
            receipt = Path(directory) / 'receipt'
            receipt.write_text('{"status":"complete"}')
            ready = Path(directory) / 'ready'
            code = "import sys,time;from pathlib import Path;sys.path.insert(0,'scripts');import test_profile_runner as r;" + "r.check=lambda: (Path("+repr(str(ready))+").touch(),time.sleep(30))[1];r.main('unit')"
            child = subprocess.Popen([sys.executable,'-c',code], env={**os.environ,'CP1_PROFILE_RECEIPT':str(receipt)}, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            try:
                deadline = time.monotonic()+5
                while not ready.exists() and child.poll() is None and time.monotonic()<deadline:
                    time.sleep(.01)
                self.assertTrue(ready.exists())
                child.kill()
                child.wait(timeout=5)
                self.assertFalse(receipt.exists())
            finally:
                if child.poll() is None: child.kill()
                child.wait()

    def test_component_failure_identifies_unfinished_case_without_raw_name(self):
        case = entry('python', 'test/scripts/secret_test.py', 'secret-password-token-key', 'unit')
        def fake(argv, env, timeout):
            events = [
                dict(nonce=env['PROFILE_NONCE'], runner=case['runner'], file=case['file'], case_id=case['case_id'], state='started'),
                dict(nonce=env['PROFILE_NONCE'], runner=case['runner'], file=case['file'], case_id=case['case_id'],
                     state='failed', cause='assertion', failure_line=41),
            ]
            Path(env['PROFILE_EVENTS']).write_text(''.join(json.dumps(value)+'\n' for value in events))
            raise ValueError('child-failure')
        captured = io.StringIO()
        with patch.object(runner, 'check', return_value={'entries':[case]}), patch.object(runner, 'run', side_effect=fake), contextlib.redirect_stderr(captured):
            with self.assertRaises(ValueError):
                runner.main('unit')
        output = captured.getvalue()
        self.assertEqual(output.count('PROFILE_CASE_DIAGNOSTIC'), 1)
        self.assertIn('PROFILE_CASE_DIAGNOSTIC id=' + case['id'], output)
        self.assertIn('case=redacted state=failed cause=assertion line=41 started=1 passed=0 failed=1 skipped=0', output)
        self.assertNotIn(case['case_id'], captured.getvalue())
        self.assertEqual(runner.failure_cause('exunit', [{'state': 'failed'}], 1, 0), 'error')
        self.assertEqual(runner.failure_cause('python', [{'state': 'failed'}], 1, 0), 'assertion')

    def test_membership_diagnostic_is_aggregate_and_never_prints_case_ids(self):
        from test_inventory import reconcile_diagnostics
        expected = [{'id': 'a' * 24}, {'id': 'b' * 24}]
        events = [
            {'id': 'a' * 24, 'state': 'started'}, {'id': 'a' * 24, 'state': 'passed'},
            {'id': 'a' * 24, 'state': 'started'}, {'id': 'b' * 24, 'state': 'started'},
            {'id': 'x' * 24, 'state': 'passed'}, {'id': 'b' * 24, 'state': 'skipped'},
        ]
        result = reconcile_diagnostics(expected, events)
        self.assertEqual(result, {'reason': 'extra-events', 'expected': 2, 'observed': 6,
            'missing_started': 0, 'missing_passed': 1, 'extra': 1,
            'duplicate': 1, 'invalid_state': 1})
        captured = io.StringIO()
        with contextlib.redirect_stderr(captured):
            runner.emit_membership_diagnostic('unit', 'event-reconciliation', **result)
        marker = captured.getvalue()
        self.assertIn('reason=extra-events expected=2 observed=6', marker)
        self.assertNotIn('a' * 24, marker)
        self.assertNotIn('x' * 24, marker)

    def test_committed_suites_keep_upstream_partition_isolation_and_coverage_scope(self):
        with tempfile.TemporaryDirectory() as directory:
            files = ['test/regular_test.exs', 'test/committed_test.exs']
            calls = []
            def execute(argv, extra=None, **kwargs):
                calls.append((argv, extra))
                if argv[:3] == ['mix', 'run', '--no-start']:
                    Path(directory, 'committed-files.json').write_text(json.dumps(files[1:]))
            with patch.dict(os.environ, {'CP1_PROFILE_COVERAGE': '0'}):
                runner.execute_exunit(execute, 'integration', files, directory, 'a' * 32, '55435')
            tests = [(argv, env) for argv, env in calls if argv[:2] == ['mix', 'test']]
            self.assertEqual(len(tests), 2)
            self.assertEqual(tests[0][0][-1], files[0])
            self.assertEqual(tests[0][1], None)
            self.assertEqual(tests[1][0][-1], files[1])
            self.assertRegex(tests[1][1]['MIX_TEST_PARTITION'], r'^profile[a-f0-9]{32}_c0$')
            self.assertEqual(tests[1][1]['POSTGRES_PORT'], '55435')
            prepare = [(argv, env) for argv, env in calls if argv == ['mix', 'test.prepare']]
            self.assertEqual(prepare, [(['mix', 'test.prepare'], tests[1][1])])
            calls.clear()
            with patch.dict(os.environ, {'CP1_PROFILE_COVERAGE': '1'}):
                runner.execute_exunit(execute, 'integration', files, directory, 'a' * 32, '55435')
            self.assertEqual(len(calls), 1)
            self.assertEqual(calls[0][0][-2:], files)
            self.assertIn('--export-coverage', calls[0][0])
