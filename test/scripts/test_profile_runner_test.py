import contextlib
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
            Path(env['PROFILE_EVENTS']).write_text(json.dumps(dict(nonce=env['PROFILE_NONCE'], runner=case['runner'], file=case['file'], case_id=case['case_id'], state='started'))+'\n')
            raise ValueError('child-failure')
        captured = io.StringIO()
        with patch.object(runner, 'check', return_value={'entries':[case]}), patch.object(runner, 'run', side_effect=fake), contextlib.redirect_stderr(captured):
            with self.assertRaises(ValueError):
                runner.main('unit')
        self.assertIn(case['id'], captured.getvalue())
        self.assertNotIn(case['case_id'], captured.getvalue())

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
