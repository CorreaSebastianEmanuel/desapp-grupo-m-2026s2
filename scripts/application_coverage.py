#!/usr/bin/env python3
"""Fail-closed application-only coverage collection and reconciliation."""
import argparse
from collections import defaultdict
from datetime import datetime, timezone
import fcntl
import hashlib
import html
import json
import math
import os
import re
from pathlib import Path, PurePosixPath
import subprocess
import sys
import tempfile
import uuid

ROOT = Path(__file__).resolve().parents[1]
FEATURE = ROOT / 'specs/067-whole-application-elixir-coverage-and-report-reconciliation'
SCOPE = ROOT / 'config/application_coverage_inventory.json'
CANONICAL = ROOT / 'config/credo_inventory.json'
STATUS = ROOT / 'cover/application/status.json'
OUTPUT = ROOT / 'cover/application'
EXCLUDED_PARTS = ('.git', '_build', 'deps', 'cover', 'node_modules', '.specify/workflows/runs')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def canonical_json(value):
    return (json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n').encode()


def strict_json(data):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError('report')
            result[key] = value
        return result
    return json.loads(data, object_pairs_hook=unique)


def schema_one(value):
    return isinstance(value, dict) and type(value.get('schema_version')) is int and value['schema_version'] == 1


def validate_report_counts(report):
    """Reject coercible or invalid count values before report arithmetic/rendering."""
    def counts(value, keys):
        if not isinstance(value, dict):
            raise ValueError('report')
        for key in keys:
            number = value.get(key)
            if type(number) is not int or number < 0:
                raise ValueError('report')

    def line_numbers(value):
        return (isinstance(value, list) and
                all(type(number) is int and number > 0 for number in value) and
                value == sorted(set(value)))

    def valid_percentage(value):
        if type(value) is int:
            return 0 <= value <= 100
        return type(value) is float and math.isfinite(value) and 0 <= value <= 100

    if not isinstance(report, dict) or not isinstance(report.get('included'), list):
        raise ValueError('report')
    if not isinstance(report.get('partitions'), list):
        raise ValueError('report')
    counts(report.get('totals'), ('executable', 'covered', 'uncovered'))
    if not valid_percentage(report['totals'].get('percentage')):
        raise ValueError('report')
    for file in report['included']:
        counts(file, ('executable', 'covered', 'uncovered'))
        for key in ('executable_lines', 'covered_lines', 'uncovered_lines'):
            if not line_numbers(file.get(key)):
                raise ValueError('report')
        percentage = file.get('percentage')
        if percentage is not None and not valid_percentage(percentage):
            raise ValueError('report')
    for partition in report.get('partitions', []):
        if (not isinstance(partition, dict) or not isinstance(partition.get('modules'), list) or
                not isinstance(partition.get('lines'), list)):
            raise ValueError('report')
        for module in partition.get('modules', []):
            if not isinstance(module, dict) or not line_numbers(module.get('executable_lines')):
                raise ValueError('report')
        for line in partition.get('lines', []):
            if (not isinstance(line, dict) or type(line.get('line')) is not int or line['line'] <= 0 or
                    type(line.get('calls')) is not int or line['calls'] < 0):
                raise ValueError('report')


def validate_receipt_components(receipt, profile, inventory):
    """Validate receipt component types before equality can coerce bools/floats."""
    components = receipt.get('components')
    runners = ('exunit', 'python', 'node', 'shell')
    if not isinstance(components, dict) or set(components) != set(runners):
        raise ValueError('profile-failure')
    for runner in runners:
        count = components[runner]
        if type(count) is not int or count < 0:
            raise ValueError('profile-failure')
        expected = sum(case['profile'] == profile and case['runner'] == runner
                       for case in inventory['entries'])
        if count != expected:
            raise ValueError('profile-failure')


def validate_receipt(receipt, profile, inventory, inventory_hash):
    """Enforce the complete numeric contract before consuming runner evidence."""
    if not schema_one(receipt) or not schema_one(inventory):
        raise ValueError('profile-failure')
    for key in ('audit_count', 'expected', 'passed', 'discovered', 'executed'):
        if type(receipt.get(key)) is not int or receipt[key] < 0:
            raise ValueError('profile-failure')
    cases = [case for case in inventory['entries'] if case['profile'] == profile]
    # This is the same file oracle used by test_profile_runner.main, rather
    # than the number of cases or a hard-coded historical file count.
    files = {case['file'] for case in cases if case['runner'] == 'exunit'}
    if (receipt.get('profile') != profile or receipt.get('status') != 'complete' or
            receipt.get('inventory_digest') != inventory_hash or receipt['audit_count'] != len(files) or
            any(receipt[key] != len(cases) for key in ('expected', 'passed', 'discovered', 'executed'))):
        raise ValueError('profile-failure')
    validate_receipt_components(receipt, profile, inventory)


def validate_module_counts(modules):
    if not isinstance(modules, list) or not modules:
        raise ValueError('native-export')
    for binding in modules:
        if not isinstance(binding, dict):
            raise ValueError('native-export')
        for key in ('executable_lines', 'compiler_markers'):
            values = binding.get(key)
            if (not isinstance(values, list) or
                    any(type(n) is not int or (n <= 0 if key == 'executable_lines' else n != 0) for n in values) or
                    values != sorted(set(values))):
                raise ValueError('native-export')


def validate_native_counts(value):
    if not schema_one(value) or not isinstance(value.get('lines'), list):
        raise ValueError('native-export')
    validate_module_counts(value.get('modules'))
    for line in value['lines']:
        if (not isinstance(line, dict) or type(line.get('line')) is not int or line['line'] <= 0 or
                type(line.get('calls')) is not int or line['calls'] < 0):
            raise ValueError('native-export')


def safe_path(value):
    if not isinstance(value, str) or not value or '\\' in value or '\x00' in value:
        raise ValueError('inventory')
    path = PurePosixPath(value)
    if (path.is_absolute() or path.as_posix() != value or
            any(part in ('', '.', '..') for part in path.parts) or
            any(ord(char) < 32 or ord(char) == 127 for char in value)):
        raise ValueError('inventory')
    return path.as_posix()


def git_paths(elixir_only=True):
    proc = subprocess.run(['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard'],
                          cwd=ROOT, check=True, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
    return sorted({p.decode('utf-8') for p in proc.stdout.split(b'\0') if p and
                   (not elixir_only or Path(p.decode('utf-8')).suffix in ('.ex', '.exs'))})


def snapshot(output_root=OUTPUT):
    """Stable content snapshot includes tracked/untracked sources and deletion markers."""
    records = []
    out = output_root.resolve()
    for relative in sorted(git_paths(elixir_only=False)):
        p = ROOT / relative
        if relative.startswith(FEATURE.relative_to(ROOT).as_posix() + '/') and (
                relative.endswith(('handoffs/develop.md', 'handoffs/qa.md', 'handoffs/review.md',
                                   'qa-report.md', 'review-report.md', 'evidence-summary.json'))):
            continue
        if not p.exists():
            records.append([relative, 'deleted'])
        elif p.resolve().is_relative_to(out) or any(part in EXCLUDED_PARTS for part in Path(relative).parts):
            continue
        else:
            content = os.readlink(p).encode() if p.is_symlink() else p.read_bytes()
            if relative.startswith('backlog/TASK-067-'):
                content = re.sub(rb'(?m)^(status|active_run):[^\n]*', rb'\1: <workflow>', content)
            if relative.endswith('/tasks.md') or relative.endswith('tasks.md'):
                content = content.replace(b'- [X]', b'- [ ]').replace(b'- [x]', b'- [ ]')
            records.append([relative, digest(content)])
    return digest(canonical_json(records))


def source_inventory():
    try:
        canonical = strict_json(CANONICAL.read_text())
        scope = strict_json(SCOPE.read_text())
    except (OSError, ValueError, json.JSONDecodeError):
        raise ValueError('inventory') from None
    if not schema_one(canonical) or not schema_one(scope):
        raise ValueError('inventory')
    maintained, canonical_excluded = canonical.get('maintained'), canonical.get('excluded')
    if not schema_one(canonical) or not isinstance(maintained, list) or not isinstance(canonical_excluded, list):
        raise ValueError('inventory')
    excluded_paths = [x.get('path') for x in canonical_excluded if isinstance(x, dict)]
    canonical_list = maintained + excluded_paths
    if (len(excluded_paths) != len(canonical_excluded) or
            not all(isinstance(path, str) and safe_path(path) == path for path in canonical_list) or
            len(set(canonical_list)) != len(canonical_list)):
        raise ValueError('inventory')
    canonical_paths = set(maintained) | set(excluded_paths)
    entries = scope.get('entries')
    if not schema_one(scope) or not isinstance(entries, list):
        raise ValueError('inventory')
    found = {}
    for row in entries:
        if not isinstance(row, dict):
            raise ValueError('inventory')
        path = safe_path(row.get('path'))
        role, disposition, reason = row.get('role'), row.get('disposition'), row.get('reason')
        if path in found or path not in canonical_paths or not isinstance(reason, str) or not reason.strip():
            raise ValueError('inventory')
        expected_role = (
            'archived-evidence' if path in excluded_paths else
            'application' if path.startswith('lib/') else
            'fixture' if path.startswith('test/fixtures/') else
            'test-support' if path.startswith('test/support/') else
            'test' if path.startswith('test/') else
            'configuration' if path.startswith('config/') else
            'migration' if path.startswith('priv/') else
            'script' if path.startswith('scripts/') else 'root-tooling')
        if role != expected_role or disposition != ('include' if expected_role == 'application' else 'exclude'):
            raise ValueError('inventory')
        if disposition == 'include':
            if role != 'application' or not path.startswith('lib/') or path not in maintained:
                raise ValueError('inventory')
        elif disposition == 'exclude':
            if role not in ('test', 'fixture', 'test-support', 'configuration', 'migration', 'script', 'root-tooling', 'archived-evidence'):
                raise ValueError('inventory')
        else:
            raise ValueError('inventory')
        found[path] = row
    actual = set(git_paths())
    if (set(found) != canonical_paths or actual != canonical_paths or
            any(not (ROOT / path).is_file() for path in canonical_paths)):
        raise ValueError('inventory')
    return [found[p] for p in sorted(found)]


def reconcile_records(entries, partitions):
    included = {e['path']: e for e in entries if e['disposition'] == 'include'}
    excluded = [dict(path=e['path'], role=e['role'], reason=e['reason']) for e in entries if e['disposition'] == 'exclude']
    lines = defaultdict(dict)
    modules = defaultdict(set)
    module_sources = {}
    module_populations = {}
    for partition in partitions:
        if partition.get('complete') is not True or partition.get('profile') not in ('unit', 'integration'):
            raise ValueError('partition')
        if not isinstance(partition.get('modules'), list) or not isinstance(partition.get('lines'), list):
            raise ValueError('native-export')
        for binding in partition['modules']:
            path = safe_path(binding.get('source_path'))
            name, source_hash = binding.get('module'), binding.get('source_sha256')
            if path not in included or not isinstance(name, str) or not name or not isinstance(source_hash, str):
                raise ValueError('native-export')
            if name in module_sources and module_sources[name] != (path, source_hash):
                raise ValueError('native-export')
            module_sources[name] = (path, source_hash)
            baseline = binding.get('executable_lines')
            if (not isinstance(baseline, list) or baseline != sorted(set(baseline)) or
                    any(type(n) is not int or n <= 0 for n in baseline)):
                raise ValueError('native-export')
            modules[path].add(name)
        partition_bindings = {binding['module']: binding['source_path'] for binding in partition.get('modules', [])}
        if len(partition_bindings) != len(partition.get('modules', [])):
            raise ValueError('native-export')
        seen = set()
        partition_populations = defaultdict(set, {binding['module']: set() for binding in partition.get('modules', [])})
        for record in partition.get('lines', []):
            path = safe_path(record.get('source_path'))
            module, line, calls = record.get('module'), record.get('line'), record.get('calls')
            if (path not in included or not isinstance(module, str) or not module or
                    partition_bindings.get(module) != path or type(line) is not int or line <= 0 or
                    type(calls) is not int or calls < 0):
                raise ValueError('native-export')
            ident = (path, line, module)
            if ident in seen:
                raise ValueError('native-export')
            seen.add(ident)
            modules[path].add(module)
            lines[(path, line)][module] = max(lines[(path, line)].get(module, 0), calls)
            partition_populations[module].add(line)
        if partition_populations:
            for binding in partition['modules']:
                if partition_populations[binding['module']] != set(binding['executable_lines']):
                    raise ValueError('native-export')
            normalized_populations = {name: frozenset(population) for name, population in partition_populations.items()}
            if module_populations and normalized_populations != module_populations:
                raise ValueError('native-export')
            module_populations = normalized_populations
    files = []
    aggregate_exec, aggregate_covered = set(), set()
    for path, row in included.items():
        executable = sorted(line for (source, line) in lines if source == path)
        covered = sorted(line for line in executable if any(calls > 0 for calls in lines[(path, line)].values()))
        aggregate_exec.update((path, line) for line in executable)
        aggregate_covered.update((path, line) for line in covered)
        count, hit = len(executable), len(covered)
        files.append(dict(path=path, role=row['role'], modules=sorted(modules[path]), executable_lines=executable,
                          covered_lines=covered, uncovered_lines=sorted(set(executable) - set(covered)),
                          executable=count, covered=hit, uncovered=count-hit,
                          zero_executable_reason='Native instrumentation confirms no executable source lines' if not count else None,
                          percentage=round(100 * hit / count, 2) if count else None))
    total, hit = len(aggregate_exec), len(aggregate_covered)
    if total == 0:
        raise ValueError('report')
    return dict(included=files, excluded=excluded,
                totals=dict(executable=total, covered=hit, uncovered=total-hit,
                            percentage=round(100 * hit / total, 2)))


def contained_path(root, relative):
    """One read/write boundary, including existing ancestors of new paths."""
    declared_input = Path(root).absolute()
    if declared_input.is_symlink():
        raise ValueError('publication')
    declared = declared_input.resolve()
    path = declared_input / safe_path(relative)
    current = path
    while current != declared_input:
        if current.is_symlink():
            raise ValueError('publication')
        current = current.parent
    if not path.resolve().is_relative_to(declared):
        raise ValueError('publication')
    return path


def validate_run_identity(run_id, started_at=None):
    try:
        if not isinstance(run_id, str) or str(uuid.UUID(run_id)) != run_id:
            raise ValueError('report')
        if started_at is not None:
            if not isinstance(started_at, str) or 'T' not in started_at:
                raise ValueError('report')
            stamp = datetime.fromisoformat(started_at)
            if stamp.tzinfo is None or stamp.utcoffset() is None:
                raise ValueError('report')
    except (ValueError, TypeError, AttributeError):
        raise ValueError('report') from None


def partition_schedule(inventory=None):
    """Reconstruct normal scheduling from the owner's unchanged file oracle."""
    if inventory is None:
        inventory = strict_json((ROOT / 'config/test_profiles.json').read_text())
    files = {profile: sorted({case['file'] for case in inventory['entries']
                            if case['profile'] == profile and case['runner'] == 'exunit'})
             for profile in ('unit', 'integration')}
    with tempfile.TemporaryDirectory(prefix='application-schedule-') as directory:
        target = Path(directory) / 'committed.json'
        argv = ['mix', 'run', '--no-start', '-e',
                'File.write!(System.fetch_env!("PROFILE_COMMITTED_FILES"), '
                'Jason.encode!(FootballMarket.TestProfileAudit.audit!("integration").committed_files))']
        env = {key: value for key, value in os.environ.items()
               if not key.startswith(('APPLICATION_COVERAGE_', 'CP1_COVERAGE_')) and key != 'CP1_PROFILE_COVERAGE'}
        env.update(MIX_ENV='test', PROFILE_COMMITTED_FILES=str(target))
        if (subprocess.run(argv, cwd=ROOT, env=env, stdin=subprocess.DEVNULL,
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode or not target.is_file()):
            raise ValueError('partition')
        committed = strict_json(target.read_text())
    if (not isinstance(committed, list) or any(not isinstance(p, str) for p in committed) or
            len(committed) != len(set(committed)) or not set(committed) <= set(files['integration'])):
        raise ValueError('partition')
    regular = [file for file in files['integration'] if file not in committed]
    result = {'unit': [dict(id='main', selected_files=files['unit'])] if files['unit'] else [],
              'integration': ([dict(id='regular', selected_files=regular)] if regular else []) +
              [dict(id='committed_' + str(i), selected_files=[file]) for i, file in enumerate(committed)]}
    if any(not parts for parts in result.values()):
        raise ValueError('partition')
    return result


def partition_identity(part, profile, expected, run_id, observed=True):
    """Validate every declared identity, including optional expected fields."""
    if not isinstance(part, dict):
        raise ValueError('partition')
    files = expected['selected_files']
    selection = digest(json.dumps(files, separators=(',', ':')).encode())
    export = 'app_' + profile + '_' + run_id.replace('-', '') + '_' + expected['id'] + '.coverdata'
    fields = dict(profile=profile, id=expected['id'], selected_files=files,
                  selected_sha256=selection, export=export)
    for key, value in fields.items():
        if (observed or key in ('id', 'selected_files') or key in part) and part.get(key) != value:
            raise ValueError('partition')
    if observed:
        value = part.get('export_sha256')
        if not isinstance(value, str) or re.fullmatch('[0-9a-f]{64}', value) is None:
            raise ValueError('partition')
    return tuple(part.get(key) for key in ('profile', 'id', 'selected_sha256', 'export', 'export_sha256'))


def validate_profile_partitions(parts, profile, schedule, run_id, expected=False):
    if not isinstance(parts, list) or len(parts) != len(schedule[profile]):
        raise ValueError('partition')
    return [partition_identity(part, profile, want, run_id, observed=not expected)
            for part, want in zip(parts, schedule[profile])]


def validate_partition_set(partitions, run_id=None, schedule=None):
    if not isinstance(partitions, list) or any(not isinstance(p, dict) for p in partitions):
        raise ValueError('partition')
    if {p.get('profile') for p in partitions} != {'unit', 'integration'}:
        raise ValueError('partition')
    validate_run_identity(run_id)
    schedule = partition_schedule() if schedule is None else schedule
    for profile in ('unit', 'integration'):
        validate_profile_partitions([p for p in partitions if p.get('profile') == profile], profile, schedule, run_id)
    exports = [p['export'] for p in partitions]
    normalized = [p.get('normalized_file') for p in partitions]
    if len(exports) != len(set(exports)) or len(normalized) != len(set(normalized)):
        raise ValueError('partition')


def validate_sidecar(sidecar, profile, run_id, snap, receipt, receipt_hash, schedule, report_parts=None):
    if (not schema_one(sidecar) or sidecar.get('profile') != profile or
            sidecar.get('run_id') != run_id or sidecar.get('snapshot_digest') != snap or
            sidecar.get('receipt_nonce') != receipt.get('nonce') or sidecar.get('receipt_sha256') != receipt_hash):
        raise ValueError('partition')
    validate_profile_partitions(sidecar.get('expected'), profile, schedule, run_id, expected=True)
    identities = validate_profile_partitions(sidecar.get('partitions'), profile, schedule, run_id)
    for expected, observed in zip(sidecar['expected'], sidecar['partitions']):
        if 'export_sha256' in expected and expected['export_sha256'] != observed['export_sha256']:
            raise ValueError('partition')
    if report_parts is not None:
        if identities != validate_profile_partitions(report_parts, profile, schedule, run_id):
            raise ValueError('partition')
    return sidecar['partitions']


def atomic_json(path, obj, root=None):
    path = Path(path).absolute()
    declared_root = Path(OUTPUT if root is None else root).absolute()
    try:
        relative = path.relative_to(declared_root)
    except ValueError:
        raise ValueError('publication') from None
    path = contained_path(declared_root, relative.as_posix())
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix='.tmp-', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(canonical_json(obj))
            stream.flush()
            os.fsync(stream.fileno())
        os.chmod(name, 0o600)
        os.replace(name, path)
    finally:
        Path(name).unlink(missing_ok=True)


def current_status(state, run_id, snap, category=None, report=None):
    value = dict(schema_version=1, run_id=run_id, state=state, snapshot_digest=snap)
    if category:
        value['error_category'] = category
    if report:
        value.update(report_path=report, report_sha256=digest(contained_path(OUTPUT, report).read_bytes()))
    atomic_json(STATUS, value)


def preflight():
    if not subprocess.check_output(['node', '--version'], cwd=ROOT, text=True,
                                   stderr=subprocess.DEVNULL).strip().startswith('v24.'):
        raise ValueError('prerequisite')
    commands = [(['sh', 'scripts/check_toolchain.sh'], 'prerequisite'),
                (['elixir', '--version'], 'toolchain'),
                (['docker', 'info'], 'prerequisite'),
                (['docker', 'compose', 'version'], 'prerequisite'),
                (['mix', 'infrastructure.verify'], 'prerequisite'),
                (['node', '-e', 'require("./tools/openapi/node_modules/playwright-core").chromium.launch({headless:true,args:["--no-sandbox"]}).then(b=>b.close()).catch(()=>process.exit(1))'], 'prerequisite'),
                (['mix', 'assets.build'], 'prerequisite'), (['mix', 'test.prepare'], 'prerequisite')]
    for command, category in commands:
        proc = subprocess.run(command, cwd=ROOT, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if proc.returncode:
            raise ValueError(category)
    proc = subprocess.run(['python3', 'scripts/test_inventory.py', 'check'], cwd=ROOT,
                          stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if proc.returncode:
        raise ValueError('inventory')
    print('APPLICATION_COVERAGE_PREFLIGHT status=ready')


def report_html(report):
    rows = ''.join('<tr><td>' + html.escape(x['path']) + '</td><td>' + str(x['covered']) + '</td><td>' +
                   str(x['uncovered']) + '</td><td>' + str(x['executable']) + '</td><td>' +
                   ('N/A' if x['percentage'] is None else f"{x['percentage']:.2f}%") + '</td></tr>' for x in report['included'])
    exclusions = ''.join('<li>' + html.escape(x['path']) + ': ' + html.escape(x['reason']) + '</li>' for x in report['excluded'])
    return ('<!doctype html><meta charset="utf-8"><title>Application coverage</title><h1>Application coverage</h1>'
            f"<p>Run {html.escape(report['run_id'])}; snapshot {html.escape(report['snapshot_digest'])}</p>"
            f"<p>{report['totals']['percentage']:.2f}% ({report['totals']['covered']} / {report['totals']['executable']})</p>"
            '<table><tr><th>File</th><th>Covered</th><th>Uncovered</th><th>Executable</th><th>Coverage</th></tr>' + rows +
            '</table><h2>Excluded files</h2><ul>' + exclusions + '</ul>')


def measurements(report):
    rendered = []
    for file in report['included']:
        percentage = 'N/A' if file['percentage'] is None else f"{file['percentage']:.2f}%"
        rendered.append(f"| `{file['path']}` | {file['covered']} | {file['uncovered']} | {file['executable']} | {percentage} |")
    rows = '\n'.join(rendered)
    excluded = '\n'.join(f"- `{row['path']}` ({row['role']}): {row['reason']}" for row in report['excluded'])
    return (f"# Application coverage measurement\n\nRun: `{report['run_id']}`\n\nSnapshot: `{report['snapshot_digest']}`\n\n"
            f"Application implementation: {report['totals']['percentage']:.2f}% "
            f"({report['totals']['covered']} / {report['totals']['executable']} executable lines; "
            f"{report['totals']['uncovered']} uncovered).\n\n"
            "| File | Covered | Uncovered | Executable | Coverage |\n| --- | ---: | ---: | ---: | ---: |\n" + rows +
            "\n\n## Excluded files\n\n" + excluded +
            "\n\nThis informational measurement has no minimum threshold. It does not establish correctness and excludes nested BEAM, E2E and JavaScript execution.\n")


def validate(pending=None, pending_path=None):
    contained_path(OUTPUT, STATUS.relative_to(OUTPUT).as_posix())
    if not STATUS.exists():
        raise ValueError('report')
    status = strict_json(STATUS.read_text())
    if not isinstance(status, dict):
        raise ValueError('report')
    if pending is not None:
        status = dict(schema_version=1, state='complete', run_id=pending['run_id'],
                      snapshot_digest=pending['snapshot_digest'],
                      report_path=pending_path.relative_to(OUTPUT).as_posix(),
                      report_sha256=digest(pending_path.read_bytes()))
    if not schema_one(status) or status.get('state') != 'complete':
        raise ValueError(status.get('error_category', 'report'))
    rel = safe_path(status.get('report_path'))
    report_path = contained_path(OUTPUT, rel)
    if not report_path.resolve().is_relative_to(OUTPUT.resolve()) or digest(report_path.read_bytes()) != status.get('report_sha256'):
        raise ValueError('report')
    report = strict_json(report_path.read_text())
    if not schema_one(report):
        raise ValueError('report')
    validate_report_counts(report)
    for partition in report['partitions']:
        validate_module_counts(partition['modules'])
    validate_run_identity(report.get('run_id'), report.get('started_at'))
    if (report.get('started_at') is None or rel != 'runs/' + report['run_id'] + '/report.json'):
        raise ValueError('report')
    current_toolchain = dict(elixir=subprocess.check_output(['elixir', '--version'], cwd=ROOT, text=True,
                                                            stderr=subprocess.STDOUT).strip(),
                             node=subprocess.check_output(['node', '--version'], cwd=ROOT, text=True).strip())
    if (not isinstance(report, dict) or report.get('status') != 'complete' or report.get('run_id') != status.get('run_id') or
            report.get('snapshot_digest') != status.get('snapshot_digest') or
            report.get('snapshot_digest') != snapshot() or report.get('source_inventory_sha256') != digest(SCOPE.read_bytes()) or
            report.get('canonical_inventory_sha256') != digest(CANONICAL.read_bytes()) or
            report.get('test_inventory_sha256') != digest((ROOT / 'config/test_profiles.json').read_bytes()) or
            report.get('snapshot_algorithm') != 'sha256-all-inputs-v2' or
            report.get('toolchain') != current_toolchain or
            not isinstance(report.get('started_at'), str) or
            not isinstance(report.get('head'), str)):
        raise ValueError('snapshot')
    entries = source_inventory()
    linked = {}
    receipt_evidence = report.get('receipts')
    if not isinstance(receipt_evidence, dict) or set(receipt_evidence) != {'unit', 'integration'}:
        raise ValueError('profile-failure')
    for profile, evidence in receipt_evidence.items():
        if not isinstance(evidence, dict):
            raise ValueError('profile-failure')
        receipt_file = contained_path(report_path.parent, evidence.get('receipt_path'))
        sidecar_file = contained_path(report_path.parent, evidence.get('sidecar_path'))
        if (not receipt_file.is_file() or digest(receipt_file.read_bytes()) != evidence.get('receipt_sha256') or
                not sidecar_file.is_file() or digest(sidecar_file.read_bytes()) != evidence.get('sidecar_sha256')):
            raise ValueError('profile-failure')
        receipt = strict_json(receipt_file.read_text())
        inventory_bytes = (ROOT / 'config/test_profiles.json').read_bytes()
        validate_receipt(receipt, profile, strict_json(inventory_bytes), digest(inventory_bytes))
        if receipt.get('nonce') != evidence.get('nonce'):
            raise ValueError('profile-failure')
        sidecar = strict_json(sidecar_file.read_text())
        linked[profile] = (sidecar, receipt)
    schedule = partition_schedule()
    validate_partition_set(report['partitions'], report['run_id'], schedule)
    for profile, (sidecar, receipt) in linked.items():
        validate_sidecar(sidecar, profile, report['run_id'], report['snapshot_digest'], receipt,
                         receipt_evidence[profile]['receipt_sha256'], schedule,
                         [p for p in report['partitions'] if p.get('profile') == profile])
    from test_profile_components import verify_receipts
    with tempfile.TemporaryDirectory(prefix='application-receipts-') as directory:
        for profile, evidence in receipt_evidence.items():
            Path(directory, profile + '.json').write_bytes(
                contained_path(report_path.parent, evidence['receipt_path']).read_bytes())
        try:
            verify_receipts(directory)
        except (ValueError, KeyError, TypeError):
            raise ValueError('profile-failure') from None
    module_file = contained_path(report_path.parent, 'modules.json')
    if not module_file.is_file() or digest(module_file.read_bytes()) != report.get('module_manifest_sha256'):
        raise ValueError('native-export')
    module_manifest = strict_json(module_file.read_text())
    validate_module_counts(module_manifest)
    manifest_by_name = {}
    for binding in module_manifest:
        name = binding.get('module')
        path = safe_path(binding.get('source_path'))
        if (not isinstance(name, str) or not name or name in manifest_by_name or path not in {e['path'] for e in entries} or
                not isinstance(binding.get('source_sha256'), str) or digest((ROOT / path).read_bytes()) != binding['source_sha256']):
            raise ValueError('native-export')
        scope_entry = next(e for e in entries if e['path'] == path)
        if binding.get('disposition') != scope_entry['disposition']:
            raise ValueError('native-export')
        manifest_by_name[name] = binding
    included_paths = {e['path'] for e in entries if e['disposition'] == 'include'}
    if {b['source_path'] for b in module_manifest if b.get('disposition') == 'include'} != included_paths:
        raise ValueError('native-export')
    for partition in report['partitions']:
        contained_path(report_path.parent, partition.get('export'))
        contained_path(report_path.parent, partition.get('normalized_file'))
    contained_path(report_path.parent, 'report.html')
    contained_path(report_path.parent, 'measurements.md')
    for partition in report['partitions']:
        export_file = contained_path(report_path.parent, partition.get('export'))
        normalized_file = contained_path(report_path.parent, partition.get('normalized_file'))
        if (not export_file.is_file() or digest(export_file.read_bytes()) != partition.get('export_sha256') or
                not normalized_file.is_file() or digest(normalized_file.read_bytes()) != partition.get('normalized_sha256')):
            raise ValueError('native-export')
        normalized = strict_json(normalized_file.read_text())
        validate_native_counts(normalized)
        if (normalized.get('export_sha256') != partition.get('export_sha256') or
                normalized.get('lines') != partition.get('lines') or
                normalized.get('modules') != partition.get('modules')):
            raise ValueError('native-export')
        expected_modules = [binding for binding in module_manifest if binding['disposition'] == 'include']
        if partition.get('modules') != expected_modules or partition.get('module_manifest_sha256') != report.get('module_manifest_sha256'):
            raise ValueError('native-export')
    # Prove the archived baseline independently once; each partition still gets
    # its own fresh native import and complete module/line/hash checks.
    with tempfile.TemporaryDirectory(prefix='application-baseline-') as directory:
        fresh = Path(directory) / 'modules.json'
        argv = ['mix', 'run', '--no-start', 'scripts/application_coverage_native.exs',
                '--manifest', '--output', str(fresh)]
        if subprocess.run(argv, cwd=ROOT, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                          stderr=subprocess.DEVNULL).returncode or not fresh.is_file():
            raise ValueError('native-export')
        if strict_json(fresh.read_text()) != module_manifest:
            raise ValueError('native-export')
    for partition in report['partitions']:
        export_file = contained_path(report_path.parent, partition['export'])
        normalized = strict_json(contained_path(report_path.parent, partition['normalized_file']).read_text())
        with tempfile.TemporaryDirectory(prefix='application-native-validate-') as directory:
            reread = Path(directory) / 'normalized.json'
            argv = ['mix', 'run', '--no-start', 'scripts/application_coverage_native.exs',
                    '--export', str(export_file), '--modules', str(module_file), '--output', str(reread)]
            if subprocess.run(argv, cwd=ROOT, stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
                              stderr=subprocess.DEVNULL).returncode or not reread.is_file():
                raise ValueError('native-export')
            if strict_json(reread.read_text()) != normalized:
                raise ValueError('native-export')
    accounting = reconcile_records(entries, report.get('partitions', []))
    if accounting != {k: report[k] for k in ('included', 'excluded', 'totals')}:
        raise ValueError('report')
    if report_html(report) != contained_path(report_path.parent, 'report.html').read_text():
        raise ValueError('report')
    measured_text = contained_path(report_path.parent, 'measurements.md').read_text()
    if measured_text != measurements(report):
        raise ValueError('report')
    if snapshot() != report['snapshot_digest']:
        raise ValueError('snapshot')
    return report


def run():
    contained_path(OUTPUT.parent, OUTPUT.name)
    out = OUTPUT.absolute()
    if out == ROOT or not out.is_relative_to(ROOT):
        raise ValueError('publication')
    out.mkdir(parents=True, exist_ok=True, mode=0o700)
    lock_path = contained_path(out, '.lock')
    contained_path(out, 'runs')
    contained_path(out, STATUS.relative_to(out).as_posix())
    if lock_path.is_symlink() or STATUS.is_symlink() or (out / 'runs').is_symlink():
        raise ValueError('publication')
    lock_path.touch(mode=0o600, exist_ok=True)
    with lock_path.open('r+') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise ValueError('lock') from None
        run_id = str(uuid.uuid4())
        snap = snapshot()
        started_at = datetime.now(timezone.utc).isoformat()
        head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True, stderr=subprocess.DEVNULL).strip()
        current_status('running', run_id, snap)
        staging = Path(tempfile.mkdtemp(prefix='.staging-', dir=out))
        try:
            preflight()
            if snapshot() != snap:
                raise ValueError('snapshot')
            entries = source_inventory()
            if any(e['disposition'] == 'include' for e in entries) is False:
                raise ValueError('inventory')
            env = {**os.environ, 'MIX_ENV': 'test', 'APPLICATION_COVERAGE_DIR': str(staging.resolve()),
                   'APPLICATION_COVERAGE_RUN_ID': run_id, 'APPLICATION_COVERAGE_SNAPSHOT': snap}
            module_manifest = contained_path(staging, 'modules.json')
            native = ['mix', 'run', '--no-start', 'scripts/application_coverage_native.exs', '--manifest',
                      '--output', str(module_manifest)]
            if subprocess.run(native, cwd=ROOT, env=env, stdin=subprocess.DEVNULL,
                              stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode or not module_manifest.exists():
                raise ValueError('native-export')
            module_manifest = contained_path(staging, 'modules.json')
            schedule = partition_schedule()
            partitions = []
            receipt_evidence = {}
            for profile in ('unit', 'integration'):
                if snapshot() != snap:
                    raise ValueError('snapshot')
                receipt = contained_path(staging, profile + '-receipt.json')
                env['CP1_PROFILE_RECEIPT'] = str(receipt)
                proc = subprocess.run(['sh', 'scripts/test_profile.sh', profile], cwd=ROOT, env=env,
                                      stdin=subprocess.DEVNULL)
                if snapshot() != snap:
                    raise ValueError('snapshot')
                if proc.returncode or not receipt.exists():
                    raise ValueError('profile-failure')
                receipt = contained_path(staging, receipt.name)
                metadata = strict_json(receipt.read_text())
                inventory_bytes = (ROOT / 'config/test_profiles.json').read_bytes()
                validate_receipt(metadata, profile, strict_json(inventory_bytes), digest(inventory_bytes))
                sidecar = contained_path(staging, profile + '-coverage.json')
                if not sidecar.exists():
                    raise ValueError('partition')
                sidecar = contained_path(staging, sidecar.name)
                side = strict_json(sidecar.read_text())
                observed_partitions = validate_sidecar(side, profile, run_id, snap, metadata,
                                                       digest(receipt.read_bytes()), schedule)
                for item in observed_partitions:
                    export = contained_path(staging, item['export'])
                    if not export.is_file() or item.get('export_sha256') != digest(export.read_bytes()):
                        raise ValueError('partition')
                    normalized_path = contained_path(staging, profile + '_' + item['id'] + '.normalized.json')
                    invocation = ['mix', 'run', '--no-start', 'scripts/application_coverage_native.exs',
                                  '--export', str(export), '--modules', str(module_manifest),
                                  '--output', str(normalized_path)]
                    if subprocess.run(invocation, cwd=ROOT, env=env, stdin=subprocess.DEVNULL,
                                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode or not normalized_path.exists():
                        raise ValueError('native-export')
                    normalized_path = contained_path(staging, normalized_path.name)
                    normalized = strict_json(normalized_path.read_text())
                    validate_native_counts(normalized)
                    if normalized.get('export_sha256') != digest(export.read_bytes()):
                        raise ValueError('native-export')
                    partitions.append(dict(profile=profile, id=item['id'], selected_files=item['selected_files'],
                                           selected_sha256=item['selected_sha256'], export=item['export'],
                                           export_sha256=digest(export.read_bytes()), complete=True,
                                           module_manifest_sha256=digest(module_manifest.read_bytes()),
                                           normalized_file=normalized_path.name,
                                           normalized_sha256=digest(normalized_path.read_bytes()),
                                           modules=normalized.get('modules'), lines=normalized.get('lines')))
                receipt_evidence[profile] = dict(receipt_path=receipt.name, receipt_sha256=digest(receipt.read_bytes()),
                                                 sidecar_path=sidecar.name, sidecar_sha256=digest(sidecar.read_bytes()),
                                                 nonce=metadata['nonce'])
            if snapshot() != snap:
                raise ValueError('snapshot')
            validate_partition_set(partitions, run_id, schedule)
            accounting = reconcile_records(entries, partitions)
            report = dict(schema_version=1, status='complete', run_id=run_id, snapshot_digest=snap,
                          head=head, snapshot_algorithm='sha256-all-inputs-v2',
                          started_at=started_at,
                          toolchain=dict(elixir=subprocess.check_output(['elixir', '--version'], cwd=ROOT, text=True,
                                                                         stderr=subprocess.STDOUT).strip(),
                                         node=subprocess.check_output(['node', '--version'], cwd=ROOT, text=True).strip()),
                          canonical_inventory_sha256=digest(CANONICAL.read_bytes()),
                          source_inventory_sha256=digest(SCOPE.read_bytes()),
                          test_inventory_sha256=digest((ROOT / 'config/test_profiles.json').read_bytes()),
                          module_manifest_sha256=digest(module_manifest.read_bytes()),
                          receipts=receipt_evidence, partitions=partitions, **accounting)
            final_rel = 'runs/' + run_id
            final = contained_path(out, final_rel)
            if final.exists():
                raise ValueError('publication')
            atomic_json(contained_path(staging, 'report.json'), report)
            contained_path(staging, 'report.html').write_text(report_html(report), encoding='utf-8')
            contained_path(staging, 'measurements.md').write_text(measurements(report), encoding='utf-8')
            final.parent.mkdir(parents=True, exist_ok=True)
            os.rename(staging, final)
            relative_report = final_rel + '/report.json'
            validate(pending=report, pending_path=final / 'report.json')
            if snapshot() != snap:
                raise ValueError('snapshot')
            current_status('complete', run_id, snap, report=relative_report)
            print('APPLICATION_COVERAGE status=complete run=' + run_id)
        except Exception as error:
            category = str(error) if isinstance(error, ValueError) and str(error) in {
                'prerequisite', 'inventory', 'snapshot', 'profile-failure', 'partition', 'native-export',
                'report', 'publication', 'lock'} else 'report'
            current_status('failed', run_id, snap, category=category)
            raise ValueError(category) from None
        finally:
            import shutil
            shutil.rmtree(staging, ignore_errors=True)


def main():
    os.environ['MIX_ENV'] = 'test'
    parser = argparse.ArgumentParser()
    parser.add_argument('command', choices=('preflight', 'run', 'validate'))
    args = parser.parse_args()
    try:
        if args.command == 'preflight':
            preflight()
        elif args.command == 'run':
            run()
        else:
            report = validate()
            print('APPLICATION_COVERAGE status=valid percentage=' + str(report['totals']['percentage']))
    except Exception as error:
        category = str(error) if isinstance(error, ValueError) else 'report'
        if category not in ('prerequisite', 'inventory', 'snapshot', 'profile-failure', 'partition', 'native-export', 'report', 'publication', 'lock'):
            category = 'report'
        print('APPLICATION_COVERAGE status=failed category=' + category, file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    os.umask(0o077)
    sys.exit(main())
