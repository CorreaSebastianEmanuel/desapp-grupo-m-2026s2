import json
import os
import runpy
import shutil
import subprocess
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from unittest.mock import patch

from scripts.agentflow_check import run_check
from scripts.agentflow_runtime import Console, DIMENSIONS, MARKER, metrics_summary, numeric_usage, stage_from_args, usage_delta
from scripts.agentflow_verification import manifest, readiness

ROOT = Path(__file__).resolve().parents[1]


class VerificationTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        subprocess.run(["git", "init", "-q"], cwd=self.root, check=True)
        (self.root / ".gitignore").write_text(".agentflow/runs/\n")
        (self.root / "src.py").write_text("source")
        self.feature = self.root / "specs/001-test"
        self.feature.mkdir(parents=True)
        (self.feature / "spec.md").write_text("FR-001: observable behavior\nSC-001: success criterion\n")
        (self.feature / "plan.md").write_text("Plan\n")
        (self.feature / "tasks.md").write_text("- [X] T001 Implement behavior\n")
        self.data = {"schema_version": 1, "runtime_required": False,
                     "coverage": {"FR-001": ["unit"], "SC-001": ["unit"]},
                     "checks": [{"id": "unit", "argv": [sys.executable, "-c", "print('FULL_OUTPUT_SENTINEL')"]}]}
        self.write_manifest()

    def write_manifest(self):
        (self.feature / "verification.json").write_text(json.dumps(self.data))

    def check(self):
        with redirect_stdout(StringIO()) as output:
            code = run_check(self.root, self.feature, "unit")
        self.assertNotIn("FULL_OUTPUT_SENTINEL", output.getvalue())
        return code

    def test_successful_check_receipt_and_completion_recording(self):
        (self.feature / "tasks.md").write_text("- [ ] T001 Implement behavior\n")
        self.assertEqual(0, self.check())
        with self.assertRaisesRegex(RuntimeError, "Incomplete"):
            readiness(self.root, self.feature)
        (self.feature / "tasks.md").write_text("- [X] T001 Implement behavior\n")
        self.assertTrue(readiness(self.root, self.feature)["ready"])

    def test_source_untracked_input_and_deleted_tracked_input_invalidate_evidence(self):
        subprocess.run(["git", "add", "src.py"], cwd=self.root, check=True)
        self.check()
        (self.root / "src.py").unlink()
        with self.assertRaisesRegex(RuntimeError, "Stale"):
            readiness(self.root, self.feature)
        (self.root / "src.py").write_text("source")
        self.check()
        (self.root / "new.py").write_text("new input")
        with self.assertRaisesRegex(RuntimeError, "Stale"):
            readiness(self.root, self.feature)

    def test_inputs_and_output_hashes_are_bound(self):
        self.check()
        (self.feature / "plan.md").write_text("Changed plan")
        with self.assertRaisesRegex(RuntimeError, "Stale"):
            readiness(self.root, self.feature)

    def test_supporting_artifact_changes_and_deletions_invalidate_receipts(self):
        (self.feature / "contracts").mkdir()
        contract = self.feature / "contracts/context.md"
        contract.write_text("Original contract")
        model = self.feature / "data-model.md"
        model.write_text("Original model")
        self.check()
        contract.write_text("Changed contract")
        with self.assertRaisesRegex(RuntimeError, "Stale"):
            readiness(self.root, self.feature)
        self.check()
        model.unlink()
        with self.assertRaisesRegex(RuntimeError, "Stale"):
            readiness(self.root, self.feature)
        self.check()
        (self.feature / "qa-report.md").write_text("QA output is not a design input")
        self.assertTrue(readiness(self.root, self.feature)["ready"])
        self.check()
        log = next((self.root / ".agentflow/runs/checks").glob("*.log"))
        # Corrupt all possible receipt outputs, including the most recent one.
        for log in log.parent.glob("*.log"):
            log.write_text("altered")
        with self.assertRaisesRegex(RuntimeError, "changed check output"):
            readiness(self.root, self.feature)

    def test_failed_reexecution_replaces_prior_success(self):
        self.data["checks"][0]["argv"] = [sys.executable, "-c", "from pathlib import Path; import sys; sys.exit(3 if Path('.agentflow/runs/fail').exists() else 0)"]
        self.write_manifest()
        self.assertEqual(0, self.check())
        (self.root / ".agentflow/runs/fail").touch()
        self.assertEqual(3, self.check())
        with self.assertRaisesRegex(RuntimeError, "failed"):
            readiness(self.root, self.feature)

    def test_check_changing_source_is_not_ready(self):
        self.data["checks"][0]["argv"] = [sys.executable, "-c", "from pathlib import Path; Path('src.py').write_text('changed')"]
        self.write_manifest()
        self.assertEqual(1, self.check())
        with self.assertRaisesRegex(RuntimeError, "Stale"):
            readiness(self.root, self.feature)

    def test_missing_or_unexecutable_check_is_not_ready(self):
        with self.assertRaisesRegex(RuntimeError, "missing JSON"):
            readiness(self.root, self.feature)
        self.data["checks"][0]["argv"] = ["/nonexistent/agentflow-test-command"]
        self.write_manifest()
        self.assertEqual(127, self.check())
        with self.assertRaisesRegex(RuntimeError, "failed"):
            readiness(self.root, self.feature)

    def test_coverage_and_http_obligation_cannot_be_silently_skipped(self):
        del self.data["coverage"]["SC-001"]
        self.write_manifest()
        with self.assertRaisesRegex(RuntimeError, "Coverage"):
            manifest(self.feature)
        self.data["coverage"]["SC-001"] = ["unit"]
        (self.feature / "contracts").mkdir()
        (self.feature / "contracts/http.md").write_text("GET /api/players returns 200\n")
        self.write_manifest()
        with self.assertRaisesRegex(RuntimeError, "runtime obligation"):
            manifest(self.feature)
        self.data["checks"][0].update(runtime=True, expectation="Assert status and response body")
        self.write_manifest()
        self.assertTrue(manifest(self.feature)["checks"][0]["runtime"])

    def test_root_http_route_also_requires_runtime_assertions(self):
        (self.feature / "spec.md").write_text("FR-001: GET / returns 200.\nSC-001: Success.\n")
        with self.assertRaisesRegex(RuntimeError, "runtime obligation"):
            manifest(self.feature)

    def test_openapi_contract_formats_require_runtime_assertions(self):
        contracts = self.feature / "contracts"
        contracts.mkdir()
        cases = [
            ("openapi.yaml", "openapi: 3.0.0\npaths:\n  /players:\n    get:\n      responses: {}\n"),
            ("openapi.yml", "paths:\n  '/':\n    $ref: './operations.yaml'\n"),
            ("openapi.yml", "paths:\n  '/players:search':\n    post: {}\n"),
            ("openapi.yaml", 'paths: {"/players": {get: {responses: {}}}}'),
            ("openapi.json", json.dumps({"openapi": "3.0.0", "paths": {"/players": {"get": {}}}})),
            ("openapi.json", json.dumps({"paths": {"/": {"$ref": "operations.json"}}})),
            ("api.raml", "#%RAML 1.0\n/players:\n  get:\n    responses: {}\n"),
            ("http.md", "get /players returns 200"),
        ]
        for name, text in cases:
            with self.subTest(name=name, text=text):
                contract = contracts / name
                contract.write_text(text)
                self.data["checks"][0].pop("runtime", None)
                self.write_manifest()
                with self.assertRaisesRegex(RuntimeError, "runtime obligation"):
                    manifest(self.feature)
                self.data["checks"][0].update(runtime=True, expectation="Assert status and body")
                self.write_manifest()
                self.assertTrue(manifest(self.feature)["checks"][0]["runtime"])
                contract.unlink()

    def test_non_http_and_malformed_json_contracts(self):
        contracts = self.feature / "contracts"
        contracts.mkdir()
        contract = contracts / "context.json"
        contract.write_text(json.dumps({"properties": {"name": {"type": "string"}}}))
        self.assertFalse(manifest(self.feature)["runtime_required"])
        contract.write_text('{"paths":')
        with self.assertRaisesRegex(RuntimeError, "Invalid or missing JSON"):
            manifest(self.feature)

    def test_duplicate_json_keys_and_malformed_commands_rejected(self):
        (self.feature / "verification.json").write_text('{"schema_version":1,"schema_version":1}')
        with self.assertRaises(RuntimeError):
            manifest(self.feature)
        self.data["checks"][0]["argv"] = []
        self.write_manifest()
        with self.assertRaisesRegex(RuntimeError, "argv"):
            manifest(self.feature)

    def test_only_explicit_qa_review_tasks_can_be_deferred(self):
        self.data["task_stages"] = {"T002": "qa"}
        self.write_manifest()
        (self.feature / "tasks.md").write_text("- [X] T001 Implement behavior\n- [ ] T002 [gate:qa] Implement additional behavior\n")
        self.check()
        with self.assertRaisesRegex(RuntimeError, "Only explicit"):
            readiness(self.root, self.feature)
        (self.feature / "tasks.md").write_text("- [X] T001 Implement behavior\n- [ ] T002 [gate:qa] Independent QA verify behavior\n")
        self.check()
        self.assertTrue(readiness(self.root, self.feature)["ready"])


class RuntimeTest(unittest.TestCase):
    def test_mock_pipeline_human_stdin_fragments_failure_and_durable_metrics(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "scripts").mkdir()
            for name in ("agentflow_codex.py", "agentflow_runtime.py"):
                shutil.copy2(ROOT / "scripts" / name, root / "scripts" / name)
            fake = root / "codex"
            fake.write_text("#!" + sys.executable + "\nimport json,sys\n"
                            "assert sys.stdin.read() == ''\n"
                            "print(json.dumps({'type':'thread.started','thread_id':'PRIVATE_SENTINEL'}))\n"
                            "print(json.dumps({'type':'item.completed','item':{'text':'PRIVATE_SENTINEL'}}))\n"
                            "print(json.dumps({'type':'turn.completed','usage':{'input_tokens':100,'output_tokens':20}}))\n")
            fake.chmod(0o755)
            runner = root / "fake-specify.py"
            runner.write_text("import os,subprocess,sys,time\n"
                              "subprocess.run([os.environ['SPECKIT_INTEGRATION_CODEX_EXECUTABLE'],'exec','Agentflow stage: develop\\nWork'],check=True)\n"
                              "sys.stdout.write('Human gate: ¿apro');sys.stdout.flush();time.sleep(.02)\n"
                              "sys.stdout.write('bar? [approve/reject]: ');sys.stdout.flush()\n"
                              "choice=input()\nprint('CHOICE_RECEIVED='+choice)\nraise SystemExit(3)\n")
            task = root / "task.md"
            task.write_text("---\nid: TASK-001\nactive_run: none\n---\n")
            harness = root / "harness.py"
            harness.write_text(f"import sys,runpy\nfrom pathlib import Path\nsys.path.insert(0,{str(ROOT)!r})\n"
                               f"api=runpy.run_path({str(ROOT / 'agentflow')!r})\ng=api['monitor_process'].__globals__\n"
                               f"root=Path({str(root)!r})\ng.update(ROOT=root,RUNS=root/'.agentflow/runs',SPEC_RUNS=root/'.specify/workflows/runs')\n"
                               f"code,_=api['monitor_process']([sys.executable,{str(runner)!r}],root/'task.md')\nraise SystemExit(code)\n")
            env = {**os.environ, "PATH": str(root) + os.pathsep + os.environ["PATH"]}
            env.pop("SPECKIT_INTEGRATION_CODEX_EXECUTABLE", None)
            env.pop("AGENTFLOW_CONSOLE", None)
            result = subprocess.run([sys.executable, str(harness)], input="approve\n", text=True,
                                    capture_output=True, env=env, timeout=15)
            self.assertEqual(3, result.returncode, result.stderr)
            self.assertIn("Human gate: ¿aprobar? [approve/reject]: CHOICE_RECEIVED=approve", result.stdout)
            self.assertNotIn("PRIVATE_SENTINEL", result.stdout)
            self.assertEqual(120, metrics_summary(root / ".agentflow/runs/TASK-001.metrics.jsonl")["measured_input_plus_output"])
            self.assertIn("PRIVATE_SENTINEL", (root / ".agentflow/runs/TASK-001.live.log").read_text())

    def test_console_fragmented_human_gate_and_payload_privacy(self):
        console = Console()
        result = console.feed("AGENTF") + console.feed('LOW_EVENT {"event":"agent_started","stage":"develop"}\n')
        result += console.feed("SECRET_PROMPT\n")
        result += console.feed('{"type":"item.completed","item":{"text":"SECRET_TOOL"}}\n')
        result += console.feed(MARKER + '{"event":"agent_ended","stage":"develop","exit_code":1}\n')
        result += console.feed("Gate: approve?") + console.feed(" [approve/reject]: ")
        self.assertIn("exit=1", result)
        self.assertIn("Gate: approve? [approve/reject]: ", result)
        self.assertNotIn("SECRET", result)
        self.assertEqual("raw output", Console(full=True).feed("raw output"))

    def test_stage_markers_usage_dimensions_and_unknowns(self):
        self.assertEqual("develop", stage_from_args(["exec", "$speckit-implement Agentflow stage: develop\nDo work"]))
        self.assertEqual("unknown", stage_from_args(["Agentflow stage: develop\nAgentflow stage: qa"]))
        first = numeric_usage({"input_tokens": 100, "cached_input_tokens": 80, "output_tokens": 20})
        self.assertEqual(first, usage_delta(first, None, True))
        self.assertTrue(all(x is None for x in usage_delta(first, None, False).values()))
        reset = numeric_usage({"input_tokens": 10, "output_tokens": 2})
        self.assertTrue(all(x is None for x in usage_delta(reset, first, True).values()))
        self.assertIsNone(first["reasoning_output_tokens"])

    def test_metric_summary_omits_private_values_and_preserves_absent_usage(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "metrics.jsonl"
            values = [{"event": "agent_started", "stage": "develop", "session_hash": "PRIVATE_SENTINEL"},
                      {"event": "usage", "stage": "develop", "incremental_usage": {"input_tokens": 100, "cached_input_tokens": 80, "output_tokens": 20}, "text": "PRIVATE_SENTINEL"},
                      {"event": "agent_ended", "stage": "develop", "exit_code": 0, "elapsed_seconds": 2},
                      {"event": "agent_started", "stage": "qa"}]
            path.write_text("\n".join(json.dumps(v) for v in values))
            result = metrics_summary(path)
            self.assertEqual(120, result["measured_input_plus_output"])
            self.assertEqual(1, result["stages"][0]["attempts"])
            self.assertIsNone(result["stages"][1]["measured_input_plus_output"])
            self.assertIsNone(result["stages"][0]["measured"]["reasoning_output_tokens"])
            self.assertNotIn("PRIVATE_SENTINEL", json.dumps(result))

    def test_wrapper_forwarding_usage_resume_and_summary_console(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            fake = root / "fake-codex"
            fake.write_text("#!" + sys.executable + "\nimport json,sys\n"
                            "assert '--json' in sys.argv and '--model' in sys.argv\n"
                            "assert sys.stdin.read() == ''\n"
                            "print(json.dumps({'type':'thread.started','thread_id':'PRIVATE_SENTINEL'}))\n"
                            "print(json.dumps({'type':'item.completed','item':{'text':'PRIVATE_SENTINEL'}}))\n"
                            "print(json.dumps({'type':'turn.completed','usage':{'input_tokens':100,'cached_input_tokens':80,'output_tokens':20}}))\n")
            fake.chmod(0o755)
            metrics = root / "TASK-001.metrics.jsonl"
            env = {**os.environ, "AGENTFLOW_CODEX_REAL": str(fake), "AGENTFLOW_TASK_ID": "TASK-001", "AGENTFLOW_METRICS_FILE": str(metrics)}
            command = [sys.executable, str(ROOT / "scripts/agentflow_codex.py"), "exec", "Agentflow stage: develop\nWork", "--model", "fixture-model"]
            result = subprocess.run(command, env=env, input="approve\n", text=True, capture_output=True)
            self.assertEqual(0, result.returncode, result.stderr)
            console = Console()
            self.assertNotIn("PRIVATE_SENTINEL", console.feed(result.stdout, final=True))
            self.assertEqual(120, metrics_summary(metrics)["measured_input_plus_output"])
            # Reused identity is deliberately unknown, not double-counted.
            subprocess.run(command, env=env, text=True, capture_output=True, check=True)
            summary = metrics_summary(metrics)
            self.assertEqual(120, summary["measured_input_plus_output"])
            self.assertEqual(1, summary["stages"][0]["unknown_events"])


class SnapshotTest(unittest.TestCase):
    def test_history_and_status_use_requested_feature_and_saved_step_count(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            api = runpy.run_path(str(ROOT / "agentflow"))
            g = api["history"].__globals__
            g.update(ROOT=root, BACKLOG=root / "backlog", SPEC_RUNS=root / ".specify/workflows/runs",
                     FEEDBACK=root / "backlog/feedback")
            g["BACKLOG"].mkdir()
            (g["BACKLOG"] / "TASK-001-test.md").write_text("---\nid: TASK-001\ntitle: Test\nstatus: wip\nactive_run: run\n---\n")
            own = root / "specs/001-own/handoffs"
            foreign = root / "specs/002-foreign/handoffs"
            own.mkdir(parents=True)
            foreign.mkdir(parents=True)
            (own.parent / "spec.md").write_text("**Feature Branch**: `001-test`\n")
            (own / "develop.md").write_text("OWN_FEATURE")
            (foreign / "develop.md").write_text("FOREIGN_FEATURE")
            run = g["SPEC_RUNS"] / "run"
            run.mkdir(parents=True)
            order = [s for s in api["STEP_ORDER"] if s != "tasks"]
            (run / "workflow.yml").write_text("steps:\n" + "".join(f"  - id: {s}\n" for s in order))
            (run / "state.json").write_text(json.dumps({"current_step_index": 11, "current_step_id": "review", "step_results": {}}))
            from types import SimpleNamespace
            with redirect_stdout(StringIO()) as output:
                api["history"](SimpleNamespace(task="TASK-001"))
                api["status"](SimpleNamespace(task="TASK-001"))
            self.assertIn("OWN_FEATURE", output.getvalue())
            self.assertNotIn("FOREIGN_FEATURE", output.getvalue())
            self.assertNotIn("- tasks:", output.getvalue())
            self.assertIn("12/12", output.getvalue())

    def test_rewind_uses_legacy_and_combined_order_preserves_snapshot_and_prior_gate(self):
        for combined in (False, True):
            with self.subTest(combined=combined), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                api = runpy.run_path(str(ROOT / "agentflow"))
                g = api["rewind_run"].__globals__
                g.update(ROOT=root, RUNS=root / ".agentflow/runs", SPEC_RUNS=root / ".specify/workflows/runs",
                         FEEDBACK=root / "backlog/feedback", WORKFLOW=root / ".agentflow/workflow.yml")
                run = g["SPEC_RUNS"] / "run"
                run.mkdir(parents=True)
                order = [s for s in api["STEP_ORDER"] if not (combined and s == "tasks")]
                snapshot = "steps:\n" + "".join(
                    f"- id: {s}\n" + ("  steps:\n  - id: human_product_check\n" if s == "product_check" else "")
                    for s in order)
                (run / "workflow.yml").write_text(snapshot)
                state = {"status": "completed", "step_results": {s: {"status": "completed"} for s in order}}
                state["step_results"]["human_product_check"] = {"status": "completed", "output": {"choice": "approve"}}
                (run / "state.json").write_text(json.dumps(state))
                task = root / "task.md"
                task.write_text("---\nid: TASK-001\n---\n")
                self.assertTrue(api["rewind_run"](task, "run", "develop"))
                result = json.loads((run / "state.json").read_text())
                self.assertEqual(order.index("develop"), result["current_step_index"])
                self.assertIn("human_product_check", result["step_results"])
                self.assertEqual(snapshot, (run / "workflow.yml").read_text())
                api["rewind_run"](task, "run", "product")
                self.assertNotIn("human_product_check", json.loads((run / "state.json").read_text())["step_results"])

    def test_combined_planning_and_required_hooks_preserved(self):
        text = (ROOT / ".agentflow/workflow.yml").read_text()
        self.assertEqual(text, (ROOT / ".specify/workflows/desapp-delivery/workflow.yml").read_text())
        self.assertNotIn("  - id: tasks\n", text)
        self.assertIn("$speckit-plan", text)
        self.assertIn("$speckit-tasks", text)
        self.assertIn("required hooks", text)
        self.assertEqual(3, text.count("--readiness"))


if __name__ == "__main__":
    unittest.main()
