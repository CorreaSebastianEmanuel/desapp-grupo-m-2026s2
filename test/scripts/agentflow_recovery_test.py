"""Durable stage attempt and retry policy tests."""
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scripts import agentflow_stage_checks as checks
from scripts.agentflow_verification import atomic_json


class StageAttemptTest(unittest.TestCase):
    def test_two_unchanged_failed_attempts_refuse_third_and_relevant_change_resets_scope(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            manifest = [{"id": "unit", "argv": ["python3", "-m", "unittest"], "env": {}}]
            with patch.object(checks, "retry_fingerprint", return_value="same-input"):
                for _ in range(2):
                    path, data, attempt = checks._begin_attempt(root, feature, "develop", manifest)
                    attempt["state"] = "failed"
                    atomic_json(path, data)
                with self.assertRaisesRegex(RuntimeError, "retry limit"):
                    checks._begin_attempt(root, feature, "develop", manifest)
            with patch.object(checks, "retry_fingerprint", return_value="repaired-input"):
                path, data, attempt = checks._begin_attempt(root, feature, "develop", manifest)
                self.assertEqual(attempt["state"], "running")
                self.assertEqual(len(data["attempts"]), 3)

    def test_corrupt_stage_journal_is_not_replaced(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            path = checks._stage_attempt_file(root, feature, "qa")
            path.parent.mkdir(parents=True); path.write_text("not-json")
            with self.assertRaisesRegex(RuntimeError, "corrupt"):
                checks._begin_attempt(root, feature, "qa", [])
            self.assertEqual(path.read_text(), "not-json")

    def test_running_attempt_is_recovered_as_interrupted_and_counts_toward_cap(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            manifest = [{"id": "unit", "argv": ["python3", "-m", "unittest"], "env": {}}]
            with patch.object(checks, "retry_fingerprint", return_value="same-input"):
                path, data, attempt = checks._begin_attempt(root, feature, "develop", manifest)
                attempt["state"] = "failed"; attempt["elapsed_ms"] = 4
                atomic_json(path, data)
                _, data, attempt = checks._begin_attempt(root, feature, "develop", manifest)
                attempt["state"] = "running"  # Simulate process death before finalization.
                atomic_json(path, data)
                with self.assertRaisesRegex(RuntimeError, "retry limit"):
                    checks._begin_attempt(root, feature, "develop", manifest)
            final = __import__("json").loads(path.read_text())
            self.assertEqual([row["state"] for row in final["attempts"]], ["failed", "interrupted"])

    def test_attempt_finalization_is_idempotent_and_preserves_partial_results(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp); feature = root / "feature"; feature.mkdir()
            path, data, attempt = checks._begin_attempt(root, feature, "qa", [])
            journal = {"checks": [{"id": "done", "status": "passed", "evidence": ".agentflow/runs/checks/done.log"},
                                  {"id": "pending", "status": "unexecuted", "evidence": None}],
                       "elapsed_ms": 8}
            checks._finish_attempt(path, data, attempt, journal)
            once = __import__("json").loads(path.read_text())
            checks._finish_attempt(path, data, attempt, journal)
            twice = __import__("json").loads(path.read_text())
            self.assertEqual(twice["attempts"][0]["state"], "failed")
            self.assertEqual(twice["attempts"][0]["failing_checks"], ["pending"])
            self.assertEqual(twice["attempts"][0]["evidence"], [".agentflow/runs/checks/done.log"])


if __name__ == "__main__":
    unittest.main()
