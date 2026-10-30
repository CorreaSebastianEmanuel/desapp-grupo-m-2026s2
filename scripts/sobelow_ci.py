#!/usr/bin/env python3
"""Required offline Sobelow control. Policy and exceptions: TASK-074 spec.md."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
VERSION = "0.18.1"
COMMAND = ["mix", "sobelow", "--private", "--no-config", "--strict",
           "--format", "json", "--exit", "low", "--threshold", "low", "--summary"]
LEVELS = ("high_confidence", "medium_confidence", "low_confidence")
# Exact findings on reviewed source bytes; changes require fresh individual triage.
EXCEPTIONS = [
    {
        "type": "Config.CSP: Missing Content-Security-Policy",
        "file": "lib/football_market_web/router.ex",
        "line": 11,
        "confidence": "high_confidence",
        "sha256": "a15f9f96845fd846169676c389471bdc0b160830c4a3f89d0f558fa406bb2ab8"
    },
    {
        "type": "SQL.Query: SQL injection",
        "file": "lib/football_market/catalog.ex",
        "line": 183,
        "confidence": "low_confidence",
        "sha256": "f3217180b5eacfa44e531f69a66e2c48d71edb89d247a2fa2b68b1da8055c6a4"
    },
    {
        "type": "DOS.StringToAtom: Unsafe `String.to_atom`",
        "file": "lib/football_market/quotes.ex",
        "line": 387,
        "confidence": "low_confidence",
        "sha256": "19919db18bc88da2525814a3280ea278482292a18f26e0d129a869607ce741e2"
    },
    {
        "type": "SQL.Query: SQL injection",
        "file": "lib/football_market/quotes/membership.ex",
        "line": 194,
        "confidence": "low_confidence",
        "sha256": "bffa364a8de8551773f7ec4ebe0eb1b036d3c56962a7a31d3bae0570eddd3f46"
    },
    {
        "type": "SQL.Query: SQL injection",
        "file": "lib/football_market/quotes/membership.ex",
        "line": 218,
        "confidence": "low_confidence",
        "sha256": "bffa364a8de8551773f7ec4ebe0eb1b036d3c56962a7a31d3bae0570eddd3f46"
    },
    {
        "type": "Traversal.FileModule: Directory Traversal in `File.read`",
        "file": "lib/football_market/statistics/ingestion/publisher.ex",
        "line": 333,
        "confidence": "low_confidence",
        "sha256": "2745d6bed95ad8dea1b76c3725f6a1b7de577e0cc20b03c028f7d2119e5f5cca"
    },
    {
        "type": "Traversal.FileModule: Directory Traversal in `File.read`",
        "file": "lib/football_market/synchronization/input.ex",
        "line": 116,
        "confidence": "low_confidence",
        "sha256": "36346a165a98349c7f95e05cd5202ed3e4f61a6f72c357e0c0556950bcb24fdc"
    },
    {
        "type": "XSS.HTML: XSS in `html`",
        "file": "lib/football_market_web/controllers/session_controller.ex",
        "line": 152,
        "confidence": "medium_confidence",
        "sha256": "2cbf9f169fd24af921e2faea946702afd92f966334448f438cfa4ccc6139f556"
    }
]


def validate_report(report):
    if not isinstance(report, dict) or set(report) != {"findings", "sobelow_version", "total_findings"}:
        raise ValueError("invalid-report-shape")
    if report["sobelow_version"] != VERSION:
        raise ValueError("unexpected-analyzer-version")
    groups = report["findings"]
    if not isinstance(groups, dict) or set(groups) != set(LEVELS):
        raise ValueError("invalid-confidence-groups")
    findings = []
    for level in LEVELS:
        if not isinstance(groups[level], list):
            raise ValueError("invalid-findings-list")
        for finding in groups[level]:
            if (not isinstance(finding, dict)
                    or not {"type", "file", "line"} <= finding.keys()
                    or not isinstance(finding["type"], str) or not finding["type"]
                    or not isinstance(finding["file"], str) or not finding["file"]
                    or type(finding["line"]) is not int or finding["line"] < 0):
                raise ValueError("invalid-finding-metadata")
            findings.append({**finding, "confidence": level})
    if type(report["total_findings"]) is not int or report["total_findings"] != len(findings):
        raise ValueError("invalid-finding-total")
    return findings


def validate_summary(stderr):
    match = re.fullmatch(
        r"Scan summary: discovered: (\d+), scanned: (\d+), ignored: (\d+), "
        r"unreadable: (\d+), unparseable: (\d+), pending: (\d+)\n?", stderr)
    if not match:
        raise ValueError("missing-summary-or-analyzer-diagnostics")
    discovered, scanned, ignored, unreadable, unparseable, pending = map(int, match.groups())
    # Sobelow itself ignores dev/test config. No user exclusions are permitted.
    if not scanned or unreadable or unparseable or pending or discovered != scanned + ignored:
        raise ValueError("incomplete-scan")
    return dict(zip(("discovered", "scanned", "ignored", "unreadable", "unparseable", "pending"),
                    map(int, match.groups())))


def snapshot(root):
    files = [root / "mix.exs", root / "mix.lock"]
    files += [p for folder in ("lib", "config") for p in (root / folder).rglob("*") if p.is_file()]
    return {p.relative_to(root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(files) if p.is_file()}


def classify(findings, sources):
    accepted, blocking = [], []
    for finding in findings:
        identity = {key: finding[key] for key in ("type", "file", "line", "confidence")}
        identity["sha256"] = sources.get(finding["file"])
        (accepted if identity in EXCEPTIONS else blocking).append(finding)
    return accepted, blocking


def analyze(root, output):
    evidence = {"status": "failed", "sobelow_version": VERSION, "command": COMMAND,
                "errors": [], "accepted": [], "blocking": []}
    try:
        if any((root / name).exists() or (root / name).is_symlink()
               for name in (".sobelow-conf", ".sobelow-skips")):
            raise ValueError("project-sobelow-configuration-not-permitted")
        before = snapshot(root)
        evidence["source_digest"] = hashlib.sha256(json.dumps(before, sort_keys=True).encode()).hexdigest()
        result = subprocess.run(COMMAND + ["--root", os.path.relpath(root, ROOT)], cwd=ROOT,
                                env={**os.environ, "MIX_ENV": "test"},
                                capture_output=True, text=True, timeout=120)
        evidence["analyzer_exit_status"] = result.returncode
        findings = validate_report(json.loads(result.stdout))
        # Sobelow normalizes paths against an empty root and strips the leading slash.
        # Bind only exact known root-relative paths; never accept arbitrary suffix matches.
        prefix = str(root.resolve()).lstrip("/") + "/"
        relative_prefix = os.path.relpath(root, ROOT).rstrip("/") + "/"
        for finding in findings:
            for candidate in (prefix, relative_prefix):
                if finding["file"].startswith(candidate):
                    finding["file"] = finding["file"][len(candidate):]
                    break
        evidence["scan"] = validate_summary(result.stderr)
        if result.returncode != (1 if findings else 0):
            raise ValueError("unexpected-analyzer-exit-status")
        if before != snapshot(root):
            raise ValueError("source-changed-during-scan")
        evidence["accepted"], evidence["blocking"] = classify(findings, before)
        if evidence["blocking"]:
            evidence["errors"].append("unaccepted-security-findings")
        else:
            evidence["status"] = "passed"
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        # No source excerpts, raw process output, environment or secret values in artifacts.
        evidence["errors"].append(str(error) if type(error) is ValueError else type(error).__name__)
    revision = subprocess.run(["git", "rev-parse", "HEAD"], cwd=ROOT,
                              capture_output=True, text=True, check=True).stdout.strip()
    evidence["revision"] = revision
    evidence["trigger_revision"] = os.environ.get("GITHUB_SHA", revision)
    evidence["dirty"] = bool(subprocess.run(
        ["git", "status", "--porcelain"], cwd=ROOT, capture_output=True, check=True).stdout)
    output.mkdir(parents=True, exist_ok=True)
    (output / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")
    for finding in evidence["blocking"]:
        print(f"{finding['file']}:{finding['line']}: {finding['type']} ({finding['confidence']})")
    print(f"Sobelow {VERSION}: {evidence['status']}; "
          f"accepted={len(evidence['accepted'])}, blocking={len(evidence['blocking'])}; "
          f"errors={','.join(evidence['errors'])}")
    return 0 if evidence["status"] == "passed" else 1


def main():
    if len(sys.argv) != 1:
        raise SystemExit("sobelow_ci.py takes no arguments")
    output = ROOT / "tmp/sobelow-ci"
    if output.is_symlink() or output.parent.is_symlink():
        raise SystemExit("Sobelow output must not be a symlink")
    return analyze(ROOT, output)


if __name__ == "__main__":
    sys.exit(main())
