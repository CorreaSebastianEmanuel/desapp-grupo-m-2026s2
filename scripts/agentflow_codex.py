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
from datetime import datetime, timezone
from glob import glob
from pathlib import Path

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
    base = {"schema_version": 1, "task": task, "stage": stage, "attempt": attempt,
            "assignment_id": assignment_id, "configured": selection.get('configured') if selection else None,
            "resolved": {key: selection[key] for key in ('model','effort')} if selection else None,
            "selection_sources": selection.get('sources') if selection else None,
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
    # outbound loopback traffic, which the default workspace-write sandbox
    # denies. Grant network access without widening filesystem permissions,
    # unless the locked stage selection already chose an explicit sandbox.
    if args and args[0] == "exec" and not any(
        arg == "--sandbox" or arg.startswith(("-s", "--sandbox=")) for arg in args
    ):
        args = [args[0], "-c", "sandbox_workspace_write.network_access=true", *args[1:]]
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
