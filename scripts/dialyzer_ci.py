#!/usr/bin/env python3
"""Required Dialyzer gate; exact reviewed exceptions, distinct model/error evidence."""
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
VERSIONS = dict(otp="29.0.6", elixir="1.20.3", dialyzer="6.0.2", dialyxir="1.4.8")
CACHE_INPUTS = (".tool-versions", "mix.exs", "mix.lock", "scripts/dialyzer_ci.py",
                "scripts/dialyzer_analyze.exs", "scripts/dialyzer_exceptions.json")
IDENTITY = ("file", "line", "kind", "message_sha256", "source_sha256")


def cache_key(root=ROOT, system=None, machine=None, runner=None, versions=None):
    inputs = {path: hashlib.sha256((root / path).read_bytes()).hexdigest()
              for path in CACHE_INPUTS}
    inputs.update({p.relative_to(root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                   for p in (root / "config").rglob("*.exs")})
    payload = dict(schema=1, system=system or platform.system(),
                   machine=machine or platform.machine(),
                   runner=runner or os.environ.get("ImageOS", platform.platform()),
                   image_version=os.environ.get("ImageVersion", "local"),
                   versions=versions or VERSIONS, profiles=["dev", "test"], inputs=inputs)
    return "dialyzer-" + hashlib.sha256(json.dumps(payload, sort_keys=True).encode()).hexdigest()


def lock_digest():
    return hashlib.sha256((ROOT / "mix.lock").read_bytes()).hexdigest()


def classify(report, returncode, profile, phase, exceptions):
    if (report.get("status") != "analyzed" or report.get("versions") != VERSIONS
            or report.get("profile") != profile or report.get("phase") != phase
            or type(report.get("files")) is not int or report["files"] < 1
            or not isinstance(report.get("findings"), list)):
        raise ValueError("invalid-or-incomplete-analysis")
    findings = report["findings"]
    if returncode != (2 if findings else 0):
        raise ValueError("analyzer-exit-status")
    accepted, blocking = [], []
    for finding in findings:
        if (set(finding) != set(IDENTITY) | {"message"}
                or type(finding["line"]) is not int or finding["line"] < 0
                or any(not isinstance(finding[k], str) or not finding[k]
                       for k in ("file", "kind", "message", "message_sha256"))
                or hashlib.sha256(finding["message"].encode()).hexdigest() != finding["message_sha256"]):
            raise ValueError("invalid-finding")
        identity = {key: finding[key] for key in IDENTITY}
        match = dict(profile=profile, phase=phase, lock_sha256=lock_digest(), **identity)
        allowed = any({key: entry[key] for key in match} == match
                      and isinstance(entry.get("reason"), str) and entry["reason"].strip()
                      for entry in exceptions)
        (accepted if allowed else blocking).append(finding)
    return accepted, blocking


def analyze(profile, phase, output, exceptions, sample=None):
    output.mkdir(parents=True, exist_ok=True)
    raw = output / "native.json"
    raw.unlink(missing_ok=True)
    command = ["mix", "run", "--no-start", "scripts/dialyzer_analyze.exs", phase, str(raw)]
    if sample is not None:
        command.append(str(sample))
    evidence = dict(profile=profile, phase=phase, status="error", accepted=[], blocking=[], errors=[])
    start = time.monotonic()
    try:
        result = subprocess.run(command, cwd=ROOT, env={**os.environ, "MIX_ENV": profile},
                                capture_output=True, text=True, timeout=900)
        evidence["analyzer_exit_status"] = result.returncode
        report = json.loads(raw.read_text())
        if report.get("status") == "error":
            raise ValueError(report.get("error", "native-error") + ":" + report.get("exception", "native"))
        evidence["accepted"], evidence["blocking"] = classify(
            report, result.returncode, profile, phase, exceptions)
        evidence["files"] = report["files"]
        evidence["status"] = "findings" if evidence["blocking"] else "passed"
    except (OSError, ValueError, subprocess.SubprocessError, KeyError, TypeError) as error:
        evidence["errors"].append(str(error) if type(error) is ValueError else type(error).__name__)
    evidence["seconds"] = round(time.monotonic() - start, 2)
    (output / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    print(f"Dialyzer {profile}/{phase}: {evidence['status']}; "
          f"accepted={len(evidence['accepted'])} blocking={len(evidence['blocking'])}; "
          f"errors={','.join(evidence['errors'])}")
    for finding in evidence["blocking"]:
        print(f"{finding['file']}:{finding['line']}: {finding['kind']}")
    return 0 if evidence["status"] == "passed" else 1


def prepare(profile, output):
    output.mkdir(parents=True, exist_ok=True)
    raw = output / f"{profile}-prepare-native.json"
    raw.unlink(missing_ok=True)
    start = time.monotonic()
    status = 1
    error = None
    try:
        with (output / f"{profile}-prepare.log").open("w") as log:
            result = subprocess.run(
                ["mix", "run", "--no-start", "scripts/dialyzer_analyze.exs", "prepare", str(raw)],
                cwd=ROOT, env={**os.environ, "MIX_ENV": profile}, stdout=log,
                stderr=subprocess.STDOUT, timeout=900)
        status = result.returncode
        if status == 0 and json.loads(raw.read_text()) != {"status": "prepared"}:
            status, error = 1, "incomplete-preparation"
    except (OSError, ValueError, subprocess.SubprocessError) as failure:
        status = 1
        error = type(failure).__name__
    return dict(prepare_exit=status, prepare_seconds=round(time.monotonic() - start, 2),
                error=error)


def main():
    if sys.argv[1:] == ["cache-key"]:
        print(cache_key())
        return 0
    if sys.argv[1:]:
        raise SystemExit("usage: dialyzer_ci.py [cache-key]")
    output = ROOT / "tmp/dialyzer-ci"
    output.mkdir(parents=True, exist_ok=True)
    exceptions = json.loads((ROOT / "scripts/dialyzer_exceptions.json").read_text())
    summary = dict(cache_key=cache_key(), versions=VERSIONS, profiles={},
                   plt_files_before=sorted(p.relative_to(ROOT).as_posix()
                                           for p in (ROOT / "tmp/dialyzer").rglob("*.plt")),
                   hosted_cache_hit=os.environ.get("DIALYZER_CACHE_HIT", "not-measured"),
                   dirty=bool(subprocess.run(["git", "status", "--porcelain"], cwd=ROOT,
                                             capture_output=True, check=True).stdout),
                   revision=subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT,
                                           capture_output=True, text=True, check=True).stdout.strip())
    failed = False
    for profile in ("dev", "test"):
        preparation = prepare(profile, output)
        summary["profiles"][profile] = preparation
        if preparation["prepare_exit"]:
            failed = True
            continue
        for phase in ("model", "application"):
            failed = bool(analyze(profile, phase, output / profile / phase, exceptions)) or failed
    summary["status"] = "failed" if failed else "passed"
    (output / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
    return int(failed)


if __name__ == "__main__":
    sys.exit(main())
