import importlib.util
import hashlib
import json
import tempfile
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("sonar_elixir_probe", ROOT / "scripts/sonar_elixir_probe.py")
probe = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(probe)


def sample_report():
    return {
        "schema_version": 1,
        "status": "complete",
        "run_id": "probe-run",
        "snapshot_digest": "source-snapshot",
        "included": [{
            "path": "lib/football_market/probe.ex",
            "executable": 3,
            "covered": 2,
            "executable_lines": [4, 9, 15],
            "covered_lines": [4, 15],
        }],
    }


class SonarElixirProbeTest(unittest.TestCase):
    def test_coverage_adapter_emits_generic_report_from_unique_application_lines(self):
        document = ET.fromstring(probe.render_coverage(sample_report()))
        self.assertEqual(document.tag, "coverage")
        self.assertEqual(document.attrib, {"version": "1"})
        file = document.find("file")
        self.assertEqual(file.attrib, {"path": "lib/football_market/probe.ex"})
        self.assertEqual(
            [(line.attrib["lineNumber"], line.attrib["covered"]) for line in file.findall("lineToCover")],
            [("4", "true"), ("9", "false"), ("15", "true")],
        )

    def test_external_issue_is_an_explicit_synthetic_credo_path_probe(self):
        rendered, path, line = probe.render_issue(
            {"maintained": ["lib/football_market/probe.ex"]}, sample_report()
        )
        issue_report = json.loads(rendered)
        self.assertEqual((path, line), ("lib/football_market/probe.ex", 4))
        self.assertEqual(issue_report["issues"][0]["ruleId"], "TASK-069-PROBE")
        location = issue_report["issues"][0]["primaryLocation"]
        self.assertEqual(location["filePath"], path)
        self.assertEqual(location["textRange"]["startLine"], line)
        self.assertIn("not a Credo finding", location["message"])
        self.assertEqual(issue_report["rules"][0]["engineId"], "credo-task-069-probe")

    def test_invalid_and_coercible_line_numbers_are_rejected(self):
        for bad_line in (True, 0, -1, "4"):
            with self.subTest(line=bad_line):
                report = sample_report()
                report["included"][0]["executable_lines"] = [bad_line]
                report["included"][0]["covered_lines"] = []
                with self.assertRaises(ValueError):
                    probe.render_coverage(report)

    def test_duplicate_or_foreign_coverage_lines_are_rejected(self):
        for executable, covered in (([4, 4], [4]), ([4], [9])):
            with self.subTest(executable=executable, covered=covered):
                report = sample_report()
                report["included"][0]["executable_lines"] = executable
                report["included"][0]["covered_lines"] = covered
                with self.assertRaises(ValueError):
                    probe.render_coverage(report)

    def test_probe_source_must_be_in_credo_inventory_and_application_report(self):
        with self.assertRaisesRegex(ValueError, "no-covered-credo-source-for-probe"):
            probe.render_issue({"maintained": ["lib/not-measured.ex"]}, sample_report())

    def test_build_binds_generated_reports_to_coverage_snapshot_and_hashes(self):
        with tempfile.TemporaryDirectory(prefix="task069-probe-", dir=ROOT / "tmp") as directory:
            fixture = Path(directory)
            coverage_root = fixture / "cover/application"
            report_path = coverage_root / "runs/probe-run/report.json"
            report_path.parent.mkdir(parents=True)
            report = {**sample_report(), "head": "coverage-source-revision"}
            report_path.write_text(json.dumps(report), encoding="utf-8")
            status_path = coverage_root / "status.json"
            status_path.write_text(json.dumps({"report_path": "runs/probe-run/report.json"}), encoding="utf-8")
            inventory_path = fixture / "credo_inventory.json"
            inventory_path.write_text(json.dumps({"maintained": ["lib/football_market/probe.ex"]}), encoding="utf-8")
            output = fixture / "probe-output"

            with (patch.object(probe, "STATUS", status_path),
                  patch.object(probe, "INVENTORY", inventory_path),
                  patch.object(probe, "verify_coverage")):
                probe.build(output)

            metadata = json.loads((output / "probe.json").read_text(encoding="utf-8"))
            issue = (output / "external-issues.json").read_bytes()
            coverage = (output / "coverage.xml").read_bytes()
            self.assertEqual(metadata["coverage_source_revision"], "coverage-source-revision")
            self.assertEqual(metadata["coverage_run_id"], "probe-run")
            self.assertEqual(metadata["external_issue_sha256"], hashlib.sha256(issue).hexdigest())
            self.assertEqual(metadata["coverage_report_sha256"], hashlib.sha256(coverage).hexdigest())


if __name__ == "__main__":
    unittest.main()
