"""Vibecode documentation policy examples and exclusions."""
import unittest
from pathlib import Path


class WorkflowSpeedPolicyTest(unittest.TestCase):
    def test_low_risk_procedure_keeps_preflight_ci_independent_gates_and_human_merge(self):
        text = Path("docs/WORKFLOW_SPEED.md").read_text(encoding="utf-8")
        section = text.split("## Procedimiento proporcional", 1)[1].split("## Medición", 1)[0]
        for phrase in ("especificación", "rollback", "preflight", "CI", "QA", "review", "merge\nhumano"):
            self.assertIn(phrase, section)

    def test_high_risk_and_workflow_changes_are_excluded_and_no_selector_added(self):
        text = Path("docs/WORKFLOW_SPEED.md").read_text(encoding="utf-8")
        section = text.split("## Procedimiento proporcional", 1)[1].split("## Medición", 1)[0]
        for phrase in ("seguridad", "finanzas", "integridad de datos", "migraciones",
                       "contratos externos", "workflow/gates/herramientas", "impacto incierto", "TASK-070"):
            self.assertIn(phrase, section)
        agentflow = Path("agentflow").read_text(encoding="utf-8")
        self.assertNotIn("--vibecode", agentflow)


if __name__ == "__main__":
    unittest.main()
