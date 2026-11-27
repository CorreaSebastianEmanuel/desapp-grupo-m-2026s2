import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location(
    "sonar_elixir_reports", ROOT / "scripts/sonar_elixir_reports.py"
)
MOD = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MOD)


class SonarElixirReportsTest(unittest.TestCase):
    def test_empty_credo_and_sobelow_produce_valid_empty_generic_report(self):
        credo = {"issues": []}
        sobelow = {
            "sobelow_version": "0.18.1",
            "total_findings": 0,
            "findings": {"high_confidence": [], "medium_confidence": [], "low_confidence": []},
        }
        report = MOD.merge_generic_issues(credo, sobelow, sources={})
        self.assertEqual(report, {"rules": [], "issues": []})

    def test_converts_credo_and_blocking_sobelow_findings_and_skips_non_lib_paths(self):
        credo = {
            "issues": [
                {
                    "check": "Credo.Check.Warning.UnusedEnumOperation",
                    "category": "warning",
                    "filename": "lib/football_market/ranking.ex",
                    "line_no": 42,
                    "message": "There should be no unused return values here.",
                    "priority": 20,
                },
                {
                    "check": "Credo.Check.Readability.ModuleDoc",
                    "category": "readability",
                    "filename": "test/ranking_test.exs",
                    "line_no": 1,
                    "message": "Skipped because it is outside lib/.",
                    "priority": 5,
                },
            ]
        }
        sobelow = {
            "sobelow_version": "0.18.1",
            "total_findings": 1,
            "findings": {
                "high_confidence": [
                    {
                        "type": "SQL.Query: SQL injection",
                        "file": "lib/football_market/catalog.ex",
                        "line": 120,
                    }
                ],
                "medium_confidence": [],
                "low_confidence": [],
            },
        }
        report = MOD.merge_generic_issues(
            credo,
            sobelow,
            sources={"lib/football_market/catalog.ex": "0" * 64},
            include_accepted=False,
        )
        self.assertEqual(len(report["rules"]), 2)
        self.assertEqual(len(report["issues"]), 2)

        rule_ids = {r["id"] for r in report["rules"]}
        self.assertEqual(
            rule_ids,
            {
                "credo:credo_check_warning_unusedenumoperation",
                "sobelow:sql_query_sql_injection",
            },
        )
        credo_issue = next(i for i in report["issues"] if i["ruleId"].startswith("credo:"))
        self.assertEqual(credo_issue["primaryLocation"]["filePath"], "lib/football_market/ranking.ex")
        self.assertEqual(credo_issue["primaryLocation"]["textRange"], {"startLine": 42})

        sobelow_rule = next(r for r in report["rules"] if r["id"].startswith("sobelow:"))
        self.assertEqual(sobelow_rule["impacts"], [{"softwareQuality": "SECURITY", "severity": "HIGH"}])

    def test_filters_reviewed_sobelow_exception_unless_include_accepted_is_set(self):
        exc = MOD.sobelow_ci.EXCEPTIONS[0]
        sobelow = {
            "sobelow_version": "0.18.1",
            "total_findings": 1,
            "findings": {
                "high_confidence": [
                    {"type": exc["type"], "file": exc["file"], "line": exc["line"]}
                ],
                "medium_confidence": [],
                "low_confidence": [],
            },
        }
        sources = {exc["file"]: exc["sha256"]}

        filtered = MOD.merge_generic_issues({"issues": []}, sobelow, sources=sources, include_accepted=False)
        self.assertEqual(filtered, {"rules": [], "issues": []})

        included = MOD.merge_generic_issues({"issues": []}, sobelow, sources=sources, include_accepted=True)
        self.assertEqual(len(included["issues"]), 1)

    def test_refuses_output_outside_tmp(self):
        for outside in (ROOT / "config", ROOT / "tmp" / ".." / "lib", Path("/var/tmp/sonar-outside")):
            with self.assertRaisesRegex(ValueError, "output-must-be-under-tmp"):
                MOD.ensure_safe_output(outside)

    def test_rejects_path_traversal_and_invalid_credo_shape(self):
        self.assertIsNone(MOD.normalize_relative_path("../etc/passwd"))
        self.assertIsNone(MOD.normalize_relative_path("/abs/path.ex"))
        self.assertEqual(MOD.normalize_relative_path("./lib/app.ex"), "lib/app.ex")
        with self.assertRaisesRegex(ValueError, "invalid-credo-json"):
            MOD.convert_credo_issues({"unexpected": []})


if __name__ == "__main__":
    unittest.main()
