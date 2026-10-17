#!/usr/bin/env python3
"""Assert CI applicability/environment and execute one isolated candidate suite."""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path

try:
    from .agentflow_verification import load_json
    from .workflow_artifact_probe import active_feature
except ImportError:
    from agentflow_verification import load_json
    from workflow_artifact_probe import active_feature

WORKFLOWS = ('.github/workflows/quality-baseline.yml', '.github/workflows/sonarcloud.yml',
             '.github/workflows/agentflow-finalize.yml')


SOURCE_PATHS = {
    'agentflow', '.gitignore', '.agentflow/models.json', '.agentflow/workflow.yml',
    '.specify/workflows/desapp-delivery/workflow.yml',
    '.github/workflows/quality-baseline.yml',
    '.specify/templates/plan-template.md', '.specify/templates/tasks-template.md',
    'docs/AGENT_CONTEXT_POLICY.md', 'docs/AGENT_VERIFICATION.md',
    'docs/AGENTFLOW_MODELS.md', 'docs/AGENTFLOW_PILOT.md',
    'docs/adr/0026-proportional-delivery-and-local-evidence.md',
    'docs/adr/0027-stable-stage-model-assignments.md',
    'backlog/TASK-064-proportional-agentflow-delivery-and-measurable-efficiency.md',
    'backlog/feedback/TASK-064.md',
    'test/ci/quality_baseline_contract_test.exs', 'test/ci/fixtures/quality-baseline.sha256',
    'test/ci/workflow_scope_test.exs', 'test/support/workflow_scope.ex',
    'test/scripts/support/agentflow_delivery_fixtures.py',
    'test/scripts/ci_unit_tests_test.sh', 'scripts/ci_unit_tests.sh',
}
SOURCE_PATHS.update('scripts/'+name+'.py' for name in (
    'agentflow_artifacts','agentflow_ci_check','agentflow_verification','agentflow_check',
    'agentflow_evidence','agentflow_models','agentflow_codex','agentflow_runtime',
    'agentflow_providers','agentflow_opencode',
    'workflow_artifact_probe','agentflow_feature'))
SOURCE_PATHS.update('test/scripts/'+name+'_test.py' for name in (
    'agentflow_policy','agentflow_ci_check','agentflow_clean_checkout','agentflow_artifacts',
    'agentflow_evidence','agentflow_feedback','agentflow_models','agentflow_metrics',
    'agentflow_providers',
    'workflow_artifact_probe','agentflow_completion','agentflow_branch','agentflow_feature',
    'task_feature_binding_acceptance'))
SOURCE_PATHS.update('.specify/scripts/bash/'+name+'.sh' for name in ('setup-plan','setup-tasks','check-prerequisites'))
SOURCE_PATHS.update('.agents/skills/'+name+'/SKILL.md' for name in (
    'speckit-plan','speckit-tasks','speckit-implement','speckit-analyze','speckit-converge',
    'feedback','start','resume','verify'))
SOURCE_PATHS.update('test/football_market/'+area+'/scope_test.exs' for area in ('market','statistics','providers'))


def allowed_source(name):
    return name in SOURCE_PATHS or name.startswith('specs/064-proportional-agentflow-delivery/')


def run(root, argv, *, timeout=60):
    try:
        result = subprocess.run(argv, cwd=root, capture_output=True, text=True, timeout=timeout)
    except (OSError, subprocess.TimeoutExpired) as error:
        raise RuntimeError(f'Required command unavailable: {argv[0]}') from error
    if result.returncode:
        # Child output may contain local connection configuration; do not echo it.
        raise RuntimeError(f'Required command failed ({result.returncode}): {argv[0]}')
    return result.stdout.strip()


def inventory(root, data):
    expected = data.get('ci_workflow_digests')
    actual = {name: hashlib.sha256((root / name).read_bytes()).hexdigest() for name in WORKFLOWS}
    if expected != actual:
        raise RuntimeError('CI inventory drift: reconcile plan/verification ci_workflow_digests against current workflows')
    checks = {c['id'] for c in data['checks']}
    obligations = data.get('ci_obligations', [])
    if not obligations or len({o['id'] for o in obligations}) != len(obligations):
        raise RuntimeError('CI inventory requires unique obligation identities')
    represented = set()
    for obligation in obligations:
        if obligation.get('workflow') not in actual or not obligation.get('reason', '').strip():
            raise RuntimeError('CI obligation requires a known workflow and applicability reason')
        disposition = obligation.get('disposition')
        if disposition == 'local-equivalent':
            ids = obligation.get('checks')
            if not ids or not set(ids).issubset(checks):
                raise RuntimeError('Local CI obligation requires executable mapped checks')
        elif disposition == 'ci-required':
            # Remote success cannot be inferred from a statement of applicability.
            raise RuntimeError('Required external CI evidence is unavailable; local readiness blocked')
        elif disposition != 'not-applicable':
            raise RuntimeError('Unknown CI obligation disposition')
        represented.add(obligation['workflow'])
    if represented != set(actual):
        raise RuntimeError('CI inventory omits a current workflow')
    return actual


def environment(root, runner=run):
    assessments = {}
    failures = []

    def assess(name, action):
        try:
            value = action()
            assessments[name] = value
        except (RuntimeError, OSError, ValueError) as error:
            failures.append(f'{name}: {error}')

    assess('beam', lambda: runner(root, ['sh', 'scripts/check_toolchain.sh']))

    def node():
        observed = runner(root, ['node', '--version'])
        if not re.fullmatch(r'v24\.\d+\.\d+', observed):
            raise RuntimeError(f'expected Node 24.x, observed {observed}; activate the CI toolchain')
        return observed

    assess('node', node)
    assess('git', lambda: runner(root, ['git', '--version']))
    assess('ruby-yaml', lambda: runner(root, ['ruby', '-ryaml', '-e', 'puts RUBY_VERSION']))
    assess('compose', lambda: runner(root, ['docker', 'compose', 'version', '--short']))

    def dependencies():
        if not (root / 'mix.lock').is_file() or not (root / 'tools/openapi/package-lock.json').is_file():
            raise RuntimeError('locked dependency inputs are absent')
        result = runner(root, ['mix', 'deps'])
        if re.search(r'lock mismatch|not available|outdated|could not find', result, re.I):
            raise RuntimeError('Mix dependencies missing or differ from lock; run documented locked setup')
        runner(root, ['npm', 'ls', '--prefix', 'tools/openapi', '--depth=0'])
        return 'installed locked dependency graph checked'

    assess('dependencies', dependencies)
    assess('chromium', lambda: runner(root, ['node', '-e',
        "const {chromium}=require('./tools/openapi/node_modules/playwright-core'); "
        "(async()=>{const b=await chromium.launch({headless:true});await b.close();"
        "console.log('Chromium launched');})().catch(()=>process.exit(1))"]))
    assess('services-ready', lambda: runner(root, ['sh', 'scripts/local_services.sh', 'ready']))

    def service(name, version):
        compose = ['docker', 'compose', '--project-name', 'football_market_local']
        container = runner(root, [*compose, 'ps', '-q', name])
        if not container or '\n' in container:
            raise RuntimeError('expected one ready local service')
        image = runner(root, ['docker', 'inspect', '--format', '{{.Config.Image}}', container])
        workflow = (root / '.github/workflows/quality-baseline.yml').read_text()
        if not image.startswith(f'{name}:{version}-alpine@sha256:') or f'image: {image}' not in workflow:
            raise RuntimeError(f'expected pinned {name} {version} image matching CI')
        if name == 'postgres':
            value = runner(root, [*compose, 'exec', '-T', name, 'psql', '-U',
                os.environ.get('POSTGRES_USER', 'postgres'), '-d', 'postgres', '-Atc', 'SHOW server_version'])
            if value.split()[0] != version:
                raise RuntimeError(f'expected PostgreSQL {version}')
        else:
            value = runner(root, [*compose, 'exec', '-T', name, 'redis-cli', 'INFO', 'server'])
            if f'redis_version:{version}' not in value.splitlines():
                raise RuntimeError(f'expected Redis {version}')
        return f'pinned {version}; runtime version asserted'

    assess('postgres', lambda: service('postgres', '17.6'))
    assess('redis', lambda: service('redis', '8.2.1'))
    if failures:
        raise RuntimeError('Preflight failed:\n' + '\n'.join(failures))
    return assessments


def candidate_paths(root):
    output = subprocess.run(['git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z'],
                            cwd=root, capture_output=True, check=True).stdout
    return sorted(set(os.fsdecode(name) for name in output.split(b'\0') if name))


def snapshot(root, destination):
    """Overlay current Git-listed inputs on HEAD without making a commit."""
    run(root, ['git', 'clone', '--quiet', '--no-hardlinks', '--no-checkout', str(root), str(destination)])
    run(destination, ['git', 'checkout', '--quiet', 'HEAD'])
    files = candidate_paths(root)
    digest = hashlib.sha256()
    for name in files:
        if name.startswith(('.agentflow/runs/', '.specify/workflows/runs/')) or name == '.specify/feature.json':
            continue
        source = root / name
        target = destination / name
        if source.is_symlink():
            raise RuntimeError(f'Candidate symlinks require explicit handling: {name}')
        if source.is_file():
            content = source.read_bytes()
            digest.update(name.encode() + b'\0' + hashlib.sha256(content).digest())
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source, target)
        else:
            digest.update(name.encode() + b'\0<deleted>')
            if target.is_file() or target.is_symlink():
                target.unlink()
    (destination / '.specify/feature.json').unlink(missing_ok=True)
    return digest.hexdigest()


def assert_collection(output):
    if 'FOOTBALL_MARKET_CI_DISCOVERY_SENTINEL' not in output.splitlines():
        raise RuntimeError('Required discovery sentinel absent')
    summaries = [line.strip() for line in output.splitlines()
                 if re.match(r'^\s*(?:Result:|\d+ tests?\b)', line)]
    if not summaries:
        raise RuntimeError('Required test collection is empty or has no discovery count')
    # The final summary must prove completion, even if an earlier line looked green.
    summary = summaries[-1]
    pinned = re.fullmatch(r'Result: (\d+)/(\d+) passed(?:, \d+ excluded)?', summary)
    all_passed = re.fullmatch(r'Result: (\d+) passed(?:, \d+ excluded)?', summary)
    legacy = re.fullmatch(r'(\d+) tests?, 0 failures?(?:, \d+ (?:excluded|skipped))*', summary)
    if pinned and int(pinned[1]) > 0 and pinned[1] == pinned[2]:
        return int(pinned[1])
    if all_passed and int(all_passed[1]) > 0:
        return int(all_passed[1])
    if legacy and int(legacy[1]) > 0:
        return int(legacy[1])
    raise RuntimeError('Required test collection is empty, partial or failed')


def clean_tests(root):
    with tempfile.TemporaryDirectory(prefix='agentflow-candidate-') as temporary:
        destination = Path(temporary).resolve() / 'candidate'
        identity = snapshot(root, destination)
        # Reuse installed locked dependencies, preserving live build outputs.
        # Build artifacts are disposable copies; never share mutable _build.
        for name in ('deps', '_build', 'tools/openapi/node_modules'):
            source = root / name
            if not source.is_dir():
                raise RuntimeError(f'Candidate requires installed {name}; perform documented locked setup')
            shutil.copytree(source, destination / name, symlinks=True)
        result = subprocess.run(['sh', 'scripts/ci_unit_tests.sh'], cwd=destination,
            env={**os.environ, 'MIX_ENV': 'test'}, capture_output=True, text=True)
        print(result.stdout, end='')
        print(result.stderr, end='')
        if result.returncode:
            raise RuntimeError(f'Isolated candidate suite failed ({result.returncode})')
        count = assert_collection(result.stdout)
        print(json.dumps({'candidate': identity, 'tests': count, 'private_pointer': False,
                          'full_suite_invocations': 1}))
        return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=('preflight', 'clean-tests'))
    args = parser.parse_args()
    root = Path.cwd()
    feature = active_feature(root)
    identities = inventory(root, load_json(feature / 'verification.json'))
    if args.command == 'preflight':
        print(json.dumps({'ci': identities, 'environment': environment(root)}))
    else:
        clean_tests(root)


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, subprocess.SubprocessError, OSError) as error:
        raise SystemExit(str(error)) from error
