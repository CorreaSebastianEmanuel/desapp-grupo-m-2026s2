"""Pure per-field selection and immutable, run-bound assignment generations."""
from __future__ import annotations
import hashlib
import json
import re
import uuid
from datetime import datetime, timezone
from pathlib import Path
try:
    from .agentflow_feature import metadata
    from .agentflow_verification import load_json, atomic_json
except ImportError:
    from agentflow_feature import metadata
    from agentflow_verification import load_json, atomic_json

STAGES = ('product', 'product_challenge', 'architecture', 'develop', 'qa', 'review')
MODELS = {'gpt-6-luna', 'gpt-6.1-sol'}
EFFORTS = {'low', 'medium', 'high'}


def pair(stage, model, effort):
    if stage not in STAGES or not isinstance(model,str) or not isinstance(effort,str) or model not in MODELS or effort not in EFFORTS:
        raise RuntimeError(f'Unsupported selection for stage {stage}: model={model!r}, effort={effort!r}; select an approved pair explicitly')


def stage_flags(values):
    result = {}
    for value in values or []:
        stage, separator, setting = value.partition('=')
        if not separator or stage not in STAGES or not setting or stage in result:
            raise RuntimeError('Unknown or duplicate stage selection; use STAGE=VALUE once per field')
        result[stage] = setting
    return result


def resolve(root, task, args):
    path = root / '.agentflow/models.json'
    data = load_json(path)
    if not isinstance(data, dict) or set(data) != {'schema_version', 'stages'} or type(data['schema_version']) is not int or data['schema_version'] != 1 or not isinstance(data['stages'], dict) or set(data['stages']) != set(STAGES):
        raise RuntimeError('Repository model configuration requires schema 1 and exactly six stages')
    for stage, value in data['stages'].items():
        if not isinstance(value, dict) or set(value) != {'model', 'effort'}:
            raise RuntimeError(f'Invalid model configuration for stage {stage}')
        pair(stage, value['model'], value['effort'])
    fields = metadata(task)
    overrides = {field: stage_flags(getattr(args, 'stage_'+field, [])) for field in ('model','effort')}
    result = {}
    for stage in STAGES:
        row = {'configured': dict(data['stages'][stage]), 'sources': {}}
        for field in ('model', 'effort'):
            candidates = [(overrides[field].get(stage), f'cli.stage_{field}'),
                          (getattr(args, field, None), 'cli.'+field),
                          (fields.get('develop_'+field) if stage=='develop' else None, 'task.develop_'+field),
                          (data['stages'][stage][field], 'repository.'+stage+'.'+field)]
            value, source = next((value, source) for value, source in candidates if value is not None)
            row[field] = value
            row['sources'][field] = source
        pair(stage, row['model'], row['effort'])
        result[stage] = row
    return {'schema_version': 1, 'task_id': fields['id'], 'stages': result,
            'repository_config_digest': hashlib.sha256(path.read_bytes()).hexdigest()}


def directory(root):
    path = root / '.agentflow/runs/assignments'
    if not path.resolve().is_relative_to(root.resolve()):
        raise RuntimeError('Unsafe assignment storage')
    return path


def save(root, selection, parent=None):
    ident = uuid.uuid4().hex
    path = directory(root) / (ident+'.json')
    value = {**selection, 'assignment_id': ident, 'generation': 1 if parent is None else parent['generation']+1,
             'parent': parent.get('assignment_id') if parent else None,
             'created_at': datetime.now(timezone.utc).isoformat()}
    atomic_json(path, value)
    return path


def bind(root, path, run):
    if not re.fullmatch(r'[a-zA-Z0-9_-]+', run):
        raise RuntimeError('Invalid assignment run binding')
    data = load_json(path)
    index = directory(root) / 'bindings.json'
    bindings = load_json(index) if index.exists() else {'runs': {}, 'assignments': {}}
    previous = bindings['assignments'].get(data['assignment_id'])
    content_hash=hashlib.sha256(path.read_bytes()).hexdigest()
    if previous is not None and (previous['run'] != run or previous['sha256'] != content_hash):
        raise RuntimeError('Assignment generation is already bound to another run')
    bindings['runs'][run] = data['assignment_id']
    bindings['assignments'][data['assignment_id']] = {'run':run,'sha256':content_hash}
    atomic_json(index, bindings)


def saved(root, task_id, run):
    bindings = load_json(directory(root) / 'bindings.json')
    ident = bindings.get('runs', {}).get(run)
    if not isinstance(ident, str) or not re.fullmatch('[a-f0-9]{32}', ident):
        raise RuntimeError('Saved assignment is unbound or unavailable; explicitly recover legacy settings')
    path=directory(root) / (ident+'.json')
    bound=bindings.get('assignments',{}).get(ident,{})
    if bound.get('run') != run or bound.get('sha256') != hashlib.sha256(path.read_bytes()).hexdigest():
        raise RuntimeError('Saved assignment integrity/binding mismatch')
    value = load_json(path)
    validate(value, task_id)
    return value


def validate(value, task_id):
    if value.get('schema_version') != 1 or value.get('task_id') != task_id or set(value.get('stages', {})) != set(STAGES):
        raise RuntimeError('Malformed or cross-task assignment generation')
    for stage, row in value['stages'].items():
        pair(stage, row.get('model'), row.get('effort'))
    return value


def has_flags(args):
    return any(getattr(args, field, None) for field in ('model','effort','stage_model','stage_effort'))


def resume_selection(root, task, run, args, state):
    fields = metadata(task)
    adopt = getattr(args, 'adopt_models', False)
    if has_flags(args) and not adopt:
        raise RuntimeError('Resume selection flags require --adopt-models; saved settings remain authoritative')
    index=directory(root)/'bindings.json'
    bindings=load_json(index) if index.exists() else {}
    old=saved(root,fields['id'],run) if run in bindings.get('runs',{}) else None
    if not adopt:
        if old is None:
            # Only structured saved fields may recover historical selection.
            settings = (state or {}).get('launch_settings', {})
            stages = {stage: {'model': settings.get(stage, {}).get('model'),
                              'effort': settings.get(stage, {}).get('effort'),
                              'sources': {'model': 'saved.legacy', 'effort': 'saved.legacy'}} for stage in STAGES}
            unknown = any(row['model'] is None or row['effort'] is None for row in stages.values())
            if unknown:
                raise RuntimeError('Legacy model/effort are unknown; supply explicit missing settings with --adopt-models. Prior observations remain unknown')
            old = {'schema_version': 1, 'task_id': fields['id'], 'stages': stages,
                   'repository_config_digest': None, 'generation': 0}
            validate(old, fields['id'])
        return old, False
    selected = resolve(root, task, args)
    if old is None:
        explicit = {field: stage_flags(getattr(args, 'stage_'+field, [])) for field in ('model','effort')}
        settings = (state or {}).get('launch_settings', {})
        for stage in STAGES:
            for field in ('model','effort'):
                if not getattr(args, field, None) and stage not in explicit[field]:
                    known = settings.get(stage, {}).get(field)
                    if known is None:
                        raise RuntimeError(f'Legacy {stage} {field} is unknown; supply an explicit value before adoption')
                    selected['stages'][stage][field] = known
                    selected['stages'][stage]['sources'][field] = 'saved.legacy'
            pair(stage, selected['stages'][stage]['model'], selected['stages'][stage]['effort'])
    return selected, True


def launch_args(args, selection, stage):
    pair(stage, selection['model'], selection['effort'])
    clean = []
    index = 0
    while index < len(args):
        arg = args[index]
        if arg in ('--profile','-p') or arg.startswith('--profile='):
            raise RuntimeError(f'{stage}: unmanaged profile conflicts with frozen assignment')
        if arg in ('--model','-m') or arg.startswith('--model='):
            value = args[index+1] if '=' not in arg else arg.split('=',1)[1]
            if value != selection['model']:
                raise RuntimeError(f'{stage}: unmanaged model conflicts with frozen selection')
            index += 2 if '=' not in arg else 1
            continue
        if arg in ('-c','--config') and index+1 < len(args) and args[index+1].startswith('model='):
            raise RuntimeError(f'{stage}: unmanaged model configuration conflicts with assignment')
        if arg.startswith('-m') and arg != '-m':
            raise RuntimeError(f'{stage}: unmanaged model flag conflicts with assignment')
        if arg in ('-c','--config') and index+1 < len(args) and args[index+1].startswith('model_reasoning_effort='):
            if args[index+1].split('=',1)[1].strip('"\'') != selection['effort']:
                raise RuntimeError(f'{stage}: unmanaged effort conflicts with frozen selection')
            index += 2
            continue
        if arg.startswith(('--config=model', '-cmodel')):
            raise RuntimeError(f'{stage}: unmanaged model configuration conflicts with assignment')
        clean.append(arg)
        index += 1
    return [*clean, '--model', selection['model'], '-c', 'model_reasoning_effort='+json.dumps(selection['effort'])]


def fresh_session_args(args):
    """Adoption must not continue a child session selected under an old generation."""
    if 'resume' not in args[:4]: return args
    values=list(args)
    index=values.index('resume')
    values.pop(index)
    if index<len(values) and values[index]=='--last':
        values.pop(index)
    elif index<len(values) and re.fullmatch(r'[a-fA-F0-9-]{8,}',values[index]):
        values.pop(index)
    else:
        raise RuntimeError('Cannot safely adopt unknown child resume format; start a new explicit attempt')
    return values
