import copy
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("sobelow_ci", ROOT / "scripts/sobelow_ci.py")
control = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(control)


class SobelowCiTest(unittest.TestCase):
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
