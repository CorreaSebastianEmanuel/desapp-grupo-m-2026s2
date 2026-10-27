"""Contract tests for fail-closed workflow check metadata and safe outcomes."""
from __future__ import annotations

import json
import os
import signal
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

from agentflow_runtime import safe_diagnostic
from agentflow_verification import manifest
import agentflow_stage_checks as stage_checks
from agentflow_stage_checks import _report


class ManifestContractTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.feature = Path(self.temp.name)
        (self.feature / "spec.md").write_text("FR-001\n")
        self.checks = [
            {"id": "first", "argv": ["true"], "depends_on": [],
             "isolation": "isolated", "state_reads": [], "state_writes": []},
            {"id": "second", "argv": ["true"], "depends_on": ["first"],
             "isolation": "isolated", "state_reads": [], "state_writes": []},
        ]
        self.write()

    def tearDown(self):
        self.temp.cleanup()

    def write(self):
        (self.feature / "verification.json").write_text(json.dumps({
            "schema_version": 1, "runtime_required": False,
            "checks": self.checks, "coverage": {"FR-001": ["first"]},
        }))

    def test_accepts_known_dependency_and_declared_effects(self):
        self.assertEqual(manifest(self.feature)["checks"], self.checks)

    def test_unknown_dependency_fails_before_any_execution(self):
        self.checks[1]["depends_on"] = ["missing"]
        self.write()
        before = (self.feature / "verification.json").read_bytes()
        with self.assertRaisesRegex(RuntimeError, "dependency"):
            manifest(self.feature)
        self.assertEqual((self.feature / "verification.json").read_bytes(), before)

    def test_dependency_cycle_fails(self):
        self.checks[0]["depends_on"] = ["second"]
        self.write()
        with self.assertRaisesRegex(RuntimeError, "cycle"):
            manifest(self.feature)

    def test_unknown_isolation_and_duplicate_effects_fail(self):
        self.checks[0]["isolation"] = "maybe"
        self.write()
        with self.assertRaisesRegex(RuntimeError, "isolation"):
            manifest(self.feature)
        self.checks[0]["isolation"] = "isolated"
        self.checks[0]["state_reads"] = ["cache", "cache"]
        self.write()
        with self.assertRaisesRegex(RuntimeError, "state"):
            manifest(self.feature)

    def test_legacy_manifest_remains_valid_with_unknown_independence(self):
        self.checks = [{"id": "first", "argv": ["true"]}]
        self.write()
        self.assertEqual(manifest(self.feature)["checks"][0], self.checks[0])

    def test_static_class_requires_exact_registered_argv(self):
        self.checks[0]["execution_class"] = "static"
        self.write()
        with self.assertRaisesRegex(RuntimeError, "static"):
            manifest(self.feature)

    def test_typed_prerequisites_reject_shell_like_targets(self):
        self.checks[0]["prerequisites"] = [{"id": "database", "kind": "service",
                                            "target": "postgres", "expected": "service-ready",
                                            "recovery": "start-local-services"}]
        self.write()
        self.assertEqual(manifest(self.feature)["checks"][0]["prerequisites"][0]["target"], "postgres")
        self.checks[0]["prerequisites"][0]["target"] = "postgres; touch /tmp/pwned"
        self.write()
        with self.assertRaisesRegex(RuntimeError, "prerequisite"):
            manifest(self.feature)


class SafeDiagnosticTest(unittest.TestCase):
    def test_catalog_diagnostic_never_reflects_secret_or_exception_text(self):
        canary = "token-NEVER-PRINT"
        result = safe_diagnostic(task="TASK-070", feature="068-feature", stage="qa",
                                 check="check-failed", category="check-failed",
                                 expected=canary, observed=canary, evidence=canary)
        self.assertNotIn(canary, json.dumps(result))
        self.assertEqual(result["cause"], "A required check failed.")
        self.assertEqual(result["expected"], "registered-condition")
        self.assertEqual(result["evidence"], None)

    def test_incomplete_qa_projection_cannot_pass(self):
        with tempfile.TemporaryDirectory() as temp:
            report = Path(temp) / "qa-report.md"
            _report(report, "qa", {"checks": [
                {"id": "done", "status": "passed", "evidence": "evidence.log"},
                {"id": "pending", "status": "unexecuted", "evidence": None},
            ]})
            self.assertIn("Verdict: FAIL", report.read_text())
            self.assertIn("pending", report.read_text())


class StageExecutionTest(unittest.TestCase):
    def setUp(self):
        retry_patch = patch.object(stage_checks, "retry_fingerprint", return_value="fixture-input")
        retry_patch.start()
        self.addCleanup(retry_patch.stop)

    def make_feature(self, root, checks):
        feature = root / "feature"
        feature.mkdir()
        (feature / "spec.md").write_text("FR-001\n")
        (feature / "verification.json").write_text(json.dumps({
            "schema_version": 1, "runtime_required": False, "checks": checks,
            "coverage": {"FR-001": [checks[0]["id"]]},
        }))
        return feature

    def test_failure_continues_independent_and_blocks_state_dependent(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = self.make_feature(root, [
                {"id": "bad", "argv": ["false"], "depends_on": [], "isolation": "isolated",
                 "state_reads": [], "state_writes": ["cache"]},
                {"id": "free", "argv": ["true"], "depends_on": [], "isolation": "isolated",
                 "state_reads": [], "state_writes": []},
                {"id": "reads-cache", "argv": ["true"], "depends_on": [], "isolation": "isolated",
                 "state_reads": ["cache"], "state_writes": []},
                {"id": "after-bad", "argv": ["true"], "depends_on": ["bad"], "isolation": "isolated",
                 "state_reads": [], "state_writes": []},
            ])
            called = []
            attempt_tokens = []
            def fake(check, _root, _stage, _reuse, _attempt_token=None):
                called.append(check["id"])
                attempt_tokens.append(_attempt_token)
                return {"status": "failed" if check["id"] == "bad" else "passed",
                        "elapsed_ms": 1, "category": None, "evidence": None, "exit_code": 1}
            with patch.object(stage_checks, "_safe_command", fake):
                code = stage_checks.run_stage(root, feature, "qa")
            self.assertEqual(code, 1)
            self.assertEqual(called, ["bad", "free"])
            self.assertEqual(len(set(attempt_tokens)), 1)
            self.assertRegex(attempt_tokens[0], r"^[a-f0-9]{32}$")
            outcomes = json.loads(next((root / ".agentflow/runs/checks/stage-journals/feature").glob("qa.json")).read_text())
            self.assertEqual(outcomes["stage_attempt_token"], attempt_tokens[0])
            self.assertEqual([row["status"] for row in outcomes["checks"]],
                             ["failed", "passed", "blocked", "blocked"])
            self.assertIn("Verdict: FAIL", (feature / "qa-report.md").read_text())

    def test_retry_limit_survives_unrelated_independent_input_change(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            feature = self.make_feature(root, [
                {"id": "dependency", "argv": ["true"], "depends_on": [],
                 "isolation": "isolated", "state_reads": [], "state_writes": []},
                {"id": "bad", "argv": ["false"], "depends_on": ["dependency"],
                 "isolation": "isolated", "state_reads": [], "state_writes": []},
                {"id": "independent", "argv": ["true"], "depends_on": [],
                 "isolation": "isolated", "state_reads": [], "state_writes": []},
            ])
            inputs = {"dependency": "dep-v1", "bad": "bad-v1", "independent": "free-v1"}
            def fingerprint(_root, _feature, check):
                return inputs[check["id"]]
            def fail_bad(check, *_args, **_kwargs):
                return {"status": "failed" if check["id"] == "bad" else "passed",
                        "elapsed_ms": 1, "category": "check-failed", "evidence": None,
                        "exit_code": 1 if check["id"] == "bad" else 0}
            with patch.object(stage_checks, "retry_fingerprint", side_effect=fingerprint), \
                 patch.object(stage_checks, "_safe_command", side_effect=fail_bad):
                self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 1)
                self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 1)
                inputs["independent"] = "free-v2"
                with self.assertRaisesRegex(RuntimeError, "retry limit"):
                    stage_checks.run_stage(root, feature, "qa")

    def test_retry_limit_allows_recovery_when_failed_or_dependency_input_changes(self):
        for changed_id in ("bad", "dependency"):
            with self.subTest(changed_id=changed_id), tempfile.TemporaryDirectory() as temp:
                root = Path(temp)
                feature = self.make_feature(root, [
                    {"id": "dependency", "argv": ["true"], "depends_on": [],
                     "isolation": "isolated", "state_reads": [], "state_writes": []},
                    {"id": "bad", "argv": ["false"], "depends_on": ["dependency"],
                     "isolation": "isolated", "state_reads": [], "state_writes": []},
                    {"id": "independent", "argv": ["true"], "depends_on": [],
                     "isolation": "isolated", "state_reads": [], "state_writes": []},
                ])
                inputs = {"dependency": "dep-v1", "bad": "bad-v1", "independent": "free-v1"}
                def fingerprint(_root, _feature, check):
                    return inputs[check["id"]]
                def fail_bad(check, *_args, **_kwargs):
                    return {"status": "failed" if check["id"] == "bad" else "passed",
                            "elapsed_ms": 1, "category": "check-failed", "evidence": None,
                            "exit_code": 1 if check["id"] == "bad" else 0}
                with patch.object(stage_checks, "retry_fingerprint", side_effect=fingerprint), \
                     patch.object(stage_checks, "_safe_command", side_effect=fail_bad):
                    self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 1)
                    self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 1)
                    inputs[changed_id] += "-changed"
                    self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 1)

    def test_interrupted_attempt_without_retry_scope_uses_complete_stage_snapshot(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            feature = self.make_feature(root, [
                {"id": "bad", "argv": ["false"], "depends_on": [],
                 "isolation": "isolated", "state_reads": [], "state_writes": []},
                {"id": "independent", "argv": ["true"], "depends_on": [],
                 "isolation": "isolated", "state_reads": [], "state_writes": []},
            ])
            inputs = {"bad": "bad-v1", "independent": "free-v1"}
            def fingerprint(_root, _feature, check):
                return inputs[check["id"]]
            def fail_bad(check, *_args, **_kwargs):
                return {"status": "failed" if check["id"] == "bad" else "passed",
                        "elapsed_ms": 1, "category": "check-failed", "evidence": None,
                        "exit_code": 1 if check["id"] == "bad" else 0}
            attempt_path = stage_checks._stage_attempt_file(root, feature, "qa")
            with patch.object(stage_checks, "retry_fingerprint", side_effect=fingerprint), \
                 patch.object(stage_checks, "_safe_command", side_effect=fail_bad):
                self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 1)
                saved = json.loads(attempt_path.read_text())
                for prior in saved["attempts"]:
                    prior["state"] = "interrupted"
                    prior.pop("retry_scope", None)
                    prior.pop("retry_snapshot", None)
                    prior.pop("dependency_graph", None)
                saved["attempts"].append(json.loads(json.dumps(saved["attempts"][0])))
                stage_checks.atomic_json(attempt_path, saved)
                with self.assertRaisesRegex(RuntimeError, "retry limit"):
                    stage_checks.run_stage(root, feature, "qa")

    def test_concurrent_launchers_serialize_attempt_journal_without_lost_rows(self):
        import subprocess
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = self.make_feature(root, [
                {"id": "only", "argv": ["true"], "depends_on": [],
                 "isolation": "isolated", "state_reads": [], "state_writes": []}])
            started = root / "first-child-started"
            launched_second = root / "second-launched"
            release = root / "release-first"
            script = r'''import os, sys, time
from pathlib import Path
sys.path.insert(0, str(Path(os.environ["REPO_ROOT"]) / "scripts"))
import agentflow_stage_checks as stage
root = Path(os.environ["STAGE_ROOT"])
feature = Path(os.environ["FEATURE_ROOT"])
Path(os.environ["LAUNCHED_MARKER"]).write_text("launched")
def fake(*args, **kwargs):
    if os.environ.get("BLOCK_FIRST") == "1":
        Path(os.environ["STARTED_MARKER"]).write_text("started")
        deadline = time.time() + 10
        while not Path(os.environ["RELEASE_MARKER"]).exists() and time.time() < deadline:
            time.sleep(.01)
        if not Path(os.environ["RELEASE_MARKER"]).exists():
            raise RuntimeError("fixture release timeout")
    return {"status":"passed", "elapsed_ms":1, "category":None, "evidence":None, "exit_code":0}
stage.retry_fingerprint = lambda *_args: "fixture-input"
stage._safe_command = fake
try:
    raise SystemExit(stage.run_stage(root, feature, "qa"))
except RuntimeError as error:
    print(str(error), file=sys.stderr)
    raise SystemExit(75)
'''
            def launch(block, marker):
                env = {**os.environ, "REPO_ROOT": str(ROOT), "STAGE_ROOT": str(root),
                       "FEATURE_ROOT": str(feature), "BLOCK_FIRST": block,
                       "LAUNCHED_MARKER": str(marker), "STARTED_MARKER": str(started),
                       "RELEASE_MARKER": str(release)}
                return subprocess.Popen([sys.executable, "-c", script], env=env,
                                        stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True)
            first = launch("1", root / "first-launched")
            try:
                deadline = time.time() + 10
                while not started.exists() and time.time() < deadline:
                    if first.poll() is not None:
                        self.fail("first launcher exited before its check started")
                    time.sleep(.01)
                self.assertTrue(started.exists())
                second = launch("0", launched_second)
                try:
                    deadline = time.time() + 10
                    while not launched_second.exists() and time.time() < deadline:
                        time.sleep(.01)
                    self.assertTrue(launched_second.exists())
                    time.sleep(.1)
                    attempt_path = root / ".agentflow/runs/checks/stage-attempts/feature/qa.json"
                    while not attempt_path.exists() and time.time() < deadline:
                        time.sleep(.01)
                    during = json.loads(attempt_path.read_text())
                    self.assertEqual(len(during["attempts"]), 1)
                    self.assertEqual(during["attempts"][0]["state"], "running")
                    self.assertTrue(attempt_path.with_name("qa.lock").is_file())
                    self.assertEqual(second.wait(timeout=5), 75)
                    self.assertIn("Stage is already running", second.communicate(timeout=1)[1])
                finally:
                    release.write_text("release")
                first_output = first.communicate(timeout=10)[1]
                second_output = second.communicate(timeout=10)[1]
                self.assertEqual(first.returncode, 0, first_output)
                self.assertEqual(second.returncode, 75, second_output)
                saved = json.loads(attempt_path.read_text())
                self.assertEqual(len(saved["attempts"]), 1)
                self.assertEqual([item["state"] for item in saved["attempts"]], ["passed"])
            finally:
                if first.poll() is None:
                    release.write_text("release")
                    first.kill(); first.wait(timeout=5)
                if first.stderr and not first.stderr.closed:
                    first.stderr.close()
                if "second" in locals() and second.poll() is None:
                    second.kill(); second.wait(timeout=5)
                if "second" in locals() and second.stderr and not second.stderr.closed:
                    second.stderr.close()

    def test_registered_static_checks_overlap_by_at_most_two(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            definitions = [
                {"id": "artifacts", "argv": ["python3", "scripts/agentflow_artifacts.py",
                                                "specs/068-agentflow-preflight-recovery"],
                 "depends_on": [], "isolation": "isolated", "state_reads": [], "state_writes": [],
                 "execution_class": "static"},
                {"id": "parity", "argv": ["python3", "scripts/agentflow_stage_checks.py", "--ci-parity"],
                 "depends_on": [], "isolation": "isolated", "state_reads": [], "state_writes": [],
                 "execution_class": "static"},
            ]
            measurements = []
            for workers in (1, 2):
                case_root = root / f"workers-{workers}"; case_root.mkdir()
                feature = self.make_feature(case_root, definitions)
                lock = threading.Lock(); active = [0]; peak = [0]
                def fake(check, _root, _stage, _reuse, _attempt_token=None):
                    with lock:
                        active[0] += 1; peak[0] = max(peak[0], active[0])
                    time.sleep(.04)
                    with lock: active[0] -= 1
                    return {"status": "passed", "elapsed_ms": 40, "category": None,
                            "evidence": None, "exit_code": 0}
                started = time.monotonic()
                with patch.object(stage_checks, "_safe_command", fake):
                    code = stage_checks.run_stage(case_root, feature, "develop", workers=workers)
                wall_ms = int((time.monotonic()-started)*1000)
                self.assertEqual(code, 0)
                self.assertLessEqual(peak[0], workers)
                measurements.append((workers, wall_ms, peak[0]))
            print("STATIC_FIXTURE " + " ".join(f"workers={w},wall_ms={ms},peak={peak}" for w,ms,peak in measurements))
            self.assertEqual(measurements[1][2], 2)

    def test_interrupted_check_stops_batch_and_leaves_remaining_unexecuted(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            feature = self.make_feature(root, [
                {"id": "first", "argv": ["first"], "depends_on": [], "isolation": "isolated",
                 "state_reads": [], "state_writes": []},
                {"id": "second", "argv": ["second"], "depends_on": [], "isolation": "isolated",
                 "state_reads": [], "state_writes": []},
            ])
            called = []
            def fake(check, _root, _stage, _reuse, _attempt_token=None):
                called.append(check["id"])
                return {"status": "interrupted", "elapsed_ms": 1, "category": "interrupted",
                        "evidence": None, "exit_code": 130}
            with patch.object(stage_checks, "_safe_command", fake):
                code = stage_checks.run_stage(root, feature, "qa")
            self.assertEqual(code, 130)
            self.assertEqual(called, ["first"])
            rows = json.loads((root / ".agentflow/runs/checks/stage-journals/feature/qa.json").read_text())["checks"]
            self.assertEqual([row["status"] for row in rows], ["interrupted", "unexecuted"])

    def test_dependency_contamination_is_transitive_and_report_keeps_declaration_order(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            feature = self.make_feature(root, [
                {"id": ident, "argv": ["true"], "depends_on": deps,
                 "isolation": "isolated", "state_reads": [], "state_writes": writes}
                for ident, deps, writes in (("first", [], ["db"]), ("second", ["first"], []),
                                            ("third", ["second"], []), ("free", [], []))
            ])
            called = []
            def fake(check, _root, _stage, _reuse, _attempt_token=None):
                called.append(check["id"])
                return {"status": "failed" if check["id"] == "first" else "passed",
                        "elapsed_ms": 3, "category": "check-failed", "evidence": None, "exit_code": 1}
            with patch.object(stage_checks, "_safe_command", fake):
                self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 1)
            self.assertEqual(called, ["first", "free"])
            rows = json.loads((root / ".agentflow/runs/checks/stage-journals/feature/qa.json").read_text())["checks"]
            self.assertEqual([row["id"] for row in rows], ["first", "second", "third", "free"])
            self.assertEqual([row["status"] for row in rows], ["failed", "blocked", "blocked", "passed"])

    def test_fresh_qa_requires_independent_assessment_even_when_all_checks_pass(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = self.make_feature(root, [
                {"id": "ok", "argv": ["true"], "depends_on": [], "isolation": "isolated",
                 "state_reads": [], "state_writes": []}])
            with patch.object(stage_checks, "_safe_command", return_value={
                    "status": "passed", "elapsed_ms": 1, "category": None,
                    "evidence": None, "exit_code": 0}):
                self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 0)
            self.assertIn("Verdict: FAIL", (feature / "qa-report.md").read_text())

    def test_static_argv_and_effects_reject_unregistered_or_stateful_commands(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = self.make_feature(root, [
                {"id": "fake", "argv": ["mix", "test"], "depends_on": [],
                 "isolation": "isolated", "state_reads": [], "state_writes": [],
                 "execution_class": "static"}])
            with patch.object(stage_checks, "_safe_command", side_effect=AssertionError("must not execute")):
                with self.assertRaisesRegex(RuntimeError, "static"):
                    stage_checks.run_stage(root, feature, "develop")

    def test_safe_command_records_elapsed_time_from_monotonic_clock(self):
        check = {"id": "fixture"}
        with patch.object(stage_checks.time, "monotonic", side_effect=[10.0, 10.125]), \
             patch.object(stage_checks.subprocess, "run", return_value=type("Result", (), {
                 "returncode": 0, "stdout": "{}", "stderr": ""})()):
            result = stage_checks._safe_command(check, Path("."), "develop", False)
        self.assertEqual(result["elapsed_ms"], 125)

    def test_full_stage_attempt_token_is_forwarded_to_check_child(self):
        token = "a" * 32
        captured = []
        result = type("Result", (), {"returncode": 0, "stdout": "{}", "stderr": ""})()
        with patch.object(stage_checks.subprocess, "run",
                           side_effect=lambda argv, **kwargs: (captured.append(kwargs["env"]), result)[1]):
            stage_checks._safe_command({"id": "unit"}, Path("."), "develop", False, token)
        self.assertEqual(captured[0]["AGENTFLOW_STAGE_ATTEMPT_TOKEN"], token)

    def test_sigint_and_sigterm_are_recorded_as_interrupted_and_stop_following_checks(self):
        for name in ("SIGINT", "SIGTERM"):
            with self.subTest(signal=name), tempfile.TemporaryDirectory() as temp:
                root = Path(temp); feature = self.make_feature(root, [
                    {"id": ident, "argv": ["true"], "depends_on": [], "isolation": "isolated",
                     "state_reads": [], "state_writes": []} for ident in ("first", "second")])
                signum = getattr(stage_checks.signal, name)
                called = []
                def fake(check, _root, _stage, _reuse, _attempt_token=None):
                    called.append(check["id"])
                    stage_checks.signal.raise_signal(signum)
                    return {"status": "passed", "elapsed_ms": 1, "category": None,
                            "evidence": None, "exit_code": 0}
                with patch.object(stage_checks, "_safe_command", fake):
                    self.assertEqual(stage_checks.run_stage(root, feature, "qa"), 130 if name == "SIGINT" else 130)
                self.assertEqual(called, ["first"])
                rows = json.loads((root / ".agentflow/runs/checks/stage-journals/feature/qa.json").read_text())["checks"]
                self.assertEqual([row["status"] for row in rows], ["passed", "interrupted"])


class StageSummaryTest(unittest.TestCase):
    def test_safe_command_and_stage_summary_preserve_complete_profile_details(self):
        import subprocess as subprocess_module
        from pathlib import Path
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / 'feature'; feature.mkdir()
            (feature / 'spec.md').write_text('FR-001\n')
            (feature / 'verification.json').write_text(json.dumps({
                'schema_version': 1, 'runtime_required': False,
                'checks': [{'id': 'ci_profiles', 'argv': ['true']}],
                'coverage': {'FR-001': ['ci_profiles']},
            }))
            detail = {'id': 'a' * 24, 'runner': 'python', 'file': 'test/scripts/example_test.py',
                      'case_id': 'redacted', 'profile': 'unit', 'state': 'failed', 'cause': 'assertion',
                      'failure_line': 41, 'started': 1, 'passed': 0, 'failed': 1, 'skipped': 0}
            summary = {'profile': 'unit', 'step': 'tests', 'started': 12, 'passed': 10,
                       'failed': 1, 'skipped': 1}
            payload = {'check': 'ci_profiles', 'exit_code': 1,
                       'evidence': '.agentflow/runs/checks/feature/failure.log',
                       'failure_diagnostics': {'profile_discrepancies': [detail,
                           {'id': 'b' * 24, 'runner': 'python', 'file': 'test/private_test.py',
                            'case_id': 'private-case', 'profile': 'unit', 'state': 'secret',
                            'cause': 'private', 'failure_line': 1, 'started': 1, 'passed': 0,
                            'failed': 1, 'skipped': 0}],
                           'profile_event_summaries': [summary,
                               {'profile': 'unit', 'step': 'private', 'started': 1, 'passed': 0,
                                'failed': 1, 'skipped': 0}],
                           'raw': 'PROFILE-DETAIL-SECRET-CANARY'}}
            completed = subprocess_module.CompletedProcess([], 1, json.dumps(payload) + '\n', '')
            with patch.object(stage_checks.subprocess, 'run', return_value=completed):
                command = stage_checks._safe_command({'id': 'ci_profiles'}, root, 'develop', False)
            self.assertEqual(command['profile_discrepancies'], [detail])
            self.assertEqual(command['profile_event_summaries'], [summary])
            self.assertNotIn('PROFILE-DETAIL-SECRET-CANARY', json.dumps(command))
            journal = root / '.agentflow/runs/checks/stage-journals/feature/develop.json'
            journal.parent.mkdir(parents=True)
            journal.write_text(json.dumps({'stage': 'develop', 'checks': [
                {'id': 'ci_profiles', **command}]}))
            row = stage_checks.summarize_stage(root, feature, 'develop')['checks'][0]
            self.assertEqual(row['profile_discrepancies'], [detail])
            self.assertEqual(row['profile_event_summaries'], [summary])
            self.assertNotIn('PROFILE-DETAIL-SECRET-CANARY', json.dumps(row))

    def test_stage_summary_recovers_registered_event_summary_from_safe_evidence(self):
        from pathlib import Path
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / 'feature'; feature.mkdir()
            (feature / 'spec.md').write_text('FR-001\n')
            (feature / 'verification.json').write_text(json.dumps({
                'schema_version': 1, 'runtime_required': False,
                'checks': [{'id': 'ci_profiles', 'argv': ['true']}],
                'coverage': {'FR-001': ['ci_profiles']},
            }))
            inventory = root / 'config/test_profiles.json'; inventory.parent.mkdir()
            inventory.write_text(json.dumps({'schema_version': 1, 'entries': []}))
            evidence = root / '.agentflow/runs/checks/feature/failure.log'; evidence.parent.mkdir(parents=True)
            evidence.write_text('PROFILE_EVENT_SUMMARY profile=integration step=tests started=4 passed=3 failed=1 skipped=0\n'
                                'PROFILE_EVENT_SUMMARY profile=unit step=private started=99 passed=99 failed=0 skipped=0\n')
            journal = root / '.agentflow/runs/checks/stage-journals/feature/develop.json'
            journal.parent.mkdir(parents=True)
            journal.write_text(json.dumps({'stage': 'develop', 'checks': [
                {'id': 'ci_profiles', 'status': 'failed',
                 'evidence': '.agentflow/runs/checks/feature/failure.log'}]}))
            row = stage_checks.summarize_stage(root, feature, 'develop')['checks'][0]
            self.assertEqual(row['profile_event_summaries'], [
                {'profile': 'integration', 'step': 'tests', 'started': 4, 'passed': 3,
                 'failed': 1, 'skipped': 0}])

    def test_summary_maps_only_registered_profile_case_and_safe_category(self):
        import hashlib
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            (feature / "spec.md").write_text("FR-001\n")
            (feature / "verification.json").write_text(json.dumps({
                "schema_version": 1, "runtime_required": False,
                "checks": [{"id": "ci_profiles", "argv": ["true"]}],
                "coverage": {"FR-001": ["ci_profiles"]},
            }))
            runner, file, case_id, profile = "python", "test/scripts/example_test.py", "test.scripts.example_test.Example.test_case", "unit"
            ident = hashlib.sha256("\0".join((runner, file, case_id)).encode()).hexdigest()[:24]
            oversized_case = "test.scripts.example_test.Example.test_oversized_line"
            oversized_ident = hashlib.sha256("\0".join((runner, file, oversized_case)).encode()).hexdigest()[:24]
            inventory = root / "config/test_profiles.json"; inventory.parent.mkdir()
            inventory.write_text(json.dumps({"schema_version": 1, "entries": [
                {"id": ident, "runner": runner, "file": file, "case_id": case_id, "profile": profile},
                {"id": oversized_ident, "runner": runner, "file": file,
                 "case_id": oversized_case, "profile": profile}]}))
            evidence = root / ".agentflow/runs/checks/feature/failure.log"; evidence.parent.mkdir(parents=True)
            evidence.write_text(f"PROFILE_DISCREPANCY id={ident} line=41\n"
                                f"PROFILE_DISCREPANCY id={ident} line=1000001\n"
                                f"PROFILE_DISCREPANCY id={oversized_ident} line=1000001\n"
                                "PROFILE_DISCREPANCY id=aaaaaaaaaaaaaaaaaaaaaaaa line=91\n"
                                "PROFILE_BROWSER_DIAGNOSTIC cause=dependency-missing stage=integration\n"
                                "PROFILE_BROWSER_DIAGNOSTIC cause=secret-canary stage=integration\n"
                                "PROFILE_MEMBERSHIP_DIAGNOSTIC profile=unit phase=nonce-validation reason=nonce-mismatch expected=9 observed=9 missing_started=0 missing_passed=0 extra=0 duplicate=0 invalid_state=0 wrong_nonce=2\n"
                                "PROFILE_MEMBERSHIP_DIAGNOSTIC profile=unit phase=nonce-validation reason=secret-canary expected=9 observed=9 missing_started=0 missing_passed=0 extra=0 duplicate=0 invalid_state=0 wrong_nonce=2\n"
                                "PROFILE_MEMBERSHIP_EXTRA profile=unit runner=python file=test/scripts/example_test.py\n"
                                "PROFILE_MEMBERSHIP_EXTRA profile=unit runner=python file=test/private_test.py\n"
                                "CP1_PROFILE_OUTCOME status=failed category=test-failure\n"
                                "RAW-TRACE-CANARY\n")
            journal = root / ".agentflow/runs/checks/stage-journals/feature/develop.json"
            journal.parent.mkdir(parents=True)
            journal.write_text(json.dumps({"stage": "develop", "checks": [
                {"id": "ci_profiles", "status": "failed", "elapsed_ms": 12,
                 "evidence": ".agentflow/runs/checks/feature/failure.log"}]}))
            row = stage_checks.summarize_stage(root, feature, "develop")["checks"][0]
            self.assertEqual(row["profile_discrepancies"], [{"id": ident, "runner": runner,
                "file": file, "case_id": case_id, "profile": profile, "failure_line": 41}])
            self.assertEqual(row["profile_categories"], ["test-failure"])
            self.assertEqual(row["profile_browser_diagnostics"],
                             [{"cause": "dependency-missing", "stage": "integration"}])
            self.assertEqual(row["profile_membership_diagnostics"], [{"profile": "unit",
                "phase": "nonce-validation", "reason": "nonce-mismatch", "expected": 9, "observed": 9,
                "missing_started": 0, "missing_passed": 0, "extra": 0, "duplicate": 0,
                "invalid_state": 0, "wrong_nonce": 2}])
            self.assertEqual(row["profile_membership_extra_sources"], [{"profile": "unit",
                "runner": "python", "file": "test/scripts/example_test.py"}])
            self.assertNotIn("RAW-TRACE-CANARY", json.dumps(row))
            self.assertNotIn("aaaaaaaaaaaaaaaaaaaaaaaa", json.dumps(row))
            self.assertNotIn(oversized_ident, json.dumps(row))

    def test_safe_command_preserves_only_allowlisted_browser_cause(self):
        import subprocess as subprocess_module
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            payload = {"check": "ci_profiles", "exit_code": 1,
                "evidence": ".agentflow/runs/checks/feature/failure.log",
                "failure_diagnostics": {"profile_browser_diagnostics": [
                    {"cause": "launch-failed", "stage": "integration"}],
                    "raw": "RAW-DETAIL-CANARY"}}
            completed = subprocess_module.CompletedProcess([], 1, json.dumps(payload) + "\n", "")
            with patch.object(stage_checks.subprocess, "run", return_value=completed):
                result = stage_checks._safe_command({"id": "ci_profiles"}, root, "develop", False)
            self.assertEqual(result["profile_browser_diagnostics"],
                             [{"cause": "launch-failed", "stage": "integration"}])
            self.assertNotIn("RAW-DETAIL-CANARY", json.dumps(result))

    def test_summary_exposes_only_registered_ids_and_safe_allowlisted_fields(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            (feature / "spec.md").write_text("FR-001\n")
            (feature / "verification.json").write_text(json.dumps({
                "schema_version": 1, "runtime_required": False,
                "checks": [{"id": "known", "argv": ["true"]}],
                "coverage": {"FR-001": ["known"]},
            }))
            journal = root / ".agentflow/runs/checks/stage-journals/feature/develop.json"
            journal.parent.mkdir(parents=True)
            journal.write_text(json.dumps({"stage": "develop", "checks": [
                {"id": "known", "status": "failed", "category": "secret-error-message",
                 "diagnostic": {"category": "check-failed", "raw": "CANARY-DO-NOT-LEAK"},
                 "elapsed_ms": 23, "evidence": ".agentflow/runs/checks/feature/failure.log",
                 "stdout": "CANARY-DO-NOT-LEAK"},
                {"id": "unregistered-secret-id", "status": "passed", "evidence": "secret"},
            ]}))
            result = stage_checks.summarize_stage(root, feature, "develop")
            encoded = json.dumps(result)
            self.assertEqual(result["checks"], [{"id": "known", "status": "failed",
                "category": "check-failed", "elapsed_ms": 23,
                "evidence": ".agentflow/runs/checks/feature/failure.log"}])
            self.assertNotIn("CANARY-DO-NOT-LEAK", encoded)
            self.assertNotIn("unregistered-secret-id", encoded)


class CiParityTest(unittest.TestCase):
    def test_ci_parity_accepts_unit_and_integration_profile_pair_and_rejects_mismatch(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            feature = root / "feature"
            feature.mkdir()
            (feature / "spec.md").write_text("FR-001\n")
            (root / ".agentflow").mkdir()
            (root / ".specify/workflows/desapp-delivery").mkdir(parents=True)
            workflow = ('- id: ci_baseline\n  run: "python3 scripts/agentflow_stage_checks.py --ci-parity"\n')
            (root / ".agentflow/workflow.yml").write_text(workflow)
            (root / ".specify/workflows/desapp-delivery/workflow.yml").write_text(workflow)
            (root / ".github/workflows").mkdir(parents=True)
            (root / ".github/workflows/quality-baseline.yml").write_text("run: scripts/ci_unit_tests.sh\n")
            (root / "scripts").mkdir()
            (root / "scripts/ci_unit_tests.sh").write_text("for profile in unit integration; do :; done\n")
            fixture = root / "test/scripts"
            fixture.mkdir(parents=True)
            (fixture / "ci_unit_tests_test.sh").write_text("#!/bin/sh\nexit 0\n")
            data = {"schema_version": 1, "runtime_required": False, "checks": [
                {"id": "unit", "argv": ["mise", "exec", "--", "mix", "test.unit"],
                 "env": {"MIX_ENV": "test"}},
                {"id": "integration", "argv": ["mise", "exec", "--", "mix", "test.integration"],
                 "env": {"MIX_ENV": "test"}},
            ], "coverage": {"FR-001": ["unit", "integration"]}}
            (feature / "verification.json").write_text(json.dumps(data))
            with patch.object(stage_checks, "active_feature", return_value=feature):
                self.assertEqual(stage_checks.ci_parity(root)["profiles"], ["unit", "integration"])
                data["checks"][1]["argv"] = ["mise", "exec", "--", "mix", "test.unit"]
                (feature / "verification.json").write_text(json.dumps(data))
                with self.assertRaisesRegex(RuntimeError, "wrapper/profile obligation"):
                    stage_checks.ci_parity(root)

    def test_summary_fails_closed_for_bad_status_category_and_evidence(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            (feature / "spec.md").write_text("FR-001\n")
            (feature / "verification.json").write_text(json.dumps({"schema_version": 1,
                "runtime_required": False, "checks": [{"id": "known", "argv": ["true"]}],
                "coverage": {"FR-001": ["known"]}}))
            journal = root / ".agentflow/runs/checks/stage-journals/feature/develop.json"
            journal.parent.mkdir(parents=True)
            journal.write_text(json.dumps({"stage": "develop", "checks": [
                {"id": "known", "status": ["PASS-with-secret"], "category": ["private"],
                 "elapsed_ms": -3, "evidence": "../../private.log"}]}))
            self.assertEqual(stage_checks.summarize_stage(root, feature, "develop")["checks"],
                [{"id": "known", "status": "unexecuted", "category": None,
                  "elapsed_ms": None, "evidence": None}])

    def test_real_signal_exit_codes_are_nonzero_and_classified_interrupted(self):
        for name in ("SIGINT", "SIGTERM"):
            with self.subTest(signal=name), tempfile.TemporaryDirectory() as temp:
                root = Path(temp); scripts = root / "scripts"; scripts.mkdir()
                signum = getattr(signal, name)
                (scripts / "agentflow_check.py").write_text(
                    f"import os, signal\nos.kill(os.getpid(), {signum})\n")
                result = stage_checks._safe_command({"id": "signal-fixture"}, root, "qa", False)
                self.assertNotEqual(result["exit_code"], 0)
                self.assertEqual(result["status"], "interrupted")


if __name__ == "__main__":
    unittest.main()
