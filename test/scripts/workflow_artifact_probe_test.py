#!/usr/bin/env python3
import importlib.util
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[2] / "scripts" / "workflow_artifact_probe.py"
SPEC = importlib.util.spec_from_file_location("workflow_artifact_probe", SCRIPT)
PROBE = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(PROBE)


class ProbeFixture(unittest.TestCase):
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
        subprocess.run(['git','init','-q','-b','003-example'],cwd=self.root,check=True)
        (self.root/'backlog').mkdir()
        (self.root/'backlog/TASK-003-example.md').write_text('---\nid: TASK-003\ntitle: Example\nstatus: wip\nactive_run: run\n---\n')
        for relative in PROBE.STAGES["develop"]:
            path = self.feature / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("present\n", encoding="utf-8")

        (self.feature/'spec.md').write_text('**Feature Branch**: `003-example`\n')

    def tearDown(self):
        self.temp.cleanup()


class WorkflowArtifactProbeTest(ProbeFixture):
    def test_pointer_is_not_authority(self):
        (self.root/'.specify/feature.json').write_text('{"feature_directory":"specs/099-other"}')
        self.assertEqual(PROBE.active_feature(self.root),self.feature)
        (self.root/'.specify/feature.json').unlink()
        self.assertEqual(PROBE.active_feature(self.root),self.feature)

    def test_base_detached_and_wrong_branch_are_rejected(self):
        for branch in ('main','003-wrong'):
            subprocess.run(['git','symbolic-ref','HEAD',f'refs/heads/{branch}'],cwd=self.root,check=True)
            with self.assertRaises(RuntimeError):PROBE.active_feature(self.root)
        subprocess.run(['git','-c','user.name=Test','-c','user.email=test@example.test','commit','--allow-empty','-qm','fixture'],cwd=self.root,check=True)
        subprocess.run(['git','checkout','--detach','-q'],cwd=self.root,check=True)
        with self.assertRaises(RuntimeError):PROBE.active_feature(self.root)

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

    def test_develop_ignores_documented_url_with_file_suffix(self):
        (self.feature / "tasks.md").write_text(
            "- [X] T014 Serve `/openapi.json` from `priv/static/openapi.json`\n",
            encoding="utf-8",
        )
        contract = self.root / "priv" / "static" / "openapi.json"
        contract.parent.mkdir(parents=True)
        contract.write_text("{}\n", encoding="utf-8")

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


class AuthoritativeReceiptSelectionTest(ProbeFixture):
    def test_unequal_numbers_select_stage_and_receipt_despite_stale_pointer(self):
        from scripts.agentflow_check import run_check
        self.feature.rename(self.feature.with_name('055-example'))
        self.feature=self.feature.with_name('055-example')
        self.feature.joinpath('spec.md').write_text('**Feature Branch**: `003-example`\nFR-001\n')
        self.feature.joinpath('tasks.md').write_text('- [X] T001 Create implementation\n')
        self.feature.joinpath('verification.json').write_text(json.dumps({
            'schema_version':1,'runtime_required':False,
            'checks':[{'id':'association','argv':['python3','-c',
                'from pathlib import Path; p=Path("specs/055-example/spec.md"); assert p.read_text().splitlines() == ["**Feature Branch**: `003-example`", "FR-001"]; print("Validated owned fixture specification")']}],
            'coverage':{'FR-001':['association']},'task_stages':{}}))
        self.assertEqual(PROBE.active_feature(self.root),self.feature)
        self.assertEqual(run_check(self.root,PROBE.active_feature(self.root),'association'),0)
        self.assertTrue((self.feature/'handoffs/check-association.json').is_file())
        self.assertTrue(PROBE.probe(self.root,'develop',True)['valid'])
        # Unchecking an implementation task must still close the readiness gate.
        self.feature.joinpath('tasks.md').write_text('- [ ] T001 Create implementation\n')
        with self.assertRaisesRegex(RuntimeError,'Incomplete implementation task'):
            PROBE.probe(self.root,'develop',True)
        self.feature.joinpath('tasks.md').write_text('- [X] T001 Create implementation\n')
        # A passing receipt remains bound to actual output and source bytes.
        receipt=json.loads((self.feature/'handoffs/check-association.json').read_text())
        evidence=self.root/receipt['evidence'];evidence.write_text('altered output\n')
        with self.assertRaisesRegex(RuntimeError,'changed check output'):
            PROBE.probe(self.root,'develop',True)

    def test_stage_selection_refuses_shared_invalid_associations(self):
        from test.scripts.agentflow_feature_test import Fixture,ASSOCIATION_CASES,poison
        for case in ASSOCIATION_CASES:
            if case=='foreign-reports' or case.startswith(('foreign-qa-','foreign-review-','outside-')):continue # stage selection does not read verdict outputs
            with self.subTest(case=case):
                fixture=Fixture();fixture.setUp()
                try:
                    poison(fixture,case)
                    subprocess.run(['git','init','-q','-b','017-football-data-api-adapter'],cwd=fixture.root,check=True)
                    before={p:p.read_bytes() for p in (fixture.root/'backlog').glob('*.md')}
                    session=fixture.root/'.specify/feature.json';session.parent.mkdir(exist_ok=True);session.write_text('{"feature_directory":"specs/099-other"}')
                    session_before=session.read_bytes()
                    with self.assertRaises(RuntimeError):PROBE.active_feature(fixture.root)
                    self.assertEqual({p:p.read_bytes() for p in before},before)
                    self.assertEqual(session.read_bytes(),session_before)
                finally:fixture.doCleanups()


if __name__ == "__main__":
    unittest.main()
