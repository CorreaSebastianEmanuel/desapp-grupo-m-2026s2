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
from pathlib import Path

try:
    from .agentflow_runtime import DIMENSIONS, MARKER, numeric_usage, read_metrics, stage_from_args, usage_delta
except ImportError:
    from agentflow_runtime import DIMENSIONS, MARKER, numeric_usage, read_metrics, stage_from_args, usage_delta


def main(args: list[str]) -> int:
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
    base = {"task": task, "stage": stage, "attempt": attempt}

    def emit(kind, **fields):
        value = {**base, "event": kind, "timestamp": datetime.now(timezone.utc).isoformat(),
                 "elapsed_seconds": round(time.monotonic() - started, 3), **fields}
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as output:
            output.write(json.dumps(value) + "\n")
        print(MARKER + json.dumps(value), flush=True)

    if "--json" not in args:
        args = [*args, "--json"]
    emit("agent_started")
    # Gates belong to Spec Kit. An agent must not consume piped gate answers.
    child = subprocess.Popen([real, *args], stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, text=True, encoding="utf-8", errors="replace")
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
            if event.get("type") == "thread.started" and isinstance(event.get("thread_id"), str):
                session_hash = hashlib.sha256(event["thread_id"].encode()).hexdigest()
                baselines = [v for p in path.parent.glob("TASK-*.metrics.jsonl") for v in read_metrics(p)
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
                emit("agent_failed")
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
    emit("agent_ended", exit_code=code)
    return code


if __name__ == "__main__":
    try:
        raise SystemExit(main(sys.argv[1:]))
    except (OSError, KeyError):
        print(MARKER + json.dumps({"event": "agent_ended", "stage": "unknown", "exit_code": 127}), flush=True)
        raise SystemExit(127)
