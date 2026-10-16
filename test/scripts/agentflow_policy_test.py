"""Behavioral gates preserve canonical completeness and independent acceptance."""
import json
import sys
from scripts.agentflow_verification import readiness
from scripts.agentflow_feature import FeatureAssociation, require_reports
from scripts.agentflow_check import run_check
from scripts import workflow_artifact_probe as probe
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture, applicability, verification


class PolicyTest(DeliveryFixture):
    def setUp(self):
        super().setUp()
        self.json('specs/003-example/verification.json',verification([sys.executable,'-c',"print('fixture acceptance')"]))

    def test_canonical_manifest_required_with_conditional_plan(self):
        self.write('specs/003-example/plan.md','```json artifact-applicability\n'+json.dumps(applicability())+'\n```')
        self.write('specs/003-example/handoffs/architecture.md','delta')
        (self.feature/'verification.json').unlink()
        with self.assertRaisesRegex(RuntimeError,'verification.json'):
            probe.probe(self.root,'plan')

    def test_implementation_cannot_be_mislabeled_as_independent_gate(self):
        self.write('specs/003-example/tasks.md','- [ ] T001 [gate:qa] Implement the feature\n')
        data=verification([sys.executable,'-c',"print('fixture')"])
        data['task_stages']={'T001':'qa'}
        self.json('specs/003-example/verification.json',data)
        with self.assertRaisesRegex(RuntimeError,'Only explicit independent'):
            readiness(self.root,self.feature)

    def test_both_exact_terminal_verdicts_remain_required(self):
        association=FeatureAssociation(self.root/'backlog/TASK-003-example.md','003-example',self.feature)
        self.write('specs/003-example/qa-report.md','Verdict: PASS\n')
        for review in ('Verdict: FAIL','Verdict: PASS\nAdditional unverified text','PASS'):
            self.write('specs/003-example/review-report.md',review)
            with self.assertRaises(RuntimeError): require_reports(association)
        self.write('specs/003-example/review-report.md','Verdict: PASS\n')
        require_reports(association)
        self.write('specs/003-example/qa-report.md','Verdict: FAIL\n')
        with self.assertRaises(RuntimeError): require_reports(association)

    def test_current_checklist_is_a_read_only_gate(self):
        self.write('specs/003-example/tasks.md','- [X] T001 Build behavior\n')
        self.write('specs/003-example/checklists/requirements.md','- [ ] Reviewer criterion\n')
        self.baseline()
        run_check(self.root,self.feature,'fixture')
        before=(self.feature/'checklists/requirements.md').read_bytes()
        with self.assertRaisesRegex(RuntimeError,'checklist'):
            readiness(self.root,self.feature)
        self.assertEqual((self.feature/'checklists/requirements.md').read_bytes(),before)

    def test_reports_alone_do_not_authorize_summary_or_local_readiness(self):
        from scripts.agentflow_evidence import finalize
        self.write('specs/003-example/qa-report.md','Verdict: PASS\n')
        self.write('specs/003-example/review-report.md','Verdict: PASS\n')
        with self.assertRaises(RuntimeError): finalize(self.root,'TASK-003')
        self.assertFalse((self.feature/'evidence-summary.json').exists())


class CandidateBoundaryTest(__import__('unittest').TestCase):
    def test_task064_preserves_application_and_checkpoint_boundary(self):
        from pathlib import Path
        import subprocess
        from scripts.agentflow_ci_check import allowed_source
        root=Path(__file__).resolve().parents[2]
        head=subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()
        self.assertFalse(allowed_source('lib/football_market/market.ex'))
        self.assertFalse(allowed_source('docs/PRODUCT.md'))
        self.assertFalse(allowed_source('docs/CHECKPOINTS.md'))
        self.assertFalse(allowed_source('.github/workflows/agentflow-finalize.yml'))
        if head.startswith('064-'):
            changed=subprocess.check_output(['git','diff','HEAD','--name-only','-z'],cwd=root).decode().split('\0')
            new=subprocess.check_output(['git','ls-files','--others','--exclude-standard','-z'],cwd=root).decode().split('\0')
            illegal=sorted(name for name in set(changed+new)-{''} if not allowed_source(name))
            self.assertEqual(illegal,[],'Candidate extends the approved source boundary')
