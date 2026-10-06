"""Durable task ownership and contained evidence, independent of delivery adapters."""
from __future__ import annotations
from dataclasses import dataclass
import os
from pathlib import Path
import re

FRONTMATTER = re.compile(r'\A---\r?\n(.*?)^---[ \t]*(?:\r?\n|$)', re.M | re.S)

class AssociationError(ValueError, RuntimeError):
    """An actionable, fail-closed ownership or evidence error."""

def slug(text):
    return re.sub(r'[^a-z0-9]+', '-', text.lower()).strip('-') or 'task'

def read_text(path):
    try:
        return path.read_bytes().decode('utf-8')
    except (OSError, UnicodeError) as error:
        raise AssociationError(f'Cannot read {path}: {error}') from error

def parsed_metadata(task):
    """Read the scalar contract once, retaining value spans for safe updates."""
    text = read_text(task)
    front = FRONTMATTER.match(text)
    if not front:
        raise AssociationError(f'Invalid task frontmatter: {task}')
    fields, spans = {}, {}
    offset = front.start(1)
    for number, line in enumerate(front.group(1).splitlines(keepends=True), 2):
        content = line.rstrip('\r\n')
        if not content.strip() or content.lstrip().startswith('#'):
            offset += len(line)
            continue
        match = re.fullmatch(r'([a-z_]+):[ \t]*(.*)', content)
        def invalid(reason, key):
            raise AssociationError(f'{reason} {key} metadata at line {number}: {task}')
        if not match:
            # Identify only the key, never expose potentially sensitive values.
            key = content.split(':', 1)[0].strip().strip('"\'').lower()
            invalid('Unsupported', key if re.fullmatch(r'[a-z_]+', key) else 'entry')
        key, raw = match.groups()
        if key in fields:
            invalid('Duplicate', key)
        value = raw.strip()
        left = match.start(2) + len(raw) - len(raw.lstrip())
        right = match.end(2) - (len(raw) - len(raw.rstrip()))
        if value.startswith(('"', "'")):
            if len(value) < 2 or value[-1] != value[0]:
                invalid('Malformed scalar', key)
            value = value[1:-1]
            left += 1
            right -= 1
        elif value.startswith(('[', '{', '|', '>', '!', '&', '*')):
            invalid('Unsupported scalar', key)
        fields[key] = value
        spans[key] = (offset + left, offset + right)
        offset += len(line)
    return text, fields, spans

def metadata(task):
    return parsed_metadata(task)[1]

def expected_branch(task):
    fields = metadata(task)
    ident, title = fields.get('id', ''), fields.get('title', '')
    if not re.fullmatch(r'TASK-\d{3}', ident) or not title.strip():
        raise AssociationError(f'Missing or invalid id/title: {task}')
    if not task.name.startswith(ident + '-') or task.suffix != '.md':
        raise AssociationError(f'Filename/frontmatter identity mismatch for {ident}: {task}')
    return f'{ident[5:]}-{slug(title)}'

def task_id_from_head(head_ref):
    match = re.fullmatch(r'(\d{3})-[a-z0-9][a-z0-9-]*', head_ref)
    if not match:
        raise AssociationError(f'Not an Agentflow feature branch: {head_ref}')
    return f'TASK-{match.group(1)}'

def task_for_id(root, task_id):
    if not re.fullmatch(r'TASK-\d{3}', task_id):
        raise AssociationError(f'Invalid task identity: {task_id}')
    matches = []
    for candidate in sorted((root / 'backlog').glob('TASK-*.md')):
        filename_claim = candidate.name.startswith(task_id + '-')
        try:
            text = read_text(candidate)
            header = FRONTMATTER.match(text)
            front = header.group(1) if header else text if text.startswith('---') else ''
            # Discovery is deliberately broader than the accepted scalar grammar:
            # unsupported Unicode whitespace must not hide a competing ID claim.
            # Use the parser's line boundaries and normalize case-insensitive
            # claims before comparing them with the canonical task identity.
            claims = [claim.upper() for line in front.splitlines() for claim in
                      re.findall(r"(?i)^[^\S\r\n]*[\"']?id[\"']?[^\S\r\n]*:[^\r\n]*?(TASK-\d{3})", line)]
        except AssociationError:
            if filename_claim:
                raise
            continue
        if filename_claim or task_id in claims:
            matches.append(candidate)
    if len(matches) != 1:
        raise AssociationError(f'Expected exactly one backlog file for {task_id}; candidates: {matches}')
    task = matches[0]
    expected_branch(task)
    if metadata(task)['id'] != task_id:
        raise AssociationError(f'Requested {task_id} disagrees with {task}')
    if task.resolve().parent != (root / 'backlog').resolve():
        raise AssociationError(f'Unsafe backlog path for {task_id}: {task}')
    return task

@dataclass(frozen=True)
class FeatureAssociation:
    task: Path
    branch: str
    feature: Path

def contained_file(feature, name):
    path = feature / name
    try:
        resolved = path.resolve(strict=True)
        if not resolved.is_relative_to(feature.resolve()) or not resolved.is_file():
            raise AssociationError(f'Unsafe canonical file {path}: outside selected feature')
        read_text(resolved)
    except (OSError, RuntimeError) as error:
        if isinstance(error, AssociationError):
            raise
        raise AssociationError(f'Cannot read canonical file {path}: {error}') from error
    return resolved

def resolve_feature(root, task, head_ref=None, allow_missing=False):
    root = root.resolve()
    fields = metadata(task)
    branch = expected_branch(task)
    ident = fields['id']
    if task_for_id(root, ident) != task:
        raise AssociationError(f'{ident} {branch}: caller task is not canonical: {task}')
    def fail(reason, candidates=()):
        raise AssociationError(f'{ident} expected {branch}: {reason}; candidates: {", ".join(map(str,candidates)) or "none"}')
    if head_ref is not None and head_ref != branch:
        fail(f'branch mismatch, found {head_ref}')
    specs = (root / 'specs').resolve()
    target = None
    if 'feature_directory' in fields:
        value = fields['feature_directory']
        if not re.fullmatch(r'specs/[^./\\][^/\\]*', value) or any(p in ('.','..') for p in Path(value).parts):
            fail(f'Invalid feature_directory {value!r}')
        target = (root / value).resolve()
        if not target.is_dir() or target.parent != specs:
            fail(f'Unsafe or missing feature_directory {value!r}', [target])
    matches, legacy, seen = [], [], set()
    for child in sorted((root / 'specs').iterdir()) if (root / 'specs').is_dir() else []:
        if not child.is_dir():
            continue
        candidate = child.resolve()
        numbered = child.name.startswith(ident[5:] + '-')
        explicit_target = candidate == target
        relevant = numbered or explicit_target
        try:
            # Scan declaration text, then enforce containment before selecting it.
            text = read_text(child / 'spec.md')
        except AssociationError as error:
            if relevant:
                fail(str(error), [child])
            continue
        declarations = [line for line in text.splitlines() if re.match(r'^\s*(?:#{1,6}\s*)?(?:\*\*)?Feature Branch\b', line, re.I)]
        claims_task = any(re.search(r'(?<!\d)' + ident[5:] + r'-', line) for line in declarations)
        relevant = relevant or claims_task
        if not relevant:
            continue
        if candidate.parent != specs:
            fail('Unsafe feature directory', [child])
        try:
            contained_file(candidate, 'spec.md')
        except AssociationError as error:
            fail(str(error), [child])
        values = []
        for line in declarations:
            match = re.fullmatch(r'\s*\*\*Feature Branch\*\*:[ \t]*`(\d{3}-[a-z0-9][a-z0-9-]*)`[ \t]*', line)
            if not match:
                fail('Malformed Feature Branch declaration', [child])
            values.append(match.group(1))
        if len(values) > 1:
            fail('Duplicate Feature Branch declarations', [child])
        value = values[0] if values else None
        if value and value.startswith(ident[5:] + '-') and value != branch:
            fail(f'Conflicting Feature Branch {value}', [child])
        if explicit_target and value not in (None, branch):
            fail(f'Metadata disagrees with Feature Branch {value}', [child])
        if candidate in seen:
            continue
        seen.add(candidate)
        if value == branch:
            matches.append(candidate)
        # Valid foreign declarations are not eligible legacy owners.
        if numbered and value is None:
            legacy.append((candidate, value))
    if len(matches) > 1:
        fail('Ambiguous branch ownership', matches)
    if matches:
        selected = matches[0]
        if target is not None and selected != target:
            fail('Metadata conflicts with branch ownership', [target, selected])
    elif target is not None:
        # The scan validated its readable spec and declaration, including aliases.
        contained_file(target, 'spec.md')
        selected = target
    elif len(legacy) == 1 and legacy[0][1] is None:
        selected = legacy[0][0]
    elif legacy:
        fail('Ambiguous or contradictory legacy ownership', [p for p,_ in legacy])
    elif allow_missing:
        return None
    else:
        fail('Missing feature ownership')
    return FeatureAssociation(task, branch, selected)

def terminal_verdict(path):
    lines = [line.strip() for line in read_text(path).splitlines() if line.strip()]
    return lines[-1] if lines else ''

def require_reports(association):
    for name in ('qa-report.md', 'review-report.md'):
        try:
            path = contained_file(association.feature, name)
            if terminal_verdict(path) != 'Verdict: PASS':
                raise AssociationError(f'{name} has not passed')
        except AssociationError as error:
            raise AssociationError(f'{metadata(association.task)["id"]} expected {association.branch}, {association.feature}: {name} has not passed: {error}') from error

def complete_reviewed_task(root, task, head_ref=None, allow_done_noop=False):
    """Validate all inputs, then replace two values in one atomic local write.

    Human acceptance/confirmed merge authorization belongs to the caller.
    """
    import tempfile
    branch = expected_branch(task)
    fields = metadata(task)
    ident = fields['id']
    if task_for_id(root, ident) != task or (head_ref is not None and head_ref != branch):
        raise AssociationError(f'{ident} expected {branch}: invalid task/full branch {head_ref}')
    status = fields.get('status')
    if not status:
        raise AssociationError(f'{ident} expected {branch}: missing status in {task}')
    if status == 'done' and allow_done_noop:
        return None
    if status != 'review':
        raise AssociationError(f'Refusing to finalize {ident} expected {branch} from {status}')
    if not fields.get('active_run'):
        raise AssociationError(f'{ident} expected {branch}: missing active_run in {task}')
    association = resolve_feature(root, task, head_ref=head_ref)
    require_reports(association)
    text, current_fields, spans = parsed_metadata(task)
    if current_fields != fields:
        raise AssociationError(f'{ident}: task metadata changed during completion: {task}')
    # These are the exact scalar boundaries validated by the common parser.
    replacements = [(spans[key], value) for key, value in (('status', 'done'), ('active_run', 'none'))]
    for (start, end), value in sorted(replacements, reverse=True):
        text = text[:start] + value + text[end:]
    updated = text.encode('utf-8')
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=task.parent, suffix='.tmp', delete=False) as output:
            temporary = Path(output.name)
            output.write(updated)
            output.flush()
            os.fsync(output.fileno())
        os.chmod(temporary, task.stat().st_mode)
        os.replace(temporary, task)
    except OSError as error:
        raise AssociationError(f'{ident} expected {branch}: cannot finalize {task}: {error}') from error
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    return task
