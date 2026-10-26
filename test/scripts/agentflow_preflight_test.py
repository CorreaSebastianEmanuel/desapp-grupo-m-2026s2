"""Read-only effective child preflight contract tests."""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from agentflow_preflight import build_context, evaluate, evaluate_declarations, node24_path


class PreflightTest(unittest.TestCase):
    def toolchain_context(self, root, stage='develop'):
        root.mkdir(parents=True, exist_ok=True)
        (root / '.tool-versions').write_text('erlang 29.0.6\nelixir 1.20.3-otp-29\n')
        tools = root / 'bin'; tools.mkdir()
        for name, body in {
            'mise': '#!/bin/sh\nexit 0\n',
            'elixir': '#!/bin/sh\nprintf "Elixir 1.20.4 (compiled with Erlang/OTP 29)\\n"\n',
            'node': '#!/bin/sh\nprintf "v24.22.1\\n"\n',
        }.items():
            path = tools / name; path.write_text(body); path.chmod(0o755)
        scripts = root / 'scripts'; scripts.mkdir()
        service = scripts / 'local_services.sh'; service.write_text('#!/bin/sh\nexit 0\n'); service.chmod(0o755)
        return build_context(stage, 'codex', ['codex'], root=root, cwd=root,
                             env={'PATH': str(tools) + os.pathsep + os.environ.get('PATH', '')})

    def fake_pinned_versions(self, *, elixir='Elixir 1.20.3 (compiled with Erlang/OTP 29)',
                             erlang='29', node='v24.22.1'):
        calls = []
        def run(argv, **kwargs):
            calls.append((list(argv), kwargs))
            if argv[-2:] == ['elixir', '--version']:
                stdout = elixir
            elif 'erl' in argv:
                stdout = erlang
            elif argv[-2:] == ['node', '--version']:
                stdout = node
            elif argv[-1:] == ['--version'] and argv[0].endswith('/node'):
                stdout = node
            else:
                stdout = ''
            return type('Result', (), {'returncode': 0, 'stdout': stdout, 'stderr': ''})()
        return calls, run

    def test_wrong_global_elixir_is_ignored_when_mise_selects_project_pin(self):
        with tempfile.TemporaryDirectory() as temp:
            context = self.toolchain_context(Path(temp))
            calls, run = self.fake_pinned_versions()
            with patch('agentflow_preflight._probe', return_value=None), \
                    patch('agentflow_preflight.subprocess.run', side_effect=run):
                result = evaluate(context)
            self.assertTrue(result['ready'], result)
            mise_calls = [argv for argv, _ in calls if argv and argv[0].endswith('/mise')]
            self.assertEqual([argv[3:] for argv in mise_calls], [
                ['elixir', '--version'], ['erl', '-noshell', '-eval',
                 'io:format("~s", [erlang:system_info(otp_release)]), halt().']])
            self.assertFalse(any(argv and argv[0].endswith('/elixir') for argv, _ in calls))
            self.assertTrue(any(argv and argv[0].endswith('/node') and argv[-1] == '--version'
                                for argv, _ in calls))
            self.assertTrue(all(kwargs['env'] == context.env and kwargs['cwd'] == context.cwd
                                for _, kwargs in calls))

    def test_mise_elixir_or_node_version_mismatch_fails_with_safe_remediation(self):
        with tempfile.TemporaryDirectory() as temp:
            context = self.toolchain_context(Path(temp))
            (Path(temp) / 'bin/node').write_text('#!/bin/sh\nprintf "v20.18.1\\n"\n')
            (Path(temp) / 'bin/node').chmod(0o755)
            calls, run = self.fake_pinned_versions(elixir='Elixir 1.20.4 (compiled with Erlang/OTP 29)',
                                                   node='v20.18.1')
            with patch('agentflow_preflight._probe', return_value=None), \
                    patch('agentflow_preflight.subprocess.run', side_effect=run):
                result = evaluate(context)
            self.assertFalse(result['ready'])
            self.assertEqual([(value['check'], value['category']) for value in result['prerequisites']],
                             [('elixir', 'prerequisite-incompatible'),
                              ('node', 'prerequisite-incompatible')])
            rendered = json.dumps(result)
            self.assertNotIn('1.20.4', rendered)
            self.assertNotIn('20.18.1', rendered)

    def test_product_launch_preflight_checks_task_toolchain_and_docs_only_manifest_can_opt_out(self):
        with tempfile.TemporaryDirectory() as temp:
            context = self.toolchain_context(Path(temp), stage='product')
            calls, run = self.fake_pinned_versions(elixir='Elixir 1.20.4 (compiled with Erlang/OTP 29)')
            with patch('agentflow_preflight._probe', return_value=None), \
                    patch('agentflow_preflight.subprocess.run', side_effect=run):
                result = evaluate(context)
            self.assertFalse(result['ready'])
            self.assertIn('elixir', [item['check'] for item in result['prerequisites']])

        with tempfile.TemporaryDirectory() as temp:
            context = self.toolchain_context(Path(temp), stage='product')
            context.env['AGENTFLOW_TOOLCHAIN_REQUIRED'] = 'false'
            def docs_probe(argv, **_kwargs):
                if argv and argv[0] == 'sh':
                    return type('Result', (), {'returncode': 0, 'stdout': '', 'stderr': ''})()
                raise AssertionError('docs-only work must skip project toolchain probes')
            with patch('agentflow_preflight._probe', return_value=None), \
                    patch('agentflow_preflight.subprocess.run', side_effect=docs_probe):
                self.assertTrue(evaluate(context)['ready'])

        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            context = build_context('product', 'codex', ['codex'], root=root, cwd=root,
                                    env={'PATH': os.environ.get('PATH', '')})
            with patch('agentflow_preflight._probe', return_value=None):
                self.assertTrue(evaluate(context)['ready'])

    def test_node_resolver_uses_nvm_24_when_effective_path_has_other_major(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); current = root/'current'; fallback = root/'nvm/v24.22.1/bin'
            current.mkdir(); fallback.mkdir(parents=True)
            for path, version in ((current/'node', 'v20.18.1'), (fallback/'node', 'v24.22.1')):
                path.write_text(f'#!/bin/sh\nprintf "{version}\\n"\n'); path.chmod(0o755)
            with patch('agentflow_preflight.glob.glob', return_value=[str(fallback)]):
                self.assertEqual(node24_path(str(current)), str(fallback))
                self.assertIsNone(node24_path(str(fallback)))
    def test_uses_child_path_and_working_directory(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            tools = root / "child-bin"
            tools.mkdir()
            for name in ("git", "specify", "codex"):
                path = tools / name
                path.write_text("#!/bin/sh\nexit 0\n")
                path.chmod(0o755)
            env = {"PATH": str(tools), "SAFE_SETTING": "yes"}
            context = build_context("develop", "codex", [str(tools / "codex"), "exec"],
                                    root=root, cwd=root, env=env)
            before = {item.relative_to(root).as_posix(): item.read_bytes()
                      for item in root.rglob("*") if item.is_file()}
            result = evaluate(context, inventory=[("git", "executable"),
                                                    ("specify", "executable"),
                                                    ("codex", "provider-executable")])
            after = {item.relative_to(root).as_posix(): item.read_bytes()
                     for item in root.rglob("*") if item.is_file()}
            self.assertTrue(result["ready"])
            self.assertEqual(before, after)

    def test_missing_child_executable_is_failed_with_safe_details(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            context = build_context("qa", "codex", ["codex", "exec"], root=root,
                                    cwd=root, env={"PATH": str(root)})
            result = evaluate(context, inventory=[("codex", "provider-executable")])
            self.assertFalse(result["ready"])
            diagnostic = result["prerequisites"][0]
            self.assertEqual(diagnostic["category"], "prerequisite-missing")
            self.assertEqual(diagnostic["observed"], "missing")
            self.assertNotIn(str(root), json.dumps(result))

    def test_unknown_inventory_is_not_reported_as_ready(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            context = build_context("develop", "codex", ["codex"], root=root,
                                    cwd=root, env={"PATH": ""})
            result = evaluate(context, inventory=[("not-installed", "registered-version")])
            self.assertFalse(result["ready"])
            self.assertEqual(result["prerequisites"][0]["category"], "prerequisite-missing")

    def test_incompatible_python_is_reported_without_version_output(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); tools = root / "bin"; tools.mkdir()
            python = tools / "python3"
            python.write_text("#!/bin/sh\nprintf '%s\\n' 'Python 2.7 token-CANARY'\n")
            python.chmod(0o755)
            context = build_context("architecture", "codex", ["python3"], root=root,
                                    cwd=root, env={"PATH": str(tools)})
            result = evaluate(context, inventory=[("python3", "python-3")])
            rendered = json.dumps(result)
            self.assertFalse(result["ready"])
            self.assertEqual(result["prerequisites"][0]["category"], "prerequisite-incompatible")
            self.assertNotIn("2.7", rendered)
            self.assertNotIn("CANARY", rendered)

    def test_configuration_change_and_explicit_path_override_use_final_child_context(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            original = root / "original"; original.mkdir()
            override = root / "override"; override.mkdir()
            (original / "required-tool").write_text("#!/bin/sh\nexit 0\n")
            (original / "required-tool").chmod(0o755)
            (override / "override-tool").write_text("#!/bin/sh\nexit 0\n")
            (override / "override-tool").chmod(0o755)

            child_env = {"PATH": str(original), "WORKFLOW_MODE": "default"}
            base = build_context("develop", "codex", ["codex"], root=root, cwd=root, env=child_env)
            child_env.update(PATH=str(override), WORKFLOW_MODE="override")
            override_context = build_context("develop", "codex", ["codex"], root=root, cwd=root,
                                             env=child_env)
            self.assertFalse(evaluate(base, inventory=[("override-tool", "executable")])["ready"])
            self.assertTrue(evaluate(override_context, inventory=[("override-tool", "executable")])["ready"])
            self.assertEqual(base.env["WORKFLOW_MODE"], "default")
            self.assertEqual(override_context.env["WORKFLOW_MODE"], "override")
            self.assertIsNot(base.env, override_context.env)

    def test_changed_child_path_is_not_hidden_by_parent_path(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); parent_path = root / "parent"; parent_path.mkdir()
            child_path = root / "child"; child_path.mkdir()
            (parent_path / "git").write_text("#!/bin/sh\nexit 0\n")
            (parent_path / "git").chmod(0o755)
            context = build_context("develop", "codex", ["codex"], root=root, cwd=root,
                                    env={"PATH": str(child_path)})
            result = evaluate(context, inventory=[("git", "executable")])
            self.assertFalse(result["ready"])
            self.assertEqual(result["prerequisites"][0]["category"], "prerequisite-missing")

    def test_missing_setting_is_safe_and_service_failure_is_unavailable(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); scripts = root / "scripts"; scripts.mkdir()
            service = scripts / "local_services.sh"
            service.write_text("#!/bin/sh\n[ \"$1\" = ready ] || exit 9\nexit 1\n")
            service.chmod(0o755)
            secret = "API-CANARY-DO-NOT-PRINT"
            context = build_context("develop", "codex", ["codex"], root=root, cwd=root,
                                    env={"PATH": "/bin:/usr/bin", "UNRELATED_SECRET": secret})
            declarations = [
                {"id": "required-setting", "kind": "setting", "target": "MISSING_SETTING",
                 "expected": "setting-present", "recovery": "configure-setting"},
                {"id": "postgres", "kind": "service", "target": "postgres",
                 "expected": "service-ready", "recovery": "start-local-services"},
            ]
            result = evaluate_declarations(context, declarations)
            self.assertEqual([row["category"] for row in result],
                             ["prerequisite-missing", "prerequisite-unavailable"])
            self.assertEqual([row["check"] for row in result], ["required-setting", "postgres"])
            self.assertNotIn(secret, json.dumps(result))

    def test_service_probe_timeout_is_unknown_and_safe(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            context = build_context("develop", "codex", ["codex"], root=root, cwd=root, env={})
            declaration = [{"id": "postgres", "kind": "service", "target": "postgres",
                            "expected": "service-ready", "recovery": "check-local-services"}]
            with patch("agentflow_preflight.subprocess.run", side_effect=subprocess.TimeoutExpired("probe", 5)):
                result = evaluate_declarations(context, declaration)
            self.assertEqual(result[0]["category"], "prerequisite-unknown")
            self.assertEqual(result[0]["observed"], "probe-failed")

    def test_unknown_prerequisite_kind_fails_closed(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            context = build_context("develop", "codex", ["codex"], root=root, cwd=root, env={})
            declaration = [{"id": "future-probe", "kind": "future", "target": "value",
                            "expected": "future-ready", "recovery": "inspect-policy"}]
            result = evaluate_declarations(context, declaration)
            self.assertEqual(result[0]["category"], "prerequisite-unknown")
            self.assertEqual(result[0]["observed"], "unsupported")

    def test_identical_context_produces_identical_redacted_results(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); secret = "SETTING-CANARY-DO-NOT-PRINT"
            context = build_context("develop", "codex", ["codex"], root=root, cwd=root,
                                    env={"PATH": "", "PRIVATE_VALUE": secret})
            declaration = [{"id": "required-setting", "kind": "setting", "target": "MISSING_SETTING",
                            "expected": "setting-present", "recovery": "configure-setting"}]
            first = evaluate_declarations(context, declaration)
            second = evaluate_declarations(context, declaration)
            self.assertEqual(first, second)
            self.assertNotIn(secret, json.dumps(first))


if __name__ == "__main__":
    unittest.main()
