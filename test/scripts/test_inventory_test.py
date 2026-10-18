import copy
import importlib.util
from pathlib import Path
import unittest


def load(name):
    spec = importlib.util.spec_from_file_location(name, Path('scripts') / (name + '.py'))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class InventoryTest(unittest.TestCase):
    def setUp(self):
        self.audit = load('test_inventory')
        self.case = self.audit.entry('python', 'test/scripts/example_test.py', 'Example.test_a', 'unit')

    def test_exact_independent_population(self):
        self.audit.validate([self.case], [self.case])
        for expected, discovered in [([], [self.case]), ([self.case], []),
                                      ([self.case, self.case], [self.case])]:
            with self.assertRaises(ValueError):
                self.audit.validate(expected, discovered)

    def test_substituted_identity_does_not_pass_equal_count(self):
        other = self.audit.entry('python', 'test/scripts/example_test.py', 'Example.test_b', 'unit')
        with self.assertRaises(ValueError):
            self.audit.validate([self.case], [other])

    def test_duplicate_unknown_and_wrong_assignment(self):
        for field, value in [('profile', 'smoke'), ('profile', 'integration'), ('id', 'forged')]:
            other = {**self.case, field: value}
            with self.assertRaises(ValueError):
                self.audit.validate([other], [self.case])

    def test_reconciliation_requires_exact_start_and_terminal_sets(self):
        events = [{'id': self.case['id'], 'state': state} for state in ('started', 'passed')]
        self.audit.reconcile([self.case], events)
        for broken in [[], events[:1], events + events, [events[0], {**events[1], 'state': 'skipped'}],
                       [{**event, 'id': 'substitution'} for event in events]]:
            with self.assertRaises(ValueError):
                self.audit.reconcile([self.case], broken)

    def test_updates_add_only_explicitly_selected_new_profile_cases(self):
        import contextlib
        import io
        import json
        import tempfile
        from unittest.mock import patch

        integration = self.audit.entry('shell', 'test/scripts/new_test.sh', 'new', 'integration')
        with tempfile.TemporaryDirectory() as directory:
            inventory = Path(directory) / 'inventory.json'
            inventory.write_text(json.dumps({'schema_version': 1, 'entries': [], 'helpers': {}}))
            with patch.object(self.audit, 'INVENTORY', inventory), \
                    patch.object(self.audit, 'discover', return_value=[self.case, integration]), \
                    contextlib.redirect_stdout(io.StringIO()):
                with patch('sys.argv', ['inventory', 'update', '--profile', 'unit']):
                    self.assertEqual(self.audit.main(), 0)
                self.assertEqual(json.loads(inventory.read_text())['entries'], [self.case])
                with patch('sys.argv', ['inventory', 'update', '--profile', 'integration']):
                    self.assertEqual(self.audit.main(), 0)
                self.assertEqual(json.loads(inventory.read_text())['entries'],
                                 sorted([self.case, integration], key=lambda case: case['id']))

    def test_update_without_explicit_assignment_cannot_add_exunit_cases(self):
        import contextlib
        import io
        import tempfile
        from unittest.mock import patch

        case = self.audit.entry('exunit', 'test/new_test.exs', 'New:test new', 'unit')
        with tempfile.TemporaryDirectory() as directory:
            inventory = Path(directory) / 'inventory.json'
            with patch.object(self.audit, 'INVENTORY', inventory), \
                    patch.object(self.audit, 'discover', return_value=[case]), \
                    patch('sys.argv', ['inventory', 'update']), \
                    contextlib.redirect_stdout(io.StringIO()), \
                    contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(self.audit.main(), 1)
            self.assertFalse(inventory.exists())

    def test_check_rejects_test_files_outside_discovered_native_population(self):
        import contextlib
        import json
        import tempfile
        from unittest.mock import patch

        for name in ('test/scripts/empty_test.py', 'test/unconfigured/nested_test.py',
                     'tools/openapi/nested/rogue.test.mjs'):
            with self.subTest(name=name), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                known = root / self.case['file']
                known.parent.mkdir(parents=True)
                known.write_text('controlled discovered fixture')
                unknown = root / name
                unknown.parent.mkdir(parents=True, exist_ok=True)
                unknown.write_text('controlled undiscovered fixture')
                inventory = root / 'inventory.json'
                inventory.write_text(json.dumps({'schema_version': 1,
                                                  'entries': [self.case], 'helpers': {}}))
                with contextlib.chdir(root), patch.object(self.audit, 'INVENTORY', inventory), \
                        patch.object(self.audit, 'discover', return_value=[self.case]):
                    with self.assertRaisesRegex(ValueError, 'undiscovered-test-file'):
                        self.audit.check()
                    unknown.unlink()
                    self.assertEqual(self.audit.check()['entries'], [self.case])

    def test_membership_diagnostic_identifies_only_opaque_cases(self):
        import contextlib
        import io
        captured = io.StringIO()
        with contextlib.redirect_stderr(captured), self.assertRaises(ValueError):
            self.audit.validate([self.case], [])
        self.assertIn(self.case['id'], captured.getvalue())
        self.assertNotIn(self.case['case_id'], captured.getvalue())
        self.assertNotIn(self.case['file'], captured.getvalue())

    def test_compiled_audit_failure_keeps_opaque_membership_diagnostics(self):
        import contextlib
        import io
        import json
        import sys
        import tempfile
        from types import SimpleNamespace
        from unittest.mock import patch
        expected = self.audit.entry('exunit', 'test/fake_test.exs', 'Fake:test removed', 'unit')
        def child(argv, env=None, timeout=120):
            Path(env['PROFILE_DISCOVERY']).write_text('[]')
            raise ValueError('discovery-child')
        with tempfile.TemporaryDirectory() as directory:
            inventory = Path(directory) / 'inventory.json'
            inventory.write_text(json.dumps({'entries':[expected]}))
            captured = io.StringIO()
            with patch.object(self.audit, 'INVENTORY', inventory), patch.object(self.audit, 'capture', side_effect=child), patch.dict(sys.modules, {'test_profile_components':SimpleNamespace(discover_native=lambda:[])}), contextlib.redirect_stderr(captured):
                with self.assertRaises(ValueError):
                    self.audit.discover(enforce=True)
            self.assertIn(expected['id'], captured.getvalue())
            self.assertNotIn(expected['case_id'], captured.getvalue())
