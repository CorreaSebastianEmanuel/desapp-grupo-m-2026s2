#!/usr/bin/env python3
"""Shared plan-owned supporting-artifact applicability policy."""
from __future__ import annotations
import argparse
import json
import re
import subprocess
from pathlib import Path
try:
    from .agentflow_verification import unique_object
except ImportError:
    from agentflow_verification import unique_object

NAMES = {'research': 'research.md', 'data_model': 'data-model.md',
         'contracts': 'contracts', 'quickstart': 'quickstart.md'}


def historical_plan(plan: Path) -> bool:
    """Only Git-proven plans predating this policy retain legacy handling.

    Current plan contents or a saved workflow's age cannot establish provenance.
    An adopted policy in committed plan history also prevents legacy downgrade.
    Missing/shallow history fails closed rather than guessing compatibility.
    """
    root = plan.parent
    def git(*args):
        return subprocess.run(['git', *args], cwd=root, capture_output=True,
                              text=True, check=True).stdout.strip()
    try:
        root = Path(git('rev-parse', '--show-toplevel'))
        if git('rev-parse', '--is-shallow-repository') != 'false':
            return False
        relative = plan.resolve().relative_to(root.resolve()).as_posix()
        revisions = git('log', '--format=%H', '--diff-filter=A', '--', relative).splitlines()
        if not revisions or git('log', '--format=%H', '-G', 'artifact-applicability', '--', relative):
            return False
        revision = revisions[-1]
        # Require the actual historical blob; a deletion/re-add cannot invent it.
        git('show', f'{revision}:{relative}')
        policy = subprocess.run(['git', 'cat-file', '-e',
                                 f'{revision}:scripts/agentflow_artifacts.py'],
                                cwd=root, capture_output=True)
        return policy.returncode == 1 or policy.returncode == 128
    except (OSError, ValueError, subprocess.SubprocessError):
        return False


def validate(feature: Path, *, setup=False, stage=None):
    plan = feature / 'plan.md'
    if setup and not plan.exists():
        return None
    if not plan.is_file() or not plan.read_text(encoding='utf-8').strip():
        raise RuntimeError('Missing or empty plan.md')
    text = plan.read_text()
    blocks = re.findall(r'```json artifact-applicability\s*\n(.*?)\n```', text, re.S)
    if not blocks:
        if 'artifact-applicability' in text:
            raise RuntimeError('Malformed artifact-applicability block')
        if historical_plan(plan):
            return None
        raise RuntimeError('Missing artifact-applicability block; no historical legacy provenance')
    if len(blocks) != 1:
        raise RuntimeError('Exactly one artifact-applicability block is required')
    try:
        data = json.loads(blocks[0], object_pairs_hook=unique_object)
    except ValueError as error:
        raise RuntimeError('Invalid artifact-applicability JSON') from error
    if not isinstance(data, dict) or set(data) != {'schema_version', *NAMES} or type(data['schema_version']) is not int or data['schema_version'] != 1:
        raise RuntimeError('Artifact applicability requires schema 1 and all four decisions')
    for key, name in NAMES.items():
        entry = data[key]
        if not isinstance(entry, dict) or set(entry) != {'required', 'reason'} or type(entry['required']) is not bool or not isinstance(entry['reason'], str) or not entry['reason'].strip():
            raise RuntimeError(f'Invalid applicability decision: {key}')
        if not entry['required'] or setup:
            continue
        path = feature / name
        if not path.resolve().is_relative_to(feature.resolve()):
            raise RuntimeError(f'Unsafe supporting artifact: {name}')
        files = list(path.rglob('*')) if key == 'contracts' and path.is_dir() else [path]
        if any(p.is_symlink() and not p.resolve().is_relative_to(feature.resolve()) for p in files):
            raise RuntimeError(f'Unsafe supporting artifact: {name}')
        if not any(p.is_file() and p.read_bytes().strip() for p in files):
            raise RuntimeError(f'Missing or empty applicable artifact: {name}')
    if stage is not None and not setup:
        canonical=['spec.md','plan.md','verification.json']
        if stage!='plan': canonical.append('tasks.md')
        if stage in ('qa','review'): canonical.append('qa-report.md')
        if stage=='review': canonical.append('review-report.md')
        for name in canonical:
            path=feature/name
            if not path.resolve().is_relative_to(feature.resolve()) or not path.is_file() or not path.read_bytes().strip():
                raise RuntimeError(f'Missing or empty canonical artifact: {name}')
    return data


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('feature', type=Path)
    parser.add_argument('--setup', action='store_true')
    parser.add_argument('--stage',choices=('plan','tasks','develop','qa','review'),default='plan')
    args = parser.parse_args()
    try:
        print(json.dumps(validate(args.feature.resolve(), setup=args.setup, stage=args.stage)))
    except (RuntimeError, OSError) as error:
        raise SystemExit(str(error)) from error
