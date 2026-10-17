"""Execution-provider registry: the seam between Agentflow and agent CLIs.

Agentflow dispatches every agent stage through Spec Kit's generic integration
mechanism (integration key + operator env overrides), so provider support
stays declarative here instead of being spread across the workflow. Provider
availability is verified against the installed CLI; model availability lives
in external repository configuration (.agentflow/providers.json read by
agentflow_models), never hard-coded in this registry.
"""
from __future__ import annotations
import json
import os
import shutil
import sys
from pathlib import Path

try:
    from .agentflow_verification import load_json
except ImportError:
    from agentflow_verification import load_json

PROVIDERS = ("codex", "opencode")
DEFAULT_PROVIDER = "codex"
AUTO = "auto"
# Non-interactive CLI identity per provider. OpenCode exposes `opencode run`;
# Codex exposes `codex exec`. Both are provider-owned interfaces; Agentflow
# neither replaces nor wraps the provider's own non-interactive mode.
CLI = {"codex": "codex", "opencode": "opencode"}
REAL_ENV = {"codex": "AGENTFLOW_CODEX_REAL", "opencode": "AGENTFLOW_OPENCODE_REAL"}
EXECUTABLE_ENV = {"codex": "SPECKIT_INTEGRATION_CODEX_EXECUTABLE",
                  "opencode": "SPECKIT_INTEGRATION_OPENCODE_EXECUTABLE"}
EXTRA_ARGS_ENV = {"codex": "SPECKIT_INTEGRATION_CODEX_EXTRA_ARGS",
                  "opencode": "SPECKIT_INTEGRATION_OPENCODE_EXTRA_ARGS"}
# Mirrors each provider's own no-interaction approval flag: Codex accepts
# workspace edits under --approve-for-me; OpenCode approves non-denied
# permissions under --auto.
EXTRA_ARGS = {"codex": "--approve-for-me", "opencode": "--auto"}
SHIM = {"codex": "agentflow_codex", "opencode": "agentflow_opencode"}


def normalize(value):
    value = (value or DEFAULT_PROVIDER).__str__().strip().lower()
    if value == AUTO:
        return DEFAULT_PROVIDER
    if value not in PROVIDERS:
        raise RuntimeError(f"Unknown execution provider {value!r}; select one of "
                           f"{AUTO}|{'|'.join(PROVIDERS)}")
    return value


def from_args(args):
    """Canonical provider for a command whose result may carry --provider or
    the legacy --agent option; both must agree when both are present."""
    provider = getattr(args, "provider", None)
    legacy = getattr(args, "agent", None)
    if provider is not None and legacy is not None and normalize(provider) != normalize(legacy):
        raise RuntimeError("--provider and --agent select different execution providers")
    chosen = provider if provider is not None else legacy
    return normalize(chosen)


def require(provider):
    """Refuse to dispatch a provider whose CLI is missing or unauthenticated."""
    if not shutil.which(CLI[provider]):
        raise SystemExit(f"Install and authenticate the {CLI[provider]} CLI")
    return provider


def shim_executable(root, provider):
    name = SHIM[provider]
    suffix = ".cmd" if os.name == "nt" and name == "agentflow_codex" else ".py"
    return str(Path(root) / "scripts" / (name + suffix))


def env_overrides(child_env, provider, root):
    """Interpose Agentflow's forwarding shim without clobbering an operator
    override. Extra-args defaults use setdefault so an operator-provided value
    (for example CI approval flags) keeps precedence."""
    provider = normalize(provider)
    executable_env = EXECUTABLE_ENV[provider]
    if child_env.get(executable_env):
        return child_env
    child_env[executable_env] = shim_executable(root, provider)
    child_env[REAL_ENV[provider]] = shutil.which(CLI[provider]) or CLI[provider]
    child_env.setdefault(EXTRA_ARGS_ENV[provider], EXTRA_ARGS[provider])
    return child_env


def config_path(root):
    return Path(root) / ".agentflow" / "providers.json"


def provider_config(root, provider):
    """Optional repository configuration for one provider. Absent file means
    legacy single-provider Codex behavior; present file is validated strictly.

    Returns dict with keys:
      models        allowed provider models (nonempty list of unique strings)
      efforts       allowed reasoning efforts or False when unsupported
      stage_models  optional stage|'*' → model mapping for provider ports
      verify_model  optional model used by Agentflow's own direct commands
    """
    path = config_path(root)
    if not path.exists():
        return None
    try:
        data = load_json(path)
    except (OSError, ValueError) as error:
        raise RuntimeError(f".agentflow/providers.json is unreadable: {error}") from error
    if not isinstance(data, dict) or set(data) != {"schema_version", "providers"} \
        or type(data["schema_version"]) is not int or data["schema_version"] != 1 \
        or not isinstance(data["providers"], dict):
        raise RuntimeError(".agentflow/providers.json requires schema_version 1 and a providers mapping")
    if provider not in data["providers"]:
        raise RuntimeError(f".agentflow/providers.json does not define provider {provider!r}; "
                           f"defined: {', '.join(sorted(data['providers']))}")
    value = data["providers"][provider]
    if not isinstance(value, dict) or set(value) - {"models", "efforts", "stage_models", "verify_model"}:
        raise RuntimeError(f"Invalid provider configuration for {provider}; allowed fields: "
                           "models, efforts, stage_models, verify_model")
    models = value.get("models")
    if not isinstance(models, list) or not models or any(not isinstance(model, str) or not model for model in models) \
        or len(set(models)) != len(models):
        raise RuntimeError(f"Provider {provider} requires a nonempty unique 'models' list")
    efforts = value.get("efforts", [])
    if efforts is False:
        efforts = None
    elif isinstance(efforts, list):
        if not all(isinstance(effort, str) and effort for effort in efforts) or len(set(efforts)) != len(efforts):
            raise RuntimeError(f"Provider {provider} requires unique nonempty effort values")
    else:
        raise RuntimeError(f"Provider {provider} 'efforts' must be a list or false")
    stage_models = value.get("stage_models", {})
    if not isinstance(stage_models, dict):
        raise RuntimeError(f"Provider {provider} 'stage_models' must be a mapping")
    # stage_models keys stay provider-agnostic here; agentflow_models validates
    # each mapping explicitly against ITS stage list, so unknown stages fail at
    # resolution with a precise message instead of a silent catalog drift.
    for stage, model in stage_models.items():
        if not isinstance(stage, str) or not stage or not isinstance(model, str) or not model:
            raise RuntimeError(f"Provider {provider} stage_models entries must map a stage name to a model")
        if model not in models:
            raise RuntimeError(f"Provider {provider} stage_models has {stage!r} → {model!r} outside its models list")
    verify_model = value.get("verify_model")
    if verify_model is not None and (not isinstance(verify_model, str) or verify_model not in models):
        raise RuntimeError(f"Provider {provider} verify_model must be one of its declared models")
    return {"models": models, "efforts": efforts,
            "stage_models": stage_models, "verify_model": verify_model}


def model_flags(provider, model, effort=None):
    """Append a frozen per-stage selection to an already validated invocation.

    Codex keeps model/effort as separate selections; OpenCode encodes the
    model in its single -m flag and does not accept a reasoning-effort
    parameter, so Agentflow never fabricates one for it.
    """
    if provider == "codex":
        return ["--model", model, "-c", "model_reasoning_effort=" + json.dumps(effort)]
    if provider == "opencode":
        return ["-m", model]
    raise RuntimeError(f"Provider {provider} does not expose non-interactive model flags")


def command(provider, root, prompt, model=None):
    """Agentflow's own direct non-interactive invocation (auxiliary commands
    such as verify), selected through the same provider seam."""
    provider = normalize(provider)
    if provider == "codex":
        return [CLI[provider], "exec", "-C", str(root), EXTRA_ARGS[provider], "--ephemeral", prompt]
    if provider == "opencode":
        argv = [CLI[provider], "run", EXTRA_ARGS[provider]]
        if model:
            argv.extend(["-m", model])
        argv.append(prompt)
        return argv
    raise RuntimeError(f"Provider {provider} does not support direct commands")


def report(root):
    """Human-readable provider identification for documentation and gates."""
    return {provider: {"cli": CLI[provider],
                       "cli_installed": bool(shutil.which(CLI[provider]))}
            for provider in PROVIDERS}
