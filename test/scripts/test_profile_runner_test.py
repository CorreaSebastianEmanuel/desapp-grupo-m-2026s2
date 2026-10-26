import contextlib
import errno
import importlib.util
import io
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'scripts'))
import test_profile_runner as runner
from test_inventory import entry


class RunnerTest(unittest.TestCase):
    def test_profile_timeout_ceilings_allow_full_integration_without_widening_other_profiles(self):
        self.assertEqual(runner.profile_timeout_ceiling('unit'), 600)
        self.assertEqual(runner.profile_timeout_ceiling('integration'), 1800)
        self.assertEqual(runner.profile_timeout_ceiling('e2e'), 180)
        with self.assertRaisesRegex(ValueError, 'usage'):
            runner.profile_timeout_ceiling('unknown')

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

    def test_browser_preflight_classifies_only_closed_causes_and_keeps_raw_errors_private(self):
        def completed(code=0, stdout='v24.1.0'):
            return subprocess.CompletedProcess([], code, stdout, '')
        with patch.object(runner.shutil, 'which', return_value=None):
            self.assertEqual(runner.browser_prerequisite({'PATH': ''}, lambda *_: None), 'executable-missing')
        with patch.object(runner.shutil, 'which', return_value='/node'), \
                patch.object(runner.subprocess, 'run', return_value=completed(stdout='v20.1.0')):
            self.assertEqual(runner.browser_prerequisite({'PATH': '/bin'}, lambda *_: None), 'launch-failed')
        for cause, results in (
            ('dependency-missing', [completed(), completed(code=1, stdout='')]),
            ('executable-missing', [completed(), completed(), completed(code=1, stdout='')]),
        ):
            with self.subTest(cause=cause), patch.object(runner.shutil, 'which', return_value='/node'), \
                    patch.object(runner.subprocess, 'run', side_effect=results):
                self.assertEqual(runner.browser_prerequisite({'PATH': '/bin'}, lambda *_: None), cause)
        for error, cause in ((OSError(errno.ENOENT, 'private-path-sentinel'), 'executable-missing'),
                             (OSError(errno.EACCES, 'private-path-sentinel'), 'permission-denied'),
                             (ValueError('timeout'), 'launch-timeout'),
                             (ValueError('private-error-sentinel'), 'launch-failed')):
            with self.subTest(cause=cause), patch.object(runner.shutil, 'which', return_value='/node'), \
                    patch.object(runner.subprocess, 'run', side_effect=[completed(), completed(), completed()]):
                self.assertEqual(runner.browser_prerequisite(
                    {'PATH': '/bin'}, lambda *_args, error=error: (_ for _ in ()).throw(error)), cause)
        with patch.object(runner.shutil, 'which', return_value='/node'), \
                patch.object(runner.subprocess, 'run', side_effect=[completed(), completed(), completed()]):
            self.assertEqual(runner.browser_prerequisite(
                {'PATH': '/bin'}, lambda *_: (_ for _ in ()).throw(ValueError('child-failure'))),
                'launch-failed')
        with patch.object(runner.shutil, 'which', return_value='/node'), \
                patch.object(runner.subprocess, 'run', side_effect=[completed(), completed(), completed()]):
            self.assertIsNone(runner.browser_prerequisite({'PATH': '/bin'}, lambda *_: None))

    def test_browser_prerequisite_uses_configured_chromium_and_default_when_unset(self):
        completed = subprocess.CompletedProcess([], 0, 'v24.1.0', '')
        for env in ({'PATH': '/bin', 'CHROMIUM_PATH': '/verified/chrome/chrome'}, {'PATH': '/bin'}):
            launched = []
            def launch(argv, child_env, _timeout):
                launched.append((argv, child_env))
            with self.subTest(configured='CHROMIUM_PATH' in env), \
                    patch.object(runner.shutil, 'which', return_value='/node'), \
                    patch.object(runner.subprocess, 'run', side_effect=[completed, completed, completed]):
                self.assertIsNone(runner.browser_prerequisite(env, launch))
            argv, child_env = launched[0]
            script = argv[2]
            self.assertIn('process.env.CHROMIUM_PATH', script)
            self.assertEqual(child_env.get('CHROMIUM_PATH'), env.get('CHROMIUM_PATH'))

    def test_browser_preflight_supervisor_timeout_emits_safe_timeout_cause(self):
        captured = io.StringIO()
        with patch.object(runner, 'check', return_value={'entries': []}), \
                patch.object(runner, 'browser_prerequisite', return_value='launch-timeout'), \
                contextlib.redirect_stderr(captured), self.assertRaisesRegex(ValueError, 'browser-prerequisite'):
            runner.main('e2e')
        self.assertEqual(captured.getvalue().splitlines(), [
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-timeout',
            'PROFILE_BROWSER_DIAGNOSTIC cause=launch-timeout stage=e2e'])
        self.assertNotIn('private', captured.getvalue())

    def test_generated_playwright_probe_preserves_only_closed_launch_causes(self):
        node = runner.shutil.which('node')
        if not node:
            self.skipTest('Node is required by the profile runner')
        cases = (
            ('Timeout 10000ms exceeded', None, 'launch-timeout'),
            ('spawn chromium EACCES permission denied', 'EACCES', 'permission-denied'),
            ('Cannot find module private-package', 'MODULE_NOT_FOUND', 'dependency-missing'),
            ('error while loading shared libraries: libExample.so: cannot open shared object file',
             None, 'dependency-missing'),
            ('spawn chromium ENOENT no such file or directory', 'ENOENT', 'executable-missing'),
            ("Executable doesn't exist at /private/browser", None, 'executable-missing'),
            ('Host system is missing dependencies to run browsers.', None, 'dependency-missing'),
            ('private-launch-sentinel', None, 'launch-failed'),
        )
        source = runner.browser_launch_probe_script()
        for message, code, cause in cases:
            with self.subTest(cause=cause, message=message):
                wrapper = (
                    "const vm=require('vm'), real=process, source=" + json.dumps(source) + ";"
                    "const error=Object.assign(new Error(" + json.dumps(message) + ")," +
                    json.dumps({'code': code}) + ");"
                    "const child={env:{},stderr:real.stderr,set exitCode(value){real.exitCode=value}};"
                    "vm.runInNewContext(source,{require:()=>({chromium:{launch:()=>Promise.reject(error)}}),process:child});"
                    "setTimeout(()=>real.exit(real.exitCode||0),0);"
                )
                output = io.StringIO()
                with contextlib.redirect_stderr(output), self.assertRaises(runner.BrowserLaunchFailure) as raised:
                    runner.run([node, '-e', wrapper], os.environ.copy(), 5)
                self.assertEqual(raised.exception.cause, cause)
                self.assertNotIn('private-launch-sentinel', output.getvalue())
                self.assertNotIn(message, output.getvalue())

    def test_python_browser_probe_exceptions_map_only_closed_causes(self):
        for error, cause in (
            (TimeoutError('private timeout text'), 'launch-timeout'),
            (PermissionError('private permission denied path'), 'permission-denied'),
            (FileNotFoundError('private no such file path'), 'executable-missing'),
            (ModuleNotFoundError('private dependency'), 'dependency-missing'),
            (RuntimeError("Executable doesn't exist at /private/browser"), 'executable-missing'),
            (RuntimeError('Host system is missing dependencies to run browsers.'), 'dependency-missing'),
            (OSError('private unknown error'), 'launch-failed'),
        ):
            with self.subTest(cause=cause):
                self.assertEqual(runner._browser_probe_error(error, 'launch-failed'), cause)

    def test_supervisor_forwards_only_complete_safe_browser_records(self):
        from pathlib import Path
        evidence = io.BytesIO(b'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed\n'
                              b'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed secret=x\n'
                              b'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=private\n'
                              b'PROFILE_BROWSER_DIAGNOSTIC cause=launch-failed stage=integration\n'
                              b'BROWSER-RAW-CANARY private-path-sentinel\n')
        captured = io.StringIO()
        with contextlib.redirect_stderr(captured):
            runner._forward_safe_browser_diagnostics(evidence)
        self.assertEqual(captured.getvalue().splitlines(), [
            'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-failed',
            'PROFILE_BROWSER_DIAGNOSTIC cause=launch-failed stage=integration'])
        self.assertNotIn('CANARY', captured.getvalue())

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
        with patch.object(runner, 'check', return_value={'entries':[case]}), patch.object(runner, 'browser_prerequisite', return_value=None), patch.object(runner, 'run', side_effect=fake), contextlib.redirect_stderr(captured):
            with self.assertRaises(ValueError):
                runner.main('unit')
        output = captured.getvalue()
        self.assertEqual(output.count('PROFILE_CASE_DIAGNOSTIC'), 1)
        self.assertIn('PROFILE_CASE_DIAGNOSTIC id=' + case['id'], output)
        self.assertIn('case=redacted state=failed cause=assertion line=41 started=1 passed=0 failed=1 skipped=0', output)
        self.assertNotIn(case['case_id'], captured.getvalue())
        self.assertEqual(runner.failure_cause('exunit', [{'state': 'failed'}], 1, 0), 'error')
        self.assertEqual(runner.failure_cause('python', [{'state': 'failed'}], 1, 0), 'assertion')

    def test_unregistered_failure_event_never_emits_case_identity(self):
        expected = entry('python', 'test/scripts/expected_test.py', 'test.expected.Case.test_known', 'unit')
        exunit = entry('exunit', 'test/expected_test.exs', 'Expected:test known', 'unit')
        unregistered_id = 'test.scripts.unregistered_test.Case.test_private_marker'
        unregistered = entry('python', 'test/scripts/unregistered_test.py', unregistered_id, 'unit')
        def fake(argv, env, _timeout):
            if argv[0] != 'mix':
                return
            events = [dict(nonce=env['PROFILE_NONCE'], runner=unregistered['runner'],
                           file=unregistered['file'], case_id=unregistered['case_id'], state='started'),
                      dict(nonce=env['PROFILE_NONCE'], runner=unregistered['runner'],
                           file=unregistered['file'], case_id=unregistered['case_id'], state='failed',
                           cause='assertion', failure_line=17)]
            Path(env['PROFILE_EVENTS']).write_text(''.join(json.dumps(value)+'\n' for value in events))
            raise ValueError('child-failure')
        captured = io.StringIO()
        with patch.object(runner, 'check', return_value={'entries':[expected, exunit]}), \
                patch.object(runner, 'run', side_effect=fake), contextlib.redirect_stderr(captured):
            with self.assertRaises(ValueError):
                runner.main('unit')
        self.assertNotIn(unregistered_id, captured.getvalue())
        self.assertNotIn('PROFILE_CASE_DIAGNOSTIC', captured.getvalue())

    def test_mix_test_failure_emits_only_aggregate_lifecycle_counts(self):
        case = entry('exunit', 'test/fake_test.exs', 'Fake:test secret_case_name', 'unit')
        def fake(argv, env, timeout):
            if argv[0] != 'mix':
                return
            events = [
                dict(nonce=env['PROFILE_NONCE'], runner='exunit', file=case['file'], case_id=case['case_id'], state='started'),
                dict(nonce=env['PROFILE_NONCE'], runner='exunit', file=case['file'], case_id=case['case_id'], state='failed', error='secret assertion'),
            ]
            Path(env['PROFILE_EVENTS']).write_text(''.join(json.dumps(value)+'\n' for value in events))
            raise ValueError('child-failure')
        captured = io.StringIO()
        with patch.object(runner, 'check', return_value={'entries':[case]}), patch.object(runner, 'run', side_effect=fake), contextlib.redirect_stderr(captured):
            with self.assertRaises(ValueError):
                runner.main('unit')
        output = captured.getvalue()
        self.assertIn('PROFILE_EVENT_SUMMARY profile=unit step=tests started=1 passed=0 failed=1 skipped=0', output)
        self.assertNotIn('secret_case_name', output)
        self.assertNotIn('secret assertion', output)

    def test_mix_failure_before_any_test_event_emits_zero_summary(self):
        case = entry('exunit', 'test/fake_test.exs', 'Fake:test case', 'unit')
        def fake(argv, _env, _timeout):
            if argv[0] == 'mix':
                raise ValueError('child-failure')
        captured = io.StringIO()
        with patch.object(runner, 'check', return_value={'entries':[case]}), patch.object(runner, 'run', side_effect=fake), contextlib.redirect_stderr(captured):
            with self.assertRaises(ValueError):
                runner.main('unit')
        self.assertIn('PROFILE_EVENT_SUMMARY profile=unit step=tests started=0 passed=0 failed=0 skipped=0', captured.getvalue())

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
            self.assertEqual(tests[0][1]['POSTGRES_PORT'], '55435')
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
