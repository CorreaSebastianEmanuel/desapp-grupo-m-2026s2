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
    from . import agentflow_providers as providers
except ImportError:
    from agentflow_feature import metadata
    from agentflow_verification import load_json, atomic_json
    import agentflow_providers as providers

STAGES = ('product', 'product_challenge', 'architecture', 'develop', 'qa', 'review')
MODELS = {'gpt-6-luna', 'gpt-6.1-sol'}
EFFORTS = {'low', 'medium', 'high'}


def pair(stage, model, effort, root=None, provider=None):
    """Validate one stage selection for a provider.

    Codex keeps the legacy global allowlist (same messages as before); other
    providers validate the model against the repository provider
    configuration and never fabricate reasoning-effort parameters a CLI does
    not carry, so non-Codex effort is informational and may stay unknown."""
    provider = providers.normalize(provider)
    if stage not in STAGES or not isinstance(model,str) or not model:
        raise RuntimeError(f'Unsupported selection for stage {stage}: model={model!r}, effort={effort!r}; select an approved pair explicitly')
    if provider == providers.DEFAULT_PROVIDER:
        if not isinstance(effort,str) or model not in MODELS or effort not in EFFORTS:
            raise RuntimeError(f'Unsupported selection for stage {stage}: model={model!r}, effort={effort!r}; select an approved pair explicitly')
        return
    if root is None:
        raise RuntimeError(f'Stage {stage}: provider {provider} selection requires the repository provider configuration')
    config = providers.provider_config(root, provider)
    if config is None:
        raise RuntimeError(f'Provider {provider} has no repository configuration (.agentflow/providers.json); keep codex or add it explicitly')
    if model not in config['models']:
        raise RuntimeError(f'Unsupported selection for stage {stage}: model={model!r} is not configured for provider {provider}; update .agentflow/providers.json explicitly')


def stage_flags(values):
    result = {}
    for value in values or []:
        stage, separator, setting = value.partition('=')
        if not separator or stage not in STAGES or not setting or stage in result:
            raise RuntimeError('Unknown or duplicate stage selection; use STAGE=VALUE once per field')
        result[stage] = setting
    return result


def stage_model(root, provider, stage, model, sources=None):
    """Map a repository-configured stage model onto a provider-capable model.

    Codex passes through unchanged. Other providers may keep the same model
    name when the provider configuration lists it, otherwise an explicit
    stage_models mapping in .agentflow/providers.json decides. Explicit
    operator or task overrides must name a provider-available model directly:
    silently swapping them would hide a decision Agentflow was told to follow."""
    if provider == providers.DEFAULT_PROVIDER:
        return model
    config = providers.provider_config(root, provider)
    if model in config['models']:
        return model
    if sources is not None and not str(sources.get('model', '')).startswith('repository.'):
        raise RuntimeError(f'Stage {stage}: model {model!r} is not available for provider {provider}; '
                           f'choose one of {", ".join(sorted(config["models"]))} or update .agentflow/providers.json explicitly')
    mapped = config['stage_models'].get(stage) or config['stage_models'].get('*')
    if not mapped:
        raise RuntimeError(f'Stage {stage}: model {model!r} is not available for provider {provider}; '
                           f'add an explicit stage_models entry to .agentflow/providers.json')
    if mapped not in config['models']:
        raise RuntimeError(f'.agentflow/providers.json stage_models for {stage!r} ({mapped!r}) is outside '
                           f"provider {provider}'s models list")
    if sources is not None:
        sources['model'] = f'{sources.get("model", "repository")}|provider.{provider}'
    return mapped


def resolve(root, task, args, provider=None):
    path = root / '.agentflow/models.json'
    data = load_json(path)
    if not isinstance(data, dict) or set(data) != {'schema_version', 'stages'} or type(data['schema_version']) is not int or data['schema_version'] != 1 or not isinstance(data['stages'], dict) or set(data['stages']) != set(STAGES):
        raise RuntimeError('Repository model configuration requires schema 1 and exactly six stages')
    provider = providers.normalize(provider) if provider is not None else providers.from_args(args)
    for stage, value in data['stages'].items():
        if not isinstance(value, dict) or set(value) != {'model', 'effort'}:
            raise RuntimeError(f'Invalid model configuration for stage {stage}')
        pair(stage, value['model'], value['effort'], root=root, provider='codex')
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
        row['model'] = stage_model(root, provider, stage, row['model'], row['sources'])
        pair(stage, row['model'], row['effort'], root=root, provider=provider)
        result[stage] = row
    return {'schema_version': 1, 'provider': provider, 'task_id': fields['id'], 'stages': result,
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
    validate(value, task_id, root=root)
    return value


def validate(value, task_id, root=None):
    provider = providers.normalize(value.get('provider'))
    if value.get('schema_version') != 1 or value.get('task_id') != task_id or set(value.get('stages', {})) != set(STAGES):
        raise RuntimeError('Malformed or cross-task assignment generation')
    for stage, row in value['stages'].items():
        pair(stage, row.get('model'), row.get('effort'), root=root, provider=provider)
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
            validate(old, fields['id'], root=root)
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
            pair(stage, selected['stages'][stage]['model'], selected['stages'][stage]['effort'],
                 root=root, provider=selected.get('provider'))
    return selected, True


def launch_args(args, selection, stage, provider=None, root=None):
    """Validate a child invocation against the frozen stage selection and
    append exactly the provider-owned flags that carry the selection."""
    provider = providers.normalize(provider) if provider is not None else providers.normalize(selection.get('provider'))
    pair(stage, selection['model'], selection.get('effort'), provider=provider, root=root)
    if provider != providers.DEFAULT_PROVIDER:
        return launch_embedded(args, selection, stage, provider, root)
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
    return [*clean, *providers.model_flags(provider, selection['model'], selection.get('effort'))]


def launch_embedded(args, selection, stage, provider, root=None):
    """Provider-flag shaping for OpenCode: the single -m model flag is
    inserted before positional message tokens, session continuation is
    refused, and reasoning-effort flags are never invented."""
    if root is None:
        raise RuntimeError(f'{stage}: provider {provider} launch requires the repository provider configuration')
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
        if arg in ('--continue','-c','--session','-s') or arg.startswith(('--session=','-s=')):
            raise RuntimeError(f'{stage}: session continuation conflicts with a frozen provider selection')
        if arg.startswith('-m') and arg != '-m':
            raise RuntimeError(f'{stage}: unmanaged model flag conflicts with assignment')
        clean.append(arg)
        index += 1
    flags = providers.model_flags(provider, selection['model'])
    if clean and clean[0] == 'run':
        # OpenCode parses flags before positional message tokens reliably;
        # trailing flags risk being consumed as message text.
        return [*clean[:1], *flags, *clean[1:]]
    return [*clean, *flags]


def fresh_session_args(args, provider=None):
    """Adoption must not continue a child session selected under an old generation."""
    if providers.normalize(provider) != providers.DEFAULT_PROVIDER and 'resume' not in args[:4]:
        return args
    if providers.normalize(provider) != providers.DEFAULT_PROVIDER:
        raise RuntimeError('OpenCode dispatch does not use Codex resume arguments; start a new explicit attempt')
    if 'resume' not in args[:4]: return args
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
