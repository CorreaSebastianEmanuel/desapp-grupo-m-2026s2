#!/usr/bin/env python3
"""Build isolated generic SonarCloud reports for the TASK-069 probe."""

import argparse
import hashlib
import json
import os
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = ROOT / "tmp/sonar-elixir-probe"
STATUS = ROOT / "cover/application/status.json"
INVENTORY = ROOT / "config/credo_inventory.json"


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"))


def safe_int(value):
    return type(value) is int and value >= 0


def coverage_files(report):
    if not isinstance(report, dict) or report.get("schema_version") != 1 or report.get("status") != "complete":
        raise ValueError("invalid-application-coverage-report")

    included = report.get("included")
    if not isinstance(included, list) or not included:
        raise ValueError("application-coverage-has-no-included-files")

    seen_paths = set()
    files = []
    for item in included:
        if not isinstance(item, dict):
            raise ValueError("invalid-application-coverage-file")
        path = item.get("path")
        executable = item.get("executable_lines")
        covered = item.get("covered_lines")
        if (not isinstance(path, str) or not path.startswith("lib/") or ".." in Path(path).parts
                or path in seen_paths or not isinstance(executable, list) or not isinstance(covered, list)):
            raise ValueError("invalid-application-coverage-file")
        seen_paths.add(path)
        if (any(not safe_int(line) or line == 0 for line in executable + covered)
                or len(set(executable)) != len(executable) or len(set(covered)) != len(covered)
                or not set(covered).issubset(executable)):
            raise ValueError("invalid-application-coverage-lines")
        files.append((path, executable, set(covered)))
    return files


def render_coverage(report):
    files = coverage_files(report)
    root = ET.Element("coverage", {"version": "1"})
    for path, executable, covered in files:
        file_node = ET.SubElement(root, "file", {"path": path})
        for line in executable:
            ET.SubElement(file_node, "lineToCover", {
                "lineNumber": str(line),
                "covered": "true" if line in covered else "false",
            })
    return ET.tostring(root, encoding="unicode", xml_declaration=True) + "\n"


def render_issue(inventory, report):
    maintained = inventory.get("maintained") if isinstance(inventory, dict) else None
    if not isinstance(maintained, list) or not maintained:
        raise ValueError("invalid-credo-inventory")
    coverage = coverage_files(report)
    maintained_set = set(maintained)
    source = next(((path, executable) for path, executable, _covered in coverage
                   if path in maintained_set and executable), None)
    if source is None:
        raise ValueError("no-covered-credo-source-for-probe")
    path, executable = source
    rule_id = "TASK-069-PROBE"
    report_data = {
        "rules": [{
            "id": rule_id,
            "name": "Controlled Credo external import probe",
            "description": "Synthetic issue used only to verify the generic external issue import path.",
            "engineId": "credo-task-069-probe",
            "cleanCodeAttribute": "CONVENTIONAL",
            "impacts": [{"softwareQuality": "MAINTAINABILITY", "severity": "INFO"}],
        }],
        "issues": [{
            "ruleId": rule_id,
            "primaryLocation": {
                "message": "TASK-069 controlled probe; this is not a Credo finding.",
                "filePath": path,
                "textRange": {"startLine": executable[0]},
            },
        }],
    }
    return json.dumps(report_data, indent=2, sort_keys=True) + "\n", path, executable[0]


def report_path(status):
    relative = status.get("report_path") if isinstance(status, dict) else None
    if not isinstance(relative, str) or Path(relative).is_absolute() or ".." in Path(relative).parts:
        raise ValueError("invalid-application-coverage-status")
    path = (STATUS.parent / relative).resolve()
    if not path.is_relative_to(STATUS.parent.resolve()) or not path.is_file():
        raise ValueError("application-coverage-report-missing")
    return path


def verify_coverage():
    result = subprocess.run(
        [sys.executable, str(ROOT / "scripts/application_coverage.py"), "validate"],
        cwd=ROOT, check=False, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True,
    )
    if result.returncode:
        raise ValueError("application-coverage-validation-failed")


def build(output):
    verify_coverage()
    if not INVENTORY.is_file() or INVENTORY.is_symlink():
        raise ValueError("credo-inventory-missing-or-unsafe")
    status = read_json(STATUS)
    report_file = report_path(status)
    report = read_json(report_file)
    inventory = read_json(INVENTORY)
    issue, source_path, source_line = render_issue(inventory, report)
    coverage = render_coverage(report)

    output = Path(output)
    if not output.is_absolute():
        output = ROOT / output
    output = Path(os.path.abspath(output))
    tmp_root = Path(os.path.abspath(ROOT / "tmp"))
    if not output.is_relative_to(tmp_root):
        raise ValueError("probe-output-must-be-under-tmp")
    current = output
    while current != tmp_root:
        if current.is_symlink():
            raise ValueError("probe-output-must-not-be-symlink")
        current = current.parent
    if tmp_root.is_symlink():
        raise ValueError("probe-output-must-not-be-symlink")
    output.mkdir(parents=True, exist_ok=True)

    (output / "external-issues.json").write_text(issue, encoding="utf-8")
    (output / "coverage.xml").write_text(coverage, encoding="utf-8")
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    metadata = {
        "schema_version": 1,
        "task": "TASK-069",
        "revision": revision,
        "coverage_source_revision": report["head"],
        "coverage_run_id": report["run_id"],
        "coverage_snapshot_digest": report["snapshot_digest"],
        "source_path": source_path,
        "source_line": source_line,
        "external_issue_sha256": hashlib.sha256(issue.encode()).hexdigest(),
        "coverage_report_sha256": hashlib.sha256(coverage.encode()).hexdigest(),
    }
    (output / "probe.json").write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return output


def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    return parser.parse_args(argv)


def main(argv=None):
    try:
        output = build(parse_args(sys.argv[1:] if argv is None else argv).output)
    except (OSError, ValueError, json.JSONDecodeError, subprocess.CalledProcessError) as error:
        print(f"TASK-069 probe generation failed: {error}", file=sys.stderr)
        return 1
    print(f"TASK-069 probe reports written under {output.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
