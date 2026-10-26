"""Disposable delivery inputs; never open a live run or launch a model."""
import json
import subprocess
import tempfile
import unittest
from pathlib import Path


class DeliveryFixture(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.git('init', '-q', '-b', '003-example')
        self.git('config', 'user.name', 'Fixture')
        self.git('config', 'user.email', 'fixture@example.test')
        self.feature = self.root / 'specs/003-example'
        self.write('backlog/TASK-003-example.md', '---\nid: TASK-003\ntitle: Example\nstatus: wip\nactive_run: none\n---\n')
        self.write('specs/003-example/spec.md', '**Feature Branch**: `003-example`\nFR-001 SC-001\n')
        self.write('specs/003-example/plan.md', 'Fixture plan\n```json artifact-applicability\n' +
                   json.dumps(applicability()) + '\n```\n')
        self.write('specs/003-example/tasks.md', '- [ ] T001 Build behavior\n')
        self.write('.gitignore', '.agentflow/runs/\n.specify/feature.json\n')
        self.write('scripts/local_services.sh', '#!/bin/sh\n[ "$1" = ready ] && exit 0\nexit 0\n')
        # Launcher behavior tests target state transitions and child dispatch.
        # The effective host toolchain belongs to dedicated preflight tests.
        from unittest.mock import patch
        preflight = patch('scripts.agentflow_preflight.preflight_or_raise')
        preflight.start()
        self.addCleanup(preflight.stop)

    def git(self, *args):
        return subprocess.run(['git', *args], cwd=self.root, capture_output=True, text=True, check=True).stdout.strip()

    def write(self, name, content):
        path = self.root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def json(self, name, value):
        return self.write(name, json.dumps(value) + '\n')

    def baseline(self):
        self.git('add', '.')
        self.git('commit', '-qm', 'fixture baseline')


def applicability(required=False):
    return {'schema_version': 1, **{key: {'required': required, 'reason': 'Fixture decision'}
            for key in ('research', 'data_model', 'contracts', 'quickstart')}}


def verification(argv):
    return {'schema_version': 1, 'runtime_required': False,
            'checks': [{'id': 'fixture', 'argv': argv}],
            'coverage': {'FR-001': ['fixture'], 'SC-001': ['fixture']}}


def usage_event(attempt='a', event_id='1', **fields):
    return {'schema_version': 1, 'task': 'TASK-003', 'stage': 'develop',
            'attempt': attempt, 'event_id': event_id, 'event': 'usage', **fields}


def assignment(stages):
    return {'schema_version': 1, 'assignment_id': 'fixture', 'task_id': 'TASK-003',
            'generation': 1, 'stages': stages}


def receipt(**fields):
    return {'schema_version': 2, 'state': 'passed', 'exit_code': 0,
            'stage': 'develop', 'workspace': 'fixture', **fields}


def final_summary(**fields):
    return {'schema_version': 1, 'task': 'TASK-003', 'checks': [], 'coverage': {}, **fields}


def feedback(impact='implementation', **fields):
    return {'discrepancy': 'Fixture regression', 'impact': impact,
            'required_regressions': ['fixture'], **fields}


def saved_snapshot(directory):
    """Byte snapshot suitable for asserting that resume preserves old state."""
    return {path.relative_to(directory).as_posix(): path.read_bytes()
            for path in directory.rglob('*') if path.is_file() and '.git' not in path.parts}
