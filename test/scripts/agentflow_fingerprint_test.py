"""Agentflow tooling must never invalidate product fingerprints or receipts."""
import sys
from scripts.agentflow_check import run_check
from scripts import agentflow_verification as v
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture, verification


TOOLING = {
    'agentflow': '#!/usr/bin/env python3\nprint("cli")\n',
    '.agentflow/config.toml': 'default_provider = "codex"\nmax_feedback_cycles = 8\n',
    '.agentflow/workflow.yml': 'schema_version: "1.0"\nsteps:\n  - id: product\n',
    '.agentflow/providers.json': '{"schema_version": 1, "providers": {}}\n',
    'scripts/agentflow_verification.py': 'x = 1\n',
    'scripts/agentflow_opencode.py': 'print("opencode shim")\n',
    'scripts/agentflow_codex.cmd': 'echo codex\n',
    'scripts/workflow_artifact_probe.py': 'print("probe")\n',
    'scripts/product_decision_probe.py': 'print("decision")\n',
}
PRODUCT = {
    'lib/market.exs': 'defmodule Market do\nend\n',
    'config/runtime.exs': 'import Config\n',
    'priv/repo/migrations/001_create.exs': 'defmodule Create do\nend\n',
    'scripts/test_profile.sh': 'echo profile\n',
    'scripts/ci_unit_tests.sh': 'echo ci\n',
    'scripts/local_services.sh': 'echo services\n',
    'mix.exs': 'defmodule MixProject do\nend\n',
    'mix.lock': '%{\n}\n',
    '.tool-versions': 'elixir 1.20.3\n',
}


class SourceFingerprintTest(DeliveryFixture):
    def setUp(self):
        super().setUp()
        for name, content in {**PRODUCT, **TOOLING}.items():
            self.write(name, content)
        # Editing spec/plan/tasks stays fingerprint-bound; tasks untouched here.
        self.write('specs/003-example/tasks_checklist.md', '- [ ] fixture task\n')

    def fingerprint(self):
        return v.source_fingerprint(self.root)

    def test_tooling_edits_do_not_change_the_fingerprint(self):
        before = self.fingerprint()
        for name, content in TOOLING.items():
            self.write(name, content + '# tooling edit\n')
        self.assertEqual(self.fingerprint(), before)
        # A brand-new tooling file is equally invisible to the fingerprint.
        self.write('scripts/agentflow_future_shim.py', 'brand-new tooling\n')
        self.assertEqual(self.fingerprint(), before)

    def test_product_edits_still_change_the_fingerprint(self):
        before = self.fingerprint()
        for name, content in PRODUCT.items():
            current = self.fingerprint()
            self.write(name, content + '# product edit\n')
            self.assertNotEqual(self.fingerprint(), current)
            self.assertNotEqual(self.fingerprint(), before)
        # specs content stays bound as well (checkbox state is normalized away).
        current = self.fingerprint()
        self.write('specs/003-example/tasks_checklist.md', '- [X] fixture task\n')
        self.assertNotEqual(self.fingerprint(), current)


class ReceiptToolingIndependenceTest(DeliveryFixture):
    """OpenCode tooling edits between check and reuse keep receipts current."""

    def setUp(self):
        super().setUp()
        self.data = verification([sys.executable, '-c', "print('fixture check')"])
        self.json('specs/003-example/verification.json', self.data)
        self.write('.agentflow/config.toml', 'max_feedback_cycles = 8\n')
        self.write('scripts/agentflow_opencode.py', 'print("shim")\n')
        self.baseline()

    def receipt(self):
        return v.current_receipt(self.root, self.feature, self.data['checks'][0],
                                 v.source_fingerprint(self.root), v.input_fingerprint(self.feature))

    def test_tooling_edit_between_check_and_reuse_keeps_receipt_current(self):
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 0)
        self.assertEqual(self.receipt()['state'], 'passed')
        self.write('.agentflow/config.toml',
                   'max_feedback_cycles = 9\nstage_timeout_minutes = 45\n')
        self.write('scripts/agentflow_opencode.py', 'print("shim edited")\n')
        self.assertEqual(self.receipt()['state'], 'passed')

    def test_product_source_edit_between_check_and_reuse_still_invalidates(self):
        self.assertEqual(run_check(self.root, self.feature, 'fixture'), 0)
        self.write('lib/market.exs', 'defmodule Market do\n  :edited\nend\n')
        with self.assertRaises(RuntimeError):
            self.receipt()
