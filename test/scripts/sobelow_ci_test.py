import copy
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("sobelow_ci", ROOT / "scripts/sobelow_ci.py")
control = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(control)
SUMMARY_SPEC = importlib.util.spec_from_file_location("quality_summary", ROOT / "scripts/quality_summary.py")
summary = importlib.util.module_from_spec(SUMMARY_SPEC)
SUMMARY_SPEC.loader.exec_module(summary)


class SobelowCiTest(unittest.TestCase):
    def summary_fixture(self, root, revision):
        def write_json(relative, value):
            path = root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(json.dumps(value))
            return path

        write_json("tmp/credo-ci/evidence.json", {
            "revision": revision, "complete": True, "status": "passed", "errors": [],
            "credo_version": "1.7.19", "rule_level": "default-priority", "effective": ["lib/a.ex"],
            "cli_exit_status": 0, "oracle_exit_status": 0, "source_digest": "a" * 64
        })
        (root / "tmp/credo-ci/cli.log").write_text(
            "lib/a.ex:2:3: warning: sample [Credo.Check.Warning.Sample]\n")
        write_json("tmp/sobelow-ci/evidence.json", {
            "revision": revision, "status": "passed", "sobelow_version": control.VERSION,
            "errors": [], "scan": {"discovered": 1, "scanned": 1, "ignored": 0,
                                     "unreadable": 0, "unparseable": 0, "pending": 0},
            "accepted": [], "blocking": []
        })
        write_json("tmp/dialyzer-ci/summary.json", {
            "revision": revision, "status": "passed",
            "versions": {"otp": "29.0.6", "elixir": "1.20.3", "dialyzer": "6.0.2", "dialyxir": "1.4.8"}
        })
        for profile in ("dev", "test"):
            for phase in ("model", "application"):
                write_json(f"tmp/dialyzer-ci/{profile}/{phase}/evidence.json", {
                    "status": "passed", "errors": [], "files": 1, "accepted": [], "blocking": []
                })
        report = {
            "head": revision, "status": "complete", "run_id": "11111111-1111-4111-8111-111111111111",
            "snapshot_digest": "b" * 64, "toolchain": {"elixir": "Elixir 1.20.3 / OTP 29.0.6"},
            "totals": {"covered": 1, "uncovered": 1, "executable": 2, "percentage": 50.0},
            "included": [{"path": "lib/a.ex"}]
        }
        report_path = write_json("cover/application/runs/11111111-1111-4111-8111-111111111111/report.json", report)
        write_json("cover/application/status.json", {
            "state": "complete", "run_id": report["run_id"], "snapshot_digest": report["snapshot_digest"],
            "report_path": f"runs/{report['run_id']}/report.json",
            "report_sha256": hashlib.sha256(report_path.read_bytes()).hexdigest()
        })
        env = {"QUALITY_REVISION": revision, "GITHUB_REPOSITORY": "owner/project",
               "CREDO_OUTCOME": "success", "SOBELOW_OUTCOME": "success", "DIALYZER_OUTCOME": "success",
               "APPLICATION_COVERAGE_OUTCOME": "success", "UNIT_OUTCOME": "success",
               "PROFILE_RECEIPTS_OUTCOME": "success",
               "CREDO_ARTIFACT_URL": "https://github.com/owner/project/actions/runs/1/artifacts/1",
               "CREDO_ARTIFACT_OUTCOME": "success", "SOBELOW_ARTIFACT_OUTCOME": "success",
               "DIALYZER_ARTIFACT_OUTCOME": "success", "COVERAGE_ARTIFACT_OUTCOME": "success",
               "SOBELOW_ARTIFACT_URL": "https://github.com/owner/project/actions/runs/1/artifacts/2",
               "DIALYZER_ARTIFACT_URL": "https://github.com/owner/project/actions/runs/1/artifacts/3",
               "COVERAGE_ARTIFACT_URL": "https://github.com/owner/project/actions/runs/1/artifacts/4"}
        return env

    def test_summary_combines_current_analyzer_and_coverage_reports(self):
        revision = "0123456789abcdef0123456789abcdef01234567"
        with tempfile.TemporaryDirectory(prefix="quality-summary-complete-") as directory:
            root = Path(directory)
            env = self.summary_fixture(root, revision)
            sobelow_report = root / "tmp/sobelow-ci/evidence.json"
            sobelow = json.loads(sobelow_report.read_text())
            sobelow["accepted"] = [{"file": "lib/a.ex", "line": 2,
                                    "type": "Reviewed.Rule: controlled finding"}]
            sobelow_report.write_text(json.dumps(sobelow))
            rendered = summary.render(env, root)
            self.assertIn("Required analysis result: Approved", rendered)
            self.assertIn(f"/blob/{revision}/lib/a.ex#L2", rendered)
            self.assertIn("Reviewed.Rule: controlled finding", rendered)
            self.assertIn("Credo.Check.Warning.Sample", rendered)
            self.assertIn("TASK-067 coverage | Approved", rendered)
            self.assertIn("https://github.com/owner/project/actions/runs/1/artifacts/4", rendered)

    def test_publisher_appends_summary_and_fails_closed_on_nonapproved_result(self):
        with tempfile.TemporaryDirectory(prefix="quality-summary-output-") as directory:
            destination = Path(directory) / "summary.md"
            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(destination)}), \
                    patch.object(summary, "render", return_value="Required analysis result: Approved\n"):
                self.assertEqual(summary.main(), 0)
            self.assertIn("Required analysis result: Approved", destination.read_text())

            with patch.dict(os.environ, {"GITHUB_STEP_SUMMARY": str(destination)}), \
                    patch.object(summary, "render", return_value="Required analysis result: Failed closed\n"):
                self.assertEqual(summary.main(), 1)
            self.assertIn("Required analysis result: Failed closed", destination.read_text())

    def test_native_credo_findings_with_optional_positions_reach_summary(self):
        result = subprocess.run([
            "mix", "run", "--no-start", "-e", '''
Application.ensure_all_started(:credo)
source = Credo.SourceFile.parse("defmodule ProbeTest do\\nend\\n", "test/probe_test.ex")
[issue] = Credo.Check.Warning.WrongTestFileExtension.run(source)
Enum.each([issue, %{issue | column: 4}, %{issue | line_no: nil, column: nil}], fn finding ->
  IO.puts(Credo.CLI.Output.Formatter.Flycheck.to_flycheck(finding))
end)
'''], cwd=ROOT, env={**os.environ, "MIX_ENV": "test"},
            capture_output=True, text=True, timeout=120, check=True)
        native_lines = [line for line in result.stdout.splitlines()
                        if line.startswith("test/probe_test.ex")]
        self.assertEqual(len(native_lines), 3)
        self.assertTrue(native_lines[0].startswith("test/probe_test.ex:1: W:"))
        revision = "0123456789abcdef0123456789abcdef01234567"
        with tempfile.TemporaryDirectory(prefix="quality-summary-credo-") as directory:
            root = Path(directory)
            env = self.summary_fixture(root, revision)
            report = root / "tmp/credo-ci/evidence.json"
            evidence = json.loads(report.read_text())
            evidence.update(status="failed", errors=["standard-credo-cli-failed"], cli_exit_status=1)
            report.write_text(json.dumps(evidence))
            env["CREDO_OUTCOME"] = "failure"
            for line in native_lines:
                with self.subTest(native=line):
                    (root / "tmp/credo-ci/cli.log").write_text(line + "\n")
                    rendered = summary.render(env, root)
                    self.assertIn("Credo | Failed due to findings", rendered)
                    self.assertIn(f"/blob/{revision}/test/probe_test.ex", rendered)
                    self.assertIn("rule unavailable; warning kind W", rendered)
                    self.assertIn("Required analysis result: Failed closed", rendered)
                    if ":1:" in line:
                        self.assertIn("test/probe_test.ex#L1", rendered)
                    else:
                        self.assertIn("line unavailable", rendered)

    def test_analyzer_error_reports_preserve_other_outcomes_and_artifacts(self):
        revision = "0123456789abcdef0123456789abcdef01234567"
        mutations = [
            ("Sobelow missing successful report", "tmp/sobelow-ci/evidence.json", None,
             "SOBELOW_OUTCOME", "success", "Sobelow", "missing-or-malformed-report"),
            ("Sobelow timeout", "tmp/sobelow-ci/evidence.json", {
                "revision": revision, "status": "failed", "sobelow_version": control.VERSION,
                "errors": ["TimeoutExpired"], "accepted": [], "blocking": []
            }, "SOBELOW_OUTCOME", "failure", "Sobelow", "TimeoutExpired"),
            ("Sobelow malformed output", "tmp/sobelow-ci/evidence.json", {
                "revision": revision, "status": "failed", "sobelow_version": control.VERSION,
                "errors": ["missing-summary-or-analyzer-diagnostics"], "accepted": [], "blocking": []
            }, "SOBELOW_OUTCOME", "failure", "Sobelow", "missing-summary-or-analyzer-diagnostics"),
            ("Credo incomplete", "tmp/credo-ci/evidence.json", {
                "revision": revision, "status": "failed", "complete": False,
                "errors": ["oracle-incomplete"], "credo_version": "1.7.19"
            }, "CREDO_OUTCOME", "failure", "Credo", "oracle-incomplete"),
            ("Credo missing successful report", "tmp/credo-ci/evidence.json", None,
             "CREDO_OUTCOME", "success", "Credo", "missing-or-malformed-report"),
            ("Dialyzer missing summary", "tmp/dialyzer-ci/summary.json", None,
             "DIALYZER_OUTCOME", "failure", "Dialyzer", "missing-or-malformed-report"),
            ("Dialyzer phase error", "tmp/dialyzer-ci/dev/model/evidence.json", {
                "status": "error", "errors": ["TimeoutExpired"], "accepted": [], "blocking": []
            }, "DIALYZER_OUTCOME", "failure", "Dialyzer dev/model", "TimeoutExpired"),
            ("Dialyzer missing successful phase", "tmp/dialyzer-ci/dev/model/evidence.json", None,
             "DIALYZER_OUTCOME", "success", "Dialyzer dev/model", "missing-or-malformed-report"),
            ("Coverage malformed status", "cover/application/status.json", "{",
             "APPLICATION_COVERAGE_OUTCOME", "success", "TASK-067 coverage", "missing-or-malformed-report"),
        ]
        for name, path, report, outcome_key, step_outcome, label, diagnostic in mutations:
            with self.subTest(case=name), tempfile.TemporaryDirectory(prefix="quality-summary-error-") as directory:
                root = Path(directory)
                env = self.summary_fixture(root, revision)
                env[outcome_key] = step_outcome
                target = root / path
                if report is None:
                    target.unlink()
                elif isinstance(report, str):
                    target.write_text(report)
                else:
                    target.write_text(json.dumps(report))
                if name == "Dialyzer phase error":
                    dialyzer_path = root / "tmp/dialyzer-ci/summary.json"
                    dialyzer = json.loads(dialyzer_path.read_text())
                    dialyzer["status"] = "failed"
                    dialyzer_path.write_text(json.dumps(dialyzer))
                rendered = summary.render(env, root)
                self.assertIn(f"{label} | Analyzer execution/configuration error", rendered)
                self.assertIn(diagnostic, rendered)
                self.assertIn(f"Revision: `{revision}`", rendered)
                self.assertIn("Profile receipt verification | Approved", rendered)
                self.assertIn("### Retained reports", rendered)
                self.assertIn("https://github.com/owner/project/actions/runs/1/artifacts/4", rendered)
                self.assertIn("Required analysis result: Failed closed", rendered)
                self.assertNotIn("Required analysis result: Approved", rendered)
                if outcome_key != "CREDO_OUTCOME":
                    self.assertIn("Credo | Approved", rendered)
                if outcome_key != "APPLICATION_COVERAGE_OUTCOME":
                    self.assertIn("Coverage provenance:", rendered)
                if name == "Dialyzer phase error":
                    self.assertIn("Dialyzer dev/application | Approved", rendered)
                    self.assertIn("Dialyzer test/model | Approved", rendered)
                destination = root / "summary.md"
                renderer = summary.render
                with patch.dict(os.environ, {**env, "GITHUB_STEP_SUMMARY": str(destination)}, clear=True), \
                        patch.object(summary, "render", side_effect=lambda: renderer(env, root)):
                    self.assertEqual(summary.main(), 1)
                self.assertEqual(destination.read_text(), rendered)

    def test_failed_dialyzer_step_preserves_successful_phases_without_approving_gate(self):
        revision = "0123456789abcdef0123456789abcdef01234567"
        with tempfile.TemporaryDirectory(prefix="quality-summary-phase-") as directory:
            root = Path(directory)
            env = self.summary_fixture(root, revision)
            env["DIALYZER_OUTCOME"] = "failure"
            rendered = summary.render(env, root)
            self.assertIn("Dialyzer workflow step | Failed", rendered)
            for profile in ("dev", "test"):
                for phase in ("model", "application"):
                    self.assertIn(f"Dialyzer {profile}/{phase} | Approved", rendered)
            self.assertIn("Required analysis result: Failed closed", rendered)

    def test_summary_keeps_skipped_and_stale_evidence_nonpassing(self):
        revision = "0123456789abcdef0123456789abcdef01234567"
        env = {"GITHUB_SHA": revision, "GITHUB_REPOSITORY": "owner/project",
               "GITHUB_SERVER_URL": "https://github.com"}
        with tempfile.TemporaryDirectory(prefix="quality-summary-status-") as directory:
            root = Path(directory)
            rendered = summary.render(env, root)
            self.assertIn("Not executed/skipped", rendered)
            self.assertIn("Required analysis result: Failed closed", rendered)
            (root / "tmp/sobelow-ci").mkdir(parents=True)
            (root / "tmp/sobelow-ci/evidence.json").write_text(json.dumps({
                "revision": "fedcba9876543210fedcba9876543210fedcba98",
                "status": "passed", "scan": {"scanned": 1, "ignored": 0},
                "sobelow_version": control.VERSION, "errors": [], "accepted": [], "blocking": []
            }))
            env["SOBELOW_OUTCOME"] = "success"
            rendered = summary.render(env, root)
            self.assertIn("Sobelow | Analyzer execution/configuration error", rendered)
            self.assertIn("stale-or-incomplete-sobelow-report", rendered)
            self.assertIn("Required analysis result: Failed closed", rendered)
        linked = summary.finding_link("https://github.com", "owner/project", revision,
                                      {"file": "lib/a.ex", "line": 0})
        self.assertIn("line unavailable", linked)
        self.assertIn("rule/warning kind unavailable", linked)
        linked = summary.finding_link("https://github.com", "owner/project", revision,
                                      {"file": "lib/probe.ex", "line": 3,
                                       "type": "SQL.Query: SQL injection"})
        self.assertIn(f"/blob/{revision}/lib/probe.ex#L3", linked)
        self.assertIn("SQL.Query: SQL injection", linked)
        for path in ("/workspace/lib/probe.ex", "../lib/probe.ex", "lib/../probe.ex"):
            with self.subTest(path=path), self.assertRaises(summary.EvidenceError):
                summary.finding_link("https://github.com", "owner/project", revision,
                                     {"file": path, "line": 3})

    def test_finding_paths_normalize_the_configured_root_alias(self):
        with tempfile.TemporaryDirectory(prefix="sobelow-root-alias-") as directory:
            parent = Path(directory)
            actual_root = parent / "private-var-root"
            actual_root.mkdir()
            configured_root = parent / "var-root"
            configured_root.symlink_to(actual_root, target_is_directory=True)
            reported_path = str(configured_root).lstrip("/") + "/lib/probe.ex"
            unrelated_path = "workspace/lib/other.ex"

            normalized = control.normalize_finding_paths(
                [{"file": reported_path}, {"file": unrelated_path}], configured_root)

        self.assertEqual(normalized, [
            {"file": "lib/probe.ex"},
            {"file": unrelated_path},
        ])

    def test_real_finding_and_recovery_reach_the_pr_summary(self):
        revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
        with tempfile.TemporaryDirectory(prefix="quality-summary-control-") as directory:
            root = Path(directory)
            (root / "lib").mkdir(parents=True)
            (root / "mix.exs").write_text('''defmodule Probe.MixProject do
  use Mix.Project
  def project, do: [app: :probe, version: "0.1.0"]
end
''')
            (root / "mix.lock").write_text("%{}\n")
            (root / "lib/router.ex").write_text("defmodule Probe.Router do\n  use ProbeWeb, :router\nend\n")
            source = root / "lib/probe.ex"
            source.write_text('''defmodule Probe do
  def lookup(name) do
    Ecto.Adapters.SQL.query!(Repo, "SELECT id FROM users WHERE name = '#{name}'", [])
  end
end
''')
            evidence_dir = root / "tmp/sobelow-ci"
            self.assertEqual(control.analyze(root, evidence_dir), 1)
            unsafe = json.loads((evidence_dir / "evidence.json").read_text())
            unsafe["revision"] = revision
            (evidence_dir / "evidence.json").write_text(json.dumps(unsafe))
            env = {"GITHUB_SHA": revision, "GITHUB_REPOSITORY": "owner/project",
                   "GITHUB_SERVER_URL": "https://github.com", "SOBELOW_OUTCOME": "failure"}
            unsafe_summary = summary.render(env, root)
            self.assertIn("Sobelow | Failed due to findings", unsafe_summary)
            self.assertIn("lib/probe.ex:line 3", unsafe_summary)
            self.assertIn("SQL.Query: SQL injection", unsafe_summary)
            self.assertIn(f"/blob/{revision}/lib/probe.ex#L3", unsafe_summary)

            source.write_text('''defmodule Probe do
  def lookup(name) do
    Ecto.Adapters.SQL.query!(Repo, "SELECT id FROM users WHERE name = $1", [name])
  end
end
''')
            self.assertEqual(control.analyze(root, evidence_dir), 0)
            corrected = json.loads((evidence_dir / "evidence.json").read_text())
            corrected["revision"] = revision
            (evidence_dir / "evidence.json").write_text(json.dumps(corrected))
            env["SOBELOW_OUTCOME"] = "success"
            rendered = summary.render(env, root)
            self.assertIn("Sobelow | Approved", rendered)
            self.assertNotIn("Failed due to findings", rendered)
            controls = ROOT / "tmp/sobelow-ci/summary-controls.json"
            controls.parent.mkdir(parents=True, exist_ok=True)
            controls.write_text(json.dumps({
                "revision": revision,
                "run_id": os.environ.get("GITHUB_RUN_ID"),
                "run_attempt": os.environ.get("GITHUB_RUN_ATTEMPT"),
                "analyzer_version": control.VERSION,
                "unsafe": unsafe,
                "unsafe_summary": unsafe_summary,
                "corrected": corrected,
                "corrected_summary": rendered
            }, indent=2) + "\n")

    def test_real_analyzer_detection_recovery_and_execution_errors(self):
        with tempfile.TemporaryDirectory(prefix="sobelow-control-") as directory:
            root = Path(directory)
            (root / "lib").mkdir()
            (root / "mix.exs").write_text('''defmodule Probe.MixProject do
  use Mix.Project
  def project, do: [app: :probe, version: "0.1.0"]
end
''')
            (root / "mix.lock").write_text("%{}\n")
            (root / "lib/router.ex").write_text('''defmodule Probe.Router do
  use ProbeWeb, :router
end
''')
            source = root / "lib/probe.ex"
            source.write_text('''defmodule Probe do
  def lookup(name) do
    Ecto.Adapters.SQL.query!(Repo, "SELECT id FROM users WHERE name = '#{name}'", [])
  end
end
''')
            output = root / "evidence"
            self.assertEqual(control.analyze(root, output), 1)
            unsafe = json.loads((output / "evidence.json").read_text())
            self.assertEqual(unsafe["analyzer_exit_status"], 1)
            self.assertTrue(any(f["type"] == "SQL.Query: SQL injection" and f["line"] == 3
                                and f["file"].endswith("lib/probe.ex")
                                for f in unsafe["blocking"]))
            source.write_text('''defmodule Probe do
  def lookup(name) do
    Ecto.Adapters.SQL.query!(Repo, "SELECT id FROM users WHERE name = $1", [name])
  end
end
''')
            self.assertEqual(control.analyze(root, output), 0)
            safe = json.loads((output / "evidence.json").read_text())
            self.assertEqual(safe["analyzer_exit_status"], 0)
            self.assertEqual(safe["blocking"], [])
            self.assertNotEqual(safe["source_digest"], unsafe["source_digest"])
            source.write_text("defmodule Broken do\n def invalid(\nend\n")
            self.assertEqual(control.analyze(root, output), 1)
            broken = json.loads((output / "evidence.json").read_text())
            self.assertEqual(broken["status"], "failed")
            self.assertTrue(broken["errors"])
            self.assertNotEqual(broken["analyzer_exit_status"], 0)
            (root / ".sobelow-conf").write_text('[ignore: ["SQL"]]')
            self.assertEqual(control.analyze(root, output), 1)
            invalid = json.loads((output / "evidence.json").read_text())
            self.assertEqual(invalid["errors"], ["project-sobelow-configuration-not-permitted"])
            retained = ROOT / "tmp/sobelow-ci/controls.json"
            retained.parent.mkdir(parents=True, exist_ok=True)
            retained.write_text(json.dumps({"unsafe": unsafe, "corrected": safe,
                                            "invalid_source": broken, "invalid_config": invalid},
                                           indent=2) + "\n")

    def test_report_and_summary_fail_closed(self):
        report = {"sobelow_version": control.VERSION, "total_findings": 0,
                  "findings": {level: [] for level in control.LEVELS}}
        self.assertEqual(control.validate_report(report), [])
        mutations = [{}, {**report, "sobelow_version": "0.0.0"},
                     {**report, "total_findings": False}, {**report, "total_findings": 1},
                     {**report, "findings": {}}, {**report, "findings": []}]
        for bad in mutations:
            with self.subTest(report=bad), self.assertRaises(ValueError):
                control.validate_report(bad)
        for bad_line in (-1, True, "3", None):
            bad = copy.deepcopy(report)
            bad["total_findings"] = 1
            bad["findings"]["high_confidence"] = [{"type": "SQL.Query", "file": "a", "line": bad_line}]
            with self.subTest(line=bad_line), self.assertRaises(ValueError):
                control.validate_report(bad)
        summary = ("Scan summary: discovered: 3, scanned: 1, ignored: 2, "
                   "unreadable: 0, unparseable: 0, pending: 0\n")
        self.assertEqual(control.validate_summary(summary)["scanned"], 1)
        for bad in ("", "warning\n" + summary, summary.replace("scanned: 1", "scanned: 0"),
                    summary.replace("unreadable: 0", "unreadable: 1"),
                    summary.replace("unparseable: 0", "unparseable: 1"),
                    summary.replace("pending: 0", "pending: 1")):
            with self.subTest(summary=bad), self.assertRaises(ValueError):
                control.validate_summary(bad)

    def test_exception_requires_exact_rule_location_confidence_and_source_bytes(self):
        exception = control.EXCEPTIONS[0]
        finding = {k: v for k, v in exception.items() if k != "sha256"}
        sources = {exception["file"]: exception["sha256"]}
        self.assertEqual(control.classify([finding], sources), ([finding], []))
        for key, value in (("line", finding["line"] + 1), ("file", "lib/new.ex"),
                           ("type", "New.Rule"), ("confidence", "low_confidence")):
            changed = {**finding, key: value}
            self.assertEqual(control.classify([changed], sources), ([], [changed]))
        self.assertEqual(control.classify([finding], {exception["file"]: "changed"}), ([], [finding]))

    def test_workflow_requires_control_and_retains_evidence_in_existing_aggregate(self):
        ruby = '''require "yaml"; require "json";
d = YAML.safe_load(File.read(ARGV[0]), aliases: true); puts JSON.generate(d)'''
        workflow = json.loads(subprocess.check_output(
            ["ruby", "-e", ruby, str(ROOT / ".github/workflows/quality-baseline.yml")], text=True))
        job = workflow["jobs"]["quality-baseline"]
        step = next(s for s in job["steps"] if s.get("name") == "Sobelow security analysis")
        self.assertEqual(step["run"].splitlines(), ["python3 scripts/sobelow_ci.py",
                         "python3 -m unittest discover -s test/scripts -p sobelow_ci_test.py"])
        self.assertNotIn("if", step)
        self.assertNotIn("continue-on-error", step)
        upload = next(s for s in job["steps"] if s.get("name") == "Upload Sobelow evidence")
        self.assertEqual(upload["if"], "always()")
        self.assertEqual(upload["with"]["path"], "tmp/sobelow-ci/")
        self.assertEqual(upload["with"]["if-no-files-found"], "error")
        self.assertEqual(upload["with"]["retention-days"], 14)
        aggregate = workflow["jobs"]["thinflow-required"]
        self.assertIn("quality-baseline", aggregate["needs"])
        self.assertIn('[[ "$QUALITY_RESULT" == success ]]', aggregate["steps"][0]["run"])
        self.assertEqual(workflow["permissions"], {"contents": "read"})


if __name__ == "__main__":
    unittest.main()
