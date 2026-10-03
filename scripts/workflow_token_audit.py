#!/usr/bin/env python3
"""Read-only workflow diagnosis; emit metrics, never transcript contents."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
COUNT = re.compile(r"(?:\d+|\d{1,3}(?:,\d{3})+|\d{1,3}(?:\.\d{3})+)")
INVOCATION = re.compile(r"^\[[^\n]+\] .*\bspecify workflow (?:run|resume)\b")
STAGES = ("product", "product_challenge", "architecture", "tasks", "develop", "qa", "review", "unknown")


def classify_prompt(prompt: str) -> str:
    """Use only the initial user prompt, never commands or later tool output."""
    skills = set(re.findall(r"\$speckit-(specify|plan|tasks|implement|analyze|checklist|converge)\b", prompt))
    text = prompt.lower()
    roles = {stage for stage, phrase in (("product_challenge", "independent product"),
                                         ("qa", "independent qa"),
                                         ("review", "final independent reviewer")) if phrase in text}
    if skills:
        if len(skills) != 1:
            return "unknown"
        command_stage = {"specify": "product", "plan": "architecture", "tasks": "tasks",
                         "implement": "develop"}.get(next(iter(skills)), "unknown")
        return command_stage if not roles or roles == {command_stage} else "unknown"
    return next(iter(roles)) if len(roles) == 1 else "unknown"


def session_metrics(path: Path, identity_counts: dict | None = None) -> list[dict]:
    """Extract safe per-session metadata, including unmetered interrupted attempts."""
    if not path.is_file():
        return []
    records = []
    current = None
    prompt_lines = []
    collecting = False
    awaiting_count = False
    prompt_started = False

    def finish():
        if current is not None:
            prompt = "\n".join(prompt_lines)
            current["stage"] = classify_prompt(prompt)
            current["initial_prompt_chars"] = len(prompt)
            records.append(current.copy())

    with path.open(encoding="utf-8", errors="replace") as stream:
        for raw in stream:
            line = ANSI.sub("", raw).rstrip("\r\n")
            if line.startswith("OpenAI Codex v"):
                finish()
                current = {"reported_tokens": None}
                prompt_lines = []
                collecting = False
                awaiting_count = False
                prompt_started = False
                continue
            if current is not None and not prompt_started and line.startswith("session id: "):
                current["_session_identity"] = line.removeprefix("session id: ")
            if current is not None and current["reported_tokens"] is None:
                if awaiting_count and COUNT.fullmatch(line.strip()):
                    current["reported_tokens"] = int(line.strip().replace(",", "").replace(".", ""))
                if collecting:
                    if line.strip() in ("codex", "thinking", "exec", "tokens used"):
                        collecting = False
                    else:
                        prompt_lines.append(line)
                elif line == "user" and not prompt_started:
                    collecting = True
                    prompt_started = True
            elif current is None and awaiting_count and COUNT.fullmatch(line.strip()):
                # Retain counts from legacy logs without a session header.
                records.append({"stage": "unknown", "initial_prompt_chars": 0,
                                "reported_tokens": int(line.strip().replace(",", "").replace(".", ""))})
            awaiting_count = line.strip() == "tokens used"
    finish()
    identities = [record.get("_session_identity") for record in records]
    for record in records:
        identity = record.pop("_session_identity", None)
        occurrences = identity_counts.get(identity, 0) if identity_counts is not None else identities.count(identity)
        record["reused_session_id"] = bool(identity and occurrences > 1)
    return records


def summarize_stages(records: list[dict]) -> list[dict]:
    total = sum(record["reported_tokens"] or 0 for record in records)
    rows = []
    for stage in STAGES:
        selected = [record for record in records if record["stage"] == stage]
        if not selected:
            continue
        metered = [record for record in selected if record["reported_tokens"] is not None]
        tokens = sum(record["reported_tokens"] for record in metered)
        # Each task marks its first metered session separately before aggregation.
        first = sum(record["reported_tokens"] for record in metered if record.get("first_metered", False))
        rows.append({"stage": stage, "reported_tokens": tokens if metered else None,
                     "token_percent": round(tokens * 100 / total, 2) if total and metered else None,
                     "completed_sessions": len(metered), "attempts_without_count": len(selected) - len(metered),
                     "first_metered_tokens": first if stage != "unknown" and metered else None,
                     "repeat_metered_tokens": tokens - first if stage != "unknown" and metered else None,
                     "initial_prompt_chars": sum(record["initial_prompt_chars"] for record in selected)})
    return rows


def stage_audit(root: Path) -> dict:
    tasks = []
    all_records = []
    cohort_records = []
    reused_tasks = []
    identity_counts = {}
    # Compare identities across logs as well as within each log. Read only metadata
    # between a session header and its initial user prompt, not later tool output.
    for number in range(1, 16):
        path = root / ".agentflow/runs" / f"TASK-{number:03d}.live.log"
        if not path.is_file():
            continue
        in_header = False
        with path.open(encoding="utf-8", errors="replace") as stream:
            for raw in stream:
                line = ANSI.sub("", raw).strip()
                if line.startswith("OpenAI Codex v"):
                    in_header = True
                elif line == "user":
                    in_header = False
                elif in_header and line.startswith("session id: "):
                    identity = line.removeprefix("session id: ")
                    identity_counts[identity] = identity_counts.get(identity, 0) + 1
    for number in range(1, 16):
        ident = f"TASK-{number:03d}"
        path = root / ".agentflow/runs" / f"{ident}.live.log"
        records = session_metrics(path, identity_counts)
        seen = set()
        for record in records:
            if record["reported_tokens"] is not None:
                record["first_metered"] = record["stage"] not in seen
                seen.add(record["stage"])
        expected = log_metrics(path)["reported_tokens"]
        tokens = sum(record["reported_tokens"] or 0 for record in records)
        if expected is not None and tokens != expected:
            raise RuntimeError(f"Session totals do not reconcile for {ident}")
        reused = any(record["reused_session_id"] for record in records)
        tasks.append({"task": ident, "log_available": path.is_file(), "reused_session_ids": reused,
                      "stages": summarize_stages(records)})
        if reused:
            reused_tasks.append(ident)
        else:
            cohort_records.extend(records)
        all_records.extend(records)
    total = sum(record["reported_tokens"] or 0 for record in all_records)
    unknown = sum(record["reported_tokens"] or 0 for record in all_records if record["stage"] == "unknown")
    return {"reported_tokens": total, "attributed_token_percent": round((total - unknown) * 100 / total, 2) if total else None,
            "stages": summarize_stages(all_records), "tasks": tasks,
            "no_reused_session_cohort": {"excluded_tasks": reused_tasks,
                                        "reported_tokens": sum(record["reported_tokens"] or 0 for record in cohort_records),
                                        "stages": summarize_stages(cohort_records)}}


def log_metrics(path: Path) -> dict:
    if not path.is_file():
        return {"completed_sessions": None, "reported_tokens": None, "runner_invocations": None}
    counts = []
    invocations = 0
    awaiting_count = False
    with path.open(encoding="utf-8", errors="replace") as stream:
        for raw in stream:
            line = ANSI.sub("", raw).strip()
            invocations += bool(INVOCATION.match(line))
            if awaiting_count and COUNT.fullmatch(line):
                counts.append(int(line.replace(",", "").replace(".", "")))
            awaiting_count = line == "tokens used"
    return {"completed_sessions": len(counts), "reported_tokens": sum(counts) if counts else None,
            "runner_invocations": invocations}


def verdict(path: Path) -> str | None:
    if not path.is_file():
        return None
    lines = [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    return lines[-1].removeprefix("Verdict: ") if lines and lines[-1] in ("Verdict: PASS", "Verdict: FAIL") else None


def audit(root: Path) -> list[dict]:
    rows = []
    for number in range(1, 16):
        ident = f"TASK-{number:03d}"
        tasks = sorted((root / "backlog").glob(f"{ident}-*.md"))
        task = tasks[0] if len(tasks) == 1 else None
        status = re.search(r"(?m)^status:\s*([^\n]+)", task.read_text()) if task else None
        features = sorted((root / "specs").glob(f"{number:03d}-*"))
        feature = features[0] if len(features) == 1 and features[0].is_dir() else None
        artifacts = list(feature.rglob("*.md")) if feature else []
        volumes = {p: len(p.read_text(encoding="utf-8").split()) for p in artifacts}
        rows.append({"task": ident, "status": status[1].strip() if status else None,
                     "artifact_words": sum(volumes.values()) if feature else None,
                     "handoff_words": sum(n for p, n in volumes.items() if p.parent.name == "handoffs") if feature else None,
                     "qa": verdict(feature / "qa-report.md") if feature else None,
                     "review": verdict(feature / "review-report.md") if feature else None,
                     **log_metrics(root / ".agentflow" / "runs" / f"{ident}.live.log")})
    return rows


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stages", action="store_true", help="attribute retained session counts to stages")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    print(json.dumps(stage_audit(root) if args.stages else audit(root), indent=2))
