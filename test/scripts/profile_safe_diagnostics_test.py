import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from scripts.profile_safe_diagnostics import parse_profile_diagnostics


class SafeProfileDiagnosticsTest(unittest.TestCase):
    def test_maps_only_registered_identity_and_discards_raw_canaries(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            inventory = root / "config/test_profiles.json"
            inventory.parent.mkdir()
            runner, file, case_id, profile = "python", "test/scripts/example_test.py", "test.scripts.example_test.Example.test_safe", "unit"
            ident = hashlib.sha256("\0".join((runner, file, case_id)).encode()).hexdigest()[:24]
            invalid_case = "test.scripts.example_test.Example.test_oversized"
            invalid_ident = hashlib.sha256("\0".join((runner, file, invalid_case)).encode()).hexdigest()[:24]
            inventory.write_text(json.dumps({"schema_version": 1, "entries": [
                {"id": ident, "runner": runner, "file": file, "case_id": case_id, "profile": profile},
                {"id": invalid_ident, "runner": runner, "file": file, "case_id": invalid_case, "profile": profile}]}))
            evidence = root / ".agentflow/runs/checks/failure.log"
            evidence.parent.mkdir(parents=True)
            evidence.write_text("\n".join([
                f"PROFILE_DISCREPANCY id={ident} line=42",
                f"PROFILE_DISCREPANCY id={ident} line=1000001",
                f"PROFILE_DISCREPANCY id={invalid_ident} line=1000001",
                "PROFILE_DISCREPANCY id=aaaaaaaaaaaaaaaaaaaaaaaa line=91",
                "PROFILE_BROWSER_DIAGNOSTIC cause=launch-failed stage=integration",
                "PROFILE_BROWSER_DIAGNOSTIC cause=raw-private-message stage=integration",
                "PROFILE_MEMBERSHIP_DIAGNOSTIC profile=unit phase=event-reconciliation reason=missing-events expected=2 observed=3 missing_started=0 missing_passed=1 extra=0 duplicate=0 invalid_state=0 wrong_nonce=0",
                "PROFILE_MEMBERSHIP_DIAGNOSTIC profile=unit phase=event-reconciliation reason=private-detail expected=2 observed=3 missing_started=0 missing_passed=1 extra=0 duplicate=0 invalid_state=0 wrong_nonce=0",
                "PROFILE_MEMBERSHIP_EXTRA profile=unit runner=python file=test/scripts/example_test.py",
                "PROFILE_MEMBERSHIP_EXTRA profile=unit runner=python file=test/private_test.py",
                "CP1_PROFILE_OUTCOME status=failed category=component-failure",
                "CI_PROFILE_DIAGNOSTIC profile=integration category=test-failure",
                "PROFILE_STEP_DIAGNOSTIC profile=integration step=tests partition=regular",
                "SECRET-TRACEBACK-CANARY", ""]))
            result = parse_profile_diagnostics(root, evidence)
            self.assertEqual(result, {
                "profile_discrepancies": [{"id": ident, "runner": runner, "file": file,
                    "case_id": case_id, "profile": profile, "failure_line": 42}],
                "profile_categories": ["component-failure"],
                "profile_failures": [{"profile": "integration", "category": "test-failure"}],
                "profile_steps": [{"profile": "integration", "step": "tests", "partition": "regular"}],
                "profile_browser_diagnostics": [{"cause": "launch-failed", "stage": "integration"}],
                "profile_membership_diagnostics": [{"profile": "unit", "phase": "event-reconciliation",
                    "reason": "missing-events", "expected": 2, "observed": 3,
                    "missing_started": 0, "missing_passed": 1, "extra": 0, "duplicate": 0,
                    "invalid_state": 0, "wrong_nonce": 0}],
                "profile_membership_extra_sources": [{"profile": "unit", "runner": "python",
                    "file": "test/scripts/example_test.py"}],
            })
            self.assertNotIn("SECRET-TRACEBACK-CANARY", json.dumps(result))

    def test_rejects_evidence_outside_protected_directory(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            evidence = root / "private.log"
            evidence.write_text("PROFILE_DISCREPANCY id=aaaaaaaaaaaaaaaaaaaaaaaa")
            self.assertEqual(parse_profile_diagnostics(root, evidence), {})


if __name__ == "__main__":
    unittest.main()
