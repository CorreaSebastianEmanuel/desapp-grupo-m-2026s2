"""Conditional artifacts must agree across readiness and direct consumers."""
import json
from unittest.mock import patch

from scripts import workflow_artifact_probe as probe
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture, applicability, verification


class ApplicabilityTest(DeliveryFixture):
    def setup_plan(self, required=False):
        self.write('specs/003-example/plan.md', 'Plan\n```json artifact-applicability\n' +
                   json.dumps(applicability(required)) + '\n```\n')
        self.write('specs/003-example/handoffs/architecture.md', 'delta')
        self.json('specs/003-example/verification.json',verification(['python3','-c',"print('fixture')"]))

    def test_missing_applicable_artifacts_block_plan(self):
        self.setup_plan(True)
        with self.assertRaisesRegex(RuntimeError, 'research.md'):
            probe.probe(self.root, 'plan')

    def test_justified_minimal_plan_passes(self):
        self.setup_plan()
        self.assertTrue(probe.probe(self.root, 'plan')['valid'])

    def test_missing_decision_and_empty_reason_fail(self):
        for mutate in (lambda d: d.pop('research'), lambda d: d['research'].update(reason='')):
            data = applicability()
            mutate(data)
            self.write('specs/003-example/plan.md', '```json artifact-applicability\n'+json.dumps(data)+'\n```')
            self.write('specs/003-example/handoffs/architecture.md', 'delta')
            with self.assertRaises(RuntimeError):
                probe.probe(self.root, 'plan')

    def test_required_directory_must_contain_nonempty_safe_file(self):
        from scripts.agentflow_artifacts import validate
        self.setup_plan(True)
        for name in ('research.md', 'data-model.md', 'quickstart.md'):
            self.write('specs/003-example/'+name, 'feature-specific')
        self.write('specs/003-example/contracts/empty.md', '')
        with self.assertRaisesRegex(RuntimeError, 'contracts'):
            validate(self.feature)
        self.write('specs/003-example/contracts/contract.md', 'interface')
        self.assertTrue(validate(self.feature)['contracts']['required'])

    def test_legacy_plan_keeps_existing_policy(self):
        from scripts.agentflow_artifacts import validate
        self.write('specs/003-example/plan.md', 'Legacy plan')
        self.baseline()
        self.assertIsNone(validate(self.feature))

    def test_whole_policy_deletion_cannot_pass_plan_or_tasks_gates(self):
        self.setup_plan()
        self.write('specs/003-example/handoffs/tasks.md', 'delta')
        self.write('specs/003-example/tasks.md', '- [X] T001 Build behavior\n')
        for committed in (False, True):
            self.setup_plan()
            if committed:
                self.baseline()
            self.write('specs/003-example/plan.md', 'Plan without its policy\n')
            for stage in ('plan', 'tasks'):
                with self.subTest(committed=committed, stage=stage):
                    with self.assertRaisesRegex(RuntimeError, 'applicability'):
                        probe.probe(self.root, stage, True)

    def test_new_plan_cannot_claim_legacy_in_policy_aware_repository(self):
        from scripts.agentflow_artifacts import validate
        self.write('scripts/agentflow_artifacts.py', '# policy already installed\n')
        self.write('specs/003-example/plan.md', 'New plan without required policy\n')
        self.baseline()
        with self.assertRaisesRegex(RuntimeError, 'applicability'):
            validate(self.feature)

    def test_direct_consumers_reject_whole_block_deletion(self):
        import os, shutil, subprocess
        from pathlib import Path
        source = Path(__file__).resolve().parents[2]
        self.setup_plan()
        shutil.copytree(source/'.specify/scripts', self.root/'.specify/scripts')
        shutil.copytree(source/'.specify/templates', self.root/'.specify/templates')
        shutil.copytree(source/'scripts', self.root/'scripts', dirs_exist_ok=True,
                        ignore=shutil.ignore_patterns('__pycache__'))
        self.baseline()
        self.write('specs/003-example/plan.md', 'Deleted complete policy\n')
        env = {**os.environ, 'SPECIFY_FEATURE_DIRECTORY':str(self.feature)}
        for consumer in ('setup-tasks.sh', 'check-prerequisites.sh'):
            result = subprocess.run(['bash', str(self.root/'.specify/scripts/bash'/consumer), '--json'],
                                    cwd=self.root, env=env, capture_output=True, text=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('applicability', result.stderr)

    def test_direct_shell_and_cli_consumers_reject_missing_required_support(self):
        import os,shutil,subprocess,sys
        from pathlib import Path
        root=Path(__file__).resolve().parents[2]
        shutil.copytree(root/'.specify/scripts',self.root/'.specify/scripts')
        shutil.copytree(root/'.specify/templates',self.root/'.specify/templates')
        shutil.copytree(root/'scripts',self.root/'scripts',dirs_exist_ok=True,
                        ignore=shutil.ignore_patterns('__pycache__'))
        self.setup_plan(True)
        env={**os.environ,'SPECIFY_FEATURE_DIRECTORY':str(self.feature)}
        for consumer in ('setup-tasks.sh','check-prerequisites.sh'):
            result=subprocess.run(['bash',str(self.root/'.specify/scripts/bash'/consumer),'--json'],
                                  cwd=self.root,env=env,capture_output=True,text=True)
            self.assertNotEqual(result.returncode,0)
            self.assertIn('research.md',result.stderr)
        result=subprocess.run([sys.executable,str(root/'scripts/agentflow_artifacts.py'),str(self.feature)],
                              capture_output=True,text=True)
        self.assertNotEqual(result.returncode,0)
        self.assertIn('research.md',result.stderr)

    def test_setup_does_not_require_a_plan_before_creation(self):
        from scripts.agentflow_artifacts import validate
        (self.feature/'plan.md').unlink()
        self.assertIsNone(validate(self.feature,setup=True))

    def test_escape_and_duplicate_decisions_fail_closed(self):
        from scripts.agentflow_artifacts import validate
        self.setup_plan(True)
        outside=self.write('outside.md','unrelated contents')
        (self.feature/'research.md').symlink_to(outside)
        with self.assertRaisesRegex(RuntimeError,'Unsafe'):
            validate(self.feature)
        self.write('specs/003-example/plan.md','```json artifact-applicability\n{"schema_version":1,"schema_version":1}\n```')
        with self.assertRaises(RuntimeError): validate(self.feature)
