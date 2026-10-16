"""CI parity and failure assertions using deterministic subprocess substitutes."""
import hashlib
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import agentflow_ci_check as ci
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture


class InventoryTest(DeliveryFixture):
    def data(self):
        for name in ci.WORKFLOWS:
            self.write(name, 'fixture workflow\n')
        return {'checks': [{'id': 'unit'}],
                'ci_workflow_digests': {name: hashlib.sha256((self.root/name).read_bytes()).hexdigest() for name in ci.WORKFLOWS},
                'ci_obligations': [{'id': str(i), 'workflow': name, 'disposition': 'local-equivalent',
                                    'checks': ['unit'], 'reason': 'Required existing profile'} for i, name in enumerate(ci.WORKFLOWS)]}

    def test_changed_workflow_requires_replanning(self):
        data = self.data()
        self.assertEqual(ci.inventory(self.root, data), data['ci_workflow_digests'])
        self.write(ci.WORKFLOWS[0], 'new command\n')
        with self.assertRaisesRegex(RuntimeError, 'inventory drift'):
            ci.inventory(self.root, data)

    def test_required_unavailable_evidence_cannot_pass_with_rationale(self):
        data = self.data()
        data['ci_obligations'][0]['disposition'] = 'ci-required'
        with self.assertRaisesRegex(RuntimeError, 'evidence is unavailable'):
            ci.inventory(self.root, data)

    def test_local_obligation_needs_a_real_check(self):
        data = self.data()
        data['ci_obligations'][0]['checks'] = ['missing']
        with self.assertRaisesRegex(RuntimeError, 'mapped checks'):
            ci.inventory(self.root, data)

    def test_missing_workflow_obligation_fails_closed(self):
        data = self.data()
        data['ci_obligations'].pop()
        with self.assertRaisesRegex(RuntimeError, 'omits'):
            ci.inventory(self.root, data)


class EnvironmentTest(DeliveryFixture):
    def setUp(self):
        super().setUp()
        self.write('mix.lock', '%{}')
        self.write('tools/openapi/package-lock.json', '{}')
        self.write('.github/workflows/quality-baseline.yml',
                   'image: postgres:17.6-alpine@sha256:abc\nimage: redis:8.2.1-alpine@sha256:def\n')
        self.calls = []

    def runner(self, root, argv):
        self.calls.append(argv)
        if argv == ['node', '--version']:
            return 'v24.1.0'
        if argv[-3:-1] == ['-q', 'postgres'] or argv[-2:] == ['-q', 'postgres']:
            return 'postgres-fixture'
        if argv[-2:] == ['-q', 'redis']:
            return 'redis-fixture'
        if argv[:2] == ['docker', 'inspect']:
            return ('postgres:17.6-alpine@sha256:abc' if argv[-1] == 'postgres-fixture'
                    else 'redis:8.2.1-alpine@sha256:def')
        if argv[-1] == 'SHOW server_version':
            return '17.6 (Alpine)'
        if argv[-2:] == ['INFO', 'server']:
            return 'redis_version:8.2.1\n'
        return 'ready'

    def test_exact_versions_and_services_are_asserted(self):
        values = ci.environment(self.root, self.runner)
        self.assertEqual(values['node'], 'v24.1.0')
        self.assertIn(['sh', 'scripts/local_services.sh', 'ready'], self.calls)
        self.assertTrue(any('SHOW server_version' in args for args in self.calls))
        self.assertTrue(any('redis-cli' in args for args in self.calls))

    def test_wrong_node_cannot_pass(self):
        def runner(root, argv):
            return 'v20.18.1' if argv == ['node', '--version'] else self.runner(root, argv)
        with self.assertRaisesRegex(RuntimeError, 'expected Node 24.x, observed v20'):
            ci.environment(self.root, runner)

    def test_unavailable_service_is_a_failure(self):
        def runner(root, argv):
            if argv == ['sh', 'scripts/local_services.sh', 'ready']:
                raise RuntimeError('service unavailable')
            return self.runner(root, argv)
        with self.assertRaisesRegex(RuntimeError, 'services-ready: service unavailable'):
            ci.environment(self.root, runner)

    def test_beam_failure_cannot_be_masked_by_other_tools(self):
        def runner(root, argv):
            if argv == ['sh', 'scripts/check_toolchain.sh']:
                raise RuntimeError('wrong exact BEAM version')
            return self.runner(root, argv)
        with self.assertRaisesRegex(RuntimeError, 'beam: wrong exact BEAM'):
            ci.environment(self.root, runner)


class CollectionTest(unittest.TestCase):
    def test_empty_or_missing_discovery_fails(self):
        for text in ('', '0 tests, 0 failures', 'FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\n0 tests, 0 failures',
                     'FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL'):
            with self.subTest(text=text), self.assertRaises(RuntimeError):
                ci.assert_collection(text)

    def test_nonzero_sentinel_collection_passes(self):
        self.assertEqual(ci.assert_collection('FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\n123 tests, 0 failures\n'), 123)

    def test_pinned_exunit_result_format_retains_nonzero_collection(self):
        self.assertEqual(ci.assert_collection('FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 527/527 passed, 4 excluded\n'), 527)
        self.assertEqual(ci.assert_collection('FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 527 passed, 4 excluded\n'), 527)
        with self.assertRaises(RuntimeError):
            ci.assert_collection('FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\nResult: 0/0 passed, 4 excluded\n')

    def test_partial_failed_or_unmarked_results_cannot_pass(self):
        marker = 'FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL\n'
        for summary in ('Result: 526/527 passed, 4 excluded',
                        'Result: 0/527 passed, 527 failed',
                        'Result: 527/527 passed, 1 failed',
                        'Result: 0 passed, 4 excluded',
                        'Result: 527 passed, 1 failed',
                        'Result: 528/527 passed',
                        '527 tests, 1 failure',
                        '1 test, 0 failures\nResult: 526/527 passed, 1 failed'):
            with self.subTest(summary=summary), self.assertRaises(RuntimeError):
                ci.assert_collection(marker + summary)
        with self.assertRaisesRegex(RuntimeError, 'sentinel'):
            ci.assert_collection('Result: 527/527 passed, 4 excluded')

    def test_subprocess_failure_and_unavailable_tool_are_bounded(self):
        with self.assertRaisesRegex(RuntimeError, 'unavailable'):
            ci.run(Path.cwd(), ['agentflow-test-no-such-executable'])
        with self.assertRaisesRegex(RuntimeError, 'failed'):
            ci.run(Path.cwd(), ['sh', '-c', 'echo private-string >&2; exit 3'])
