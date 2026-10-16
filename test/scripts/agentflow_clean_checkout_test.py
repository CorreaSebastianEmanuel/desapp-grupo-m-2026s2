"""Actual candidate isolation; fixtures never change the current checkout."""
import json
import os
import subprocess
import tempfile
from pathlib import Path
from unittest.mock import patch

from scripts import agentflow_ci_check as ci
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture
from scripts.workflow_artifact_probe import active_feature


class CandidateTest(DeliveryFixture):
    def test_missing_pointer_resolves_exact_durable_owner(self):
        self.assertEqual(active_feature(self.root), self.feature)
        self.json('.specify/feature.json', {'feature_directory': 'specs/999-wrong'})
        self.assertEqual(active_feature(self.root), self.feature)

    def test_base_branch_has_actionable_ownership_failure(self):
        self.git('symbolic-ref', 'HEAD', 'refs/heads/main')
        with self.assertRaisesRegex(RuntimeError, 'feature branch'):
            active_feature(self.root)

    def test_snapshot_preserves_base_and_candidate_edits_and_omits_pointer(self):
        self.write('tracked.txt', 'before')
        self.write('deleted.txt', 'remove')
        self.baseline()
        self.write('tracked.txt', 'after')
        self.write('test/new_test.exs', 'new test')
        (self.root / 'deleted.txt').unlink()
        self.json('.specify/feature.json', {'feature_directory': 'private'})
        before = self.git('status', '--porcelain', '--untracked-files=all')
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory).resolve() / 'candidate'
            identity = ci.snapshot(self.root, target)
            self.assertEqual(len(identity), 64)
            self.assertEqual((target / 'tracked.txt').read_text(), 'after')
            self.assertFalse((target / 'deleted.txt').exists())
            self.assertTrue((target / 'test/new_test.exs').is_file())
            self.assertFalse((target / '.specify/feature.json').exists())
            self.assertEqual(ci.run(target, ['git', 'rev-parse', 'HEAD']), self.git('rev-parse', 'HEAD'))
            self.assertEqual(active_feature(target), target / 'specs/003-example')
        self.assertEqual(before, self.git('status', '--porcelain', '--untracked-files=all'))

    def setup_suite(self, status=0, count=2):
        self.write('scripts/ci_unit_tests.sh',
                   '#!/bin/sh\nprintf "%s\\n" FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL '
                   f'"{count} tests, 0 failures"\nexit {status}\n')
        (self.root / 'deps').mkdir()
        (self.root / '_build').mkdir()
        self.write('tools/openapi/node_modules/fixture/index.js', 'locked browser dependency')
        with (self.root / '.gitignore').open('a') as ignored:
            ignored.write('tools/openapi/node_modules/\n')
        self.baseline()

    def test_full_collection_runs_once_on_candidate(self):
        self.setup_suite()
        self.assertNotIn('node_modules', self.git('ls-files'))
        actual = subprocess.run
        launches = []
        def invoke(argv, **kwargs):
            if argv == ['sh', 'scripts/ci_unit_tests.sh']:
                launches.append(kwargs['cwd'])
                self.assertNotEqual(kwargs['cwd'], self.root)
                self.assertFalse((kwargs['cwd'] / '.specify/feature.json').exists())
                self.assertEqual((kwargs['cwd'] / 'tools/openapi/node_modules/fixture/index.js').read_text(),
                                 'locked browser dependency')
            return actual(argv, **kwargs)
        with patch.object(ci.subprocess, 'run', side_effect=invoke):
            self.assertEqual(ci.clean_tests(self.root), 2)
        self.assertEqual(len(launches), 1)

    def test_child_failure_propagates(self):
        self.setup_suite(status=7)
        with self.assertRaisesRegex(RuntimeError, 'suite failed \\(7\\)'):
            ci.clean_tests(self.root)

    def test_empty_child_collection_cannot_pass(self):
        self.setup_suite(count=0)
        with self.assertRaisesRegex(RuntimeError, 'empty'):
            ci.clean_tests(self.root)
