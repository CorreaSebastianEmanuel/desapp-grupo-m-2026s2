#!/usr/bin/env python3
"""Forward Spec Kit's Codex invocation and record private structured usage."""
from __future__ import annotations

import hashlib
import json
import os
import signal
import subprocess
import sys
import time
import uuid
import tomllib
from datetime import datetime, timezone
from glob import glob
from pathlib import Path


SANDBOX_MODES = frozenset(("read-only", "workspace-write", "danger-full-access"))


def _sandbox_mode(value: object) -> str:
    if not isinstance(value, str) or value not in SANDBOX_MODES:
        raise RuntimeError("Unable to resolve sandbox policy")
    return value


def _config_policy_values(args: list[str], key: str) -> tuple[list[str], list[str]]:
    explicit = []
    configured = []
    index = 0
    while index < len(args):
        arg = args[index]
        if key == "sandbox_mode" and arg in ("--sandbox", "-s"):
            if index + 1 >= len(args):
                raise RuntimeError("Unable to resolve sandbox policy")
            explicit.append(args[index + 1])
            index += 2
            continue
        if key == "sandbox_mode" and arg.startswith("--sandbox="):
            explicit.append(arg.split("=", 1)[1])
            index += 1
            continue
        if key == "sandbox_mode" and arg.startswith("-s") and arg != "-s":
            explicit.append(arg[2:])
            index += 1
            continue
        if key == "sandbox_mode" and (arg in ("-p", "--profile") or arg.startswith("--profile=")):
            # A selected profile may introduce another sandbox policy. The
            # frozen Agentflow assignment does not own profile resolution.
            raise RuntimeError("Unable to resolve sandbox policy")
        if key == "sandbox_mode" and arg in ("--full-auto", "--yolo", "--dangerously-bypass-approvals-and-sandbox"):
            raise RuntimeError("Unable to resolve sandbox policy")
        config_value = None
        if arg in ("-c", "--config"):
            if index + 1 >= len(args):
                raise RuntimeError("Unable to resolve sandbox policy")
            config_value = args[index + 1]
            index += 2
        elif arg.startswith("--config="):
            config_value = arg.split("=", 1)[1]
            index += 1
        elif arg.startswith("-c") and arg != "-c":
            config_value = arg[2:]
            index += 1
        else:
            index += 1
        if config_value is not None and config_value.lstrip().startswith(key):
            try:
                parsed = tomllib.loads(config_value)
            except (tomllib.TOMLDecodeError, ValueError):
                raise RuntimeError("Unable to resolve sandbox policy") from None
            if set(parsed) != {key}:
                raise RuntimeError("Unable to resolve sandbox policy")
            configured.append(_sandbox_mode(parsed[key]) if key == "sandbox_mode" else parsed[key])
    if len(explicit) > 1 or len(configured) > 1:
        raise RuntimeError("Unable to resolve sandbox policy")
    return explicit, configured


def resolve_approval_policy(args: list[str], *, env=None, root: Path | None = None,
                            config_path: Path | None = None) -> str | None:
    environment = os.environ if env is None else env
    explicit, invocation = _config_policy_values(args, "approval_policy")
    if len(invocation) > 1:
        raise RuntimeError("Unable to resolve approval policy")
    if explicit:
        raise RuntimeError("Unable to resolve approval policy")
    if config_path is None:
        config_home = environment.get("CODEX_HOME")
        config_path = (Path(config_home).expanduser() if config_home else Path.home() / ".codex") / "config.toml"
    if config_path.exists():
        try:
            policy = tomllib.loads(config_path.read_text(encoding="utf-8")).get("approval_policy")
        except (OSError, UnicodeError, tomllib.TOMLDecodeError, ValueError):
            raise RuntimeError("Unable to resolve approval policy") from None
        if policy is not None:
            if policy not in ("never", "on-request", "untrusted"):
                raise RuntimeError("Unable to resolve approval policy")
            if invocation and invocation[0] != policy:
                raise RuntimeError("Unable to resolve approval policy")
            return policy
    if invocation:
        if invocation[0] not in ("never", "on-request", "untrusted"):
            raise RuntimeError("Unable to resolve approval policy")
        return invocation[0]
    return None


def _root_sandbox_mode(config_path: Path, root: Path) -> str | None:
    if not config_path.exists():
        return None
    try:
        data = tomllib.loads(config_path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, tomllib.TOMLDecodeError, ValueError):
        raise RuntimeError("Unable to resolve sandbox policy") from None
    projects = data.get("projects", {})
    if not isinstance(projects, dict):
        raise RuntimeError("Unable to resolve sandbox policy")
    for project_path, policy in projects.items():
        if not isinstance(project_path, str) or not isinstance(policy, dict):
            raise RuntimeError("Unable to resolve sandbox policy")
        if "sandbox_mode" not in policy:
            continue
        try:
            configured_root = Path(project_path).expanduser().resolve()
            if root == configured_root or root.is_relative_to(configured_root):
                raise RuntimeError("Unable to resolve sandbox policy")
        except (OSError, RuntimeError):
            raise RuntimeError("Unable to resolve sandbox policy") from None
    if "default_profile" in data:
        raise RuntimeError("Unable to resolve sandbox policy")
    mode = data.get("sandbox_mode")
    return _sandbox_mode(mode) if mode is not None else None


def resolve_sandbox_mode(args: list[str], *, env=None, root: Path | None = None,
                         config_path: Path | None = None) -> str:
    """Resolve the effective closed policy without trusting inherited labels."""
    environment = os.environ if env is None else env
    root = (root or Path.cwd()).resolve()
    explicit, invocation = _config_policy_values(args, "sandbox_mode")
    local_config = root / ".codex" / "config.toml"
    if local_config.exists():
        try:
            local = tomllib.loads(local_config.read_text(encoding="utf-8"))
        except (OSError, UnicodeError, tomllib.TOMLDecodeError, ValueError):
            raise RuntimeError("Unable to resolve sandbox policy") from None
        if "sandbox_mode" in local or "profiles" in local or "default_profile" in local:
            raise RuntimeError("Unable to resolve sandbox policy")
    if config_path is None:
        config_home = environment.get("CODEX_HOME")
        config_path = (Path(config_home).expanduser() if config_home else Path.home() / ".codex") / "config.toml"
    configured = _root_sandbox_mode(config_path, root)
    if explicit:
        if invocation and invocation[0] != _sandbox_mode(explicit[0]):
            raise RuntimeError("Unable to resolve sandbox policy")
        return _sandbox_mode(explicit[0])
    if invocation:
        return invocation[0]
    return configured or "workspace-write"


def sandbox_launch_args(args: list[str], mode: str, approval_policy: str | None = None) -> list[str]:
    """Remove policy declarations and forward one normalized explicit mode."""
    mode = _sandbox_mode(mode)
    clean = []
    index = 0
    while index < len(args):
        arg = args[index]
        if arg in ("--sandbox", "-s"):
            index += 2
        elif arg.startswith("--sandbox=") or (arg.startswith("-s") and arg != "-s"):
            index += 1
        elif arg == "--approve-for-me" and mode == "danger-full-access":
            if approval_policy != "never":
                raise RuntimeError("Unable to resolve approval policy")
            index += 1
        elif arg in ("-c", "--config") and index + 1 < len(args):
            value = args[index + 1]
            if value.lstrip().startswith("sandbox_mode"):
                index += 2
            else:
                clean.extend((arg, value))
                index += 2
        elif arg.startswith("--config=") and arg.split("=", 1)[1].lstrip().startswith("sandbox_mode"):
            index += 1
        elif arg.startswith("-c") and arg != "-c" and arg[2:].lstrip().startswith("sandbox_mode"):
            index += 1
        else:
            clean.append(arg)
            index += 1
    return [*clean, "--sandbox", mode]

try:
    from .agentflow_runtime import DIMENSIONS, MARKER, numeric_usage, read_metrics, stage_from_args, usage_delta
except ImportError:
    from agentflow_runtime import DIMENSIONS, MARKER, numeric_usage, read_metrics, stage_from_args, usage_delta


def node24_path() -> str | None:
    """Local integration preflight requires Node v24; CI pins it explicitly,
    while sandboxed agents inherit a PATH that lacks the nvm install."""
    from shutil import which

    candidates = sorted(
        glob(str(Path.home() / ".nvm/versions/node/v24*/bin")), reverse=True
    )
    hit = next((entry for entry in candidates if Path(entry, "node").is_file()), None)
    if not hit:
        return None
    current = which("node")
    if current:
        try:
            probe = subprocess.run([current, "--version"], capture_output=True, text=True, timeout=5)
            if probe.stdout.strip().startswith("v24"):
                return None
        except OSError:
            pass
    return hit


def main(args: list[str]) -> int:
    extra_path = node24_path()
    if extra_path:
        os.environ["PATH"] = extra_path + os.pathsep + os.environ.get("PATH", "")
    # Mix's TCP filesystem lock fails with :eperm inside sandboxed agents.
    os.environ.setdefault("MIX_OS_CONCURRENCY_LOCK", "0")
    real = os.environ["AGENTFLOW_CODEX_REAL"]
    task = os.environ["AGENTFLOW_TASK_ID"]
    path = Path(os.environ["AGENTFLOW_METRICS_FILE"])
    stage = stage_from_args(args)
    attempt = uuid.uuid4().hex
    started = time.monotonic()
    session_hash = None
    previous = None
    reused = False
    resume = "resume" in args[:3]
    try:
        from .agentflow_models import validate, launch_args, fresh_session_args
        from .agentflow_verification import load_json
    except ImportError:
        from agentflow_models import validate, launch_args, fresh_session_args
        from agentflow_verification import load_json
    selection = None
    assignment_id = None
    assignment_path = os.environ.get('AGENTFLOW_ASSIGNMENT')
    if assignment_path:
        selected_path=Path(assignment_path).resolve()
        if not selected_path.is_relative_to(Path.cwd().resolve()/'.agentflow/runs/assignments'):
            raise RuntimeError('Assignment path escapes local namespace')
        if hashlib.sha256(selected_path.read_bytes()).hexdigest() != os.environ.get('AGENTFLOW_ASSIGNMENT_SHA256'):
            raise RuntimeError('Frozen assignment integrity mismatch')
        generation = validate(load_json(selected_path), task)
        if stage not in generation['stages']:
            raise RuntimeError(f'Unknown or ambiguous model stage: {stage}')
        selection = generation['stages'][stage]
        if os.environ.get('AGENTFLOW_NEW_SESSION')=='1':
            args=fresh_session_args(args)
        args = launch_args(args, selection, stage)
        assignment_id = generation['assignment_id']
    sandbox_mode = resolve_sandbox_mode(args)
    approval_policy = resolve_approval_policy(args)
    args = sandbox_launch_args(args, sandbox_mode, approval_policy)
    base = {"schema_version": 1, "task": task, "stage": stage, "attempt": attempt,
            "assignment_id": assignment_id, "configured": selection.get('configured') if selection else None,
            "resolved": {key: selection[key] for key in ('model','effort')} if selection else None,
            "selection_sources": selection.get('sources') if selection else None,
            "sandbox_mode": sandbox_mode,
            "observed_model": None, "observed_effort": None, "observed_source": None,
            "unknown_reason": 'execution identity not reported'}
    sequence = 0
    provider_failed = False

    def emit(kind, **fields):
        nonlocal sequence
        sequence += 1
        value = {**base, "event_id": attempt+':'+str(sequence), "event": kind, "timestamp": datetime.now(timezone.utc).isoformat(),
                 "elapsed_seconds": round(time.monotonic() - started, 3), **fields}
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as output:
            output.write(json.dumps(value) + "\n")
        print(MARKER + json.dumps(value), flush=True)

    if "--json" not in args:
        args = [*args, "--json"]
    # Local checks (database/Redis preflight, profiles and helpers) require
    # loopback access under workspace-write. Keep this network setting separate
    # from sandbox selection and preserve other explicitly selected modes.
    if args and args[0] == "exec" and sandbox_mode == "workspace-write":
        args = [args[0], "-c", "sandbox_workspace_write.network_access=true", *args[1:]]
    try:
        from .agentflow_preflight import build_context, evaluate
    except ImportError:
        from agentflow_preflight import build_context, evaluate
    final_context = build_context(stage, "codex", [real, *args], cwd=Path.cwd(), env=os.environ)
    preflight = evaluate(final_context)
    if not preflight["ready"]:
        emit("agent_failed", cause="launch prerequisite failed; inspect safe preflight result")
        print(json.dumps(preflight, sort_keys=True))
        emit("agent_ended", exit_code=2)
        return 2
    emit("agent_started")
    # Gates belong to Spec Kit. An agent must not consume piped gate answers.
    try:
        child_env = dict(os.environ)
        child_env['AGENTFLOW_CODEX_SANDBOX_MODE'] = sandbox_mode
        child = subprocess.Popen([real, *args], env=child_env, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, text=True, encoding="utf-8", errors="replace")
    except OSError:
        emit('agent_failed', cause='selected executable unavailable; no fallback')
        emit('agent_ended', exit_code=127)
        return 127
    assert child.stdout is not None
    try:
        for line in child.stdout:
            print(line, end="", flush=True)
            try:
                event = json.loads(line)
            except ValueError:
                continue
            if not isinstance(event, dict):
                continue
            if event.get('type')=='turn.completed' and isinstance(event.get('model'), str):
                base['observed_model'] = event['model']
                base['observed_source'] = 'provider.turn.completed.model'
            if event.get('type')=='turn.completed' and isinstance(event.get('reasoning_effort'),str):
                base['observed_effort']=event['reasoning_effort']
            if event.get("type") == "thread.started" and isinstance(event.get("thread_id"), str):
                session_hash = hashlib.sha256(event["thread_id"].encode()).hexdigest()
                baselines = [v for v in read_metrics(path)
                             if v.get("event") == "usage" and v.get("session_hash") == session_hash]
                if baselines:
                    latest = max(baselines, key=lambda value: value.get("timestamp", ""))
                    previous = numeric_usage(latest.get("reported_usage"))
                    reused = True
            elif event.get("type") == "turn.completed":
                current = numeric_usage(event.get("usage"))
                counter_delta = usage_delta(current, previous, bool(session_hash) and not resume)
                # Fresh exec's single terminal report has a known local baseline.
                # Reused/resumed or multiple-turn counters may be cumulative or
                # per-turn; retain snapshots without inventing incremental usage.
                known = bool(session_hash) and not resume and not reused and previous is None
                delta = current if known else {key: None for key in DIMENSIONS}
                emit("usage", session_hash=session_hash, reported_usage=current,
                     observed_counter_delta=counter_delta, incremental_usage=delta,
                     baseline_known=known)
                previous = current
            elif event.get("type") in ("turn.failed", "error"):
                provider_failed = True
                emit("agent_failed", cause="provider rejected selection; no fallback")
        code = child.wait()
    except KeyboardInterrupt:
        try:
            child.send_signal(signal.SIGINT)
        except ProcessLookupError:
            pass
        try:
            child.wait(timeout=10)
        except subprocess.TimeoutExpired:
            child.terminate()
            try:
                child.wait(timeout=10)
            except subprocess.TimeoutExpired:
                child.kill()
                child.wait()
        code = 130
    code = code or (1 if provider_failed else 0)
    if stage == "qa":
        try:
            from .agentflow_runtime import write_partial_qa_report
            from .workflow_artifact_probe import active_feature
        except ImportError:
            from agentflow_runtime import write_partial_qa_report
            from workflow_artifact_probe import active_feature
        if code or not (active_feature(Path.cwd()) / "qa-report.md").is_file():
            try:
                write_partial_qa_report(Path.cwd().resolve(), stage, "provider-ended")
                if code == 0:
                    code = 1
            except (OSError, RuntimeError):
                code = code or 1
    if code == 0 and stage in ('qa','review'):
        try:
            try:
                from .workflow_artifact_probe import active_feature
                from .agentflow_verification import atomic_json,source_fingerprint,input_fingerprint,digest
            except ImportError:
                from workflow_artifact_probe import active_feature
                from agentflow_verification import atomic_json,source_fingerprint,input_fingerprint,digest
            root=Path.cwd().resolve()
            feature=active_feature(root)
            report=feature/('qa-report.md' if stage=='qa' else 'review-report.md')
            atomic_json(root/'.agentflow/runs/attestations'/task/(stage+'.json'),
                        {'stage':stage,'attempt':attempt,'session_hash':session_hash,
                         'source':source_fingerprint(root),'inputs':input_fingerprint(feature),
                         'report_sha256':digest(report.read_bytes()),'exit_code':code})
        except (RuntimeError,OSError):
            emit('agent_failed',cause='independent report provenance unavailable')
            code=1
    emit("agent_ended", exit_code=code)
    return code


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except (OSError, KeyError, RuntimeError) as error:
        print(MARKER + json.dumps({"event": "agent_ended", "stage": stage_from_args(sys.argv[1:]), "exit_code": 127, "cause": str(error)}), flush=True)
        raise SystemExit(127)
