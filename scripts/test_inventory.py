#!/usr/bin/env python3
"""Independent committed inventory. Validation never refreshes expected membership."""
import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

PROFILES = ('unit', 'integration', 'e2e')
INVENTORY = Path('config/test_profiles.json')


def entry(runner, file, case_id, profile):
    identity = '\0'.join((runner, file, case_id))
    return dict(id=hashlib.sha256(identity.encode()).hexdigest()[:24], runner=runner,
                file=file, case_id=case_id, profile=profile)


def validate(expected, discovered):
    for population in (expected, discovered):
        identities = []
        for case in population:
            if case != entry(case['runner'], case['file'], case['case_id'], case['profile']):
                raise ValueError('identity')
            if case['profile'] not in PROFILES:
                raise ValueError('assignment')
            identities.append(case['id'])
        if len(set(identities)) != len(identities):
            raise ValueError('duplicate')
    if {json.dumps(c, sort_keys=True) for c in expected} != {json.dumps(c, sort_keys=True) for c in discovered}:
        left = {c['id']: c for c in expected}
        right = {c['id']: c for c in discovered}
        for opaque in sorted(set(left) | set(right)):
            if left.get(opaque) != right.get(opaque):
                print('PROFILE_DISCREPANCY id=' + opaque, file=sys.stderr)
        raise ValueError('membership')


def reconcile(expected, events):
    if reconcile_diagnostics(expected, events) is not None:
        raise ValueError('execution-membership')


def reconcile_diagnostics(expected, events):
    """Return bounded aggregate mismatch counts without exposing case IDs."""
    wanted = {case['id'] for case in expected}
    states = Counter((event['id'], event['state']) for event in events)
    expected_states = Counter({(ident, state): 1 for ident in wanted for state in ('started', 'passed')})
    extra = sum(count for (ident, _state), count in states.items() if ident not in wanted)
    invalid_state = sum(count for (_ident, state), count in states.items() if state not in ('started', 'passed'))
    missing_started = sum(states[(ident, 'started')] == 0 for ident in wanted)
    missing_passed = sum(states[(ident, 'passed')] == 0 for ident in wanted)
    duplicate = sum(max(0, count - 1) for _key, count in states.items())
    if not wanted:
        reason = 'empty-expected'
    elif extra:
        reason = 'extra-events'
    elif invalid_state:
        reason = 'unexpected-state'
    elif missing_started or missing_passed:
        reason = 'missing-events'
    elif duplicate:
        reason = 'duplicate-events'
    elif states != expected_states:
        reason = 'unexpected-state'
    else:
        return None
    return {'reason': reason, 'expected': len(wanted), 'observed': len(events),
            'missing_started': missing_started, 'missing_passed': missing_passed,
            'extra': extra, 'duplicate': duplicate, 'invalid_state': invalid_state}


def registered_extra_ids(expected, events, registered):
    """Return opaque IDs for extra events only when they belong to the full inventory."""
    expected_ids = {case['id'] for case in expected}
    registered_ids = {case['id'] for case in registered}
    return sorted({event['id'] for event in events
                   if event['id'] not in expected_ids and event['id'] in registered_ids})


def registered_extra_sources(expected, events, registered):
    """Map extra events to registered runner/file pairs without exposing case IDs."""
    expected_ids = {case['id'] for case in expected}
    registered_sources = {(case['runner'], case['file']) for case in registered}
    return sorted({(event['runner'], event['file']) for event in events
                   if event['id'] not in expected_ids and
                   (event.get('runner'), event.get('file')) in registered_sources})


def capture(argv, env=None, timeout=120):
    with tempfile.TemporaryFile() as output:
        result = subprocess.run(argv, env={**os.environ, **(env or {})}, stdin=subprocess.DEVNULL,
                                stdout=output, stderr=output, timeout=timeout)
        if result.returncode:
            raise ValueError('discovery-child')


def discover(enforce=False):
    from test_profile_components import discover_native
    cases = discover_native()
    with tempfile.TemporaryDirectory(prefix='profile-discovery-') as directory:
        output = str(Path(directory) / 'cases.json')
        try:
            capture(['mix', 'run', 'scripts/test_profile_discovery.exs'],
                    {'MIX_ENV': 'test', 'PROFILE_DISCOVERY': output, 'PROFILE_ENFORCE_INVENTORY': '1' if enforce else '0'})
        except ValueError:
            if enforce and Path(output).exists():
                found = [entry(**case) for case in json.loads(Path(output).read_text())]
                expected = [case for case in json.loads(INVENTORY.read_text())['entries'] if case['runner'] == 'exunit']
                validate(expected, found)
            raise
        cases += [entry(**case) for case in json.loads(Path(output).read_text())]
    return sorted(cases, key=lambda c: c['id'])


def check():
    inventory = json.loads(INVENTORY.read_text())
    if inventory['schema_version'] != 1:
        raise ValueError('schema')
    helpers = inventory.get('helpers', {})
    test_files = set()
    for root in ('test', 'tools/openapi'):
        for path in Path(root).rglob('*'):
            if 'node_modules' in path.parts or not path.is_file() or path.suffix not in ('.ex', '.exs', '.py', '.mjs', '.sh'):
                continue
            if path.name.endswith(('_test.exs', '_test.py', '_test.sh', '.test.mjs')):
                test_files.add(path.as_posix())
                continue
            if not helpers.get(path.as_posix()):
                raise ValueError('unclassified-helper')
    found = discover(enforce=True)
    if test_files != {case['file'] for case in found}:
        raise ValueError('undiscovered-test-file')
    validate(inventory['entries'], found)
    return inventory


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=['check', 'update'])
    parser.add_argument('--profile', choices=PROFILES)
    args = parser.parse_args()
    try:
        if args.command == 'check':
            inventory = check()
        else:
            found = discover()
            previous = json.loads(INVENTORY.read_text()) if INVENTORY.exists() else {'entries': []}
            validate(found, found)
            validate(previous['entries'], previous['entries'])
            old = {c['id']: c for c in previous['entries']}
            additions = [case for case in found if case['id'] not in old]
            if additions and args.profile is None:
                raise ValueError('explicit-profile-required')
            for case in found:
                if case['id'] in old and case['profile'] != old[case['id']]['profile']:
                    raise ValueError('assignment-change-review-required')
            selected = [case for case in found
                        if case['id'] in old or case['profile'] == args.profile]
            inventory = {**previous, 'schema_version': 1,
                         'entries': sorted(selected, key=lambda case: case['id'])}
            INVENTORY.write_text(json.dumps(inventory, indent=2) + '\n')
            pending = len(found) - len(selected)
            print(f'PROFILE_INVENTORY status=updated count={len(selected)} pending={pending}')
            return 0
        print('PROFILE_INVENTORY status=complete count=' + str(len(inventory['entries'])))
        return 0
    except (ValueError, OSError, subprocess.SubprocessError, KeyError):
        print('PROFILE_INVENTORY status=failed category=discovery-or-membership', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
