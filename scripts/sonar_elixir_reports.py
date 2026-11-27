#!/usr/bin/env python3
"""Generate Sonar Generic Issue (Credo + Sobelow) and Generic Coverage XML reports for Elixir."""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT / "tmp/sonar-elixir"

sys.path.insert(0, str(Path(__file__).resolve().parent))
import sobelow_ci
import sonar_elixir_probe

CREDO_CATEGORY_MAP = {
    "warning": ("RELIABILITY", "LOGICAL"),
    "consistency": ("MAINTAINABILITY", "CONVENTIONAL"),
    "readability": ("MAINTAINABILITY", "CLEAR"),
    "refactor": ("MAINTAINABILITY", "MODULAR"),
    "design": ("MAINTAINABILITY", "MODULAR"),
}

SOBELOW_SEVERITY_MAP = {
    "high_confidence": "HIGH",
    "medium_confidence": "MEDIUM",
    "low_confidence": "LOW",
}


def slugify(value):
    return re.sub(r"[^a-z0-9]+", "_", value.lower()).strip("_") or "finding"


def credo_severity(priority):
    if isinstance(priority, int):
        if priority >= 20:
            return "HIGH"
        if priority >= 10:
            return "MEDIUM"
    return "LOW"


def normalize_relative_path(raw_path):
    if not isinstance(raw_path, str) or not raw_path:
        return None
    if Path(raw_path).is_absolute():
        return None
    normalized = raw_path
    while normalized.startswith("./"):
        normalized = normalized.removeprefix("./")
    if not normalized or ".." in Path(normalized).parts or Path(normalized).is_absolute():
        return None
    return normalized


def convert_credo_issues(payload, allowed_prefix="lib/"):
    raw_issues = payload.get("issues") if isinstance(payload, dict) else None
    if not isinstance(raw_issues, list):
        raise ValueError("invalid-credo-json")

    rules = {}
    issues = []
    for item in raw_issues:
        if not isinstance(item, dict):
            continue
        file_path = normalize_relative_path(item.get("filename"))
        if not file_path or not file_path.startswith(allowed_prefix):
            continue
        check = str(item.get("check") or "Credo.Check")
        category = str(item.get("category") or "readability").lower()
        message = str(item.get("message") or check)
        line = item.get("line_no")
        line_no = line if type(line) is int and line >= 1 else 1
        quality, attribute = CREDO_CATEGORY_MAP.get(category, ("MAINTAINABILITY", "CONVENTIONAL"))
        severity = credo_severity(item.get("priority"))
        rule_id = f"credo:{slugify(check)}"

        rules.setdefault(
            rule_id,
            {
                "id": rule_id,
                "name": check,
                "description": f"Credo static analysis rule: {check} ({category}).",
                "engineId": "credo",
                "cleanCodeAttribute": attribute,
                "impacts": [{"softwareQuality": quality, "severity": severity}],
            },
        )
        issues.append(
            {
                "ruleId": rule_id,
                "primaryLocation": {
                    "message": message,
                    "filePath": file_path,
                    "textRange": {"startLine": line_no},
                },
            }
        )
    return rules, issues


def convert_sobelow_issues(report, sources=None, include_accepted=False, allowed_prefix="lib/"):
    findings = sobelow_ci.validate_report(report)
    findings = sobelow_ci.normalize_finding_paths(findings, ROOT)
    if include_accepted or sources is None:
        selected = findings
    else:
        _accepted, selected = sobelow_ci.classify(findings, sources)

    rules = {}
    issues = []
    for item in selected:
        file_path = normalize_relative_path(item.get("file"))
        if not file_path or not file_path.startswith(allowed_prefix):
            continue
        finding_type = str(item["type"])
        confidence = str(item["confidence"])
        severity = SOBELOW_SEVERITY_MAP.get(confidence, "LOW")
        line = item["line"]
        line_no = line if type(line) is int and line >= 1 else 1
        rule_id = f"sobelow:{slugify(finding_type)}"

        rules.setdefault(
            rule_id,
            {
                "id": rule_id,
                "name": finding_type,
                "description": f"Sobelow Elixir/Phoenix security rule: {finding_type}.",
                "engineId": "sobelow",
                "cleanCodeAttribute": "TRUSTWORTHY",
                "impacts": [{"softwareQuality": "SECURITY", "severity": severity}],
            },
        )
        issues.append(
            {
                "ruleId": rule_id,
                "primaryLocation": {
                    "message": f"{finding_type} ({confidence})",
                    "filePath": file_path,
                    "textRange": {"startLine": line_no},
                },
            }
        )
    return rules, issues


def merge_generic_issues(credo_payload, sobelow_payload, sources=None, include_accepted=False):
    c_rules, c_issues = convert_credo_issues(credo_payload)
    s_rules, s_issues = convert_sobelow_issues(
        sobelow_payload, sources=sources, include_accepted=include_accepted
    )
    all_rules = {**c_rules, **s_rules}
    ordered_rules = [all_rules[key] for key in sorted(all_rules)]
    return {"rules": ordered_rules, "issues": c_issues + s_issues}


def run_credo_json():
    env = {**os.environ, "MIX_ENV": "test"}
    proc = subprocess.run(
        ["mix", "credo", "--format", "json"],
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
        timeout=180,
    )
    if not proc.stdout.strip():
        raise ValueError(f"credo-empty-output (exit={proc.returncode})")
    return json.loads(proc.stdout)


def run_sobelow_json():
    env = {**os.environ, "MIX_ENV": "test"}
    proc = subprocess.run(
        sobelow_ci.COMMAND,
        cwd=ROOT,
        env=env,
        capture_output=True,
        text=True,
        timeout=180,
    )
    if not proc.stdout.strip():
        raise ValueError(f"sobelow-empty-output (exit={proc.returncode})")
    return json.loads(proc.stdout)


def ensure_safe_output(output_dir):
    output = Path(output_dir)
    if not output.is_absolute():
        output = ROOT / output
    output = Path(os.path.abspath(output))
    tmp_root = Path(os.path.abspath(ROOT / "tmp"))
    if not output.is_relative_to(tmp_root):
        raise ValueError("output-must-be-under-tmp")
    output.mkdir(parents=True, exist_ok=True)
    return output


def write_issues(output_dir, include_accepted=False):
    output = ensure_safe_output(output_dir)
    credo_payload = run_credo_json()
    sobelow_payload = run_sobelow_json()
    sources = sobelow_ci.snapshot(ROOT)
    merged = merge_generic_issues(
        credo_payload, sobelow_payload, sources=sources, include_accepted=include_accepted
    )
    target = output / "external-issues.json"
    target.write_text(json.dumps(merged, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(
        f"SONAR_ELIXIR_ISSUES status=ok rules={len(merged['rules'])} "
        f"issues={len(merged['issues'])} path={target.relative_to(ROOT).as_posix()}"
    )
    return target


def write_coverage(output_dir):
    output = ensure_safe_output(output_dir)
    sonar_elixir_probe.verify_coverage()
    status = sonar_elixir_probe.read_json(sonar_elixir_probe.STATUS)
    report_file = sonar_elixir_probe.report_path(status)
    report = json.loads(report_file.read_bytes())
    xml_text = sonar_elixir_probe.render_coverage(report)
    target = output / "coverage.xml"
    target.write_text(xml_text, encoding="utf-8")
    print(
        f"SONAR_ELIXIR_COVERAGE status=ok files={len(report.get('included', []))} "
        f"path={target.relative_to(ROOT).as_posix()}"
    )
    return target


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    for name in ("issues", "coverage", "all"):
        p = sub.add_parser(name)
        p.add_argument("--output", default=str(DEFAULT_OUTPUT))
        if name in ("issues", "all"):
            p.add_argument(
                "--include-accepted",
                action="store_true",
                help="Include reviewed Sobelow exceptions as informational findings.",
            )
    args = parser.parse_args(argv)
    if args.command == "issues":
        write_issues(args.output, include_accepted=args.include_accepted)
    elif args.command == "coverage":
        write_coverage(args.output)
    else:
        write_issues(args.output, include_accepted=args.include_accepted)
        write_coverage(args.output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
