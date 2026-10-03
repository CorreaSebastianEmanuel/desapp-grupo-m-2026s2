"""Structured, allowlisted agent metrics and bounded supervisor output."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

MARKER = "AGENTFLOW_EVENT "
STAGES = {"product", "product_challenge", "architecture", "tasks", "develop", "qa", "review", "unknown"}
DIMENSIONS = ("input_tokens", "cached_input_tokens", "output_tokens", "reasoning_output_tokens", "cache_write_input_tokens")


def stage_from_args(args: list[str]) -> str:
    matches = {match for arg in args for match in re.findall(r"(?m)(?:^|\s)Agentflow stage: ([a-z_]+)$", arg)}
    return next(iter(matches)) if len(matches) == 1 and matches.issubset(STAGES) else "unknown"


def numeric_usage(value) -> dict:
    value = value if isinstance(value, dict) else {}
    return {key: value[key] if type(value.get(key)) is int and value[key] >= 0 else None for key in DIMENSIONS}


def usage_delta(current: dict, previous: dict | None, baseline_known: bool) -> dict:
    result = {}
    regressed = bool(previous and any(current[k] is not None and previous.get(k) is not None and current[k] < previous[k] for k in DIMENSIONS))
    for key in DIMENSIONS:
        now = current[key]
        before = previous.get(key) if previous else 0 if baseline_known else None
        result[key] = now - before if now is not None and before is not None and not regressed else None
    return result


class Console:
    """Agent sections are bounded by wrapper events; runner gates pass through."""

    def __init__(self, full=False):
        self.full = full
        self.agent = False
        self.buffer = ""

    def line(self, line: str) -> str:
        if line.startswith(MARKER):
            try:
                value = json.loads(line[len(MARKER):])
            except ValueError:
                return ""
            if not isinstance(value, dict):
                return ""
            kind = value.get("event")
            stage = value.get("stage") if value.get("stage") in STAGES else "unknown"
            if kind == "agent_started":
                self.agent = True
                return f"[agent] {stage} started\n"
            if kind == "agent_ended":
                self.agent = False
                code = value.get("exit_code")
                code = code if type(code) is int else "unknown"
                return f"[agent] {stage} finished; exit={code}\n"
            if kind == "usage":
                usage = numeric_usage(value.get("incremental_usage"))
                return f"[usage] {stage}: input={usage['input_tokens']}, cached={usage['cached_input_tokens']}, output={usage['output_tokens']}\n"
            if kind in ("agent_failed", "metrics_failed"):
                return f"[agent] {stage}: {kind}; inspect local log\n"
            return ""
        if self.agent:
            return ""
        # Never print standalone Codex payloads even if a wrapper was interrupted.
        if line.lstrip().startswith("{"):
            try:
                event = json.loads(line)
            except ValueError:
                return ""
            if isinstance(event, dict) and event.get("type") in {"thread.started", "turn.started", "turn.completed", "turn.failed", "error", "item.started", "item.updated", "item.completed"}:
                return ""
        return line

    def feed(self, chunk: str, final=False) -> str:
        if self.full:
            return chunk
        self.buffer += chunk
        result = []
        while "\n" in self.buffer:
            line, self.buffer = self.buffer.split("\n", 1)
            result.append(self.line(line + "\n"))
        # Human input prompts have no newline. Surface fragments immediately;
        # hold partial JSON and wrapper markers until they can be classified.
        protected = self.buffer.lstrip().startswith("{") or MARKER.startswith(self.buffer) or self.buffer.startswith(MARKER)
        if self.buffer and not self.agent and not protected:
            result.append(self.buffer)
            self.buffer = ""
        elif final and self.buffer:
            result.append(self.line(self.buffer))
            self.buffer = ""
        return "".join(result)


def read_metrics(path: Path) -> list[dict]:
    if not path.exists():
        return []
    values = []
    for line in path.read_text(encoding="utf-8").splitlines():
        try:
            value = json.loads(line)
        except ValueError:
            continue
        if isinstance(value, dict):
            values.append(value)
    return values


def metrics_summary(path: Path) -> dict:
    rows = {}
    for value in read_metrics(path):
        if value.get("event") not in ("usage", "agent_started", "agent_ended"):
            continue
        stage = value.get("stage") if value.get("stage") in STAGES else "unknown"
        row = rows.setdefault(stage, {"stage": stage, "usage_events": 0, "unknown_events": 0,
                                      "attempts": 0, "completed_attempts": 0, "failed_attempts": 0,
                                      "elapsed_seconds": None,
                                      "measured": {key: None for key in DIMENSIONS}, "measured_input_plus_output": None})
        if value["event"] == "agent_started":
            row["attempts"] += 1
            continue
        if value["event"] == "agent_ended":
            row["completed_attempts"] += 1
            row["failed_attempts"] += type(value.get("exit_code")) is int and value["exit_code"] != 0
            elapsed = value.get("elapsed_seconds")
            if type(elapsed) in (float, int) and 0 <= elapsed < 1e9:
                row["elapsed_seconds"] = round((row["elapsed_seconds"] or 0) + elapsed, 3)
            continue
        usage = numeric_usage(value.get("incremental_usage"))
        row["usage_events"] += 1
        if any(usage[key] is None for key in ("input_tokens", "output_tokens")):
            row["unknown_events"] += 1
        else:
            row["measured_input_plus_output"] = (row["measured_input_plus_output"] or 0) + usage["input_tokens"] + usage["output_tokens"]
        for key, count in usage.items():
            if count is not None:
                row["measured"][key] = (row["measured"][key] or 0) + count
    measured = [r["measured_input_plus_output"] for r in rows.values() if r["measured_input_plus_output"] is not None]
    total = sum(measured) if measured else None
    for row in rows.values():
        count = row["measured_input_plus_output"]
        row["measured_percent"] = round(count * 100 / total, 2) if total and count is not None else None
    # Private session hashes, arbitrary metadata, prompts and commands stay local.
    return {"measured_input_plus_output": total, "stages": list(rows.values())}
