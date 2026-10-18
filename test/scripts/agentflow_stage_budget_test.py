"""Stage budget: graceful per-stage interruption pauses the run, not the task."""
import io
import json
import sys
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
from test.scripts.agentflow_branch_test import AGENTFLOW
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

SLEEPER = [sys.executable, '-c', 'import time; time.sleep(300)']
QUICK = [sys.executable, '-c', 'print("exiting stage")']


class FakeClock:
    seconds = 0.0

    def monotonic(self):
        return self.seconds

    def sleep(self, amount):
        self.seconds += amount


class StageBudgetFixture(DeliveryFixture):
    """Run monitor_process against a disposable run directory and clock."""

    def setUp(self):
        super().setUp()
        self.run = '1103-budgetrun'
        run_dir = self.root/'.specify/workflows/runs'/self.run
        run_dir.mkdir(parents=True, exist_ok=True)
        (run_dir/'state.json').write_text(json.dumps(
            {'current_step_id': 'develop', 'current_step_index': 7, 'status': 'running'})+'\n')
        (run_dir/'workflow.yml').write_text('steps:\n  - id: develop\n  - id: qa\n  - id: review\n')
        (run_dir/'log.jsonl').write_text('')
        for name, value in {'ROOT': self.root, 'BACKLOG': self.root/'backlog',
                            'FEEDBACK': self.root/'backlog/feedback', 'RUNS': self.root/'.agentflow/runs',
                            'SPEC_RUNS': self.root/'.specify/workflows/runs'}.items():
            patcher = patch.object(AGENTFLOW, name, value)
            patcher.start()
            self.addCleanup(patcher.stop)
        patcher = patch.object(AGENTFLOW.models, 'bind', lambda *_: None)
        patcher.start()
        self.addCleanup(patcher.stop)

    def monitor(self, command, budget_minutes):
        clock = FakeClock()
        patcher = patch.object(AGENTFLOW, 'time', clock)
        patcher.start()
        self.addCleanup(patcher.stop)
        # Real config wiring: the knob is read from the fixture's config.toml
        # (None writes no knob at all, exercising the disabled default).
        self.write('.agentflow/config.toml', 'max_feedback_cycles = 8\n'
                   + ('stage_timeout_minutes = %d\n' % budget_minutes if budget_minutes is not None else ''))
        output = io.StringIO()
        with redirect_stdout(output):
            code, run = AGENTFLOW.monitor_process(command, self.task_path(), run_hint=self.run)
        return code, run, output.getvalue(), clock

    def task_path(self):
        return self.root/'backlog/TASK-003-example.md'

    def state(self):
        return json.loads((self.root/'.specify/workflows/runs'/self.run/'state.json').read_text())

    def events(self):
        return [json.loads(line) for line in
                (self.root/'.specify/workflows/runs'/self.run/'log.jsonl').read_text().splitlines() if line]


class StageBudgetTest(StageBudgetFixture):

    def test_exceeded_stage_pauses_gracefully_with_resume_message(self):
        code, run, output, clock = self.monitor(SLEEPER, budget_minutes=1)
        self.assertEqual(code, 130)
        self.assertEqual(run, self.run)
        state = self.state()
        self.assertEqual(state['status'], 'paused')
        self.assertIn('Stage Development exceeded stage_timeout_minutes=1', state['error'])
        self.assertIn('interrupting safely', state['error'])
        self.assertEqual(state['current_step_id'], 'develop')
        event = [e for e in self.events() if e.get('event') == 'stage_budget_exceeded'][0]
        self.assertEqual(event['stage'], 'develop')
        self.assertGreaterEqual(event['elapsed_seconds'], 60)
        self.assertIn(f'Progress preserved. Continue with: ./agentflow resume TASK-003', output)
        # Task status stays wip; resume re-dispatches the stage from its pointer.
        self.assertIn('status: wip', self.task_path().read_text())
        self.assertFalse((self.root/'.agentflow/runs/TASK-003.process.json').exists())
        # The pointer is untouched by the interruption itself.
        self.assertEqual(state['current_step_index'], 7)

    def test_zero_budget_never_interrupts(self):
        code, run, output, clock = self.monitor(QUICK, budget_minutes=0)
        self.assertEqual(code, 0)
        self.assertNotIn('stage_budget_exceeded', str(self.events()))
        self.assertEqual(self.state()['status'], 'running')

    def test_missing_knob_defaults_to_disabled(self):
        code, run, output, clock = self.monitor(QUICK, budget_minutes=None)
        self.assertEqual(code, 0)
        self.assertEqual(self.state()['status'], 'running')

    def test_clock_resets_when_a_new_stage_appears(self):
        """Budget measured from a step change: rewrite state mid-monitor to a
        later stage so elapsed restarts from zero."""
        flag = {'switched': False}
        original_read = AGENTFLOW.read_run_state

        def switching(run):
            state = original_read(run)
            if state and 'develop' == state.get('current_step_id') and flag['switched'] is False and clock_seconds() >= 30:
                flag['switched'] = True
                state = {**state, 'current_step_id': 'qa', 'current_step_index': 8}
                (self.root/'.specify/workflows/runs'/self.run/'state.json').write_text(json.dumps(state)+'\n')
            return state

        def clock_seconds():
            return AGENTFLOW.time.seconds

        patcher = patch.object(AGENTFLOW, 'read_run_state', side_effect=switching)
        patcher.start()
        self.addCleanup(patcher.stop)
        clock = FakeClock()
        patcher = patch.object(AGENTFLOW, 'time', clock)
        patcher.start()
        self.addCleanup(patcher.stop)
        self.write('.agentflow/config.toml', 'stage_timeout_minutes = 1\nmax_feedback_cycles = 8\n')
        output = io.StringIO()
        with redirect_stdout(output):
            code, _ = AGENTFLOW.monitor_process(SLEEPER, self.task_path(), run_hint=self.run)
        self.assertEqual(code, 130)
        event = [e for e in self.events() if e.get('event') == 'stage_budget_exceeded'][0]
        # Without resetting the clock at the stage change, the interrupt would
        # hit the develop stage at fake-minute 1 before 'qa' could appear; the
        # qa event at nearly the full budget proves elapsed restarted.
        self.assertEqual(event['stage'], 'qa')
        self.assertLessEqual(event['elapsed_seconds'], 60)
        self.assertGreater(event['elapsed_seconds'], 0)
