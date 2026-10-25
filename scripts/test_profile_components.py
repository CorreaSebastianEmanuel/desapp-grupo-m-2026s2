#!/usr/bin/env python3
"""Native case discovery and execution adapters, never infer cases from exit zero."""
import inspect
import json
import os
from pathlib import Path
import re
import socket
import subprocess
import sys
import traceback
import unittest
import uuid

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def python_cases():
    def flatten(suite):
        for item in suite:
            if isinstance(item, unittest.TestSuite):
                yield from flatten(item)
            else:
                yield item
    loader = unittest.TestLoader()
    cases = list(flatten(loader.discover('test/scripts', pattern='*_test.py', top_level_dir='.')))
    if loader.errors:
        raise ValueError('python-discovery')
    discovered_files = {Path(inspect.getfile(type(case))).resolve() for case in cases}
    expected_files = {path.resolve() for path in Path('test/scripts').glob('*_test.py')}
    if discovered_files != expected_files:
        raise ValueError('undiscovered-python-file')
    return cases


def service_identity():
    ports = []
    sockets = []
    try:
        for _ in range(2):
            sock = socket.socket()
            sockets.append(sock)
            sock.bind(('127.0.0.1', 0))
            ports.append(sock.getsockname()[1])
    finally:
        for sock in sockets:
            sock.close()
    return {'project': 'profile_' + uuid.uuid4().hex, 'ports': ports, 'host': '127.0.0.1'}


def discover_native():
    from test_inventory import entry
    cases = []
    for case in python_cases():
        file = Path(inspect.getfile(type(case))).resolve().relative_to(Path.cwd()).as_posix()
        cases.append(entry('python', file, case.id(), 'unit'))
    for file in sorted(Path('tools/openapi').glob('*.test.mjs')):
        text = file.read_text()
        names = re.findall(r"^test\('([^']+)'", text, re.M)
        if not names or len(names) != len(re.findall(r'^test\(', text, re.M)):
            raise ValueError('unsupported-node-declaration')
        cases += [entry('node', file.as_posix(), name, 'unit') for name in names]
    # Shell declarations are explicit case boundaries, adjacent to their original assertions.
    for file in sorted(Path('test').rglob('*_test.sh')):
        text = file.read_text()
        names = re.findall(r"^\s*profile_case_start '([^']+)'", text, re.M)
        if not names:
            raise ValueError('unclassified-shell')
        profile = 'integration' if file.name in SERVICE_FILES else 'unit'
        cases += [entry('shell', file.as_posix(), name, profile) for name in names]
    return cases


SERVICE_FILES = {'local_services_lifecycle_test.sh', 'local_services_failure_test.sh',
                 'consecutive_lifecycle_acceptance_test.sh', 'task_002_acceptance_test.sh',
                 'database_isolation_test.sh', 'infrastructure_verify_test.sh', 'redis_disposability_test.sh'}


def event(file, case_id, state, runner, **details):
    with open(os.environ['PROFILE_EVENTS'], 'a') as stream:
        stream.write(json.dumps(dict(nonce=os.environ.get('PROFILE_NONCE'), runner=runner, file=file,
                                     case_id=case_id, state=state, **details)) + '\n')


class EventResult(unittest.TestResult):
    def report(self, test, state):
        file = Path(inspect.getfile(type(test))).resolve().relative_to(Path.cwd()).as_posix()
        event(file, test.id(), state, 'python')

    def startTest(self, test):
        super().startTest(test)
        self.report(test, 'started')

    def addSuccess(self, test):
        super().addSuccess(test)
        self.report(test, 'passed')

    def addSkip(self, test, reason):
        super().addSkip(test, reason)
        self.report(test, 'skipped')

    def addSubTest(self, test, subtest, err):
        super().addSubTest(test, subtest, err)
        if err is not None:
            self.report_failure(test, err, 'assertion')

    def report_failure(self, test, err, cause):
        file = Path(inspect.getfile(type(test))).resolve().relative_to(Path.cwd()).as_posix()
        frames = traceback.extract_tb(err[2]) if err and len(err) > 2 else []
        line = next((frame.lineno for frame in reversed(frames)
                     if Path(frame.filename).resolve() == Path.cwd() / file), None)
        details = {'cause': cause, 'failure_line': line}
        if err and len(err) > 1:
            exception_type = type(err[1]).__name__
            if re.fullmatch(r'[A-Za-z][A-Za-z0-9]{0,39}', exception_type):
                details['exception_type'] = exception_type
            # unittest's default assertEqual message for numeric mismatches is
            # safe to expose and helps diagnose cross-platform return codes.
            match = re.fullmatch(r'(-?[0-9]{1,9}) != (-?[0-9]{1,9})', str(err[1]))
            if match:
                details['numeric_comparison'] = match.groups()
        event(file, test.id(), 'failed', 'python', **details)

    def addFailure(self, test, err):
        super().addFailure(test, err)
        self.report_failure(test, err, 'assertion')

    def addError(self, test, err):
        super().addError(test, err)
        self.report_failure(test, err, 'error')


def run_python():
    result = EventResult()
    unittest.TestSuite(python_cases()).run(result)
    return int(not result.wasSuccessful() or bool(result.skipped))




def isolated_services(directory):
    """Only the test invocation's Compose project/volumes/ports may be targeted."""
    import shutil
    import tempfile
    identity = service_identity()
    real = shutil.which('docker')
    if not real:
        raise ValueError('docker-prerequisite')
    subprocess.run([real, 'info'], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15)
    subprocess.run([real, 'compose', 'version'], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15)
    compose = Path(directory) / 'compose.yaml'
    source = Path('compose.yaml').read_text().replace('football_market_local', identity['project'])
    compose.write_text(source)
    wrapper = Path(directory) / 'docker'
    wrapper.write_text('#!/usr/bin/env python3\nimport os,sys\nargs=sys.argv[1:]\n'
                       + f'real={real!r}\nproject={identity["project"]!r}\ncompose={str(compose)!r}\n'
                       + "if args and args[0]=='compose':\n"
                       + " if args[1:3] != ['--project-name','football_market_local']: sys.exit(64)\n"
                       + " args=['compose','--file',compose,'--project-name',project]+args[3:]\n"
                       + 'os.execv(real,[real]+args)\n')
    wrapper.chmod(0o700)
    env = {**os.environ, 'PATH': str(directory)+os.pathsep+os.environ['PATH'], 'TMPDIR': str(directory),
           'POSTGRES_PORT': str(identity['ports'][0]), 'REDIS_PORT': str(identity['ports'][1])}
    return identity, real, compose, env



def verify_receipts(directory, profiles=('unit', 'integration')):
    import hashlib
    inventory = json.loads(Path('config/test_profiles.json').read_text())
    digest = hashlib.sha256(Path('config/test_profiles.json').read_bytes()).hexdigest()
    for profile in profiles:
        receipt = json.loads((Path(directory) / (profile + '.json')).read_text())
        expected = sum(c['profile'] == profile for c in inventory['entries'])
        if (receipt.get('status') != 'complete' or receipt.get('profile') != profile
            or receipt.get('schema_version') != 1 or receipt.get('inventory_digest') != digest
            or not re.fullmatch(r'[a-f0-9]{32}', receipt.get('nonce', ''))
            or expected == 0 or any(receipt.get(k) != expected for k in ('expected', 'discovered', 'executed', 'passed'))):
            raise ValueError('receipt')
        for runner in ('exunit', 'python', 'node', 'shell'):
            count = sum(c['profile'] == profile and c['runner'] == runner for c in inventory['entries'])
            if receipt.get('components', {}).get(runner) != count:
                raise ValueError('component-receipt')
    print('CI_COMPONENTS workflow=complete openapi=complete profiles=complete')


if __name__ == '__main__':
    try:
        if len(sys.argv) >= 3 and sys.argv[1] == 'verify-receipts':
            verify_receipts(sys.argv[2], tuple(sys.argv[3:]))
        else:
            sys.exit(run_python())
    except (OSError, ValueError, KeyError):
        print('CI_COMPONENTS status=failed category=receipt', file=sys.stderr)
        sys.exit(1)
