"""Replay-safe measured subtotals with explicit unknown provenance."""
import json
import os
import subprocess
import sys
from pathlib import Path
from scripts.agentflow_runtime import metrics_summary, DIMENSIONS
from test.scripts.support.agentflow_delivery_fixtures import DeliveryFixture, usage_event


class MetricsTest(DeliveryFixture):
    def summary(self, values):
        path=self.write('events.jsonl',''.join(json.dumps(value)+'\n' for value in values))
        return metrics_summary(path)

    def test_replayed_events_are_not_counted_twice(self):
        event=usage_event(incremental_usage={'input_tokens':10,'output_tokens':3})
        summary=self.summary([event,event])
        self.assertEqual(summary['measured_input_plus_output'],13)
        self.assertFalse(summary['complete'])

    def test_conflicting_duplicates_are_unknown(self):
        first=usage_event(incremental_usage={'input_tokens':10,'output_tokens':3})
        second={**first,'incremental_usage':{'input_tokens':100,'output_tokens':3}}
        summary=self.summary([first,second])
        self.assertIsNone(summary['measured_input_plus_output'])
        self.assertEqual(summary['conflicting_events'],1)

    def test_unknown_dimensions_and_identity_are_never_filled_from_defaults(self):
        summary=self.summary([usage_event(incremental_usage={'input_tokens':10},resolved={'model':'gpt-6-luna','effort':'high'})])
        row=summary['stages'][0]
        self.assertIsNone(row['measured']['output_tokens'])
        self.assertIsNone(row['identities'][0]['observed_model'])
        self.assertEqual(row['dimension_coverage']['output_tokens']['unknown'],1)

    def test_cached_and_reasoning_subsets_are_not_added_to_parents(self):
        usage={key:1 for key in DIMENSIONS}
        usage.update(input_tokens=100,output_tokens=20,cached_input_tokens=50,reasoning_output_tokens=10)
        self.assertEqual(self.summary([usage_event(incremental_usage=usage)])['measured_input_plus_output'],120)

    def test_finished_attempt_without_usage_cannot_make_measurement_complete(self):
        values = [usage_event(attempt='a', incremental_usage={key: 1 for key in DIMENSIONS})]
        for attempt in ('a', 'b'):
            for event in ('agent_started', 'agent_ended'):
                values.append(usage_event(attempt=attempt, event_id=attempt+event,
                                          event=event, exit_code=0))
        summary = self.summary(values)
        self.assertFalse(summary['complete'])
        self.assertEqual(summary['stages'][0]['attempts'], 2)

    def test_reordered_events_and_interrupted_attempt_remain_partial(self):
        usage = {key: 1 for key in DIMENSIONS}
        values = [usage_event(event_id='end', event='agent_ended', exit_code=0),
                  usage_event(incremental_usage=usage),
                  usage_event(event_id='start', event='agent_started')]
        self.assertTrue(self.summary(values)['complete'])
        values.append(usage_event(attempt='interrupted', event_id='other', event='agent_started'))
        self.assertFalse(self.summary(values)['complete'])

    def test_identityless_duplicate_usage_stays_unknown(self):
        legacy = {'event': 'usage', 'stage': 'develop',
                  'incremental_usage': {key: 1 for key in DIMENSIONS}}
        summary = self.summary([legacy, legacy])
        self.assertIsNone(summary['measured_input_plus_output'])
        self.assertFalse(summary['complete'])

    def test_actual_wrapper_keeps_repeated_reset_and_resumed_counters_partial(self):
        root = Path(__file__).resolve().parents[2]
        fake = self.write('fake-provider', '#!'+sys.executable+'\nimport json\n'
                          'print(json.dumps({"type":"thread.started","thread_id":"fixture"}))\n'
                          'for count in (10, 10, 2):\n'
                          ' print(json.dumps({"type":"turn.completed","usage":'
                          '{"input_tokens":count,"output_tokens":count}}))\n')
        fake.chmod(0o755)
        path = self.root/'metrics.jsonl'
        env = {key: value for key, value in os.environ.items() if not key.startswith('AGENTFLOW_')}
        env.update(AGENTFLOW_CODEX_REAL=str(fake), AGENTFLOW_TASK_ID='TASK-003',
                   AGENTFLOW_METRICS_FILE=str(path))
        for args in (['exec'], ['exec', 'resume', '--last']):
            result = subprocess.run([sys.executable, str(root/'scripts/agentflow_codex.py'),
                                     *args, 'Agentflow stage: develop'], cwd=self.root,
                                    env=env, capture_output=True, text=True, timeout=10)
            self.assertEqual(result.returncode, 0, result.stderr)
        summary = metrics_summary(path)
        self.assertEqual(summary['measured_input_plus_output'], 20)
        self.assertFalse(summary['complete'])
        self.assertEqual(summary['stages'][0]['attempts'], 2)
        self.assertEqual(summary['stages'][0]['unknown_events'], 5)

    def test_pilot_names_reproducible_observations_and_authorized_boundary(self):
        root = Path(__file__).resolve().parents[2]
        text = (root/'docs/AGENTFLOW_PILOT.md').read_text()
        for required in ('Sol Medium', 'unknown', './agentflow metrics TASK-NNN',
                         'git diff', 'stat().st_size', 'retry', 'QA/review',
                         'normally authorized', 'Keep workflow changes and model changes'):
            self.assertIn(required, text)
