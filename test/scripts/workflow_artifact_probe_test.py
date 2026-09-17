#!/usr/bin/env python3
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[2] / "scripts" / "workflow_artifact_probe.py"
SPEC = importlib.util.spec_from_file_location("workflow_artifact_probe", SCRIPT)
PROBE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(PROBE)


class WorkflowArtifactProbeTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.feature = self.root / "specs" / "003-example"
        (self.root / ".specify").mkdir()
        self.feature.mkdir(parents=True)
        (self.feature / "handoffs").mkdir()
        (self.root / ".specify" / "feature.json").write_text(
            json.dumps({"feature_directory": "specs/003-example"}), encoding="utf-8"
        )
        for relative in PROBE.STAGES["develop"]:
            path = self.feature / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("present\n", encoding="utf-8")

    def tearDown(self):
        self.temp.cleanup()

    def test_develop_fails_when_completed_task_names_missing_artifact(self):
        (self.feature / "tasks.md").write_text(
            "- [X] T014 Record evidence in `specs/003-example/verification.md`\n",
            encoding="utf-8",
        )
        with self.assertRaisesRegex(RuntimeError, "verification.md"):
            PROBE.probe(self.root, "develop")

    def test_develop_accepts_existing_completed_task_artifacts(self):
        (self.feature / "tasks.md").write_text(
            "- [X] T014 Record evidence in `verification.md`\n"
            "- [X] T015 Run `mix format --check-formatted` using `README.md`\n",
            encoding="utf-8",
        )
        (self.feature / "verification.md").write_text("evidence\n", encoding="utf-8")
        (self.root / "README.md").write_text("instructions\n", encoding="utf-8")
        self.assertTrue(PROBE.probe(self.root, "develop")["valid"])

    def test_unchecked_task_does_not_require_future_artifact(self):
        (self.feature / "tasks.md").write_text(
            "- [ ] T014 Record evidence in `verification.md`\n", encoding="utf-8"
        )
        self.assertTrue(PROBE.probe(self.root, "develop")["valid"])

    def test_develop_accepts_glob_when_an_artifact_matches(self):
        (self.feature / "tasks.md").write_text(
            "- [X] T005 Create `priv/repo/migrations/*_create_catalog_tables.exs`\n",
            encoding="utf-8",
        )
        migration = self.root / "priv" / "repo" / "migrations" / "20260917090000_create_catalog_tables.exs"
        migration.parent.mkdir(parents=True)
        migration.write_text("migration\n", encoding="utf-8")

        self.assertTrue(PROBE.probe(self.root, "develop")["valid"])

    def test_develop_rejects_glob_without_a_matching_artifact(self):
        (self.feature / "tasks.md").write_text(
            "- [X] T005 Create `priv/repo/migrations/*_create_catalog_tables.exs`\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(RuntimeError, r"\*_create_catalog_tables"):
            PROBE.probe(self.root, "develop")

    def test_develop_rejects_glob_that_escapes_repository(self):
        outside = self.root.parent / f"escaped-{self.root.name}.md"
        outside.write_text("outside repository\n", encoding="utf-8")
        self.addCleanup(outside.unlink, missing_ok=True)
        (self.feature / "tasks.md").write_text(
            f"- [X] T005 Create `../escaped-{self.root.name[:4]}*.md`\n",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(RuntimeError, r"escaped-.*\*\.md"):
            PROBE.probe(self.root, "develop")


if __name__ == "__main__":
    unittest.main()
