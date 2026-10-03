import importlib.util
import json
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("audit", ROOT / "scripts/workflow_token_audit.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class AuditTest(unittest.TestCase):
    def test_stage_classifier_uses_roles_and_rejects_ambiguous_prompts(self):
        self.assertEqual("develop", module.classify_prompt("$speckit-implement Follow instructions"))
        self.assertEqual("product_challenge", module.classify_prompt("Act as an independent product critic"))
        self.assertEqual("qa", module.classify_prompt("Act as independent QA"))
        self.assertEqual("review", module.classify_prompt("Act as the final independent reviewer"))
        self.assertEqual("unknown", module.classify_prompt("$speckit-plan and $speckit-implement"))
        self.assertEqual("unknown", module.classify_prompt("independent QA and final independent reviewer"))
        self.assertEqual("unknown", module.classify_prompt("$speckit-implement Act as independent QA"))

    def test_unmetered_only_stage_preserves_unknown_consumption(self):
        result = module.summarize_stages([{"stage": "develop", "reported_tokens": None,
                                          "initial_prompt_chars": 10}])[0]
        for key in ("reported_tokens", "token_percent", "first_metered_tokens", "repeat_metered_tokens"):
            self.assertIsNone(result[key])
        self.assertEqual(1, result["attempts_without_count"])

    def test_sessions_ignore_later_tool_content_and_keep_interrupted_attempts(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "log"
            path.write_text("OpenAI Codex v1\nuser\n$ speckit-invalid\n"
                            "Act as independent QA\nexec\n$ speckit-invalid\n$ speckit-invalid\n"
                            "$speckit-implement SECRET_SENTINEL\ntokens used\n1,000\n"
                            "OpenAI Codex v1\nuser\n$speckit-implement\ncodex\ninterrupted\n"
                            "OpenAI Codex v1\nuser\n$speckit-plan\nthinking\ntokens used\n2.000\n")
            records = module.session_metrics(path)
            self.assertEqual(["qa", "develop", "architecture"], [r["stage"] for r in records])
            self.assertEqual([1000, None, 2000], [r["reported_tokens"] for r in records])
            self.assertNotIn("SECRET_SENTINEL", json.dumps(records))

    def test_first_metered_repeat_and_unknown_counts_reconcile(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            logs = root / ".agentflow/runs"
            logs.mkdir(parents=True)
            (logs / "TASK-001.live.log").write_text(
                "OpenAI Codex v1\nuser\n$speckit-implement\ncodex\ntokens used\n100\n"
                "OpenAI Codex v1\nuser\n$speckit-implement\ncodex\ntokens used\n200\n")
            (logs / "TASK-002.live.log").write_text(
                "OpenAI Codex v1\nuser\n$speckit-implement\ncodex\ntokens used\n300\n")
            (logs / "TASK-003.live.log").write_text("tokens used\n400\n")
            result = module.stage_audit(root)
            self.assertEqual(1000, result["reported_tokens"])
            self.assertEqual(60.0, result["attributed_token_percent"])
            develop, unknown = result["stages"]
            self.assertEqual(400, develop["first_metered_tokens"])
            self.assertEqual(200, develop["repeat_metered_tokens"])
            self.assertEqual(60.0, develop["token_percent"])
            self.assertIsNone(unknown["repeat_metered_tokens"])
            self.assertFalse(result["tasks"][3]["log_available"])

    def test_reused_session_identity_is_flagged_without_disclosure(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            logs = root / ".agentflow/runs"
            logs.mkdir(parents=True)
            (logs / "TASK-001.live.log").write_text(
                "OpenAI Codex v1\nsession id: PRIVATE_SENTINEL\nuser\n$speckit-implement\ncodex\ntokens used\n100\n"
                "OpenAI Codex v1\nsession id: PRIVATE_SENTINEL\nuser\n$speckit-implement\ncodex\ntokens used\n200\n")
            result = module.stage_audit(root)
            self.assertTrue(result["tasks"][0]["reused_session_ids"])
            self.assertEqual(["TASK-001"], result["no_reused_session_cohort"]["excluded_tasks"])
            self.assertEqual(0, result["no_reused_session_cohort"]["reported_tokens"])
            self.assertNotIn("PRIVATE_SENTINEL", json.dumps(result))
            (logs / "TASK-002.live.log").write_text(
                "OpenAI Codex v1\nsession id: PRIVATE_SENTINEL\nuser\n$speckit-implement\ncodex\ntokens used\n300\n")
            result = module.stage_audit(root)
            self.assertTrue(result["tasks"][1]["reused_session_ids"])
            self.assertEqual(["TASK-001", "TASK-002"], result["no_reused_session_cohort"]["excluded_tasks"])

    def test_grouped_counts_and_ansi_with_no_transcript_disclosure(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "log"
            path.write_text("SECRET_SENTINEL\n[2026-10-01] specify workflow resume abc\n"
                            "tokens used\n12,345\n\x1b[32mtokens used\x1b[0m\n67.890\n"
                            "tokens used\n123\ntokens used\n1.25\ntokens used\n")
            result = module.log_metrics(path)
            self.assertEqual(result, {"completed_sessions": 3, "reported_tokens": 80358,
                                      "runner_invocations": 1})
            self.assertNotIn("SECRET_SENTINEL", json.dumps(result))

    def test_missing_or_incomplete_usage_is_unknown(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "log"
            self.assertIsNone(module.log_metrics(path)["reported_tokens"])
            path.write_text("tokens used\ninterrupted\n")
            self.assertIsNone(module.log_metrics(path)["reported_tokens"])

    def test_all_tasks_status_volume_and_terminal_verdicts(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "backlog").mkdir()
            (root / "backlog/TASK-001-test.md").write_text("---\nstatus: done\n---\n")
            feature = root / "specs/001-test"
            (feature / "handoffs").mkdir(parents=True)
            (feature / "handoffs/develop.md").write_text("one two")
            (feature / "qa-report.md").write_text("Evidence\nVerdict: PASS\n")
            (feature / "review-report.md").write_text("Verdict: PASS\nLater blocker\n")
            rows = module.audit(root)
            self.assertEqual(15, len(rows))
            self.assertEqual("done", rows[0]["status"])
            self.assertEqual("PASS", rows[0]["qa"])
            self.assertIsNone(rows[0]["review"])
            self.assertEqual(2, rows[0]["handoff_words"])
            self.assertIsNone(rows[1]["artifact_words"])

    def test_all_agent_stages_reference_policy_and_keep_gates(self):
        workflow = (ROOT / ".agentflow/workflow.yml").read_text()
        installed = (ROOT / ".specify/workflows/desapp-delivery/workflow.yml").read_text()
        self.assertEqual(workflow, installed)
        for stage in ("product", "product_challenge", "architecture", "develop", "qa", "review"):
            block = workflow.split(f"  - id: {stage}\n", 1)[1].split("\n  - id:", 1)[0]
            self.assertIn("docs/AGENT_CONTEXT_POLICY.md", block)
        self.assertNotIn("  - id: tasks\n", workflow)
        self.assertIn("$speckit-plan", workflow)
        self.assertIn("$speckit-tasks", workflow)
        for gate in ("product_decision", "product_check", "plan_ready", "tasks_ready", "develop_ready", "qa_ready"):
            self.assertIn(f"  - id: {gate}\n", workflow)


if __name__ == "__main__":
    unittest.main()
