#!/usr/bin/env python3
"""Execute a validated manifest in order and preserve truthful stage outcomes."""
from __future__ import annotations

import argparse
import concurrent.futures
from contextlib import contextmanager
import json
import os
import re
import signal
import subprocess
import sys
import time
import uuid
import threading
from pathlib import Path

try:
    import fcntl as _fcntl
except ImportError:  # pragma: no cover - exercised on Windows
    _fcntl = None
try:
    import msvcrt as _msvcrt
except ImportError:  # pragma: no cover - exercised on POSIX
    _msvcrt = None

try:
    from .agentflow_verification import atomic_json, manifest, retry_fingerprint, check_identity, input_fingerprint
    from .agentflow_runtime import safe_diagnostic
    from .workflow_artifact_probe import active_feature
except ImportError:
    from agentflow_verification import atomic_json, manifest, retry_fingerprint, check_identity, input_fingerprint
    from agentflow_runtime import safe_diagnostic
    from workflow_artifact_probe import active_feature


def _safe_command(check, root, stage, reuse, stage_attempt_token=None):
    argv = [sys.executable, "scripts/agentflow_check.py", check["id"], "--stage", stage]
    if reuse and stage == "develop":
        argv.append("--reuse")
    env = os.environ.copy()
    if stage_attempt_token is not None:
        if not isinstance(stage_attempt_token, str) or not re.fullmatch(r"[a-f0-9]{32}", stage_attempt_token):
            raise RuntimeError("Invalid full-stage attempt token")
        env["AGENTFLOW_STAGE_ATTEMPT_TOKEN"] = stage_attempt_token
    started = time.monotonic()
    try:
        result = subprocess.run(argv, cwd=root, env=env, capture_output=True, text=True, check=False)
    except OSError:
        return {"status": "failed", "elapsed_ms": int((time.monotonic()-started)*1000),
                "category": "check-failed", "evidence": None}
    duration = int((time.monotonic()-started)*1000)
    evidence = None
    profile_details = {}
    try:
        details = json.loads(result.stdout.splitlines()[-1])
        evidence = details.get("evidence")
        diagnostics = details.get("failure_diagnostics")
        if isinstance(diagnostics, dict):
            # Copy only the identity fields produced by the strict inventory mapper.
            cases = diagnostics.get("profile_discrepancies")
            if isinstance(cases, list) and len(cases) <= 100:
                safe_cases = [dict(case) for case in cases if _safe_profile_discrepancy(case)]
                if safe_cases:
                    profile_details["profile_discrepancies"] = safe_cases
                categories = details.get("failure_diagnostics", {}).get("profile_categories")
                if isinstance(categories, list) and len(categories) <= 10 and all(
                    value in {"usage", "timeout", "resource-cleanup", "browser-prerequisite", "test-failure",
                              "component-failure", "docker-prerequisite", "execution-membership",
                              "inventory-or-service-prerequisite", "profile"} for value in categories
                ):
                    profile_details["profile_categories"] = categories
            summaries = diagnostics.get("profile_event_summaries")
            if isinstance(summaries, list) and len(summaries) <= 10:
                safe_summaries = [dict(item) for item in summaries
                                  if _safe_profile_event_summaries([item])]
                if safe_summaries:
                    profile_details["profile_event_summaries"] = safe_summaries
            browsers = diagnostics.get("profile_browser_diagnostics")
            if isinstance(browsers, list) and len(browsers) <= 10 and all(
                isinstance(item, dict) and set(item) == {"cause", "stage"}
                and item.get("cause") in {"executable-missing", "dependency-missing", "permission-denied",
                                           "launch-timeout", "launch-failed"}
                and item.get("stage") in {"integration", "e2e"}
                for item in browsers
            ):
                profile_details["profile_browser_diagnostics"] = browsers
            memberships = diagnostics.get("profile_membership_diagnostics")
            if isinstance(memberships, list) and len(memberships) <= 10 and all(
                _safe_membership_diagnostic(item) for item in memberships
            ):
                profile_details["profile_membership_diagnostics"] = memberships
            extra_sources = diagnostics.get("profile_membership_extra_sources")
            if isinstance(extra_sources, list) and len(extra_sources) <= 10 and all(
                _safe_membership_extra_source(item) for item in extra_sources
            ):
                profile_details["profile_membership_extra_sources"] = extra_sources
    except (ValueError, IndexError, AttributeError):
        diagnostics = None
    code = 143 if result.returncode == -signal.SIGTERM else 130 if result.returncode == -signal.SIGINT else result.returncode
    return {"status": "passed" if code == 0 else "interrupted" if code in (130, 143) else "failed",
            "elapsed_ms": duration, "category": None if code == 0 else "interrupted" if code in (130, 143) else "check-failed",
            "evidence": evidence, "exit_code": code, **profile_details}


def _safe_membership_diagnostic(item):
    reasons = {
        "committed-file-audit": {"invalid-shape", "duplicate-files", "outside-profile"},
        "nonce-validation": {"nonce-mismatch"},
        "event-reconciliation": {"empty-expected", "extra-events", "unexpected-state",
                                 "missing-events", "duplicate-events"},
        "coverage-audit": {"missing-sidecar", "missing-partition", "partition-mismatch", "missing-export"},
    }
    keys = {"profile", "phase", "reason", "expected", "observed", "missing_started",
            "missing_passed", "extra", "duplicate", "invalid_state", "wrong_nonce"}
    return (isinstance(item, dict) and set(item) == keys and
            item.get("profile") in {"unit", "integration", "e2e"} and
            item.get("phase") in reasons and item.get("reason") in reasons[item["phase"]] and
            all(type(item.get(key)) is int and 0 <= item[key] <= 10000000
                for key in keys - {"profile", "phase", "reason"}))


def _safe_profile_discrepancy(case):
    identity = {"id", "runner", "file", "case_id", "profile"}
    detail = identity | {"state", "cause", "failure_line", "started", "passed", "failed", "skipped"}
    if not isinstance(case, dict):
        return False
    keys = set(case)
    if keys not in (identity, identity | {"failure_line"}, detail):
        return False
    if (not isinstance(case.get("id"), str) or not re.fullmatch(r"[0-9a-f]{24}", case["id"]) or
            case.get("runner") not in {"exunit", "python", "node", "shell"} or
            case.get("profile") not in {"unit", "integration", "e2e"} or
            not isinstance(case.get("file"), str) or
            not re.fullmatch(r"(?:test|tools)/[A-Za-z0-9_./-]{1,220}", case["file"]) or
            ".." in Path(case["file"]).parts or
            not isinstance(case.get("case_id"), str) or
            not re.fullmatch(r"(?:test(?:\.[A-Za-z0-9_]+)+|redacted)", case["case_id"])):
        return False
    if "failure_line" in case and case["failure_line"] is not None and (
            type(case["failure_line"]) is not int or not 1 <= case["failure_line"] <= 1_000_000):
        return False
    if keys == detail:
        return (case["state"] in {"failed", "skipped", "incomplete"} and
                case["cause"] in {"assertion", "error", "skipped", "incomplete"} and
                all(type(case[key]) is int and 0 <= case[key] <= 1_000_000
                    for key in ("started", "passed", "failed", "skipped")))
    return True


def _safe_profile_event_summaries(items):
    return (isinstance(items, list) and 1 <= len(items) <= 10 and all(
        isinstance(item, dict) and set(item) == {"profile", "step", "started", "passed", "failed", "skipped"} and
        item["profile"] in {"unit", "integration", "e2e"} and item["step"] == "tests" and
        all(type(item[key]) is int and 0 <= item[key] <= 1_000_000
            for key in ("started", "passed", "failed", "skipped")) for item in items))


def _safe_membership_extra_source(item):
    return (isinstance(item, dict) and set(item) == {"profile", "runner", "file"} and
            item["profile"] in {"unit", "integration", "e2e"} and
            item["runner"] in {"exunit", "python", "node", "shell"} and
            isinstance(item["file"], str) and
            re.fullmatch(r"(?:test|tools)/[A-Za-z0-9_./-]{1,220}", item["file"]) and
            ".." not in Path(item["file"]).parts)


def _report(path, stage, journal, independent_assessment=False):
    if stage != "qa":
        return
    lines = ["# Independent QA check outcomes", "",
             "Machine outcomes are evidence inputs; an independent semantic assessment is still required.", "",
             "| Check | Outcome | Evidence |", "|---|---|---|"]
    for row in journal["checks"]:
        lines.append(f"| `{row['id']}` | {row['status']} | {row.get('evidence') or '—'} |")
    complete = all(row["status"] == "passed" for row in journal["checks"])
    verdict = "PASS" if complete and independent_assessment else "FAIL"
    lines += ["", f"Verdict: {verdict}", ""]
    temporary = path.with_suffix(".tmp")
    temporary.write_text("\n".join(lines), encoding="utf-8")
    temporary.replace(path)


def _stage_attempt_file(root: Path, feature: Path, stage: str) -> Path:
    return root / ".agentflow/runs/checks/stage-attempts" / feature.name / (stage + ".json")


def _stage_components(root: Path, feature: Path, checks):
    return {check["id"]: {"command": check_identity(check),
                          "inputs": retry_fingerprint(root, feature, check)} for check in checks}


def _dependency_graph(checks):
    return {check["id"]: list(check.get("depends_on", [])) for check in checks}


def _dependency_closure(failing_checks, graph):
    closure = set()
    pending = list(failing_checks)
    while pending:
        ident = pending.pop()
        if ident in closure or ident not in graph:
            continue
        closure.add(ident)
        pending.extend(graph[ident])
    return sorted(closure)


def _retry_snapshot(components, graph, scope):
    return {"components": {ident: components[ident] for ident in scope if ident in components},
            "dependencies": {ident: graph[ident] for ident in scope if ident in graph}}


@contextmanager
def _stage_attempt_lock(path: Path):
    """Serialize each stage's complete run so live attempts cannot overwrite each other."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a+") as stream:
        if _fcntl is not None:
            try:
                _fcntl.flock(stream.fileno(), _fcntl.LOCK_EX | _fcntl.LOCK_NB)
            except BlockingIOError:
                raise RuntimeError("Stage is already running; wait for it to finish before retrying") from None
            try:
                yield
            finally:
                _fcntl.flock(stream.fileno(), _fcntl.LOCK_UN)
        elif _msvcrt is not None:  # pragma: no cover - exercised on Windows
            stream.seek(0)
            if not stream.read(1):
                stream.seek(0)
                stream.write("\0")
                stream.flush()
            stream.seek(0)
            try:
                _msvcrt.locking(stream.fileno(), _msvcrt.LK_NBLCK, 1)
            except OSError:
                raise RuntimeError("Stage is already running; wait for it to finish before retrying") from None
            try:
                yield
            finally:
                stream.seek(0)
                _msvcrt.locking(stream.fileno(), _msvcrt.LK_UNLCK, 1)
        else:  # pragma: no cover - every supported platform has one of the lock APIs
            raise RuntimeError("Cross-process stage lock is unavailable")


def _begin_attempt(root, feature, stage, checks):
    path = _stage_attempt_file(root, feature, stage)
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        data = {"schema_version": 1, "attempts": []}
    except (OSError, ValueError) as error:
        raise RuntimeError("Stage attempt journal is corrupt; preserve it and request recovery") from error
    if not isinstance(data, dict) or data.get("schema_version") != 1 or not isinstance(data.get("attempts"), list):
        raise RuntimeError("Stage attempt journal is unsupported; preserve it and request recovery")
    components = _stage_components(root, feature, checks)
    graph = _dependency_graph(checks)
    recovered_running = False
    for prior in data["attempts"]:
        if prior.get("state") == "running":
            prior["state"] = "interrupted"
            recovered_running = True
    if recovered_running:
        # Persist abrupt termination before a retry-cap refusal can return.
        atomic_json(path, data)
    same_failures = []
    for prior in data["attempts"]:
        if prior.get("state") not in ("failed", "interrupted"):
            continue
        scope = prior.get("retry_scope")
        snapshot = prior.get("retry_snapshot")
        if (isinstance(scope, list) and scope and all(isinstance(ident, str) for ident in scope) and
                isinstance(snapshot, dict) and set(snapshot) == {"components", "dependencies"}):
            current_snapshot = _retry_snapshot(components, graph, scope)
            if current_snapshot == snapshot:
                same_failures.append(prior)
        else:
            # Legacy and interrupted records without a trustworthy failure scope
            # conservatively bind the retry cap to the complete stage snapshot.
            prior_components = prior.get("components")
            if isinstance(prior_components, dict) and prior_components == components:
                same_failures.append(prior)
    if len(same_failures) >= 2:
        elapsed = sum(value.get("elapsed_ms", 0) for value in same_failures if type(value.get("elapsed_ms")) is int)
        references = sorted({ref for value in same_failures for ref in value.get("evidence", [])
                             if isinstance(ref, str) and ref.startswith(".agentflow/runs/checks/")})
        raise RuntimeError("Stage retry limit reached for unchanged inputs; elapsed_ms=" + str(elapsed) +
                           "; evidence=" + (", ".join(references) if references else "unavailable") +
                           "; repair relevant inputs before retrying")
    attempt = {"token": uuid.uuid4().hex, "state": "running", "components": components,
               "dependency_graph": graph,
               "started_at": time.time(), "failing_checks": [], "elapsed_ms": None}
    data["attempts"].append(attempt)
    atomic_json(path, data)
    return path, data, attempt


def _finish_attempt(path, data, attempt, journal):
    attempt["state"] = "passed" if all(row["status"] == "passed" for row in journal["checks"]) else "failed"
    attempt["failing_checks"] = [row["id"] for row in journal["checks"] if row["status"] != "passed"]
    if attempt["state"] == "failed":
        failed_roots = [row["id"] for row in journal["checks"] if row["status"] == "failed"]
        graph = attempt.get("dependency_graph")
        if failed_roots and isinstance(graph, dict):
            scope = _dependency_closure(failed_roots, graph)
            attempt["retry_scope"] = scope
            attempt["retry_snapshot"] = _retry_snapshot(attempt["components"], graph, scope)
    attempt["elapsed_ms"] = journal.get("elapsed_ms")
    attempt["evidence"] = sorted({row["evidence"] for row in journal["checks"]
                                  if isinstance(row.get("evidence"), str) and
                                  row["evidence"].startswith(".agentflow/runs/checks/")})
    attempt["ended_at"] = time.time()
    atomic_json(path, data)


def run_stage(root: Path, feature: Path, stage: str, *, reuse=False, workers=2):
    if stage not in ("develop", "qa", "review") or (reuse and stage != "develop"):
        raise RuntimeError("Invalid stage or receipt reuse mode")
    data = manifest(feature)  # Entire metadata graph validates before child execution.
    lock_path = _stage_attempt_file(root, feature, stage).with_name(stage + ".lock")
    with _stage_attempt_lock(lock_path):
        return _run_stage_locked(root, feature, stage, data, reuse=reuse, workers=workers)


def _run_stage_locked(root: Path, feature: Path, stage: str, data: dict, *, reuse=False, workers=2):
    checks = data["checks"]
    attempt_path, attempts_data, stage_attempt = _begin_attempt(root, feature, stage, checks)
    journal_path = root / ".agentflow/runs/checks/stage-journals" / feature.name / (stage + ".json")
    journal = {"schema_version": 1, "stage": stage, "attempt": uuid.uuid4().hex,
               "stage_attempt_token": stage_attempt["token"],
               "checks": [{"id": check["id"], "status": "unexecuted", "evidence": None}
                          for check in checks], "started_at": time.time()}
    atomic_json(journal_path, journal)
    report_path = feature / "qa-report.md"
    _report(report_path, stage, journal)
    contaminated = set()
    finished = {}
    blocked_global = False
    interrupted = False
    journal_lock = threading.RLock()
    received_signal = []
    previous_handlers = {}
    def record_signal(signum, _frame):
        received_signal.append(signum)
    for signum in (signal.SIGINT, signal.SIGTERM):
        previous_handlers[signum] = signal.signal(signum, record_signal)

    def execute(index):
        check = checks[index]
        row = journal["checks"][index]
        with journal_lock:
            row["status"] = "running"
            atomic_json(journal_path, journal)
        result = _safe_command(check, root, stage, reuse, stage_attempt["token"])
        if result["status"] != "passed":
            result["diagnostic"] = safe_diagnostic(stage=stage, check=check["id"],
                                                   category=result.get("category") or "check-failed",
                                                   elapsed_ms=result.get("elapsed_ms"),
                                                   evidence=result.get("evidence"))
        with journal_lock:
            row.update(result)
            atomic_json(journal_path, journal)
            _report(report_path, stage, journal)
        return result

    index = 0
    while index < len(checks):
        if received_signal:
            journal["checks"][index]["status"] = "interrupted"
            journal["checks"][index]["category"] = "interrupted"
            interrupted = True
            break
        check = checks[index]
        row = journal["checks"][index]
        deps = check.get("depends_on", [])
        failed_deps = [dep for dep in deps if finished.get(dep) != "passed"]
        reads = set(check.get("state_reads", []))
        contaminated_hits = sorted(reads & contaminated)
        known_independent = check.get("isolation") == "isolated" and "depends_on" in check and "state_reads" in check and "state_writes" in check
        if failed_deps or contaminated_hits or (blocked_global and not known_independent):
            row.update(status="blocked", blocked_by=failed_deps,
                       contaminated_state=contaminated_hits,
                       category="dependency-blocked")
            finished[check["id"]] = "blocked"
            atomic_json(journal_path, journal); _report(report_path, stage, journal)
            index += 1
            continue
        if check.get("execution_class") == "static" and known_independent:
            group = []
            cursor = index
            while cursor < len(checks) and len(group) < workers:
                candidate = checks[cursor]
                candidate_known = (candidate.get("execution_class") == "static" and
                                   candidate.get("isolation") == "isolated" and
                                   candidate.get("depends_on") == [] and
                                   candidate.get("state_reads") == [] and
                                   candidate.get("state_writes") == [])
                if not candidate_known:
                    break
                group.append(cursor); cursor += 1
            if len(group) > 1:
                with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
                    futures = {pool.submit(execute, member): member for member in group}
                    results = {futures[future]: future.result() for future in concurrent.futures.as_completed(futures)}
                for member in group:
                    item = checks[member]
                    outcome = results[member]
                    finished[item["id"]] = outcome["status"]
                    if outcome["status"] != "passed":
                        contaminated.update(item.get("state_writes", []))
                        blocked_global = True
                    if outcome.get("exit_code") in (130, 143):
                        journal["checks"][member]["status"] = "interrupted"
                        interrupted = True
                index += len(group)
                if interrupted:
                    break
                continue
        outcome = execute(index)
        finished[check["id"]] = outcome["status"]
        if outcome.get("exit_code") in (130, 143):
            row["status"] = "interrupted"
            row["category"] = "interrupted"
            atomic_json(journal_path, journal); _report(report_path, stage, journal)
            interrupted = True
            break
        if outcome["status"] != "passed":
            contaminated.update(check.get("state_writes", []))
            if not known_independent:
                blocked_global = True
        index += 1
    journal["elapsed_ms"] = int((time.time()-journal["started_at"])*1000)
    for signum, handler in previous_handlers.items():
        signal.signal(signum, handler)
    atomic_json(journal_path, journal)
    _finish_attempt(attempt_path, attempts_data, stage_attempt, journal)
    _report(report_path, stage, journal)
    print(json.dumps({"stage": stage, "checks": len(checks),
                      "passed": sum(row["status"] == "passed" for row in journal["checks"]),
                      "failed": sum(row["status"] == "failed" for row in journal["checks"]),
                      "blocked": sum(row["status"] == "blocked" for row in journal["checks"]),
                      "elapsed_ms": journal["elapsed_ms"],
                      "journal": journal_path.relative_to(root).as_posix()}))
    return 130 if interrupted else 0 if all(row["status"] == "passed" for row in journal["checks"]) else 1


def ci_parity(root: Path):
    files = [root / ".agentflow/workflow.yml", root / ".specify/workflows/desapp-delivery/workflow.yml"]
    if any(not path.is_file() for path in files) or files[0].read_bytes() != files[1].read_bytes():
        raise RuntimeError("Delivery workflow copies differ; reconcile them before continuing")
    workflow = files[0].read_text(encoding="utf-8")
    if 'id: ci_baseline' not in workflow or 'run: "python3 scripts/agentflow_stage_checks.py --ci-parity"' not in workflow:
        raise RuntimeError("Local baseline is not the required wrapper parity check")
    wrapper = (root / "scripts/ci_unit_tests.sh").read_text(encoding="utf-8")
    ci = (root / ".github/workflows/quality-baseline.yml").read_text(encoding="utf-8")
    feature = active_feature(root)
    checks = {check["id"]: check for check in manifest(feature)["checks"]}
    expected_profiles = {
        "unit": ["mix", "test.unit"],
        "integration": ["mix", "test.integration"],
    }
    profiles_match = all(
        name in checks and checks[name].get("env", {}).get("MIX_ENV") == "test" and
        checks[name].get("argv", [])[3:] == argv and
        checks[name].get("argv", [])[:3] == ["mise", "exec", "--"]
        for name, argv in expected_profiles.items()
    )
    if (not profiles_match or "scripts/ci_unit_tests.sh" not in ci or
            "for profile in unit integration" not in wrapper):
        raise RuntimeError("CI wrapper/profile obligation is missing or mismatched")
    result = subprocess.run(["sh", "test/scripts/ci_unit_tests_test.sh"], cwd=root,
                            stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True, check=False)
    if result.returncode:
        raise RuntimeError("CI wrapper contract fixtures failed; inspect their local test evidence")
    return {"workflow_copies": "match", "profiles": ["unit", "integration"],
            "native_profile_runs": 0, "wrapper_contract": "passed"}


def summarize_stage(root: Path, feature: Path, stage: str) -> dict:
    """Return bounded details from the latest stage journal; never expose raw output."""
    if stage not in ("develop", "qa", "review"):
        raise RuntimeError("Invalid stage summary target")
    registered = manifest(feature)["checks"]
    journal_path = root / ".agentflow/runs/checks/stage-journals" / feature.name / (stage + ".json")
    try:
        journal = json.loads(journal_path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise RuntimeError("No stage journal is available") from None
    except (OSError, ValueError, UnicodeError):
        raise RuntimeError("Stage journal is unreadable") from None
    if not isinstance(journal, dict) or journal.get("stage") != stage or not isinstance(journal.get("checks"), list):
        raise RuntimeError("Stage journal is malformed")
    outcomes = {row["id"]: row for row in journal["checks"]
                if isinstance(row, dict) and isinstance(row.get("id"), str)}
    valid_statuses = {"unexecuted", "running", "passed", "failed", "blocked", "interrupted"}
    valid_categories = {"check-failed", "interrupted", "dependency-blocked", "configuration",
                        "prerequisite-missing", "prerequisite-incompatible", "prerequisite-unknown",
                        "prerequisite-unavailable", "retry-limit", "invalid-evidence"}
    rows = []
    for check in registered:
        source = outcomes.get(check["id"], {})
        status = source.get("status")
        if not isinstance(status, str) or status not in valid_statuses:
            status = "unexecuted"
        category = source.get("category")
        if not isinstance(category, str) or category not in valid_categories:
            diagnostic = source.get("diagnostic")
            category = diagnostic.get("category") if isinstance(diagnostic, dict) else None
        if not isinstance(category, str) or category not in valid_categories:
            category = "dependency-blocked" if status == "blocked" else None
        row = {"id": check["id"], "status": status, "category": category,
               "elapsed_ms": source.get("elapsed_ms") if type(source.get("elapsed_ms")) is int and source["elapsed_ms"] >= 0 else None,
               "evidence": source.get("evidence") if isinstance(source.get("evidence"), str) and
               re.fullmatch(r"\.agentflow/runs/checks/[A-Za-z0-9_./-]{1,240}", source["evidence"]) and
               ".." not in Path(source["evidence"]).parts else None}
        safe_cases = (source.get("profile_discrepancies") if isinstance(source.get("profile_discrepancies"), list)
                      else (source.get("diagnostic", {}).get("profile_discrepancies")
                            if isinstance(source.get("diagnostic"), dict) else None))
        if not safe_cases and row["evidence"]:
            try:
                from .profile_safe_diagnostics import parse_profile_diagnostics
            except ImportError:
                from profile_safe_diagnostics import parse_profile_diagnostics
            safe_cases = parse_profile_diagnostics(root, root / row["evidence"]).get("profile_discrepancies")
        if isinstance(safe_cases, list) and safe_cases:
            safe_cases = [dict(case) for case in safe_cases if _safe_profile_discrepancy(case)]
            if safe_cases:
                row["profile_discrepancies"] = safe_cases
        event_summaries = source.get("profile_event_summaries")
        if _safe_profile_event_summaries(event_summaries):
            row["profile_event_summaries"] = [dict(item) for item in event_summaries]
        if row["evidence"]:
            try:
                from .profile_safe_diagnostics import parse_profile_diagnostics
            except ImportError:
                from profile_safe_diagnostics import parse_profile_diagnostics
            profile_details = parse_profile_diagnostics(root, root / row["evidence"])
            if not row.get("profile_discrepancies") and profile_details.get("profile_discrepancies"):
                row["profile_discrepancies"] = profile_details["profile_discrepancies"]
            if not row.get("profile_event_summaries") and _safe_profile_event_summaries(
                    profile_details.get("profile_event_summaries")):
                row["profile_event_summaries"] = profile_details["profile_event_summaries"]
            if profile_details.get("profile_categories"):
                row["profile_categories"] = profile_details["profile_categories"]
            if profile_details.get("profile_browser_diagnostics"):
                row["profile_browser_diagnostics"] = profile_details["profile_browser_diagnostics"]
            if profile_details.get("profile_membership_diagnostics"):
                row["profile_membership_diagnostics"] = profile_details["profile_membership_diagnostics"]
            if profile_details.get("profile_membership_extra_sources"):
                row["profile_membership_extra_sources"] = profile_details["profile_membership_extra_sources"]
        rows.append(row)
    return {"stage": stage, "checks": rows}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", choices=("develop", "qa", "review"))
    parser.add_argument("--reuse", action="store_true")
    parser.add_argument("--static-workers", type=int, choices=(1, 2), default=2)
    parser.add_argument("--ci-parity", action="store_true")
    parser.add_argument("--summary", action="store_true",
                        help="print a safe summary of the latest stage journal without running checks")
    args = parser.parse_args(argv)
    root = Path.cwd().resolve()
    try:
        if args.ci_parity:
            print(json.dumps(ci_parity(root), sort_keys=True)); return 0
        if args.summary:
            if not args.stage:
                parser.error("--stage is required with --summary")
            print(json.dumps(summarize_stage(root, active_feature(root), args.stage), sort_keys=True))
            return 0
        if not args.stage:
            parser.error("--stage is required unless --ci-parity is selected")
        return run_stage(root, active_feature(root), args.stage, reuse=args.reuse,
                         workers=args.static_workers)
    except (OSError, RuntimeError, ValueError) as error:
        print(json.dumps({"category": "configuration", "cause": str(error)}), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
