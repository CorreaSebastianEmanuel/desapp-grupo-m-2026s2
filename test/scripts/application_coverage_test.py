"""Focused accounting and fail-closed coverage invariants."""
import json
import copy
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'scripts'))
import application_coverage as coverage
import test_profile_runner as profile_runner
from test_profile_components import EventResult


class CoverageAccountingTest(unittest.TestCase):
    def setUp(self):
        self.entries = [
            dict(path='lib/a.ex', role='application', disposition='include', reason='application source'),
            dict(path='test/a_test.exs', role='test', disposition='exclude', reason='test source'),
            dict(path='test/support/helper.ex', role='test-support', disposition='exclude', reason='test helper'),
        ]

    def test_coverage_runs_the_existing_ci_profile_wrapper_once(self):
        environment = {'CI_PROFILE_RECEIPTS': '/tmp/profile-ci',
                       'APPLICATION_COVERAGE_DIR': '/tmp/coverage-run',
                       'APPLICATION_COVERAGE_RUN_ID': 'run-id',
                       'APPLICATION_COVERAGE_SNAPSHOT': 'snapshot'}
        with patch.object(coverage.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0)) as run:
            coverage.run_audited_profiles(environment)
        self.assertEqual(run.call_count, 1)
        args, kwargs = run.call_args
        self.assertEqual(args[0], ['sh', 'scripts/ci_unit_tests.sh'])
        self.assertEqual(kwargs['env'], environment)
        self.assertIs(kwargs['stdin'], subprocess.DEVNULL)

        with patch.object(coverage.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1)):
            with self.assertRaisesRegex(ValueError, 'profile-failure'):
                coverage.run_audited_profiles(environment)

    def test_python_profile_failure_event_contains_only_safe_assertion_location(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {
                'PROFILE_EVENTS': str(Path(directory) / 'events.jsonl'), 'PROFILE_NONCE': 'nonce'}):
            try:
                raise AssertionError('secret assertion detail')
            except AssertionError:
                EventResult().report_failure(self, sys.exc_info(), 'assertion')
            event = json.loads(Path(directory, 'events.jsonl').read_text())
            self.assertEqual(event['state'], 'failed')
            self.assertEqual(event['cause'], 'assertion')
            self.assertIsInstance(event['failure_line'], int)
            self.assertGreater(event['failure_line'], 0)
            self.assertNotIn('secret assertion detail', json.dumps(event))

    def test_union_counts_each_source_line_once_and_or_combines_profile_hits(self):
        first = dict(profile='unit', complete=True, lines=[
            dict(module='A', source_path='lib/a.ex', line=1, calls=1),
            dict(module='A', source_path='lib/a.ex', line=2, calls=0),
        ])
        second = dict(profile='integration', complete=True, lines=[
            dict(module='A', source_path='lib/a.ex', line=1, calls=0),
            dict(module='A', source_path='lib/a.ex', line=2, calls=2),
        ])
        for part in (first, second):
            part['modules'] = [dict(module='A', source_path='lib/a.ex', source_sha256='source', executable_lines=[1, 2])]
        result = coverage.reconcile_records(self.entries, [first, second])
        self.assertEqual(result['totals'], dict(executable=2, covered=2, uncovered=0, percentage=100.0))
        self.assertEqual(result['included'][0]['executable_lines'], [1, 2])
        self.assertEqual({row['path'] for row in result['excluded']}, {'test/a_test.exs', 'test/support/helper.ex'})

    def test_test_or_support_line_is_rejected_even_if_native_export_contains_it(self):
        bad = dict(profile='unit', complete=True, lines=[dict(module='Fixture', source_path='test/a_test.exs', line=1, calls=1)])
        with self.assertRaisesRegex(ValueError, 'native-export'):
            coverage.reconcile_records(self.entries, [bad])

    def test_duplicate_and_malformed_line_identities_fail_closed(self):
        duplicate = dict(profile='unit', complete=True, lines=[
            dict(module='A', source_path='lib/a.ex', line=1, calls=0),
            dict(module='A', source_path='lib/a.ex', line=1, calls=1),
        ])
        with self.assertRaisesRegex(ValueError, 'native-export'):
            coverage.reconcile_records(self.entries, [duplicate])
        bad_bool = dict(profile='unit', complete=True, lines=[dict(module='A', source_path='lib/a.ex', line=True, calls=1)])
        with self.assertRaisesRegex(ValueError, 'native-export'):
            coverage.reconcile_records(self.entries, [bad_bool])

    def test_zero_executable_file_is_retained_but_whole_report_requires_denominator(self):
        entries = self.entries + [dict(path='lib/empty.ex', role='application', disposition='include', reason='module without executable functions')]
        partition = dict(profile='unit', complete=True,
                         modules=[dict(module='A', source_path='lib/a.ex', source_sha256='source', executable_lines=[1]),
                                  dict(module='Empty', source_path='lib/empty.ex', source_sha256='empty', executable_lines=[])],
                         lines=[dict(module='A', source_path='lib/a.ex', line=1, calls=0)])
        result = coverage.reconcile_records(entries, [partition])
        self.assertEqual(result['included'][1]['percentage'], None)
        with self.assertRaisesRegex(ValueError, 'report'):
            coverage.reconcile_records([self.entries[1]], [dict(profile='unit', complete=True, modules=[], lines=[])])

    def test_unsafe_paths_and_incomplete_partitions_are_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            external = root / 'external'
            external.mkdir()
            external_alias = root / 'external-alias'
            external_alias.symlink_to(external, target_is_directory=True)
            aliased_output = external_alias / 'output'
            aliased_output.mkdir()
            self.assertEqual(
                coverage.contained_path(aliased_output, 'new/report.json'),
                aliased_output / 'new/report.json',
            )
            declared = root / 'output'
            declared.mkdir()
            outside = root / 'outside'
            outside.mkdir()
            (declared / 'ancestor').symlink_to(outside, target_is_directory=True)
            for relative in ('ancestor/new.json', 'ancestor/nested/new.json'):
                with self.subTest(write=relative), self.assertRaisesRegex(ValueError, 'publication'):
                    coverage.contained_path(declared, relative)
                with self.assertRaisesRegex(ValueError, 'publication'):
                    coverage.atomic_json(declared / relative, {'schema_version': 1}, root=declared)
            self.assertFalse((outside / 'new.json').exists())
            self.assertEqual(coverage.contained_path(declared, 'new/file.json'), declared / 'new/file.json')
            # The declared output root itself cannot be a symlink.
            root_alias = root / 'output-alias'
            root_alias.symlink_to(declared, target_is_directory=True)
            with self.assertRaisesRegex(ValueError, 'publication'):
                coverage.contained_path(root_alias, 'new.json')
        with self.assertRaisesRegex(ValueError, 'inventory'):
            coverage.safe_path('../lib/a.ex')
        with self.assertRaisesRegex(ValueError, 'partition'):
            coverage.reconcile_records(self.entries, [dict(profile='unit', complete=False, lines=[])])

    def test_snapshot_normalizes_task_checkboxes_tracks_deletions_and_omits_output(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'spec').mkdir()
            (root / 'cover/application').mkdir(parents=True)
            (root / 'spec/tasks.md').write_text('- [ ] T001\n')
            (root / 'lib.ex').write_text('before')
            (root / 'cover/application/report.ex').write_text('generated')
            paths = ['spec/tasks.md', 'lib.ex', 'cover/application/report.ex']
            with patch.object(coverage, 'ROOT', root), patch.object(coverage, 'FEATURE', root / 'spec'), patch.object(coverage, 'git_paths', return_value=paths):
                original = coverage.snapshot(root / 'cover/application')
                self.assertEqual(original, '0855795217e58455056a808431e301e0a94f1dc9b99b8fb3b89e07ebf03b0fd5')
                (root / 'spec/tasks.md').write_text('- [X] T001\n')
                self.assertEqual(original, coverage.snapshot(root / 'cover/application'))
                (root / 'lib.ex').unlink()
                self.assertNotEqual(original, coverage.snapshot(root / 'cover/application'))

    def test_failed_current_attempt_does_not_rewrite_historical_success(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / 'cover/application'
            historical = output / 'runs/old/report.json'
            historical.parent.mkdir(parents=True)
            historical.write_text('{"status":"complete"}\n')
            with patch.object(coverage, 'OUTPUT', output), patch.object(coverage, 'STATUS', output / 'status.json'):
                coverage.current_status('complete', 'old', 'snapshot', report='runs/old/report.json')
                before = historical.read_bytes()
                coverage.current_status('running', 'new', 'snapshot')
                coverage.current_status('failed', 'new', 'snapshot', category='profile-failure')
                self.assertEqual(before, historical.read_bytes())
                self.assertEqual(json.loads((output / 'status.json').read_text())['state'], 'failed')

    def test_profile_runner_predeclares_and_executes_exact_normal_partitions(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict('os.environ', {
            'APPLICATION_COVERAGE_DIR': directory, 'APPLICATION_COVERAGE_RUN_ID': 'run-123',
        }, clear=False):
            def execute(argv, extra=None):
                if argv[:3] == ['mix', 'run', '--no-start']:
                    Path(extra['PROFILE_COMMITTED_FILES']).write_text('["test/b.exs"]')
                if '--export-coverage' in argv:
                    name = argv[argv.index('--export-coverage') + 1]
                    Path(directory, name + '.coverdata').write_bytes(b'native')

            profile_runner.execute_exunit(execute, 'unit', ['test/a.exs'], directory, 'nonce')
            unit_expected = json.loads(Path(directory, 'unit-expected.json').read_text())
            self.assertEqual(unit_expected, [dict(id='main', selected_files=['test/a.exs'])])
            profile_runner.execute_exunit(execute, 'integration', ['test/a.exs', 'test/b.exs'], directory, 'nonce')
            integration_expected = json.loads(Path(directory, 'integration-expected.json').read_text())
            integration_observed = json.loads(Path(directory, 'integration-observed.json').read_text())
            self.assertEqual([(x['id'], x['selected_files']) for x in integration_expected],
                             [(x['id'], x['selected_files']) for x in integration_observed])
            self.assertEqual([x['id'] for x in integration_expected], ['regular', 'committed_0'])
            profile_runner.execute_exunit(execute, 'integration', ['test/b.exs'], directory, 'nonce')
            self.assertEqual(json.loads(Path(directory, 'integration-expected.json').read_text()),
                             [dict(id='committed_0', selected_files=['test/b.exs'])])

    def test_snapshot_detects_configuration_scripts_and_untracked_inputs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'settings.json').write_text('before')
            with patch.object(coverage, 'ROOT', root), patch.object(coverage, 'FEATURE', root / 'spec'), patch.object(
                    coverage, 'git_paths', return_value=['settings.json']) as paths:
                before = coverage.snapshot(root / 'cover/application')
                paths.assert_called_with(elixir_only=False)
                (root / 'settings.json').write_text('after')
                self.assertNotEqual(before, coverage.snapshot(root / 'cover/application'))

    def test_native_missing_or_conflicting_populations_fail(self):
        binding = dict(module='A', source_path='lib/a.ex', source_sha256='source', executable_lines=[1, 2])
        with self.assertRaisesRegex(ValueError, 'native-export'):
            coverage.reconcile_records(self.entries, [dict(profile='unit', complete=True, modules=[binding],
                lines=[dict(module='A', source_path='lib/a.ex', line=1, calls=1)])])

    def test_same_source_line_in_multiple_modules_counts_once_and_zero_is_valid(self):
        modules = [dict(module=n, source_path='lib/a.ex', source_sha256='source', executable_lines=[2]) for n in ('A', 'B')]
        lines = [dict(module=n, source_path='lib/a.ex', line=2, calls=0) for n in ('A', 'B')]
        report = coverage.reconcile_records(self.entries, [dict(profile='unit', complete=True, modules=modules, lines=lines)])
        self.assertEqual(report['totals'], dict(executable=1, covered=0, uncovered=1, percentage=0.0))

    def test_report_count_validation_rejects_boolean_and_non_integer_counts(self):
        module = dict(module='A', source_path='lib/a.ex', source_sha256='source', executable_lines=[1])
        line = dict(module='A', source_path='lib/a.ex', line=1, calls=0)
        report = dict(included=[dict(path='lib/a.ex', executable=1, covered=0, uncovered=1,
                                     executable_lines=[1], covered_lines=[], uncovered_lines=[1], percentage=0.0)],
                      totals=dict(executable=1, covered=0, uncovered=1, percentage=0.0),
                      partitions=[dict(modules=[module], lines=[line])])
        coverage.validate_report_counts(report)

        mutations = [
            ('totals.uncovered=false', lambda value: value['totals'].__setitem__('uncovered', False)),
            ('totals.executable=float', lambda value: value['totals'].__setitem__('executable', 1.0)),
            ('totals.covered=boolean', lambda value: value['totals'].__setitem__('covered', True)),
            ('file.uncovered=boolean', lambda value: value['included'][0].__setitem__('uncovered', False)),
            ('file.line=boolean', lambda value: value['included'][0].__setitem__('uncovered_lines', [True])),
            ('partition.calls=boolean', lambda value: value['partitions'][0]['lines'][0].__setitem__('calls', False)),
            ('module.line=float', lambda value: value['partitions'][0]['modules'][0].__setitem__('executable_lines', [1.0])),
        ]
        for name, mutate in mutations:
            with self.subTest(name=name):
                invalid = json.loads(json.dumps(report))
                mutate(invalid)
                with self.assertRaisesRegex(ValueError, 'report'):
                    coverage.validate_report_counts(invalid)

    def test_hash_coherent_report_rejects_uncovered_false_before_comparison_or_tooling(self):
        report = dict(schema_version=1, included=[dict(path='lib/a.ex', executable=1, covered=1, uncovered=0,
                                                       executable_lines=[1], covered_lines=[1],
                                                       uncovered_lines=[], percentage=100.0)],
                      totals=dict(executable=1, covered=1, uncovered=0, percentage=100.0), partitions=[])
        coverage.validate_report_counts(report)
        report['totals']['uncovered'] = False
        encoded_report = coverage.canonical_json(report)
        status = dict(schema_version=1, state='complete', report_path='runs/current/report.json',
                      report_sha256=coverage.digest(encoded_report))
        self.assertEqual(status['report_sha256'], coverage.digest(encoded_report))
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'cover/application'
            report_path = output / status['report_path']
            report_path.parent.mkdir(parents=True)
            report_path.write_bytes(encoded_report)
            status_path = output / 'status.json'
            status_path.write_text(json.dumps(status))
            with patch.multiple(coverage, OUTPUT=output, STATUS=status_path), self.assertRaisesRegex(ValueError, 'report'):
                coverage.validate()

    def test_hash_coherent_report_rejects_coercible_receipt_component_counts(self):
        inventory_path = Path('config/test_profiles.json')
        inventory_bytes = inventory_path.read_bytes()
        inventory = json.loads(inventory_bytes)
        profiles = ('unit', 'integration')
        invalid_values = (False, 0.0)
        for invalid_value in invalid_values:
            with self.subTest(value=invalid_value), tempfile.TemporaryDirectory() as directory:
                output = Path(directory) / 'cover/application'
                run_id = '37dd55c2-f858-447e-a824-b909e74d626c'
                run_dir = output / 'runs' / run_id
                run_dir.mkdir(parents=True)
                receipts = {}
                for profile in profiles:
                    expected = sum(row['profile'] == profile for row in inventory['entries'])
                    components = {
                        runner: sum(row['profile'] == profile and row['runner'] == runner
                                    for row in inventory['entries'])
                        for runner in ('exunit', 'python', 'node', 'shell')
                    }
                    receipt = dict(schema_version=1, nonce=(profile + '0' * 32)[:32],
                                   inventory_digest=coverage.digest(inventory_bytes), profile=profile,
                                   audit_count=len({row['file'] for row in inventory['entries']
                                                    if row['profile'] == profile and row['runner'] == 'exunit'}),
                                   expected=expected, discovered=expected,
                                   executed=expected, passed=expected, status='complete', components=components)
                    if profile == 'unit':
                        receipt['components']['python'] = invalid_value
                    receipt_path = run_dir / (profile + '-receipt.json')
                    receipt_bytes = coverage.canonical_json(receipt)
                    receipt_path.write_bytes(receipt_bytes)
                    sidecar = dict(schema_version=1, profile=profile, receipt_nonce=receipt['nonce'],
                                   receipt_sha256=coverage.digest(receipt_bytes), run_id=run_id,
                                   snapshot_digest='snapshot', expected=[], partitions=[])
                    sidecar_path = run_dir / (profile + '-sidecar.json')
                    sidecar_bytes = coverage.canonical_json(sidecar)
                    sidecar_path.write_bytes(sidecar_bytes)
                    receipts[profile] = dict(receipt_path=receipt_path.name,
                                             receipt_sha256=coverage.digest(receipt_bytes),
                                             sidecar_path=sidecar_path.name,
                                             sidecar_sha256=coverage.digest(sidecar_bytes),
                                             nonce=receipt['nonce'])
                report = dict(schema_version=1, status='complete', run_id=run_id,
                              snapshot_digest='snapshot', snapshot_algorithm='sha256-all-inputs-v2',
                              source_inventory_sha256=coverage.digest(coverage.SCOPE.read_bytes()),
                              canonical_inventory_sha256=coverage.digest(coverage.CANONICAL.read_bytes()),
                              test_inventory_sha256=coverage.digest(inventory_bytes),
                              toolchain=dict(elixir='elixir', node='node'), started_at='2026-10-21T00:00:00+00:00', head='a' * 40,
                              included=[], partitions=[], receipts=receipts,
                              totals=dict(executable=1, covered=0, uncovered=1, percentage=0.0))
                report_path = run_dir / 'report.json'
                report_bytes = coverage.canonical_json(report)
                report_path.write_bytes(report_bytes)
                status_path = output / 'status.json'
                status_path.write_bytes(coverage.canonical_json(dict(
                    schema_version=1, state='complete', run_id=run_id, snapshot_digest='snapshot',
                    report_path='runs/' + run_id + '/report.json', report_sha256=coverage.digest(report_bytes))))
                with patch.multiple(coverage, OUTPUT=output, STATUS=status_path), patch.object(
                        coverage.subprocess, 'check_output', side_effect=['elixir', 'node']), patch.object(
                        coverage, 'snapshot', return_value='snapshot'), patch.object(
                        coverage, 'source_inventory', return_value=[]), patch.object(
                        coverage, 'validate_partition_set'), self.assertRaisesRegex(ValueError, 'profile-failure'):
                    coverage.validate()

    def test_receipt_component_counts_accept_exact_nonnegative_integers(self):
        inventory = dict(entries=[dict(profile='unit', runner='python'), dict(profile='unit', runner='shell')])
        receipt = dict(components=dict(exunit=0, python=1, node=0, shell=1))
        coverage.validate_receipt_components(receipt, 'unit', inventory)
        for value in (False, 0.0, -1):
            receipt['components']['python'] = value
            with self.subTest(value=value), self.assertRaisesRegex(ValueError, 'profile-failure'):
                coverage.validate_receipt_components(receipt, 'unit', inventory)

    def test_complete_validator_rejects_coercible_receipt_and_linked_numeric_fields(self):
        # A small real native export keeps this fixture independent of previous
        # official measurements. No profile, receipt verifier or native reader is mocked.
        Path('tmp').mkdir(exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='receipt-contract-', dir='tmp') as directory:
            output = Path(directory).resolve() / 'output'
            run_id = '37dd55c2-f858-447e-a824-b909e74d626c'
            directory = output / 'runs' / run_id
            directory.mkdir(parents=True)
            beams = directory / 'beams'
            beams.mkdir()
            beam = beams / 'Elixir.FootballMarket.Providers.beam'
            shutil.copy2(coverage.ROOT / '_build/test/lib/football_market/ebin' / beam.name, beam)
            export = directory / 'fixture.coverdata'
            manifest = directory / 'modules.json'
            normalized = directory / 'normalized.json'
            fixture_inventory = directory / 'inventory.json'
            fixture_inventory.write_text(json.dumps(dict(entries=[dict(
                path='lib/football_market/providers.ex', disposition='include')])))
            env = {key: value for key, value in os.environ.items()
                   if not key.startswith(('APPLICATION_COVERAGE_', 'CP1_COVERAGE_'))
                   and key != 'CP1_PROFILE_COVERAGE'}
            env.update(MIX_ENV='test', FIXTURE_BEAM=str(beam), FIXTURE_EXPORT=str(export))
            real_run = subprocess.run

            def native(argv, **kwargs):
                if 'scripts/application_coverage_native.exs' in argv:
                    if '--manifest' in argv:
                        argv = [*argv, '--beam-dir', str(beams), '--inventory', str(fixture_inventory)]
                    kwargs = {**kwargs, 'env': env}
                return real_run(argv, **kwargs)

            setup = ('Mix.ensure_application!(:tools); {:ok, _} = :cover.start(); '
                     '{:ok, _} = :cover.compile_beam(String.to_charlist(System.fetch_env!("FIXTURE_BEAM"))); '
                     ':ok = :cover.export(String.to_charlist(System.fetch_env!("FIXTURE_EXPORT")))')
            real_run(['mix', 'run', '--no-start', '-e', setup], env=env, check=True,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            reader = ['mix', 'run', '--no-start', 'scripts/application_coverage_native.exs']
            self.assertEqual(native(reader + ['--manifest', '--output', str(manifest)]).returncode, 0)
            self.assertEqual(native(reader + ['--export', str(export), '--modules', str(manifest),
                                             '--output', str(normalized)]).returncode, 0)
            bindings = json.loads(manifest.read_text())
            data = json.loads(normalized.read_text())
            self.assertTrue(bindings)
            self.assertTrue(data['lines'])
            entries = [dict(path=bindings[0]['source_path'], role='application', disposition='include',
                            reason='real native coverage fixture')]
            inventory_bytes = Path('config/test_profiles.json').read_bytes()
            inventory = json.loads(inventory_bytes)
            # Use the runner's actual committed-file oracle, independently of
            # coverage's schedule validator. This parses test metadata, no tests/services.
            committed_path = directory / 'committed.json'
            oracle_env = {**env, 'PROFILE_COMMITTED_FILES': str(committed_path)}
            real_run(['mix', 'run', '--no-start', '-e',
                      'File.write!(System.fetch_env!("PROFILE_COMMITTED_FILES"), '
                      'Jason.encode!(FootballMarket.TestProfileAudit.audit!("integration").committed_files))'],
                     env=oracle_env, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            committed = json.loads(committed_path.read_text())
            parts, receipts, sidecars, evidence = [], {}, {}, {}
            for profile in ('unit', 'integration'):
                cases = [case for case in inventory['entries'] if case['profile'] == profile]
                files = sorted({case['file'] for case in cases if case['runner'] == 'exunit'})
                receipts[profile] = dict(schema_version=1, profile=profile, status='complete',
                                         nonce=('a' if profile == 'unit' else 'b') * 32,
                                         inventory_digest=coverage.digest(inventory_bytes), audit_count=len(files),
                                         **{key: len(cases) for key in ('expected', 'discovered', 'executed', 'passed')},
                                         components={runner: sum(c['runner'] == runner for c in cases)
                                                     for runner in ('exunit', 'python', 'node', 'shell')})
                regular = [file for file in files if file not in committed]
                schedule = ([dict(id='main', selected_files=files)] if profile == 'unit' else
                            ([dict(id='regular', selected_files=regular)] if regular else []) +
                            [dict(id='committed_' + str(i), selected_files=[file])
                             for i, file in enumerate(committed)])
                observed = []
                for expected in schedule:
                    name = 'app_' + profile + '_' + run_id.replace('-', '') + '_' + expected['id'] + '.coverdata'
                    shutil.copyfile(export, directory / name)
                    normalized_name = profile + '_' + expected['id'] + '.normalized.json'
                    shutil.copyfile(normalized, directory / normalized_name)
                    part = dict(profile=profile, **expected, complete=True,
                                selected_sha256=coverage.digest(json.dumps(expected['selected_files'], separators=(',', ':')).encode()),
                                export=name, export_sha256=coverage.digest(export.read_bytes()),
                                normalized_file=normalized_name, normalized_sha256=coverage.digest(normalized.read_bytes()),
                                module_manifest_sha256=coverage.digest(manifest.read_bytes()),
                                modules=bindings, lines=data['lines'])
                    parts.append(part)
                    observed.append(copy.deepcopy(part))
                sidecars[profile] = dict(schema_version=1, profile=profile, run_id=run_id,
                                         snapshot_digest='fixture-snapshot', receipt_nonce=receipts[profile]['nonce'],
                                         expected=schedule, partitions=observed)
                evidence[profile] = dict(receipt_path=profile + '-receipt.json',
                                         sidecar_path=profile + '-sidecar.json', nonce=receipts[profile]['nonce'])
            report = dict(schema_version=1, status='complete', run_id=run_id, head='a' * 40, started_at='2026-10-21T01:10:00+00:00',
                          snapshot_algorithm='sha256-all-inputs-v2', snapshot_digest='fixture-snapshot',
                          source_inventory_sha256=coverage.digest(coverage.SCOPE.read_bytes()),
                          canonical_inventory_sha256=coverage.digest(coverage.CANONICAL.read_bytes()),
                          test_inventory_sha256=coverage.digest(inventory_bytes),
                          module_manifest_sha256=coverage.digest(manifest.read_bytes()),
                          toolchain=dict(elixir=subprocess.check_output(['elixir', '--version'], env=env, text=True).strip(),
                                         node=subprocess.check_output(['node', '--version'], text=True).strip()),
                          partitions=parts, receipts=evidence, **coverage.reconcile_records(entries, parts))

            def publish(receipt_values, sidecar_values, report_value, native_value, module_values, status_version=1):
                # Rebind every modified byte through sidecars, report and status.
                manifest.write_bytes(coverage.canonical_json(module_values))
                normalized.write_bytes(coverage.canonical_json(native_value))
                report_value['module_manifest_sha256'] = coverage.digest(manifest.read_bytes())
                for profile in ('unit', 'integration'):
                    rec = directory / evidence[profile]['receipt_path']
                    rec.write_bytes(coverage.canonical_json(receipt_values[profile]))
                    side = sidecar_values[profile]
                    side['receipt_sha256'] = coverage.digest(rec.read_bytes())
                    side_path = directory / evidence[profile]['sidecar_path']
                    side_path.write_bytes(coverage.canonical_json(side))
                    report_value['receipts'][profile].update(receipt_sha256=side['receipt_sha256'],
                                                            sidecar_sha256=coverage.digest(side_path.read_bytes()))
                for part in report_value['partitions']:
                    (directory / part['normalized_file']).write_bytes(coverage.canonical_json(native_value))
                    part.update(normalized_sha256=coverage.digest(normalized.read_bytes()),
                                module_manifest_sha256=coverage.digest(manifest.read_bytes()))
                report_path = directory / 'report.json'
                report_path.write_bytes(coverage.canonical_json(report_value))
                (directory / 'report.html').write_text(coverage.report_html(report_value))
                (directory / 'measurements.md').write_text(coverage.measurements(report_value))
                (output / 'status.json').write_bytes(coverage.canonical_json(dict(
                    schema_version=status_version, state='complete', run_id=report_value['run_id'],
                    snapshot_digest='fixture-snapshot', report_path='runs/' + run_id + '/report.json',
                    report_sha256=coverage.digest(report_path.read_bytes()))))

            mutations = []
            for key in ('audit_count', 'expected', 'discovered', 'executed', 'passed', 'schema_version'):
                original = receipts['unit'][key]
                for value in (False, True, float(original), None, -1, original + 1):
                    mutations.append(('receipt', key, value, 'profile-failure'))
            for runner, original in receipts['unit']['components'].items():
                for value in (False, float(original), None, -1, original + 1):
                    mutations.append(('component', runner, value, 'profile-failure'))
            for runner, original in receipts['integration']['components'].items():
                for value in (False, float(original), None, -1, original + 1):
                    mutations.append(('integration-component', runner, value, 'profile-failure'))
            for location, category in (('sidecar', 'partition'), ('normalized', 'native-export'),
                                       ('report', 'report'), ('status', 'report')):
                for value in (True, 1.0, None, -1, 2):
                    mutations.append((location, 'schema_version', value, category))
            for location in ('normalized', 'manifest', 'partition-module'):
                for value in (False, 0.0):
                    mutations.append((location, 'compiler_markers', [value], 'native-export'))
                    mutations.append((location, 'executable_lines', [value],
                                      'report' if location == 'partition-module' else 'native-export'))
            for key in ('line', 'calls'):
                for value in (False, 0.0, None, -1):
                    mutations.append(('native-line', key, value, 'native-export'))
            with patch.multiple(coverage, OUTPUT=output, STATUS=output / 'status.json'), patch.object(
                    coverage, 'snapshot', return_value='fixture-snapshot'), patch.object(
                    coverage, 'source_inventory', return_value=entries), patch.object(
                    coverage.subprocess, 'run', side_effect=native):
                publish(copy.deepcopy(receipts), copy.deepcopy(sidecars), copy.deepcopy(report),
                        copy.deepcopy(data), copy.deepcopy(bindings))
                self.assertEqual(coverage.validate()['totals'], report['totals'])
                fixture_schedule = {profile: copy.deepcopy(sidecars[profile]['expected'])
                                    for profile in ('unit', 'integration')}
                structural = [
                    'report-selection', 'side-selection', 'side-profile', 'side-export',
                    'expected-profile', 'expected-selection', 'expected-export', 'expected-export-digest',
                    'coherent-id', 'coherent-membership', 'empty-extra', 'reused-export', 'reused-normalized',
                    'foreign-export-run', 'foreign-export-profile', 'foreign-export-id',
                    'invalid-uuid', 'invalid-date', 'naive-date', 'wrong-run-directory',
                ]
                for case in structural:
                    with self.subTest(integrity=case):
                        rs, ss, rp = [copy.deepcopy(item) for item in (receipts, sidecars, report)]
                        first, side = rp['partitions'][0], ss['unit']['partitions'][0]
                        if case == 'report-selection':
                            first['selected_sha256'] = '0' * 64
                        elif case == 'side-selection':
                            side['selected_sha256'] = '0' * 64
                        elif case == 'side-profile':
                            side['profile'] = 'integration'
                        elif case == 'side-export':
                            side['export'] = 'wrong.coverdata'
                        elif case.startswith('expected-'):
                            field, value = {'expected-profile': ('profile', 'integration'),
                                            'expected-selection': ('selected_sha256', '0' * 64),
                                            'expected-export': ('export', 'wrong.coverdata'),
                                            'expected-export-digest': ('export_sha256', '0' * 64)}[case]
                            ss['unit']['expected'][0][field] = value
                        elif case == 'coherent-id':
                            first['id'] = side['id'] = ss['unit']['expected'][0]['id'] = 'unexpected'
                        elif case == 'coherent-membership':
                            group = [p for p in rp['partitions'] if p['profile'] == 'integration']
                            a, b = group[:2]
                            a['selected_files'][0], b['selected_files'][0] = b['selected_files'][0], a['selected_files'][0]
                            for part in (a, b):
                                part['selected_files'].sort()
                                part['selected_sha256'] = coverage.digest(json.dumps(part['selected_files'], separators=(',', ':')).encode())
                                for key in ('expected', 'partitions'):
                                    value = next(p for p in ss['integration'][key] if p['id'] == part['id'])
                                    value.update(selected_files=part['selected_files'], selected_sha256=part['selected_sha256'])
                        elif case == 'empty-extra':
                            extra = copy.deepcopy(first)
                            extra.update(id='extra', selected_files=[], selected_sha256=coverage.digest(b'[]'))
                            rp['partitions'].append(extra)
                            ss['unit']['expected'].append(dict(id='extra', selected_files=[]))
                            ss['unit']['partitions'].append(copy.deepcopy(extra))
                        elif case == 'reused-export':
                            a, b = [p for p in rp['partitions'] if p['profile'] == 'integration'][:2]
                            a['export'] = b['export']
                            ss['integration']['partitions'][0]['export'] = b['export']
                        elif case == 'reused-normalized':
                            rp['partitions'][1]['normalized_file'] = first['normalized_file']
                        elif case.startswith('foreign-export-'):
                            replacement = {'foreign-export-run': run_id.replace('-', '').replace('3', '4'),
                                           'foreign-export-profile': 'integration',
                                           'foreign-export-id': 'regular'}[case]
                            token = {'foreign-export-run': run_id.replace('-', ''),
                                     'foreign-export-profile': 'unit', 'foreign-export-id': 'main'}[case]
                            name = first['export'].replace(token, replacement)
                            shutil.copyfile(export, directory / name)
                            first['export'] = side['export'] = name
                        elif case == 'invalid-uuid':
                            rp['run_id'] = 'not-a-uuid'
                            for value in ss.values():
                                value['run_id'] = rp['run_id']
                        elif case in ('invalid-date', 'naive-date'):
                            rp['started_at'] = 'not-a-date' if case == 'invalid-date' else '2026-10-21T01:10:00'
                        elif case == 'wrong-run-directory':
                            rp['run_id'] = '47dd55c2-f858-447e-a824-b909e74d626c'
                            for value in ss.values():
                                value['run_id'] = rp['run_id']
                        publish(rs, ss, rp, copy.deepcopy(data), copy.deepcopy(bindings))
                        # Structural rejection must happen before native import/instrumentation.
                        def structural_only(argv, **kwargs):
                            if 'scripts/application_coverage_native.exs' in argv:
                                raise AssertionError('native ran before structural rejection')
                            return native(argv, **kwargs)
                        with patch.object(coverage, 'partition_schedule', return_value=fixture_schedule), patch.object(
                                coverage.subprocess, 'run', side_effect=structural_only):
                            with self.assertRaises(ValueError):
                                coverage.validate()
                # Every artifact read boundary, including intermediate directories,
                # must reject same-byte targets outside the declared output root.
                for relative in ('unit-receipt.json', 'unit-sidecar.json', 'modules.json',
                                 parts[0]['export'], parts[0]['normalized_file'], 'report.json', 'report.html', 'measurements.md'):
                    with self.subTest(symlink=relative):
                        publish(copy.deepcopy(receipts), copy.deepcopy(sidecars), copy.deepcopy(report),
                                copy.deepcopy(data), copy.deepcopy(bindings))
                        target = directory / relative
                        outside = output.parent / ('outside-' + target.name)
                        shutil.copyfile(target, outside)
                        target.unlink()
                        target.symlink_to(outside)
                        with patch.object(coverage, 'partition_schedule', return_value=fixture_schedule), self.assertRaises(ValueError):
                            coverage.validate()
                        target.unlink()
                        shutil.copyfile(outside, target)

                for location, key, value, category in mutations:
                    with self.subTest(location=location, key=key, value=value):
                        rs, ss, rp, nd, md = [copy.deepcopy(item) for item in
                                             (receipts, sidecars, report, data, bindings)]
                        target = {'receipt': rs['unit'], 'component': rs['unit']['components'],
                                  'integration-component': rs['integration']['components'],
                                  'sidecar': ss['unit'], 'report': rp, 'status': {},
                                  'normalized': nd if key == 'schema_version' else nd['modules'][0],
                                  'manifest': md[0], 'partition-module': rp['partitions'][0]['modules'][0],
                                  'native-line': nd['lines'][0]}[location]
                        if value is None:
                            target.pop(key, None)
                        else:
                            target[key] = value
                        publish(rs, ss, rp, nd, md, value if location == 'status' else 1)
                        with patch.object(coverage, 'partition_schedule', return_value=fixture_schedule), self.assertRaisesRegex(ValueError, category):
                            coverage.validate()
                publish(copy.deepcopy(receipts), copy.deepcopy(sidecars), copy.deepcopy(report),
                        copy.deepcopy(data), copy.deepcopy(bindings))
                self.assertEqual(coverage.validate()['totals'], report['totals'])

    def test_duplicate_json_keys_and_unsafe_report_paths_are_rejected(self):
        with self.assertRaises(ValueError):
            coverage.strict_json('{"state":"complete","state":"failed"}')
        for path in ('../old/report.json', '/etc/passwd', 'runs/../old', 'runs//old'):
            with self.assertRaises(ValueError):
                coverage.safe_path(path)

    def test_real_profile_failure_preserves_nonzero_and_failed_status(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / 'cover/application'
            def child(argv, **kwargs):
                from types import SimpleNamespace
                if '--manifest' in argv:
                    Path(argv[-1]).write_text('[]')
                    return SimpleNamespace(returncode=0)
                return SimpleNamespace(returncode=1)
            with patch.multiple(coverage, ROOT=root, FEATURE=root / 'spec', OUTPUT=output, STATUS=output / 'status.json'), patch.object(
                    coverage, 'preflight'), patch.object(coverage, 'partition_schedule', return_value={}), patch.object(coverage, 'source_inventory', return_value=self.entries), patch.object(
                    coverage, 'snapshot', return_value='snapshot'), patch.object(coverage.subprocess, 'check_output', return_value='head'), patch.object(
                    coverage.subprocess, 'run', side_effect=child):
                with self.assertRaisesRegex(ValueError, 'profile-failure'):
                    coverage.run()
                status = json.loads((output / 'status.json').read_text())
                self.assertEqual(status['state'], 'failed')
                self.assertEqual(status['error_category'], 'profile-failure')
                self.assertNotIn('report_path', status)

    def test_exact_inventory_rejects_missing_files_wrong_roles_and_duplicate_paths(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'lib').mkdir()
            (root / 'lib/a.ex').write_text('defmodule A do end')
            oracle = root / 'oracle.json'
            oracle.write_text(json.dumps(dict(schema_version=1, maintained=['lib/a.ex'], excluded=[])))
            scope = root / 'scope.json'
            rows = [self.entries[0].copy()]
            with patch.multiple(coverage, ROOT=root, CANONICAL=oracle, SCOPE=scope), patch.object(
                    coverage, 'git_paths', return_value=['lib/a.ex']):
                scope.write_text(json.dumps(dict(schema_version=1, entries=rows)))
                self.assertEqual(coverage.source_inventory(), rows)
                scope.write_text(json.dumps(dict(schema_version=1, entries=rows + rows)))
                with self.assertRaises(ValueError):
                    coverage.source_inventory()
                rows[0].update(role='script', disposition='exclude')
                scope.write_text(json.dumps(dict(schema_version=1, entries=rows)))
                with self.assertRaises(ValueError):
                    coverage.source_inventory()

    def test_missing_and_duplicate_partitions_are_rejected(self):
        with self.assertRaisesRegex(ValueError, 'partition'):
            coverage.validate_partition_set([dict(profile='unit', id='main')])
        with self.assertRaisesRegex(ValueError, 'partition'):
            coverage.validate_partition_set([dict(profile='unit', id='main'), dict(profile='unit', id='main')])

    def test_validate_refuses_missing_running_failed_and_malformed_current_report(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'cover/application'
            output.mkdir(parents=True)
            status = output / 'status.json'
            with patch.multiple(coverage, OUTPUT=output, STATUS=status):
                with self.assertRaises(ValueError):
                    coverage.validate()
                for value in ('[]', '{', '{"schema_version":1,"state":"running"}',
                              '{"schema_version":1,"state":"failed"}'):
                    status.write_text(value)
                    with self.subTest(value=value), self.assertRaises(ValueError):
                        coverage.validate()

    def test_cli_selects_test_environment_before_service_preflight(self):
        import os
        observed = []
        with patch.dict(os.environ, {'MIX_ENV': 'dev'}), patch.object(coverage.sys, 'argv', ['coverage', 'preflight']), patch.object(
                coverage, 'preflight', side_effect=lambda: observed.append(os.environ.get('MIX_ENV'))):
            self.assertEqual(coverage.main(), 0)
        self.assertEqual(observed, ['test'])

    def test_preflight_refuses_a_node_major_outside_the_existing_ci_toolchain(self):
        from types import SimpleNamespace
        with patch.object(coverage.subprocess, 'run', return_value=SimpleNamespace(returncode=0)), patch.object(
                coverage.subprocess, 'check_output', return_value='v23.0.0\n'):
            with self.assertRaisesRegex(ValueError, 'prerequisite'):
                coverage.preflight()

    def test_source_mutation_during_a_profile_never_publishes_complete_coverage(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            output = root / 'cover/application'
            def child(argv, **kwargs):
                from types import SimpleNamespace
                if '--manifest' in argv:
                    Path(argv[-1]).write_text('[]')
                return SimpleNamespace(returncode=0)
            with patch.multiple(coverage, ROOT=root, FEATURE=root / 'spec', OUTPUT=output, STATUS=output / 'status.json'), patch.object(
                    coverage, 'preflight'), patch.object(coverage, 'partition_schedule', return_value={}), patch.object(coverage, 'source_inventory', return_value=self.entries), patch.object(
                    coverage, 'snapshot', side_effect=['stable', 'stable', 'changed']), patch.object(
                    coverage.subprocess, 'check_output', return_value='head'), patch.object(coverage.subprocess, 'run', side_effect=child):
                with self.assertRaisesRegex(ValueError, 'snapshot'):
                    coverage.run()
                status = json.loads((output / 'status.json').read_text())
                self.assertEqual(status['state'], 'failed')
                self.assertEqual(status['error_category'], 'snapshot')
                self.assertNotIn('report_path', status)

    def test_malformed_control_versions_are_rejected_before_any_native_execution(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'cover/application'
            report_file = output / 'runs/new/report.json'
            report_file.parent.mkdir(parents=True)
            status_file = output / 'status.json'
            for status_version, report_version in ((True, 1), (1, 2), (1, True), (1, None)):
                report_file.write_text(json.dumps(dict(schema_version=report_version, status='complete')))
                status_file.write_text(json.dumps(dict(schema_version=status_version, state='complete',
                    report_path='runs/new/report.json', report_sha256=coverage.digest(report_file.read_bytes()))))
                with self.subTest(status=status_version, report=report_version), patch.multiple(
                        coverage, OUTPUT=output, STATUS=status_file), patch.object(
                        coverage.subprocess, 'check_output', side_effect=AssertionError('invalid control must not execute tools')):
                    with self.assertRaisesRegex(ValueError, 'report'):
                        coverage.validate()


if __name__ == '__main__':
    unittest.main()
