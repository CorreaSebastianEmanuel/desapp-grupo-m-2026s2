#!/usr/bin/env python3
"""Fail-closed profile supervisor; raw child output is never retained or published."""
import contextlib
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import shutil
import subprocess
import sys
import tempfile
import time
import uuid
from test_inventory import (check, entry, reconcile_diagnostics, registered_extra_ids,
                            registered_extra_sources)
from test_profile_components import isolated_services, SERVICE_FILES

child = None
_BROWSER_CAUSES = {"node-unavailable", "node-incompatible", "playwright-missing",
                   "bundled-chromium-missing", "chromium-launch-failed", "chromium-launch-timeout"}


def emit_membership_diagnostic(profile, phase, reason, *, expected=0, observed=0,
                               missing_started=0, missing_passed=0, extra=0,
                               duplicate=0, invalid_state=0, wrong_nonce=0):
    print("PROFILE_MEMBERSHIP_DIAGNOSTIC " + " ".join((
        f"profile={profile}", f"phase={phase}", f"reason={reason}",
        f"expected={expected}", f"observed={observed}",
        f"missing_started={missing_started}", f"missing_passed={missing_passed}",
        f"extra={extra}", f"duplicate={duplicate}", f"invalid_state={invalid_state}",
        f"wrong_nonce={wrong_nonce}")), file=sys.stderr)


def safe_case_id(value):
    """Expose conventional test identifiers only; redact arbitrary labels."""
    return value if isinstance(value, str) and re.fullmatch(r'test(?:\.[A-Za-z0-9_]+)+', value) else 'redacted'


def failure_cause(runner_name, related, failed, skipped):
    cause = next((event.get('cause') for event in related
                  if event.get('state') == 'failed' and event.get('cause') in ('assertion', 'error')),
                 None)
    if cause:
        return cause
    if failed:
        return 'error' if runner_name == 'exunit' else 'assertion'
    return 'skipped' if skipped else 'incomplete'


def emit_case_diagnostic(case, related):
    failed = sum(event.get('state') == 'failed' for event in related)
    skipped = sum(event.get('state') == 'skipped' for event in related)
    started = sum(event.get('state') == 'started' for event in related)
    passed = sum(event.get('state') == 'passed' for event in related)
    state = 'failed' if failed else 'skipped' if skipped else 'incomplete'
    cause = failure_cause(case['runner'], related, failed, skipped)
    failure = next((event for event in related if event.get('state') == 'failed'), {})
    line = failure.get('failure_line')
    line_value = str(line) if type(line) is int and 0 < line <= 1000000 else '0'
    # Keep the identity-only marker for structured QA parsing; publish details only through this closed schema.
    print('PROFILE_DISCREPANCY id=' + case['id'] + ' line=' + line_value, file=sys.stderr)
    print('PROFILE_CASE_DIAGNOSTIC id=' + case['id'] + ' runner=' + case['runner'] +
          ' file=' + case['file'] + ' case=' + safe_case_id(case['case_id']) +
          ' state=' + state + ' cause=' + cause + ' line=' + line_value +
          ' started=' + str(started) + ' passed=' + str(passed) +
          ' failed=' + str(failed) + ' skipped=' + str(skipped), file=sys.stderr)


def browser_prerequisite(env, launch):
    """Classify the integration browser smoke probe without exposing child output."""
    node = shutil.which("node", path=env.get("PATH"))
    if not node:
        return "node-unavailable"
    try:
        result = subprocess.run([node, "--version"], env=env, stdin=subprocess.DEVNULL,
                                stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
                                text=True, timeout=5, check=False)
    except (OSError, subprocess.TimeoutExpired):
        return "node-unavailable"
    if result.returncode or not re.fullmatch(r"v24\.\d+\.\d+", result.stdout.strip()):
        return "node-incompatible"
    module_probe = "require.resolve('playwright-core',{paths:['./tools/openapi']})"
    try:
        result = subprocess.run([node, "-e", module_probe], cwd=Path.cwd(), env=env,
                                stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                                stderr=subprocess.DEVNULL, timeout=5, check=False)
    except (OSError, subprocess.TimeoutExpired):
        return "playwright-missing"
    if result.returncode:
        return "playwright-missing"
    executable_probe = ("const fs=require('fs'),p=require('./tools/openapi/node_modules/playwright-core');"
                        "process.exit(fs.existsSync(p.chromium.executablePath())?0:1)")
    try:
        result = subprocess.run([node, "-e", executable_probe], cwd=Path.cwd(), env=env,
                                stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                                stderr=subprocess.DEVNULL, timeout=5, check=False)
    except (OSError, subprocess.TimeoutExpired):
        return "bundled-chromium-missing"
    if result.returncode:
        return "bundled-chromium-missing"
    try:
        launch([node, "-e", 'const {chromium}=require("./tools/openapi/node_modules/playwright-core");'
                'chromium.launch({headless:true,args:["--no-sandbox"],timeout:10000})'
                '.then(b=>b.close()).catch(()=>process.exit(1))'], env, 30)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        return "chromium-launch-timeout" if isinstance(error, ValueError) and str(error) == "timeout" else "chromium-launch-failed"
    return None


def terminate():
    global child
    if child is not None:
        try:
            os.killpg(child.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        child.wait()
        child = None


def interrupted(number, _):
    terminate()
    raise SystemExit(128 + number)


def run(argv, env, timeout):
    global child
    with tempfile.TemporaryFile() as output, tempfile.TemporaryDirectory(prefix='profile-resources-') as directory:
        resource_env = {**env, 'PROFILE_RESOURCES': str(Path(directory) / 'resources.json'),
                        'PROFILE_RESOURCE_NONCE': uuid.uuid4().hex}
        child = subprocess.Popen(argv, env=resource_env, stdin=subprocess.DEVNULL, stdout=output,
                                 stderr=output, start_new_session=True)
        try:
            status = child.wait(timeout=timeout)
            if status:
                output.seek(0)
                for raw in output:
                    line = raw.decode(errors='replace').rstrip('\r\n')
                    if re.fullmatch(r'PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=[a-z-]+', line):
                        print(line, file=sys.stderr)
                raise ValueError('child-failure')
        except subprocess.TimeoutExpired:
            raise ValueError('timeout') from None
        finally:
            terminate()
            if Path(resource_env['PROFILE_RESOURCES']).exists():
                cleanup_resources(resource_env)


def cleanup_resources(env):
    """Cleanup lives outside the BEAM that may have been killed by the supervisor."""
    with tempfile.TemporaryFile() as output:
        cleaner = subprocess.Popen(
            ['mix', 'run', '--no-start', '-e',
             'FootballMarket.E2E.Runtime.cleanup_registered!()'],
            env=env, stdin=subprocess.DEVNULL, stdout=output, stderr=output,
            start_new_session=True)
        try:
            if cleaner.wait(timeout=30):
                raise ValueError('resource-cleanup')
        except subprocess.TimeoutExpired:
            raise ValueError('resource-cleanup') from None
        finally:
            try:
                os.killpg(cleaner.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
            cleaner.wait()


def execute_exunit(execute, profile, files, directory, nonce, postgres_port=None):
    argv = ['mix', 'test', '--warnings-as-errors', '--include', 'performance', '--only', profile,
            '--formatter', 'FootballMarket.TestProfileFormatter']
    if os.environ.get('CP1_PROFILE_COVERAGE') == '1':
        execute(argv + ['--cover', '--export-coverage', profile] + files)
        return
    application_dir = os.environ.get('APPLICATION_COVERAGE_DIR')
    observed = []
    expected_partitions = []

    def invoke(partition_id, selected, extra=None):
        if not selected:
            return
        command = argv + selected
        if application_dir:
            name = 'app_' + profile + '_' + os.environ.get('APPLICATION_COVERAGE_RUN_ID', nonce).replace('-', '') + '_' + partition_id
            coverage_env = {
                'APPLICATION_COVERAGE_DIR': application_dir,
                'APPLICATION_COVERAGE_RUN_ID': os.environ.get('APPLICATION_COVERAGE_RUN_ID', ''),
                'APPLICATION_COVERAGE_SNAPSHOT': os.environ.get('APPLICATION_COVERAGE_SNAPSHOT', '')
            }
            execute(argv + ['--cover', '--export-coverage', name] + selected,
                    {**(extra or {}), **coverage_env})
            observed.append(dict(id=partition_id, profile=profile, selected_files=selected,
                                 selected_sha256=hashlib.sha256(json.dumps(selected, separators=(',', ':')).encode()).hexdigest(),
                                 export=name + '.coverdata'))
        else:
            execute(command, extra)

    if profile != 'integration':
        expected_partitions = [dict(id='main', selected_files=files)] if files else []
        if application_dir:
            Path(application_dir, profile + '-expected.json').write_text(json.dumps(expected_partitions) + '\n')
        invoke('main', files)
        if application_dir:
            Path(application_dir, profile + '-observed.json').write_text(json.dumps(observed) + '\n')
        return
    committed_path = Path(directory) / 'committed-files.json'
    execute(['mix', 'run', '--no-start', '-e',
             'File.write!(System.fetch_env!("PROFILE_COMMITTED_FILES"), '
             'Jason.encode!(FootballMarket.TestProfileAudit.audit!("integration").committed_files))'],
            {'PROFILE_COMMITTED_FILES': str(committed_path)})
    committed = json.loads(committed_path.read_text())
    if not isinstance(committed, list):
        emit_membership_diagnostic(profile, 'committed-file-audit', 'invalid-shape', expected=len(files))
        raise ValueError('execution-membership')
    if len(committed) != len(set(committed)):
        emit_membership_diagnostic(profile, 'committed-file-audit', 'duplicate-files',
                                   expected=len(files), observed=len(committed),
                                   duplicate=len(committed) - len(set(committed)))
        raise ValueError('execution-membership')
    if not set(committed) <= set(files):
        emit_membership_diagnostic(profile, 'committed-file-audit', 'outside-profile',
                                   expected=len(files), observed=len(committed),
                                   extra=len(set(committed) - set(files)))
        raise ValueError('execution-membership')
    regular = [file for file in files if file not in committed]
    expected_partitions = ([dict(id='regular', selected_files=regular)] if regular else []) + [
        dict(id='committed_' + str(index), selected_files=[file]) for index, file in enumerate(committed)]
    if application_dir:
        Path(application_dir, profile + '-expected.json').write_text(json.dumps(expected_partitions) + '\n')
    if regular:
        invoke('regular', regular)
    for index, file in enumerate(committed):
        partition = {'MIX_TEST_PARTITION': 'profile' + nonce + '_c' + str(index)}
        if postgres_port is not None:
            partition['POSTGRES_PORT'] = postgres_port
        execute(['mix', 'test.prepare'], partition)
        invoke('committed_' + str(index), [file], partition)
    if application_dir:
        Path(application_dir, profile + '-observed.json').write_text(json.dumps(observed) + '\n')


def main(profile):
    if profile not in ('unit', 'integration', 'e2e'):
        raise ValueError('usage')
    receipt = os.environ.get('CP1_PROFILE_RECEIPT')
    if receipt:
        Path(receipt).unlink(missing_ok=True)
    started = time.monotonic()
    nonce = uuid.uuid4().hex
    inventory = check()
    expected = [c for c in inventory['entries'] if c['profile'] == profile]
    digest = hashlib.sha256(Path('config/test_profiles.json').read_bytes()).hexdigest()
    ceiling = 1200 if profile == 'integration' else 180 if profile == 'e2e' else 600
    with tempfile.TemporaryDirectory(prefix='profile-') as directory, contextlib.ExitStack() as resources:
        os.chmod(directory, 0o700)
        events = Path(directory) / 'events.jsonl'
        events.touch(mode=0o600)
        env = {**os.environ, 'MIX_ENV': 'test', 'CP1_PROFILE': profile, 'PROFILE_EVENTS': str(events),
               'PROFILE_NONCE': nonce}
        for key in ('APPLICATION_COVERAGE_DIR', 'APPLICATION_COVERAGE_RUN_ID', 'APPLICATION_COVERAGE_SNAPSHOT'):
            env.pop(key, None)
        for key in ('DEBUG', 'NODE_DEBUG', 'PWDEBUG', 'BASH_ENV', 'ENV'):
            env.pop(key, None)
        if profile == 'e2e':
            env.pop('APPLICATION_COVERAGE_DIR', None)
            env.pop('APPLICATION_COVERAGE_RUN_ID', None)
            env.pop('APPLICATION_COVERAGE_SNAPSHOT', None)
        def command_location(argv, extra):
            extra = extra or {}
            if len(argv) > 1 and argv[1] == 'test.prepare':
                step = 'prepare'
            elif len(argv) > 1 and argv[1] == 'test':
                step = 'tests'
            elif len(argv) > 1 and argv[1] == 'run':
                step = 'audit' if 'PROFILE_COMMITTED_FILES' in extra else 'cleanup'
            else:
                step = 'component'
            partition_value = extra.get('MIX_TEST_PARTITION')
            if partition_value is None:
                partition = 'regular'
            else:
                match = re.fullmatch(r'profile[a-f0-9]{32}_c([0-9]{1,3})', partition_value)
                partition = 'committed-' + match.group(1) if match else 'unknown'
            return step, partition
        def execute(argv, extra=None, timeout=ceiling):
            remaining = ceiling - (time.monotonic() - started)
            if remaining <= 0:
                raise ValueError('timeout')
            try:
                run(argv, {**env, **(extra or {})}, min(timeout, remaining))
            except (OSError, ValueError, subprocess.SubprocessError) as error:
                step, partition = command_location(argv, extra)
                print(f'PROFILE_STEP_DIAGNOSTIC profile={profile} step={step} partition={partition}', file=sys.stderr)
                observations = [json.loads(raw) for raw in events.read_text().splitlines()]
                identities = {(item['runner'], item['file'], item['case_id']) for item in observations}
                for runner_name, file_name, case_id in sorted(identities):
                    related = [item for item in observations if (item['runner'], item['file'], item['case_id']) ==
                               (runner_name, file_name, case_id)]
                    states = {item.get('state') for item in related}
                    if 'failed' in states or 'skipped' in states or ('started' in states and 'passed' not in states):
                        case = entry(runner_name, file_name, case_id, profile)
                        emit_case_diagnostic(case, related)
                category = 'test-failure' if argv[0] == 'mix' else 'component-failure'
                if isinstance(error, ValueError) and str(error) in ('timeout', 'resource-cleanup'):
                    category = str(error)
                raise ValueError(category) from None
        if profile in ('integration', 'e2e'):
            browser_cause = browser_prerequisite(env, run)
            if browser_cause:
                print(f'PROFILE_BROWSER_DIAGNOSTIC cause={browser_cause} stage={profile}', file=sys.stderr)
                raise ValueError('browser-prerequisite')
        if profile == 'integration':
            service_dir = Path(directory) / 'services'
            service_dir.mkdir(mode=0o700)
            identity, docker, compose, service_env = isolated_services(service_dir)
            resources.callback(lambda: run([docker, 'compose', '--file', str(compose), '--project-name', identity['project'],
                                             'down', '--volumes', '--remove-orphans'], service_env, 30))
            # The consecutive scenario owns task_002_acceptance's leaf invocation.
            for file in sorted({c['file'] for c in expected if c['runner'] == 'shell'
                                and Path(c['file']).name != 'task_002_acceptance_test.sh'}):
                execute(['sh', file], service_env, timeout=600)
            # Existing nested committed races get clean invocation-owned PostgreSQL.
            execute(['sh', 'scripts/local_services.sh', 'start'], service_env, timeout=60)
            execute(['sh', 'scripts/local_services.sh', 'ready'], service_env, timeout=35)
            env['PROFILE_CONCURRENCY_POSTGRES_PORT'] = service_env['POSTGRES_PORT']
        if profile == 'unit':
            execute(['python3', 'scripts/test_profile_components.py'])
            for file in sorted({c['file'] for c in expected if c['runner'] == 'node'}):
                execute(['node', '--test', '--test-isolation=none',
                         '--test-reporter=./tools/openapi/profile_reporter.mjs', file],
                        {'PROFILE_NODE_FILE': file})
            for file in sorted({c['file'] for c in expected if c['runner'] == 'shell'}):
                execute(['sh', file])
        files = sorted({c['file'] for c in expected if c['runner'] == 'exunit'})
        execute_exunit(execute, profile, files, directory, nonce,
                       env.get('PROFILE_CONCURRENCY_POSTGRES_PORT'))
        resources.close()
        mapped = []
        for raw in events.read_text().splitlines():
            event = json.loads(raw)
            if event.get('nonce') != nonce:
                continue
            opaque = entry(event['runner'], event['file'], event['case_id'], profile)['id']
            mapped.append({'id': opaque, 'state': event['state'],
                           'runner': event['runner'], 'file': event['file']})
        wrong_nonce = sum(json.loads(raw).get('nonce') != nonce for raw in events.read_text().splitlines())
        if wrong_nonce:
            emit_membership_diagnostic(profile, 'nonce-validation', 'nonce-mismatch',
                                       expected=len(events.read_text().splitlines()),
                                       observed=len(events.read_text().splitlines()), wrong_nonce=wrong_nonce)
            raise ValueError('execution-membership')
        from collections import Counter
        observed = Counter((e['id'], e['state']) for e in mapped)
        for case in expected:
            opaque = case['id']
            if observed[(opaque, 'started')] != 1 or observed[(opaque, 'passed')] != 1:
                print('PROFILE_DISCREPANCY id=' + opaque, file=sys.stderr)
        mismatch = reconcile_diagnostics(expected, mapped)
        if mismatch:
            for opaque in registered_extra_ids(expected, mapped, inventory['entries']):
                print('PROFILE_DISCREPANCY id=' + opaque, file=sys.stderr)
            for runner, file in registered_extra_sources(expected, mapped, inventory['entries']):
                print(f'PROFILE_MEMBERSHIP_EXTRA profile={profile} runner={runner} file={file}', file=sys.stderr)
            emit_membership_diagnostic(profile, 'event-reconciliation', mismatch.pop('reason'), **mismatch)
            raise ValueError('execution-membership')
        count = len(expected)
        result = dict(schema_version=1, nonce=nonce, inventory_digest=digest, profile=profile,
                      audit_count=len(files), expected=count, discovered=count, executed=count,
                      passed=count, status='complete', components={runner: sum(c['runner'] == runner for c in expected)
                                                               for runner in ('exunit', 'python', 'node', 'shell')})
        if receipt:
            target = Path(receipt)
            target.parent.mkdir(parents=True, exist_ok=True)
            temporary = target.with_name(target.name + '.' + nonce)
            temporary.write_text(json.dumps(result) + '\n')
            temporary.chmod(0o600)
            temporary.replace(target)
        if os.environ.get('APPLICATION_COVERAGE_DIR') and profile in ('unit', 'integration'):
            observed_path = Path(os.environ['APPLICATION_COVERAGE_DIR']) / (profile + '-observed.json')
            expected_path = Path(os.environ['APPLICATION_COVERAGE_DIR']) / (profile + '-expected.json')
            if not observed_path.exists() or not expected_path.exists():
                emit_membership_diagnostic(profile, 'coverage-audit', 'missing-sidecar',
                                           expected=2, observed=int(observed_path.exists()) + int(expected_path.exists()))
                raise ValueError('execution-membership')
            observed = json.loads(observed_path.read_text())
            expected = json.loads(expected_path.read_text())
            if not observed:
                emit_membership_diagnostic(profile, 'coverage-audit', 'missing-partition',
                                           expected=len(expected), observed=0)
                raise ValueError('execution-membership')
            if [(p['id'], p['selected_files']) for p in observed] != [(p['id'], p['selected_files']) for p in expected]:
                emit_membership_diagnostic(profile, 'coverage-audit', 'partition-mismatch',
                                           expected=len(expected), observed=len(observed))
                raise ValueError('execution-membership')
            missing_exports = sum(not (Path(os.environ['APPLICATION_COVERAGE_DIR']) / part['export']).is_file()
                                  for part in observed)
            if missing_exports:
                emit_membership_diagnostic(profile, 'coverage-audit', 'missing-export',
                                           expected=len(observed), observed=len(observed) - missing_exports,
                                           extra=missing_exports)
                raise ValueError('execution-membership')
            sealed = dict(schema_version=1, profile=profile, receipt_nonce=nonce,
                          receipt_sha256=hashlib.sha256((Path(receipt).read_bytes() if receipt else b'')).hexdigest(),
                          run_id=os.environ.get('APPLICATION_COVERAGE_RUN_ID'),
                          snapshot_digest=os.environ.get('APPLICATION_COVERAGE_SNAPSHOT'),
                          expected=expected, partitions=observed)
            for partition in observed:
                partition['export_sha256'] = hashlib.sha256(
                    (Path(os.environ['APPLICATION_COVERAGE_DIR']) / partition['export']).read_bytes()).hexdigest()
            sidecar = Path(os.environ['APPLICATION_COVERAGE_DIR']) / (profile + '-coverage.json')
            sidecar.write_text(json.dumps(sealed) + '\n')
        print(f'CP1_PROFILE_RECEIPT profile={profile} audit_count={len(files)} expected={count} discovered={count} executed={count} passed={count} status=complete')


if __name__ == '__main__':
    os.umask(0o077)
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)
    try:
        main(sys.argv[1] if len(sys.argv) == 2 else '')
    except (ValueError, OSError, KeyError, subprocess.SubprocessError) as error:
        allowed = {'usage', 'timeout', 'resource-cleanup', 'browser-prerequisite', 'test-failure', 'component-failure', 'docker-prerequisite', 'execution-membership'}
        category = str(error) if isinstance(error, ValueError) and str(error) in allowed else 'inventory-or-service-prerequisite'
        print('CP1_PROFILE_OUTCOME status=failed category=' + category, file=sys.stderr)
        sys.exit(1)
