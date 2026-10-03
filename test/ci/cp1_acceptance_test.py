import copy
import importlib.util
import json
import tempfile
import hashlib
import re
import subprocess
import os
import sys
from unittest.mock import patch
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("cp1_acceptance", ROOT / "scripts/cp1_acceptance.py")
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
sys.path.insert(0, str(ROOT / "scripts"))
import cp1_hosted_receipts as HOSTED
SHA = "a" * 40


class CP1AcceptanceTest(unittest.TestCase):
    def setUp(self):
        self.manifest = MODULE.load_json(ROOT / "config/cp1_acceptance.json")
        self.receipts = MODULE.load_json(ROOT / "test/fixtures/cp1_acceptance/pass/receipts.json")

    def evaluate(self, receipts=None):
        return MODULE.record(self.manifest, receipts or self.receipts, SHA, "2026-09-29T12:00:00Z")

    def test_manifest_defines_exactly_ten_unique_obligations_and_traceability(self):
        obligations = MODULE.validate_manifest(self.manifest)
        self.assertEqual(10, len(obligations))
        self.assertEqual({"automated", "demonstrated", "hosted"}, {row["evidence_class"] for row in obligations})
        self.assertEqual([f"FR-{n:03d}" for n in range(1, 22)], self.manifest["traceability"]["requirements"])
        self.assertEqual([f"SC-{n:03d}" for n in range(1, 10)], self.manifest["traceability"]["success_criteria"])

    def test_manifest_cannot_remap_a_failed_governing_gate(self):
        receipts = copy.deepcopy(self.receipts)
        sonar = next(row for row in receipts["receipts"] if row["kind"] == "sonarcloud")
        sonar.update(status="NOT PASSING", open_issues=10)
        self.assertEqual("NOT PASSING", self.evaluate(receipts)["overall_result"])
        for row in self.manifest["obligations"]:
            with self.subTest(obligation=row["id"]):
                data = copy.deepcopy(self.manifest)
                target = next(item for item in data["obligations"] if item["id"] == row["id"])
                target["required_receipt"] = "repository" if row["required_receipt"] == "demo" else "demo"
                with self.assertRaises(MODULE.InvalidEvidence):
                    MODULE.record(data, receipts, SHA, "2026-09-29T12:00:00Z")

    def test_manifest_requires_criteria_complete_traceability_and_gate_classes(self):
        mutations = []
        for criterion in ("", "   ", None, []):
            data = copy.deepcopy(self.manifest)
            data["obligations"][0]["criterion"] = criterion
            mutations.append(data)
        for traceability in ({}, None, {"requirements": [], "success_criteria": []}):
            data = copy.deepcopy(self.manifest)
            data["traceability"] = traceability
            mutations.append(data)
        data = copy.deepcopy(self.manifest)
        data["traceability"]["requirements"].append("FR-001")
        mutations.append(data)
        data = copy.deepcopy(self.manifest)
        data["traceability"]["success_criteria"].pop()
        mutations.append(data)
        data = copy.deepcopy(self.manifest)
        data["obligations"][2]["evidence_class"] = "demonstrated"
        mutations.append(data)
        data = copy.deepcopy(self.manifest)
        data["obligations"][3]["supporting_regressions"] = []
        mutations.append(data)
        for index, data in enumerate(mutations):
            with self.subTest(mutation=index):
                with self.assertRaises(MODULE.InvalidEvidence):
                    MODULE.validate_manifest(data)

    def test_complete_committed_case_passes_and_renders_deterministically(self):
        result = self.evaluate()
        expected = MODULE.load_json(ROOT / "test/fixtures/cp1_acceptance/pass/expected.json")
        self.assertEqual(expected["overall_result"], result["overall_result"])
        self.assertEqual(10, len(result["obligations"]))
        rendered = MODULE.markdown(result)
        self.assertEqual(rendered, MODULE.markdown(result))
        for value in (SHA, result["manifest_sha256"], "2026-09-29T12:00:00Z", "Generator", "Criterion", "Provenance"):
            self.assertIn(value, rendered)

    def test_snapshot_never_passes(self):
        data = copy.deepcopy(self.receipts)
        data["provenance"] = "working-tree-snapshot"
        self.assertEqual("NOT PASSING", self.evaluate(data)["overall_result"])

    def test_every_non_pass_state_fails_closed(self):
        states = MODULE.load_json(ROOT / "test/fixtures/cp1_acceptance/non_pass/states.json")["states"]
        for state in states:
            with self.subTest(state=state):
                data = copy.deepcopy(self.receipts)
                data["receipts"][0]["status"] = state
                if state == "NOT PASSING":
                    self.assertEqual("NOT PASSING", self.evaluate(data)["overall_result"])
                else:
                    with self.assertRaises(MODULE.InvalidEvidence):
                        self.evaluate(data)

    def test_missing_duplicate_unknown_extra_and_mixed_sha_are_rejected(self):
        mutations = []
        missing = copy.deepcopy(self.receipts); missing["receipts"].pop(); mutations.append(missing)
        duplicate = copy.deepcopy(self.receipts); duplicate["receipts"].append(copy.deepcopy(duplicate["receipts"][0])); mutations.append(duplicate)
        unknown = copy.deepcopy(self.receipts); unknown["receipts"][0]["kind"] = "unknown"; mutations.append(unknown)
        extra = copy.deepcopy(self.receipts); extra["receipts"][0]["extra"] = "x"; mutations.append(extra)
        mixed = copy.deepcopy(self.receipts); mixed["receipts"][0]["candidate_sha"] = "b" * 40; mutations.append(mixed)
        self.assertEqual(len(MODULE.load_json(ROOT / "test/fixtures/cp1_acceptance/non_pass/mutations.json")), len(mutations))
        for data in mutations:
            with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)

    def test_unsafe_keys_content_and_references_are_rejected(self):
        for key, value in (("password", "synthetic"), ("observed", "Authorization: Bearer abcdefghijklmnop"), ("reference", "/tmp/private")):
            data = copy.deepcopy(self.receipts); data["receipts"][0][key] = value
            with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)

    def test_sonar_boundary_and_exact_population(self):
        for count, passes in ((0, True), (9, True), (10, False)):
            data = copy.deepcopy(self.receipts); data["receipts"][2]["open_issues"] = count
            if passes: self.assertEqual("PASS", self.evaluate(data)["overall_result"])
            else:
                with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)
        for field, value in (("project", "other"), ("branch", "pr"), ("analysis_status", "pending"), ("profiles", [])):
            data = copy.deepcopy(self.receipts); data["receipts"][2][field] = value
            with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)

    def test_all_secret_sentinels_are_blocked_before_publication(self):
        sentinels = MODULE.load_json(ROOT / "test/fixtures/cp1_acceptance/unsafe/sentinels.json")["sentinels"]
        for sentinel in sentinels:
            with self.subTest(sentinel=sentinel):
                data = copy.deepcopy(self.receipts)
                data["receipts"][0]["observed"] = sentinel
                with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)

    def test_demo_receipt_schema_sha_and_observations(self):
        demo = copy.deepcopy(self.receipts["receipts"][3]["runs"][0])
        MODULE.validate_demo(demo, SHA)
        for field, value in [("candidate_sha", "b" * 40), ("status", "NOT PASSING"),
                             ("behaviors", []), ("elapsed_seconds", 1201),
                             ("provider_access", True), ("seed_assertions", []),
                             ("extra", "value")]:
            with self.subTest(field=field):
                changed = copy.deepcopy(demo); changed[field] = value
                with self.assertRaises(MODULE.InvalidEvidence): MODULE.validate_demo(changed, SHA)

    def test_pass_requires_two_demos_and_complete_profiles_coverage(self):
        for kind, field in [("demo", "runs"), ("tests", "profiles"), ("tests", "coverage")]:
            data = copy.deepcopy(self.receipts)
            receipt = next(row for row in data["receipts"] if row["kind"] == kind)
            receipt.pop(field, None)
            with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)
        data = copy.deepcopy(self.receipts)
        next(r for r in data["receipts"] if r["kind"] == "demo")["runs"].pop()
        with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)

    def test_stale_nested_profiles_and_coverage_are_non_passing(self):
        for field, value in [("candidate_sha", "b" * 40), ("snapshot_label", "working-tree snapshot"),
                             ("inventory_sha256", "0" * 64), ("source_count", 0)]:
            data = copy.deepcopy(self.receipts)
            data["receipts"][4]["coverage"][field] = value
            with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)
        for field, value in [("status", "skipped"), ("audit_count", 0), ("profile", "other")]:
            data = copy.deepcopy(self.receipts)
            data["receipts"][4]["profiles"][0][field] = value
            with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)

    def test_empty_local_directory_cannot_establish_hosted_pass(self):
        with tempfile.TemporaryDirectory() as temp:
            with self.assertRaises((MODULE.InvalidEvidence, OSError)):
                MODULE.local_receipts(Path(temp), SHA)

    def test_unsafe_atomic_staging_is_destroyed(self):
        with tempfile.TemporaryDirectory() as temp:
            result = self.evaluate()
            result["collected_at"] = "CP1_PROFILE_SECRET_SENTINEL"
            with self.assertRaises(MODULE.InvalidEvidence):
                MODULE.atomic_publish(Path(temp) / "published", result)
            self.assertEqual([], list(Path(temp).iterdir()))

    def test_ephemeral_and_traversing_references_are_rejected(self):
        for ref in ["https://example.com/session/abc", "../private", "https://github.com/a?token=abc", "file:///tmp/a"]:
            with self.assertRaises(MODULE.InvalidEvidence): MODULE.validate_reference(ref)

    def local_fixture(self, root):
        demos = root / "tmp"; demos.mkdir()
        for name in ["first", "second"]:
            (demos / f"cp1-demo-{name}.json").write_text(json.dumps(self.receipts["receipts"][3]["runs"][0]))
        coverage = root / "cover/cp1/synthetic"; (coverage / "sources").mkdir(parents=True)
        sources = []
        for n, path in enumerate(re.findall(r'path: "([^"]+)"', (ROOT / "config/cp1_coverage_inventory.exs").read_text())):
            reference = f"sources/{n}.html"
            (coverage / reference).write_text("<html>synthetic coverage</html>")
            sources.append({"path": path, "source_report": reference})
        report = {"metadata": {"base_head": SHA, "snapshot_label": "committed revision",
                  "diff_sha256": hashlib.sha256(b"").hexdigest(),
                  "inventory_sha256": self.receipts["receipts"][4]["coverage"]["inventory_sha256"],
                  "profiles": self.receipts["receipts"][4]["profiles"]},
                  "sources": sources, "executable_lines": 100}
        (coverage / "manifest.json").write_text(json.dumps(report))
        (coverage / "report.html").write_text("<html>synthetic report</html>")
        return coverage

    def test_local_bundle_content_and_safe_publication(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "source"; source.mkdir()
            coverage = self.local_fixture(source)
            MODULE.local_receipts(source, SHA)
            output = Path(temp) / "published"
            MODULE.publish_local(source, SHA, output)
            self.assertTrue((output / "cover/cp1/synthetic/report.html").is_file())
            (coverage / "report.html").write_text("CP1_PROFILE_SECRET_SENTINEL")
            with self.assertRaises(MODULE.InvalidEvidence): MODULE.publish_local(source, SHA, output)
            # Already-published safe output is allowed to remain; new unsafe staging is absent.
            self.assertFalse(list(Path(temp).glob(".cp1-staging-*")))

    def test_hosted_collector_checks_content_before_claiming_pass(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "source"; source.mkdir()
            self.local_fixture(source)
            output = Path(temp) / "receipts.json"
            runs = [{"name": name, "head_sha": SHA, "status": "completed", "conclusion": "success", "html_url": "https://github.com/example/project/actions/runs/1"}
                    for name in ["Quality baseline", "SonarCloud analysis"]]
            for run, path in zip(runs, ["quality-baseline.yml", "sonarcloud.yml"]):
                run.update(path=f".github/workflows/{path}", head_branch="main", event="push", head_repository={"full_name": "example/project"})
            def sonar(path, token):
                if path.startswith("project_analyses"):
                    return {"analyses": [{"revision": SHA, "key": "synthetic"}]}
                if path.startswith("issues"):
                    return {"total": 9}
                return {"profiles": [{"language": "elixir", "name": "way", "activeRuleCount": 1}]}
            arguments = ["collector", "--candidate", SHA, "--repository", "example/project", "--ref", "refs/heads/main",
                         "--github-api", "https://api.github.com", "--output", str(output)]
            with patch.object(sys, "argv", arguments), patch.dict(os.environ, {"SONAR_TOKEN": "synthetic"}), \
                 patch.object(HOSTED, "request_json", return_value={"workflow_runs": runs}), \
                 patch.object(HOSTED, "sonar_json", side_effect=sonar), \
                 patch.object(HOSTED, "local_receipts", side_effect=lambda directory, candidate: MODULE.local_receipts(source, candidate)):
                workflow = MODULE.load_json(ROOT / "test/fixtures/cp1_acceptance/workflow/cases.json")
                with patch.object(HOSTED.time, "sleep", return_value=None):
                    for conclusion in workflow["terminal"]:
                        runs[0]["conclusion"] = conclusion
                        outcome = HOSTED.main()
                        self.assertEqual(0 if conclusion == "success" else 1, outcome)
                    runs[0]["conclusion"] = "success"
                    runs[0]["head_sha"] = "b" * 40
                    self.assertEqual(1, HOSTED.main())
                    runs[0]["head_sha"] = SHA
                    runs[0]["status"] = "in_progress"
                    self.assertEqual(1, HOSTED.main())
                    runs[0]["status"] = "completed"
                    for boundary in workflow["sonar_boundaries"]:
                        original = sonar
                        def at_boundary(path, token):
                            return {"total": boundary} if path.startswith("issues") else original(path, token)
                        with patch.object(HOSTED, "sonar_json", side_effect=at_boundary):
                            self.assertEqual(0 if boundary == 9 else 1, HOSTED.main())
                self.assertEqual(0, HOSTED.main())
                self.assertEqual("PASS", self.evaluate(MODULE.load_json(output))["overall_result"])
                (source / "tmp/cp1-demo-second.json").write_text("{}")
                self.assertEqual(1, HOSTED.main())
                self.assertEqual("NOT PASSING", self.evaluate(MODULE.load_json(output))["overall_result"])

    def test_governing_workflow_identity_and_branch_are_required(self):
        run = {"name": "Quality baseline", "head_sha": SHA, "status": "completed",
               "conclusion": "success", "path": ".github/workflows/quality-baseline.yml",
               "head_branch": "main", "event": "push", "head_repository": {"full_name": "example/project"}}
        select = lambda r: HOSTED.completed_run([r], SHA, "example/project", "Quality baseline", "quality-baseline.yml")
        self.assertEqual(run, select(run))
        for field, value in [("head_branch", "feature"), ("path", ".github/workflows/impostor.yml"),
                             ("event", "pull_request"), ("head_repository", {"full_name": "other/project"})]:
            changed = dict(run); changed[field] = value
            self.assertIsNone(select(changed))

    def test_clean_commit_cli_requires_real_matching_local_bundle(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "source"; source.mkdir()
            self.local_fixture(source)
            data = copy.deepcopy(self.receipts)
            data["receipts"][4]["coverage"] = MODULE.local_receipts(source, SHA)[2]
            receipts = Path(temp) / "input.json"; receipts.write_text(json.dumps(data))
            output = Path(temp) / "output"
            args = ["--receipts", str(receipts), "--candidate-sha", SHA, "--output", str(output)]
            with patch.object(MODULE, "git_candidate", return_value=(SHA, "committed")):
                self.assertEqual(1, MODULE.main(args))
                self.assertEqual(0, MODULE.main(args + ["--local-evidence", str(source)]))
                (source / "tmp/cp1-demo-second.json").write_text("{}")
                self.assertEqual(1, MODULE.main(args + ["--local-evidence", str(source)]))
            self.assertEqual("NOT PASSING", MODULE.load_json(output / "acceptance.json")["overall_result"])

    def test_json_artifacts_and_observations_reject_quoted_secret_fields(self):
        for field in ["password", "api_key_secret", "secret_hash", "provider_payload"]:
            value = json.dumps({field: "synthetic-sensitive-value"})
            data = copy.deepcopy(self.receipts); data["receipts"][0]["observed"] = value
            with self.assertRaises(MODULE.InvalidEvidence): self.evaluate(data)
            with tempfile.TemporaryDirectory() as temp:
                source = Path(temp) / "source"; source.mkdir()
                self.local_fixture(source)
                (source / "tmp/cp1-demo-first.json").write_text(value)
                with self.assertRaises(MODULE.InvalidEvidence): MODULE.publish_local(source, SHA, Path(temp) / "out")

    def test_secret_in_cited_json_is_not_published(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "source"; source.mkdir()
            self.local_fixture(source)
            data = copy.deepcopy(self.receipts)
            data["receipts"][4]["coverage"] = MODULE.local_receipts(source, SHA)[2]
            data["receipts"][0]["reference"] = "cited.json"
            receipts = Path(temp) / "input.json"
            output = Path(temp) / "output"
            args = ["--receipts", str(receipts), "--candidate-sha", SHA, "--output", str(output), "--local-evidence", str(source)]
            with patch.object(MODULE, "git_candidate", return_value=(SHA, "committed")):
                self.assertEqual(1, MODULE.main(args))
                for key in ["password", "api_key_secret", "secret_hash", "provider_payload"]:
                    (source / "cited.json").write_text(json.dumps({key: "sensitive-adversarial-value"}))
                    receipts.write_text(json.dumps(data))
                    self.assertEqual(1, MODULE.main(args))
                    self.assertNotIn("sensitive-adversarial-value", (output / "acceptance.json").read_text() + (output / "acceptance.md").read_text())
                (source / "cited.json").unlink()
                self.assertEqual(1, MODULE.main(args))

    def test_native_source_html_is_excluded_but_runtime_artifacts_are_scanned(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "source"; source.mkdir()
            coverage = self.local_fixture(source)
            (coverage / "native").mkdir()
            (coverage / "native/Accounts.html").write_text('<html>source: password: password, api_key_secret: secret</html>')
            MODULE.local_receipts(source, SHA)
            output = Path(temp) / "out"
            MODULE.publish_local(source, SHA, output)
            result = self.evaluate()
            MODULE.atomic_publish(Path(temp) / "final", result, self.receipts, source)
            self.assertFalse((output / "cover/cp1/synthetic/native").exists())
            self.assertFalse((Path(temp) / "final/cover/cp1/synthetic/native").exists())
            (coverage / "sources/0.html").write_text('password: synthetic-runtime-secret')
            with self.assertRaises(MODULE.InvalidEvidence): MODULE.publish_local(source, SHA, output)

    def test_actual_coverage_html_can_be_staged_and_published(self):
        real = os.environ.get("CP1_REAL_COVERAGE_DIRECTORY")
        if not real:
            return  # Optional generated-HTML exercise; synthetic case always runs above.
        import shutil
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / "source"; source.mkdir()
            coverage = self.local_fixture(source)
            shutil.rmtree(coverage)
            shutil.copytree(real, coverage)
            report = MODULE.load_json(coverage / "manifest.json")
            # Only this synthetic test copy changes identity. Original working-tree
            # metadata is retained untouched and can never establish hosted PASS.
            report["metadata"].update(base_head=SHA, snapshot_label="committed revision",
                                      diff_sha256=hashlib.sha256(b"").hexdigest())
            (coverage / "manifest.json").write_text(json.dumps(report))
            runs, profiles, receipt = MODULE.local_receipts(source, SHA)
            data = copy.deepcopy(self.receipts)
            data["receipts"][3]["runs"] = runs
            data["receipts"][4].update(profiles=profiles, coverage=receipt)
            result = self.evaluate(data)
            output = Path(temp) / "published"
            MODULE.publish_local(source, SHA, output)
            MODULE.atomic_publish(Path(temp) / "final", result, data, output)
            retained = {p.relative_to(output) for p in output.rglob("*") if p.is_file()}
            self.assertEqual({p.relative_to(source) for p in MODULE.local_artifacts(source, receipt)}, retained)
            self.assertFalse(any("native" in p.parts or "receipts" in p.parts for p in retained))
            self.assertEqual((coverage / "report.html").read_bytes(), (output / receipt["report_reference"]).read_bytes())

    def test_node_gate_preserves_baseline_and_rejects_wrong_cp1_version(self):
        with tempfile.TemporaryDirectory() as temp:
            scripts = {"elixir": "echo 1.20.3", "erl": 'case "$*" in *otp_release*) echo 29;; *) echo 17.0.6;; esac',
                       "mix": "echo Mix-1.20.3", "node": "echo v20.0.0"}
            for name, body in scripts.items():
                path = Path(temp) / name; path.write_text("#!/bin/sh\n" + body + "\n"); path.chmod(0o700)
            env = dict(os.environ, PATH=temp + os.pathsep + os.environ["PATH"])
            run = lambda flags: subprocess.run(["scripts/check_toolchain.sh", *flags], env=env, capture_output=True)
            self.assertEqual(0, run([]).returncode)
            self.assertNotEqual(0, run(["--with-node"]).returncode)
            (Path(temp) / "node").write_text("#!/bin/sh\necho v24.21.0\n")
            self.assertEqual(0, run(["--with-node"]).returncode)

    def test_demo_child_failure_never_releases_sentinels(self):
        with tempfile.TemporaryDirectory() as temp:
            binary = Path(temp) / "mix"
            binary.write_text("#!/bin/sh\necho CP1_PROFILE_SECRET_SENTINEL\nexit 1\n")
            binary.chmod(0o700)
            env = dict(os.environ, PATH=str(Path(temp)) + os.pathsep + os.environ["PATH"],
                       CP1_DEMO_CONFIRM_DISPOSABLE="yes", CP1_DEMO_DATABASE_URL="ecto://postgres:postgres@127.0.0.1/football_market_test_cp1_demo",
                       CP1_CANDIDATE_SHA=subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip())
            result = subprocess.run(["scripts/cp1_demo.sh", str(Path(temp) / "receipt.json")], cwd=ROOT, env=env, capture_output=True, text=True)
            self.assertNotEqual(0, result.returncode)
            self.assertIn("database-preparation", result.stderr)
            self.assertNotIn("SENTINEL", result.stdout + result.stderr)
            self.assertFalse((Path(temp) / "receipt.json").exists())

    def test_candidate_argument_cannot_override_dirty_checkout(self):
        with tempfile.TemporaryDirectory() as temp:
            receipts = Path(temp) / "input.json"; receipts.write_text(json.dumps(self.receipts))
            output = Path(temp) / "output"
            with patch.object(MODULE, "git_candidate", return_value=(SHA, "working-tree-snapshot")):
                self.assertEqual(1, MODULE.main(["--receipts", str(receipts), "--candidate-sha", SHA, "--output", str(output)]))
            self.assertEqual("NOT PASSING", MODULE.load_json(output / "acceptance.json")["overall_result"])

    def test_atomic_output_contains_matching_json_and_markdown(self):
        with tempfile.TemporaryDirectory() as temp:
            output = Path(temp) / "published"
            result = self.evaluate(); MODULE.atomic_publish(output, result)
            self.assertEqual(result, json.loads((output / "acceptance.json").read_text()))
            self.assertEqual(MODULE.markdown(result), (output / "acceptance.md").read_text())


if __name__ == "__main__": unittest.main()
