#!/usr/bin/env python3
"""Forward Spec Kit's OpenCode invocation and record private structured usage."""
from __future__ import annotations

import hashlib
import json
import os
import signal
import subprocess
import sys
import time
import uuid
from datetime import datetime, timezone
from pathlib import Path

try:
    from .agentflow_runtime import DIMENSIONS, MARKER, numeric_usage, read_metrics, stage_from_args, usage_delta
    from . import agentflow_providers as providers
except ImportError:
    from agentflow_runtime import DIMENSIONS, MARKER, numeric_usage, read_metrics, stage_from_args, usage_delta
    import agentflow_providers as providers

PROVIDER = "opencode"


def format_json_args(args: list[str]) -> list[str]:
    """OpenCode's structured event stream is the recordable output channel.

    Spec Kit only appends --format json for captured dispatches; streamed
    dispatches would otherwise leave the shim with human-readable output, so
    the shim requests the JSON format itself. The flag is inserted directly
    after the `run` subcommand, before positional message tokens where
    trailing flags would be consumed as message text."""
    values = list(args)
    position = 1 if values and values[0] == "run" else len(values)
    index = 0
    while index < len(values):
        if values[index] == "--format":
            if index + 1 < len(values) and values[index+1] != "json":
                values[index+1] = "json"
            return values
        if values[index].startswith("--format="):
            values[index] = "--format=json"
            return values
        index += 1
    values.insert(min(position, len(values)), "--format=json")
    return values


def main(args: list[str]) -> int:
    real = os.environ["AGENTFLOW_OPENCODE_REAL"]
    task = os.environ["AGENTFLOW_TASK_ID"]
    path = Path(os.environ["AGENTFLOW_METRICS_FILE"])
    stage = stage_from_args(args)
    attempt = uuid.uuid4().hex
    started = time.monotonic()
    session_hash = None
    previous = None
    reused = False
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
        generation_data = load_json(selected_path)
        if providers.normalize(generation_data.get('provider')) != PROVIDER:
            raise RuntimeError('Assignment generation was frozen for another provider; open a new run or switch generations deliberately')
        generation = validate(generation_data, task, root=Path.cwd())
        if stage not in generation['stages']:
            raise RuntimeError(f'Unknown or ambiguous model stage: {stage}')
        selection = generation['stages'][stage]
        if os.environ.get('AGENTFLOW_NEW_SESSION')=='1':
            args=fresh_session_args(args, provider=PROVIDER)
        args = launch_args(args, selection, stage, provider=PROVIDER, root=Path.cwd())
        assignment_id = generation['assignment_id']
    base = {"schema_version": 1, "task": task, "stage": stage, "attempt": attempt,
            "assignment_id": assignment_id, "configured": selection.get('configured') if selection else None,
            "resolved": {key: selection.get(key) for key in ('model','effort')} if selection else None,
            "selection_sources": selection.get('sources') if selection else None,
            "observed_model": None, "observed_effort": None, "observed_source": None,
            "unknown_reason": 'execution identity not reported'}
    sequence = 0

    def emit(kind, **fields):
        nonlocal sequence
        sequence += 1
        value = {**base, "event_id": attempt+':'+str(sequence), "event": kind, "timestamp": datetime.now(timezone.utc).isoformat(),
                 "elapsed_seconds": round(time.monotonic() - started, 3), **fields}
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as output:
            output.write(json.dumps(value) + "\n")
        print(MARKER + json.dumps(value), flush=True)

    args = format_json_args(args)
    emit("agent_started")
    # Gates belong to Spec Kit. An agent must not consume piped gate answers.
    try:
        child = subprocess.Popen([real, *args], stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, text=True, encoding="utf-8", errors="replace")
    except OSError:
        emit('agent_failed', cause='selected executable unavailable; no fallback')
        emit('agent_ended', exit_code=127)
        return 127
    assert child.stdout is not None
    provider_failed = False
    try:
        for line in child.stdout:
            print(line, end="", flush=True)
            try:
                event = json.loads(line)
            except ValueError:
                continue
            if not isinstance(event, dict):
                continue
            if event.get('type') == 'error':
                provider_failed = True
                emit("agent_failed", cause="provider rejected the request; no fallback")
            # OpenCode stamps every stream event with a session identifier.
            identifier = event.get("sessionID")
            if isinstance(identifier, str) and identifier.startswith("ses_") and not session_hash:
                session_hash = hashlib.sha256(identifier.encode()).hexdigest()
                base["observed_source"] = 'provider.stream.sessionID'
                baselines = [v for v in read_metrics(path)
                             if v.get("event") == "usage" and v.get("session_hash") == session_hash]
                if baselines:
                    latest = max(baselines, key=lambda value: value.get("timestamp", ""))
                    previous = numeric_usage(latest.get("reported_usage"))
                    reused = True
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
    # OpenCode's run stream carries no token accounting in this CLI version.
    # Record the attempt as intentionally unmeasured instead of inventing
    # numbers; metrics completeness stays false until usage is observable.
    emit("usage", session_hash=session_hash, reported_usage=None,
         observed_counter_delta=None, incremental_usage={key: None for key in DIMENSIONS},
         baseline_known=False, unknown_reason='provider stream reports no token usage')
    code = code or (1 if provider_failed else 0)
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
