import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock
from types import SimpleNamespace

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("dialyzer_ci", ROOT / "scripts/dialyzer_ci.py")
control = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(control)


class DialyzerCiTest(unittest.TestCase):
    def test_cache_invalidation_for_each_compatibility_input(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name in control.CACHE_INPUTS:
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text("initial")
            baseline = control.cache_key(root, "Linux", "x86_64", "ubuntu-24.04")
            self.assertEqual(baseline, control.cache_key(root, "Linux", "x86_64", "ubuntu-24.04"))
            for name in control.CACHE_INPUTS:
                path = root / name
                path.write_text("changed")
                self.assertNotEqual(baseline, control.cache_key(root, "Linux", "x86_64", "ubuntu-24.04"), name)
                path.write_text("initial")
            config = root / "config/runtime.exs"
            config.parent.mkdir()
            config.write_text("changed-build-config")
            self.assertNotEqual(baseline, control.cache_key(root, "Linux", "x86_64", "ubuntu-24.04"))
            config.unlink()
            for args in [("Darwin", "x86_64", "ubuntu-24.04"),
                         ("Linux", "aarch64", "ubuntu-24.04"),
                         ("Linux", "x86_64", "ubuntu-26.04")]:
                self.assertNotEqual(baseline, control.cache_key(root, *args))
            for version in control.VERSIONS:
                changed = {**control.VERSIONS, version: "changed"}
                self.assertNotEqual(baseline, control.cache_key(
                    root, "Linux", "x86_64", "ubuntu-24.04", changed))

    def test_report_errors_and_exact_exception_boundary(self):
        finding = dict(file="lib/example.ex", line=3, kind="invalid_contract", message="contract error",
                       message_sha256=hashlib.sha256(b"contract error").hexdigest(), source_sha256="source")
        report = dict(status="analyzed", profile="dev", phase="application", files=1,
                      versions=control.VERSIONS, findings=[finding])
        allowed = dict(profile="dev", phase="application", lock_sha256=control.lock_digest(), reason="reviewed precise finding",
                       **{key: finding[key] for key in control.IDENTITY})
        self.assertEqual(control.classify(report, 2, "dev", "application", []), ([], [finding]))
        self.assertEqual(control.classify(report, 2, "dev", "application", [allowed]), ([finding], []))
        for reason in (None, True, "", "   "):
            self.assertEqual(control.classify(report, 2, "dev", "application", [{**allowed, "reason": reason}]),
                             ([], [finding]))
        for field in (*control.IDENTITY, "profile", "phase", "lock_sha256"):
            changed = {**allowed, field: "different"}
            self.assertEqual(control.classify(report, 2, "dev", "application", [changed]), ([], [finding]))
        for field, value in [("status", "error"), ("versions", {}), ("profile", "test"),
                             ("phase", "model"), ("files", 0), ("files", True), ("findings", None)]:
            with self.assertRaises(ValueError):
                control.classify({**report, field: value}, 2, "dev", "application", [])
        for exit_code in (0, 1, -9):
            with self.assertRaises(ValueError):
                control.classify(report, exit_code, "dev", "application", [])
        invalid = copy.deepcopy(report)
        invalid["findings"][0]["message"] = "tampered"
        with self.assertRaises(ValueError):
            control.classify(invalid, 2, "dev", "application", [])

    def test_preparation_requires_receipt_even_if_process_exits_zero(self):
        with tempfile.TemporaryDirectory() as directory:
            with mock.patch.object(control.subprocess, "run", return_value=SimpleNamespace(returncode=0)):
                evidence = control.prepare("dev", Path(directory))
            self.assertEqual(evidence["prepare_exit"], 1)
            self.assertEqual(evidence["error"], "FileNotFoundError")

            for profile in ("dev", "test"):
                with self.subTest(profile=profile):
                    def prepare_native(command, **_kwargs):
                        Path(command[-1]).write_text('{"status":"prepared"}\n')
                        return SimpleNamespace(returncode=0)

                    with mock.patch.object(control.subprocess, "run", side_effect=prepare_native) as run:
                        evidence = control.prepare(profile, Path(directory))
                    self.assertEqual(evidence["prepare_exit"], 0, evidence)
                    self.assertEqual(run.call_args.args[0][4], "prepare")

            def malformed_native(command, **_kwargs):
                Path(command[-1]).write_text('{"status":"analyzed"}\n')
                return SimpleNamespace(returncode=0)

            with mock.patch.object(control.subprocess, "run", side_effect=malformed_native):
                evidence = control.prepare("test", Path(directory))
            self.assertEqual(evidence["prepare_exit"], 1)
            self.assertEqual(evidence["error"], "incomplete-preparation")

            def failed_native(command, **_kwargs):
                Path(command[-1]).write_text('{"status":"prepared"}\n')
                return SimpleNamespace(returncode=1)

            with mock.patch.object(control.subprocess, "run", side_effect=failed_native):
                evidence = control.prepare("dev", Path(directory))
            self.assertEqual(evidence["prepare_exit"], 1)

    def test_real_analyzer_contract_detection_recovery_unknowns_and_errors(self):
        for profile in ("dev", "test"):
            preparation = control.prepare(
                profile, ROOT / f"tmp/dialyzer-ci/probe-prepare-{profile}")
            self.assertEqual(preparation["prepare_exit"], 0, {profile: preparation})
        with tempfile.TemporaryDirectory(prefix="dialyzer-probe-", dir=ROOT / "tmp") as directory:
            root = Path(directory)
            source = root / "probe.ex"
            source.write_text('''defmodule Task075ContractProbe do
  @spec value() :: integer()
  def value(), do: "wrong"
end
''')
            output = root / "evidence"
            self.assertEqual(control.analyze("dev", "sample", output, [], source), 1)
            unsafe = json.loads((output / "evidence.json").read_text())
            self.assertEqual(unsafe["status"], "findings")
            self.assertEqual(unsafe["analyzer_exit_status"], 2)
            self.assertTrue(any(f["kind"] == "invalid_contract" and f["line"] == 2
                                and f["file"].endswith("/probe.ex") for f in unsafe["blocking"]))
            source.write_text(source.read_text().replace('"wrong"', '1'))
            self.assertEqual(control.analyze("dev", "sample", output, [], source), 0)
            corrected = json.loads((output / "evidence.json").read_text())
            self.assertEqual(corrected["analyzer_exit_status"], 0)
            self.assertFalse(corrected["blocking"])
            source.write_text('''defmodule Task075ContractProbe do
  def value(), do: :task075_missing.call()
end
''')
            self.assertEqual(control.analyze("dev", "sample", output, [], source), 1)
            unknown = json.loads((output / "evidence.json").read_text())
            self.assertEqual(unknown["status"], "findings")
            self.assertTrue(any(f["kind"] == "unknown_function" for f in unknown["blocking"]))
            source.write_text("defmodule Broken do\n def invalid(\nend\n")
            self.assertEqual(control.analyze("dev", "sample", output, [], source), 1)
            broken = json.loads((output / "evidence.json").read_text())
            self.assertEqual(broken["status"], "error")
            self.assertTrue(broken["errors"])
            self.assertFalse(broken["blocking"])
            retained = ROOT / "tmp/dialyzer-ci/probe-evidence.json"
            retained.parent.mkdir(parents=True, exist_ok=True)
            retained.write_text(json.dumps(dict(unsafe=unsafe, corrected=corrected,
                                                unknown=unknown, broken=broken), indent=2) + "\n")

    def test_workflow_keeps_dialyzer_required_and_cache_exact(self):
        workflow = (ROOT / ".github/workflows/quality-baseline.yml").read_text()
        quality = workflow.split("  end-to-end:")[0]
        self.assertIn("python3 scripts/dialyzer_ci.py\n", quality)
        self.assertIn("key: ${{ steps.dialyzer-cache.outputs.key }}", quality)
        self.assertIn("path: tmp/dialyzer/", quality)
        dialyzer_step = quality.split("- name: Required Dialyzer")[1].split("- name:")[0]
        self.assertNotIn("continue-on-error", dialyzer_step)
        self.assertNotIn("||", dialyzer_step)
        self.assertNotIn("restore-keys", quality)
        self.assertIn("needs: [quality-baseline, end-to-end, sonarcloud]", workflow)
