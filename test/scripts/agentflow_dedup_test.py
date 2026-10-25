"""Local-profile deduplication and HTTP obligation contracts."""
import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from scripts import agentflow_stage_checks as stage_checks
from scripts.agentflow_verification import manifest


class DedupTest(unittest.TestCase):
    def test_project_toolchain_checks_and_mix_commands_are_mise_scoped(self):
        feature = Path('specs/068-agentflow-preflight-recovery')
        data = manifest(feature)
        self.assertIs(data.get('toolchain_required'), True)
        checks = {item['id']: item for item in data['checks']}
        required = ('toolchain', 'format', 'compile', 'credo', 'assets', 'database', 'inventory', 'ci_profiles')
        for ident in required:
            self.assertEqual(checks[ident]['argv'][:3], ['mise', 'exec', '--'], ident)
        self.assertEqual(checks['launch-preflight']['argv'][0], 'python3')

    def test_parity_checks_contract_without_starting_native_profiles(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            (feature / "spec.md").write_text("FR-001\n")
            (feature / "verification.json").write_text(json.dumps({
                "schema_version": 1, "runtime_required": False,
                "checks": [{"id": "ci_profiles", "argv": ["mise", "exec", "--", "scripts/ci_unit_tests.sh"],
                            "env": {"MIX_ENV": "test"}}],
                "coverage": {"FR-001": ["ci_profiles"]},
            }))
            workflow = '  - id: ci_baseline\n    run: "python3 scripts/agentflow_stage_checks.py --ci-parity"\n'
            for name in (".agentflow/workflow.yml", ".specify/workflows/desapp-delivery/workflow.yml"):
                path = root / name; path.parent.mkdir(parents=True, exist_ok=True); path.write_text(workflow)
            (root / ".github/workflows").mkdir(parents=True)
            (root / ".github/workflows/quality-baseline.yml").write_text("run: scripts/ci_unit_tests.sh\n")
            protected = {}
            for directory in ("lib", "priv", "assets"):
                path = root / directory / "sentinel.txt"
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("protected application bytes\n")
                protected[path] = path.read_bytes()
            (root / "scripts").mkdir()
            (root / "scripts/ci_unit_tests.sh").write_text("for profile in unit integration; do :; done\n")
            (root / "test/scripts").mkdir(parents=True)
            calls = []
            def fake_run(argv, **kwargs):
                calls.append(argv)
                return SimpleNamespace(returncode=0, stderr="")
            with patch.object(stage_checks, "active_feature", return_value=feature), \
                    patch.object(stage_checks.subprocess, "run", side_effect=fake_run):
                result = stage_checks.ci_parity(root)
            self.assertEqual(result["native_profile_runs"], 0)
            self.assertEqual(calls, [["sh", "test/scripts/ci_unit_tests_test.sh"]])
            self.assertEqual({path: path.read_bytes() for path in protected}, protected)

    def test_route_obligation_requires_runtime_assertions(self):
        with tempfile.TemporaryDirectory() as temp:
            feature = Path(temp); (feature / "contracts").mkdir()
            (feature / "spec.md").write_text("FR-001\nGET /api/example\n")
            data = {"schema_version": 1, "runtime_required": False,
                    "checks": [{"id": "unit", "argv": ["true"]}],
                    "coverage": {"FR-001": ["unit"]}}
            (feature / "verification.json").write_text(json.dumps(data))
            with self.assertRaisesRegex(RuntimeError, "runtime assertion"):
                manifest(feature)
            data["checks"].append({"id": "http", "argv": ["python3", "check_http.py"],
                                  "runtime": True, "expectation": "status 200 and JSON body field id"})
            data["coverage"]["FR-001"].append("http")
            (feature / "verification.json").write_text(json.dumps(data))
            self.assertEqual(len(manifest(feature)["checks"]), 2)

    def test_parity_refuses_mismatched_workflow_or_missing_ci_obligation_without_profiles(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for rel, text in ((".agentflow/workflow.yml", "local"),
                              (".specify/workflows/desapp-delivery/workflow.yml", "different")):
                path = root / rel; path.parent.mkdir(parents=True, exist_ok=True); path.write_text(text)
            with patch.object(stage_checks.subprocess, "run", side_effect=AssertionError("no profile may run")):
                with self.assertRaisesRegex(RuntimeError, "copies differ"):
                    stage_checks.ci_parity(root)

        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            workflow = '  - id: ci_baseline\n    run: "python3 scripts/agentflow_stage_checks.py --ci-parity"\n'
            for rel in (".agentflow/workflow.yml", ".specify/workflows/desapp-delivery/workflow.yml"):
                path = root / rel; path.parent.mkdir(parents=True, exist_ok=True); path.write_text(workflow)
            (root / "scripts").mkdir(); (root / "scripts/ci_unit_tests.sh").write_text("for profile in unit integration; do :; done\n")
            (root / ".github/workflows").mkdir(parents=True); (root / ".github/workflows/quality-baseline.yml").write_text("run: scripts/ci_unit_tests.sh\n")
            feature = root / "feature"; feature.mkdir(); (feature / "spec.md").write_text("FR-001\n")
            (feature / "verification.json").write_text(json.dumps({"schema_version": 1, "runtime_required": False,
                "checks": [{"id": "other", "argv": ["true"]}], "coverage": {"FR-001": ["other"]}}))
            with patch.object(stage_checks, "active_feature", return_value=feature), \
                    patch.object(stage_checks.subprocess, "run", side_effect=AssertionError("no profiles may run")):
                with self.assertRaisesRegex(RuntimeError, "missing or mismatched"):
                    stage_checks.ci_parity(root)

    def test_bare_http_request_without_runtime_result_is_rejected(self):
        with tempfile.TemporaryDirectory() as temp:
            feature = Path(temp); (feature / "spec.md").write_text("FR-001\nGET /api/items\n")
            (feature / "verification.json").write_text(json.dumps({"schema_version": 1, "runtime_required": False,
                "checks": [{"id": "request", "argv": ["curl", "http://localhost/api/items"]}],
                "coverage": {"FR-001": ["request"]}}))
            with self.assertRaisesRegex(RuntimeError, "runtime assertion"):
                manifest(feature)

    def test_vibecode_procedure_has_explicit_high_risk_exclusions(self):
        text = Path("docs/WORKFLOW_SPEED.md").read_text()
        for value in ("Vibecode", "preflight", "CI", "QA", "review", "finanzas",
                      "integridad de datos", "workflow/gates/herramientas", "TASK-070"):
            self.assertIn(value, text)


if __name__ == "__main__":
    unittest.main()
