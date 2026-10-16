"""Canonical command manifests and current-workspace check receipts."""
from __future__ import annotations

import hashlib
import json
import os
import re
import subprocess
import uuid
from pathlib import Path

REQUIREMENT = re.compile(r"\b(?:FR|AC|SC)-\d+\b")
TASK = re.compile(r"^\s*- \[([ xX])\]\s+(T\d+)\b(.*)$", re.M)
LABEL = re.compile(r"[a-z][a-z0-9_-]{0,63}")


def digest(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)
    except (OSError, ValueError, UnicodeError) as error:
        raise RuntimeError(f"Invalid or missing JSON: {path.name}") from error


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError("Duplicate JSON key")
        result[key] = value
    return result


def http_contract_required(feature: Path) -> bool:
    """Conservatively recognize route declarations without a YAML dependency."""
    method_route = re.compile(r"\b(?:GET|POST|PUT|PATCH|DELETE|HEAD|OPTIONS)\s+/", re.I)
    if method_route.search((feature / "spec.md").read_text()):
        return True
    for path in sorted((feature / "contracts").rglob("*")):
        if not path.is_file() or path.suffix.lower() not in (".md", ".txt", ".http", ".yaml", ".yml", ".json", ".raml"):
            continue
        text = path.read_text(encoding="utf-8")
        if path.suffix.lower() == ".json":
            document = load_json(path)
            if isinstance(document, dict):
                routes = document.get("paths", {})
                if isinstance(routes, dict) and any(key.startswith("/") for key in routes):
                    return True
                if any(key.startswith("/") for key in document):
                    return True
        elif path.suffix.lower() in (".yaml", ".yml", ".raml"):
            # Block/flow mappings, quoted routes and referenced path items count
            # even when operations live elsewhere. Over-detection is preferable
            # to accepting unit-only evidence for a planned HTTP interface.
            if re.search(r'''(?:^|[,{]\s*)\s*(?:['"]/[^\n'"]*['"]|/[^\s\n]*?)\s*:''', text, re.M):
                return True
        if method_route.search(text):
            return True
    return False


def manifest(feature: Path) -> dict:
    data = load_json(feature / "verification.json")
    if not isinstance(data, dict) or type(data.get("schema_version")) is not int or data["schema_version"] != 1:
        raise RuntimeError("verification.json requires schema_version 1")
    checks = data.get("checks")
    if not isinstance(checks, list) or not checks:
        raise RuntimeError("Manifest requires concrete checks")
    ids = set()
    for check in checks:
        if not isinstance(check, dict) or not isinstance(check.get("id"), str) or not LABEL.fullmatch(check["id"]) or check["id"] in ids:
            raise RuntimeError("Invalid or duplicate check ID")
        ids.add(check["id"])
        argv = check.get("argv")
        if not isinstance(argv, list) or not argv or not all(isinstance(a, str) and a and "\0" not in a for a in argv):
            raise RuntimeError("Check argv must be a nonempty string array")
        env = check.get("env", {})
        if not isinstance(env, dict) or not all(isinstance(k, str) and re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", k) and k.upper() not in ("HOME", "CODEX_HOME") and isinstance(v, str) and "\0" not in v for k, v in env.items()):
            raise RuntimeError("Invalid check environment")
        if type(check.get("runtime", False)) is not bool:
            raise RuntimeError("runtime must be boolean")
        if type(check.get("reuse", True)) is not bool:
            raise RuntimeError("reuse must be boolean")
        if check.get("runtime") and not isinstance(check.get("expectation"), str):
            raise RuntimeError("Runtime checks require expected status/body assertions")
        if check.get("runtime") and not check["expectation"].strip():
            raise RuntimeError("Runtime checks require expected status/body assertions")
    requirements = set(REQUIREMENT.findall((feature / "spec.md").read_text()))
    coverage = data.get("coverage")
    if not requirements or not isinstance(coverage, dict) or set(coverage) != requirements:
        raise RuntimeError("Coverage must map every canonical FR/AC/SC identifier exactly")
    for mappings in coverage.values():
        if not isinstance(mappings, list) or not mappings or not all(isinstance(item, str) and item in ids for item in mappings) or len(set(mappings)) != len(mappings):
            raise RuntimeError("Coverage requires unique existing check IDs")
    http_required = http_contract_required(feature)
    if type(data.get("runtime_required")) is not bool:
        raise RuntimeError("runtime_required must explicitly be boolean")
    if (http_required or data["runtime_required"]) and not any(c.get("runtime") for c in checks):
        raise RuntimeError("HTTP/runtime obligation requires an executable runtime assertion check")
    stages = data.get("task_stages", {})
    if not isinstance(stages, dict) or not all(re.fullmatch(r"T\d+", k) and v in ("qa", "review") for k, v in stages.items()):
        raise RuntimeError("Only explicitly mapped QA/review tasks may be deferred")
    return data


def input_fingerprint(feature: Path) -> str:
    parts = []
    required = {"spec.md", "plan.md", "tasks.md", "verification.json"}
    paths = {feature / name for name in required}
    # Bind feature design inputs, including additions and deletions. Reports and
    # handoffs are outputs; updating them must not invalidate passing checks.
    paths.update(p for p in feature.glob("*.md") if p.name not in ("qa-report.md", "review-report.md", "verification.md"))
    for directory in ("contracts", "checklists"):
        paths.update(p for p in (feature / directory).rglob("*") if p.is_file())
    for path in sorted(paths):
        name = path.relative_to(feature).as_posix()
        content = path.read_bytes()
        if name == "tasks.md":
            # Recording completion after a successful check doesn't change what
            # was checked. Readiness separately validates current task state.
            content = re.sub(rb"(?m)^(\s*- )\[[ xX]\]", rb"\1[?]", content)
        parts.append(name.encode() + b"\0" + content)
    # Human feedback and explicit development overrides are canonical inputs.
    root = feature.parents[1]
    head=subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()
    ident='TASK-'+head[:3]
    feedback = root / 'backlog/feedback' / f'{ident}.md'
    parts.append(b'feedback\0' + (feedback.read_bytes() if feedback.exists() else b'<absent>'))
    return digest(b"\0".join(parts))


def source_fingerprint(root: Path) -> str:
    result = subprocess.run(["git", "ls-files", "--cached", "--others", "--exclude-standard", "-z"], cwd=root, capture_output=True)
    if result.returncode:
        raise RuntimeError("Cannot fingerprint repository inputs")
    h = hashlib.sha256()
    for raw in sorted(set(result.stdout.split(b"\0")) - {b""}):
        name = os.fsdecode(raw)
        if name.startswith(("tmp/", ".agentflow/runs/", ".specify/workflows/runs/")) or name == ".specify/feature.json":
            continue
        if re.fullmatch(r'specs/[^/]+/(?:qa-report\.md|review-report\.md|evidence-summary\.json|handoffs/(?:develop|qa|review)\.md|handoffs/check-[a-z0-9_-]+\.json)', name):
            continue
        if name.startswith('backlog/') and not name.startswith('backlog/feedback/'):
            # Lifecycle fields are outputs. Only explicit launch overrides bind source.
            content=(root/name).read_text() if (root/name).is_file() else ''
            overrides='\n'.join(re.findall(r'(?m)^develop_(?:model|effort):.*$',content))
            if overrides: h.update(raw+b'\0'+overrides.encode()+b'\0')
            continue
        path = root / name
        content = os.fsencode(os.readlink(path)) if path.is_symlink() else path.read_bytes() if path.is_file() else b"<deleted>"
        if re.fullmatch(r'specs/[^/]+/tasks\.md',name):
            content=re.sub(rb'(?m)^(\s*- )\[[ xX]\]',rb'\1[?]',content)
        h.update(raw + b"\0" + digest(content).encode() + b"\0")
    return h.hexdigest()


def check_identity(check: dict) -> str:
    return digest(json.dumps({"argv": check["argv"], "env": check.get("env", {})}, sort_keys=True).encode())


def atomic_json(path: Path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.resolve().is_relative_to(path.parents[0].resolve()):
        raise RuntimeError('Unsafe local output path')
    temporary = path.with_name(path.name + '.' + uuid.uuid4().hex + '.tmp')
    temporary.write_text(json.dumps(data, indent=2) + '\n')
    temporary.replace(path)


def workspace(root: Path, create=False):
    directory = root / '.agentflow/runs/checks'
    if not directory.resolve().is_relative_to(root.resolve()):
        raise RuntimeError('Unsafe workspace evidence directory')
    path = directory / 'workspace.json'
    if not path.exists() and create:
        atomic_json(path, {'schema_version': 2, 'workspace': uuid.uuid4().hex,
                           'root': str(root.resolve())})
    data = load_json(path)
    if data.get('schema_version') != 2 or data.get('root') != str(root.resolve()) or not re.fullmatch(r'[a-f0-9]{32}', data.get('workspace', '')):
        raise RuntimeError('Evidence belongs to another workspace; run local checks')
    return data['workspace']


def receipt_path(root, feature, check, stage='develop', create=False):
    if stage not in ('develop', 'qa', 'review') or not LABEL.fullmatch(check['id']):
        raise RuntimeError('Invalid receipt namespace')
    directory = root / '.agentflow/runs/checks' / workspace(root, create) / feature.name / stage / check['id']
    if not directory.resolve().is_relative_to((root / '.agentflow/runs/checks').resolve()):
        raise RuntimeError('Unsafe receipt namespace')
    return directory / 'receipt.json'


def retry_fingerprint(root, feature, check):
    selectors = check.get('retry_inputs')
    if selectors is None:
        return source_fingerprint(root)
    if not isinstance(selectors, list) or not selectors or any(not isinstance(p, str) or Path(p).is_absolute() or '..' in Path(p).parts for p in selectors):
        raise RuntimeError('Invalid relevant obligation input selectors')
    result = subprocess.run(['git', 'ls-files', '--cached', '--others', '--exclude-standard', '-z'], cwd=root, capture_output=True, check=True)
    parts = []
    import fnmatch
    for raw in sorted(set(result.stdout.split(b'\0')) - {b''}):
        name = os.fsdecode(raw)
        if not any(fnmatch.fnmatchcase(name, pattern) for pattern in selectors):
            continue
        path = root / name
        content = path.read_bytes() if path.is_file() and not path.is_symlink() else b'<deleted-or-link>'
        parts.append(raw + b'\0' + digest(content).encode())
    return digest(b'\0'.join(parts))


def current_receipt(root: Path, feature: Path, check: dict, source: str, inputs: str, stage='develop') -> dict:
    """Readiness and development reuse share this strict workspace validator."""
    receipt = load_json(receipt_path(root, feature, check, stage))
    if receipt.get('schema_version') != 2 or receipt.get('workspace') != workspace(root) or receipt.get('feature') != feature.name or receipt.get('stage') != stage:
        raise RuntimeError('Wrong workspace, feature or stage evidence')
    if receipt.get('state') != 'passed' or type(receipt.get('exit_code')) is not int or receipt['exit_code'] != 0:
        raise RuntimeError(f"Required check failed or is incomplete: {check['id']}")
    if receipt.get('check_identity') != check_identity(check) or receipt.get('source_before') != source or receipt.get('source_after') != source or receipt.get('inputs') != inputs:
        raise RuntimeError(f"Stale check evidence: {check['id']}")
    relative = receipt.get('evidence')
    if not isinstance(relative, str) or Path(relative).is_absolute():
        raise RuntimeError('Missing check evidence')
    evidence = (root / relative).resolve()
    directory = receipt_path(root, feature, check, stage).parent.resolve()
    if not evidence.is_relative_to(directory) or not evidence.is_file() or receipt.get('evidence_sha256') != digest(evidence.read_bytes()):
        raise RuntimeError('Missing or changed check output')
    return receipt


def readiness(root: Path, feature: Path) -> dict:
    try:
        from .agentflow_artifacts import validate
    except ImportError:
        from agentflow_artifacts import validate
    validate(feature, stage='develop')
    data = manifest(feature)
    head=subprocess.check_output(['git','branch','--show-current'],cwd=root,text=True).strip()
    feedback_guard(root, 'TASK-'+head[:3])
    tasks = TASK.findall((feature / "tasks.md").read_text())
    if not tasks or len({ident for _, ident, _ in tasks}) != len(tasks):
        raise RuntimeError("Implementation checklist is absent or has duplicate IDs")
    task_stages = data.get("task_stages", {})
    if not set(task_stages).issubset({ident for _, ident, _ in tasks}):
        raise RuntimeError("Deferred task mapping references unknown tasks")
    for mark, ident, text in tasks:
        tag = re.findall(r"\[gate:(qa|review)\]", text)
        if task_stages.get(ident) != (tag[0] if len(tag) == 1 else None):
            raise RuntimeError(f"Deferred task stage mismatch: {ident}")
        if ident in task_stages:
            title = re.sub(r"^(?:\s*\[[^\]]+\])*\s*", "", text)
            role = "Independent QA" if task_stages[ident] == "qa" else "Final review"
            if not title.startswith(role):
                raise RuntimeError(f"Only explicit independent verification tasks may be deferred: {ident}")
        if mark == " " and ident not in task_stages:
            raise RuntimeError(f"Incomplete implementation task: {ident}")
    for checklist in (feature / 'checklists').glob('*.md'):
        if re.search(r'^\s*- \[ \]', checklist.read_text(), re.M):
            raise RuntimeError('Current requirements checklist has unchecked items')
    source = source_fingerprint(root)
    inputs = input_fingerprint(feature)
    for check in data["checks"]:
        current_receipt(root, feature, check, source, inputs)
    return {"checks": len(data["checks"]), "requirements": len(data["coverage"]), "ready": True}


def feedback_guard(root, task_id):
    path=root/'backlog/feedback'/f'{task_id}.md'
    if not path.exists(): return
    for entry in re.split(r'(?m)^## Feedback \d+\s*$',path.read_text())[1:]:
        match=re.search(r'(?m)^- Impact: (.+)$',entry)
        if not match or not set(match[1].split(', ')).issubset({'product','architecture','verification','implementation','qa','review'}):
            raise RuntimeError('Human feedback impact is pending or unclassified; classify explicitly before continuing')
