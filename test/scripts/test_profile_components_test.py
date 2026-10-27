import unittest
from test.scripts.test_inventory_test import load


class ComponentsTest(unittest.TestCase):
    def test_service_targets_are_unique_owned_and_loopback(self):
        from unittest.mock import MagicMock, patch
        adapter = load('test_profile_components')
        sockets = [MagicMock() for _ in range(4)]
        for sock, port in zip(sockets, (41001, 41002, 41003, 41004)):
            sock.getsockname.return_value = ('127.0.0.1', port)
        with patch.object(adapter.socket, 'socket', side_effect=sockets):
            a = adapter.service_identity()
            b = adapter.service_identity()
        for sock in sockets:
            sock.bind.assert_called_once_with(('127.0.0.1', 0))
            sock.close.assert_called_once_with()
        self.assertNotEqual(a['project'], b['project'])
        self.assertRegex(a['project'], r'^profile_[a-f0-9]{32}$')
        self.assertNotIn('football_market_local', str(a))
        self.assertEqual(len(set(a['ports'])), 2)
        self.assertEqual(a['host'], '127.0.0.1')

    def test_failed_port_binding_closes_every_created_socket(self):
        from unittest.mock import MagicMock, patch
        adapter = load('test_profile_components')
        first, second = MagicMock(), MagicMock()
        first.getsockname.return_value = ('127.0.0.1', 41001)
        second.bind.side_effect = OSError('controlled bind failure')
        with patch.object(adapter.socket, 'socket', side_effect=[first, second]):
            with self.assertRaises(OSError):
                adapter.service_identity()
        first.close.assert_called_once_with()
        second.close.assert_called_once_with()

    def test_native_python_discovery_includes_own_case(self):
        import json
        import os
        import sys
        import tempfile
        from pathlib import Path
        from unittest.mock import patch
        adapter = load('test_profile_components')
        cases = adapter.python_cases()
        names = [case.id() for case in cases]
        self.assertEqual(len(names), len(set(names)))
        # Discovery may load tests through the package-qualified module while
        # this assertion itself was launched from a discovery root.
        self.assertTrue(any(name.endswith(self.id()) for name in names))
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {
                'PROFILE_EVENTS': str(Path(directory) / 'events.jsonl'), 'PROFILE_NONCE': 'nonce'}):
            try:
                raise AssertionError('private assertion canary')
            except AssertionError:
                adapter.EventResult().report_failure(self, sys.exc_info(), 'assertion')
            event = json.loads(Path(directory, 'events.jsonl').read_text())
            self.assertEqual(event['state'], 'failed')
            self.assertEqual(event['cause'], 'assertion')
            self.assertIsInstance(event['failure_line'], int)
            self.assertGreater(event['failure_line'], 0)
            self.assertNotIn('private assertion canary', json.dumps(event))

    def test_docker_wrapper_rewrites_only_owned_compose_targets(self):
        import json
        import os
        from pathlib import Path
        import subprocess
        import tempfile
        from unittest.mock import patch
        adapter = load('test_profile_components')
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / 'calls'
            real = root / 'fake-docker'
            real.write_text('#!/usr/bin/env python3\nimport json,sys\nfrom pathlib import Path\nwith Path('+repr(str(log))+').open("a") as f: f.write(json.dumps(sys.argv[1:])+"\\n")\n')
            real.chmod(0o700)
            private = root / 'private'
            private.mkdir()
            identity = {'project': 'profile_' + 'a' * 32,
                        'ports': [41001, 41002], 'host': '127.0.0.1'}
            with patch('shutil.which', return_value=str(real)), \
                    patch.object(adapter, 'service_identity', return_value=identity):
                identity, _, compose, env = adapter.isolated_services(private)
            subprocess.run([str(private/'docker'), 'compose', '--project-name', 'football_market_local', 'up', '-d'], env=env, check=True)
            calls = [json.loads(line) for line in log.read_text().splitlines()]
            self.assertEqual(calls[-1][:5], ['compose','--file',str(compose),'--project-name',identity['project']])
            config = compose.read_text()
            self.assertNotIn('football_market_local', config)
            self.assertIn(identity['project']+'_postgres_data', config)
            self.assertIn('postgres:17.6-alpine@sha256:', config)
            self.assertEqual(env['TMPDIR'], str(private))
            failed = subprocess.run([str(private/'docker'), 'compose', '--project-name', 'unowned', 'down'], env=env)
            self.assertNotEqual(failed.returncode, 0)
            self.assertEqual(log.read_text().splitlines(), [json.dumps(call) for call in calls])

    def test_native_node_events_match_a_controlled_population(self):
        import json
        import os
        from pathlib import Path
        import subprocess
        import tempfile
        from collections import Counter
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'fixture.test.mjs'
            source.write_text("import test from 'node:test'; test('one',()=>{}); test('two',()=>{});\n")
            events = Path(directory) / 'events'
            subprocess.run(['node','--test','--test-isolation=none',
                            '--test-reporter=./tools/openapi/profile_reporter.mjs',str(source)],
                           env={**os.environ,'PROFILE_EVENTS':str(events),'PROFILE_NODE_FILE':'fixture'}, check=True)
            result = [json.loads(line) for line in events.read_text().splitlines()]
            self.assertEqual(Counter((e['case_id'],e['state']) for e in result),
                             Counter({(name,state):1 for name in ('one','two') for state in ('started','passed')}))

    def test_nested_integration_shell_suites_are_discovered_and_owned(self):
        adapter = load('test_profile_components')
        cases = adapter.discover_native()
        for name in ('infrastructure_verify_test.sh', 'redis_disposability_test.sh'):
            selected = [case for case in cases if case['file'] == 'test/integration/' + name]
            self.assertTrue(selected, name)
            self.assertTrue(all(case['profile'] == 'integration' for case in selected))
            self.assertIn(name, adapter.SERVICE_FILES)

        from pathlib import Path
        self.assertIn('export MIX_ENV=dev', Path('test/integration/infrastructure_verify_test.sh').read_text())
        self.assertIn('football_market_test${MIX_TEST_PARTITION:-}', Path('test/integration/redis_disposability_test.sh').read_text())
