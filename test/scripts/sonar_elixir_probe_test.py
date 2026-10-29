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
            revision = "a" * 40
            report = {**sample_report(), "head": revision}
            report_path.write_text(json.dumps(report), encoding="utf-8")
            status_path = coverage_root / "status.json"
            status_path.write_text(json.dumps({"report_path": "runs/probe-run/report.json"}), encoding="utf-8")
            inventory_path = fixture / "credo_inventory.json"
            inventory_path.write_text(json.dumps({"maintained": ["lib/football_market/probe.ex"]}), encoding="utf-8")
            output = fixture / "probe-output"

            with (patch.object(probe, "STATUS", status_path),
                  patch.object(probe, "INVENTORY", inventory_path),
                  patch.object(probe, "verify_coverage"),
                  patch.object(probe.subprocess, "check_output", return_value=revision)):
                probe.build(output)

            metadata = json.loads((output / "probe.json").read_text(encoding="utf-8"))
            issue = (output / "external-issues.json").read_bytes()
            coverage = (output / "coverage.xml").read_bytes()
            application = (output / "application-coverage.json").read_bytes()
            self.assertEqual(metadata["coverage_source_revision"], revision)
            self.assertEqual(metadata["coverage_run_id"], "probe-run")
            self.assertEqual(metadata["external_issue_sha256"], hashlib.sha256(issue).hexdigest())
            self.assertEqual(metadata["coverage_report_sha256"], hashlib.sha256(coverage).hexdigest())
            self.assertEqual(metadata["application_coverage_report_sha256"], hashlib.sha256(application).hexdigest())

    def test_dispatch_requires_open_internal_task_branch_and_exact_head(self):
        repository = "owner/repository"
        ref = "refs/heads/069-verify-sonarcloud-external-elixir-report-compatibility"
        sha = "a" * 40
        pr = {"state": "open", "draft": False,
              "base": {"ref": "main", "repo": {"full_name": repository}},
              "head": {"ref": ref.removeprefix("refs/heads/"), "sha": sha,
                       "repo": {"full_name": repository}}}
        self.assertEqual(probe.validate_dispatch(repository, ref, sha, "67", pr)["revision"], sha)
        for changes in ({"state": "closed"}, {"head": {**pr["head"], "sha": "b" * 40}},
                        {"head": {**pr["head"], "repo": {"full_name": "fork/repository"}}}):
            bad = {**pr, **changes}
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                probe.validate_dispatch(repository, ref, sha, "67", bad)
        with self.assertRaisesRegex(ValueError, "probe-dispatch-refused"):
            probe.validate_dispatch(repository, "refs/heads/main", sha, "67", pr)

    def test_observation_binds_analysis_revision_and_reports_each_metric_delta(self):
        class Api:
            def get(self, path, params):
                if path == "/api/ce/task":
                    return {"task": {"id": "task-2", "componentKey": probe.PROJECT,
                                     "status": "SUCCESS", "analysisId": "analysis-2"}}
                if path == "/api/ce/component":
                    self_context = {"id": "task-2", "componentKey": probe.PROJECT,
                                    "pullRequest": "67", "status": "SUCCESS", "analysisId": "analysis-2"}
                    return {"current": self_context, "queue": []}
                if path == "/api/project_pull_requests/list":
                    return {"pullRequests": [{"key": "67", "commit": {"sha": "a" * 40},
                                              "analysisDate": "now"}]}
                if path == "/api/measures/component":
                    return {"component": {"key": probe.PROJECT, "measures": [
                        {"metric": key, "value": "72" if key == "coverage" else "1"}
                        for key in probe.METRICS]}}
                if path == "/api/issues/search":
                    return {"issues": [{"message": "TASK-069 controlled probe; synthetic"}]}
                raise AssertionError(path)

        with tempfile.TemporaryDirectory() as directory:
            task_file = Path(directory) / "report-task.txt"
            task_file.write_text("ceTaskId=task-2\n", encoding="utf-8")
            baseline = {"stage": "control", "revision": "a" * 40, "pull_request": 67,
                        "analysis": {"status": "verified", "revision": "a" * 40},
                        "measures": {key: {"status": "observed", "value": "0"}
                                     for key in probe.METRICS}}
            result = probe.observe("issue", 67, "a" * 40, task_file, "success", "secret", baseline, Api())

            class MissingMetric(Api):
                def get(self, path, params):
                    if path == "/api/measures/component" and params["metricKeys"] == "bugs":
                        raise OSError("metric-unavailable")
                    return super().get(path, params)

            partial = probe.observe("issue", 67, "a" * 40, task_file, "success", "secret",
                                    baseline, MissingMetric())
            stale_control = probe.observe("issue", 67, "a" * 40, task_file, "success", "secret",
                                          {**baseline, "revision": "b" * 40}, Api())

            class ReplacedAnalysis(Api):
                replaced = False

                def get(self, path, params):
                    document = super().get(path, params)
                    if path == "/api/measures/component":
                        self.replaced = True
                        document["component"]["measures"] = [{"metric": params["metricKeys"], "value": "99"}]
                    if path == "/api/ce/component" and self.replaced:
                        document["current"].update(id="task-3", analysisId="analysis-3")
                    return document

            class ReplacedRevision(ReplacedAnalysis):
                def get(self, path, params):
                    document = super().get(path, params)
                    if path == "/api/project_pull_requests/list" and self.replaced:
                        document["pullRequests"][0]["commit"]["sha"] = "b" * 40
                    return document

            class UnavailableFinalIdentity(ReplacedAnalysis):
                def get(self, path, params):
                    if path == "/api/ce/component" and self.replaced:
                        raise OSError("identity-unavailable")
                    return super().get(path, params)

            for api in (ReplacedAnalysis(), ReplacedRevision(), UnavailableFinalIdentity()):
                with self.subTest(replacement=type(api).__name__):
                    replaced = probe.observe("issue", 67, "a" * 40, task_file, "success", "secret",
                                             baseline, api)
                    self.assertEqual(replaced["analysis"]["status"], "unverified")
                    self.assertEqual(replaced["issue"]["status"], "unverified")
                    self.assertTrue(all(item["status"] == "unverified" and "value" not in item
                                        and item["comparison"] == "unverified"
                                        for item in replaced["measures"].values()))
        self.assertEqual(result["analysis"]["status"], "verified")
        self.assertEqual(result["issue"]["status"], "observed")
        self.assertEqual(result["measures"]["coverage"]["comparison"], "changed")
        self.assertEqual(result["measures"]["ncloc"]["comparison"], "changed")
        self.assertEqual(partial["measures"]["bugs"]["status"], "unverified")
        self.assertEqual(partial["measures"]["coverage"]["comparison"], "changed")
        self.assertTrue(all(item["comparison"] == "unverified"
                            for item in stale_control["measures"].values()))

    def test_observation_refuses_a_nonmatching_analysis_revision_and_marks_comparison_unverified(self):
        class Api:
            def get(self, path, params):
                if path == "/api/ce/task":
                    return {"task": {"id": "task-old", "componentKey": probe.PROJECT,
                                     "status": "SUCCESS", "analysisId": "analysis-old"}}
                if path == "/api/ce/component":
                    return {"current": {"id": "task-old", "componentKey": probe.PROJECT,
                                        "pullRequest": "67", "status": "SUCCESS",
                                        "analysisId": "analysis-old"}, "queue": []}
                if path == "/api/project_pull_requests/list":
                    return {"pullRequests": [{"key": "67", "commit": {"sha": "b" * 40}}]}
                raise AssertionError("stale analysis must stop further queries")

        with tempfile.TemporaryDirectory() as directory:
            task_file = Path(directory) / "report-task.txt"
            task_file.write_text("ceTaskId=task-old\n", encoding="utf-8")
            result = probe.observe("coverage", 67, "a" * 40, task_file, "success", "secret",
                                   {"measures": {}}, Api())
        self.assertEqual(result["analysis"]["reason"], "analysis-revision-mismatch")
        self.assertTrue(all(item["comparison"] == "unverified" for item in result["measures"].values()))


if __name__ == "__main__":
    unittest.main()
