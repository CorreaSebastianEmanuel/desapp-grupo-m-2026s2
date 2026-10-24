#!/usr/bin/env python3
"""Fail-closed profile supervisor; raw child output is never retained or published."""
import contextlib
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import subprocess
import sys
import tempfile
import time
import uuid
from test_inventory import check, entry, reconcile
from test_profile_components import isolated_services, SERVICE_FILES

PROFILE_TIMEOUTS = {'unit': 600, 'integration': 1500, 'e2e': 180}

child = None


def browser_preflight_command():
    """Real Chromium smoke probe; only a closed cause enum crosses the process boundary."""
    script = r'''/* PROFILE_BROWSER_PREFLIGHT */
(async () => {
  let browser;
  try {
    const {chromium} = require("./tools/openapi/node_modules/playwright-core");
    const launchOptions = {headless:true,args:["--no-sandbox"],timeout:10000};
    if (process.env.CHROMIUM_PATH) launchOptions.executablePath = process.env.CHROMIUM_PATH;
    browser = await chromium.launch(launchOptions);
    await browser.close();
  } catch (error) {
    const message = String(error && (error.message || error) || "");
    let cause = "launch-failed";
    if (/browser executable.*(?:missing|not found|does not exist)|executable doesn't exist|executable path.*not found|failed to launch.*ENOENT/i.test(message)) {
      cause = "executable-missing";
    } else if (/Cannot find module|MODULE_NOT_FOUND|shared librar|cannot open shared object|host system lacks dependencies|library .* not found/i.test(message)) {
      cause = "dependency-missing";
    } else if (/EACCES|EPERM|permission denied|access is denied/i.test(message)) {
      cause = "permission-denied";
    } else if (/ETIMEDOUT|TimeoutError|timed? ?out|timeout/i.test(message)) {
      cause = "launch-timeout";
    }
    console.error(`PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=${cause}`);
    process.exitCode = 1;
  }
})();'''
    return ['node', '-e', script]


def is_browser_preflight(argv):
    return bool(argv and argv[0] == 'node' and any(
        isinstance(argument, str) and 'PROFILE_BROWSER_PREFLIGHT' in argument for argument in argv[1:]))


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
                    if (re.fullmatch(r'PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=[a-z-]+', line)
                            or re.fullmatch(r'PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=(?:executable-missing|dependency-missing|permission-denied|launch-timeout|launch-failed)', line)):
                        print(line, file=sys.stderr)
                raise ValueError('child-failure')
        except subprocess.TimeoutExpired:
            if is_browser_preflight(argv):
                print('PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=launch-timeout', file=sys.stderr)
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
    if not isinstance(committed, list) or len(committed) != len(set(committed)) or not set(committed) <= set(files):
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
    ceiling = PROFILE_TIMEOUTS[profile]
    with tempfile.TemporaryDirectory(prefix='profile-') as directory, contextlib.ExitStack() as resources:
        os.chmod(directory, 0o700)
        events = Path(directory) / 'events.jsonl'
        events.touch(mode=0o600)
        env = profile_environment(profile, events, nonce)
        def execute(argv, extra=None, timeout=ceiling):
            remaining = ceiling - (time.monotonic() - started)
            if remaining <= 0:
                raise ValueError('timeout')
            try:
                run(argv, {**env, **(extra or {})}, min(timeout, remaining))
            except (OSError, ValueError, subprocess.SubprocessError) as error:
                observations = [json.loads(raw) for raw in events.read_text().splitlines()]
                passed = {(e['runner'], e['file'], e['case_id']) for e in observations if e.get('state') == 'passed'}
                for observed in observations:
                    identity = (observed['runner'], observed['file'], observed['case_id'])
                    if observed.get('state') in ('failed', 'skipped') or (observed.get('state') == 'started' and identity not in passed):
                        opaque = entry(observed['runner'], observed['file'], observed['case_id'], profile)['id']
                        print('PROFILE_DISCREPANCY id=' + opaque + ' line=' + str(observed.get('failure_line', 0)), file=sys.stderr)
                category = 'browser-prerequisite' if argv[0] == 'node' else 'test-failure' if argv[0] == 'mix' else 'component-failure'
                if isinstance(error, ValueError) and str(error) in ('timeout', 'resource-cleanup'):
                    category = str(error)
                raise ValueError(category) from None
        if profile in ('integration', 'e2e'):
            execute(browser_preflight_command(), timeout=30)
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
                raise ValueError('execution-membership')
            opaque = entry(event['runner'], event['file'], event['case_id'], profile)['id']
            mapped.append({'id': opaque, 'state': event['state']})
        from collections import Counter
        observed = Counter((e['id'], e['state']) for e in mapped)
        for case in expected:
            opaque = case['id']
            if observed[(opaque, 'started')] != 1 or observed[(opaque, 'passed')] != 1:
                print('PROFILE_DISCREPANCY id=' + opaque, file=sys.stderr)
        reconcile(expected, mapped)
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
                raise ValueError('execution-membership')
            observed = json.loads(observed_path.read_text())
            expected = json.loads(expected_path.read_text())
            if not observed or [(p['id'], p['selected_files']) for p in observed] != [(p['id'], p['selected_files']) for p in expected] or any(not (Path(os.environ['APPLICATION_COVERAGE_DIR']) / part['export']).is_file() for part in observed):
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


def profile_environment(profile, events, nonce, parent=None):
    """Build the child environment with bounded BEAM scheduler contention."""
    env = {**(os.environ if parent is None else parent), 'MIX_ENV': 'test', 'CP1_PROFILE': profile,
           'PROFILE_EVENTS': str(events), 'PROFILE_NONCE': nonce}
    env.setdefault('ERL_FLAGS', '+S 4:4')
    for key in ('APPLICATION_COVERAGE_DIR', 'APPLICATION_COVERAGE_RUN_ID', 'APPLICATION_COVERAGE_SNAPSHOT'):
        env.pop(key, None)
    for key in ('DEBUG', 'NODE_DEBUG', 'PWDEBUG', 'BASH_ENV', 'ENV'):
        env.pop(key, None)
    return env


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
