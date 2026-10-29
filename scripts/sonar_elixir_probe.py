#!/usr/bin/env python3
"""Build isolated generic SonarCloud reports for the TASK-069 probe."""

import argparse
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
from urllib.parse import urlencode
from urllib.request import Request, urlopen
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
    report_bytes = report_file.read_bytes()
    report = json.loads(report_bytes)
    inventory = read_json(INVENTORY)
    issue, source_path, source_line = render_issue(inventory, report)
    coverage = render_coverage(report)
    revision = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    if report.get("head") != revision:
        raise ValueError("application-coverage-revision-mismatch")

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
    (output / "application-coverage.json").write_bytes(report_bytes)
    metadata = {
        "schema_version": 1,
        "task": "TASK-069",
        "revision": revision,
        "coverage_source_revision": report["head"],
        "coverage_run_id": report["run_id"],
        "coverage_snapshot_digest": report["snapshot_digest"],
        "application_coverage_report_sha256": hashlib.sha256(report_bytes).hexdigest(),
        "source_path": source_path,
        "source_line": source_line,
        "external_issue_sha256": hashlib.sha256(issue.encode()).hexdigest(),
        "coverage_report_sha256": hashlib.sha256(coverage.encode()).hexdigest(),
    }
    (output / "probe.json").write_text(json.dumps(metadata, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return output


def validate_dispatch(repository, ref, sha, pull_request, pr_document):
    expected_ref = "refs/heads/069-verify-sonarcloud-external-elixir-report-compatibility"
    if (not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository)
            or ref != expected_ref or not re.fullmatch(r"[0-9a-f]{40}", sha)
            or not re.fullmatch(r"[1-9][0-9]*", str(pull_request))):
        raise ValueError("probe-dispatch-refused")
    if not isinstance(pr_document, dict):
        raise ValueError("probe-pull-request-mismatch")
    head, base = pr_document.get("head", {}), pr_document.get("base", {})
    if not isinstance(head, dict) or not isinstance(base, dict):
        raise ValueError("probe-pull-request-mismatch")
    head_repo = head.get("repo") if isinstance(head.get("repo"), dict) else {}
    base_repo = base.get("repo") if isinstance(base.get("repo"), dict) else {}
    if (pr_document.get("state") != "open"
            or base_repo.get("full_name") != repository or base.get("ref") != "main"
            or head_repo.get("full_name") != repository
            or head.get("ref") != expected_ref.removeprefix("refs/heads/")
            or head.get("sha") != sha):
        raise ValueError("probe-pull-request-mismatch")
    return {"repository": repository, "pull_request": int(pull_request), "revision": sha}


def github_pr(repository, pull_request):
    request = Request(f"https://api.github.com/repos/{repository}/pulls/{pull_request}", headers={
        "Accept": "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28"})
    with urlopen(request, timeout=10) as response:
        return json.loads(response.read())


METRICS = ("open_issues", "bugs", "vulnerabilities", "code_smells", "coverage", "ncloc")
PROJECT = "CorreaSebastianEmanuel_desapp-grupo-m-2026s2"


class SonarApi:
    def __init__(self, token):
        self.token = token

    def get(self, path, params):
        credentials = base64.b64encode((self.token + ":").encode()).decode()
        request = Request("https://sonarcloud.io" + path + "?" + urlencode(params), headers={
            "Authorization": "Basic " + credentials, "Accept": "application/json"})
        with urlopen(request, timeout=15) as response:
            return json.loads(response.read())


def unverified(reason):
    return {"status": "unverified", "reason": reason}


def verify_current_analysis(api, task_id, analysis_id, pull_request, revision):
    pr_doc = api.get("/api/project_pull_requests/list", {"project": PROJECT})
    pull_requests = pr_doc.get("pullRequests") if isinstance(pr_doc, dict) else None
    if not isinstance(pull_requests, list):
        raise ValueError("pull-request-list-response-invalid")
    matched = [row for row in pull_requests
               if isinstance(row, dict) and row.get("key") == str(pull_request)]
    commit = matched[0].get("commit") if len(matched) == 1 else None
    if not isinstance(commit, dict) or commit.get("sha") != revision:
        raise ValueError("analysis-revision-mismatch")
    context_doc = api.get("/api/ce/component", {"component": PROJECT, "pullRequest": pull_request})
    current = context_doc.get("current") if isinstance(context_doc, dict) else None
    if (not isinstance(current, dict) or current.get("id") != task_id
            or current.get("analysisId") != analysis_id or current.get("status") != "SUCCESS"
            or current.get("componentKey") != PROJECT
            or current.get("pullRequest") != str(pull_request)):
        raise ValueError("analysis-task-not-current-for-pr")
    return matched[0].get("analysisDate")


def observe(stage, pull_request, revision, report_task, scan_outcome, token, baseline=None, api=None):
    result = {"schema_version": 1, "task": "TASK-069", "stage": stage,
              "pull_request": int(pull_request), "revision": revision, "scan_outcome": scan_outcome,
              "analysis": unverified("missing-analysis-identity"),
              "issue": unverified("analysis-unavailable"),
              "measures": {key: unverified("analysis-unavailable") for key in METRICS}}
    if not token:
        result["analysis"] = unverified("sonar-token-unavailable")
        return result
    try:
        task_text = Path(report_task).read_text(encoding="utf-8")
        props = dict(line.split("=", 1) for line in task_text.splitlines() if "=" in line)
        task_id = props.get("ceTaskId", "")
        if not re.fullmatch(r"[A-Za-z0-9_-]+", task_id):
            raise ValueError("missing-ce-task-id")
        api = api or SonarApi(token)
        ce_document = api.get("/api/ce/task", {"id": task_id})
        ce = ce_document.get("task") if isinstance(ce_document, dict) else None
        if not isinstance(ce, dict):
            raise ValueError("analysis-task-response-invalid")
        analysis_id = ce.get("analysisId")
        if (ce.get("status") != "SUCCESS" or not isinstance(analysis_id, str) or not analysis_id
                or ce.get("id") != task_id or ce.get("componentKey") != PROJECT):
            raise ValueError("analysis-task-not-successful")
        analysis_date = verify_current_analysis(api, task_id, analysis_id, pull_request, revision)
        result["analysis"] = {"status": "verified", "ce_task_id": task_id,
                              "analysis_id": analysis_id, "revision": revision,
                              "date": analysis_date}
    except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as error:
        result["analysis"] = unverified(str(error) or "analysis-observation-failed")
    if result["analysis"]["status"] == "verified":
        for key in METRICS:
            try:
                measures_doc = api.get("/api/measures/component", {
                    "component": PROJECT, "pullRequest": pull_request, "metricKeys": key})
                component = measures_doc.get("component") if isinstance(measures_doc, dict) else None
                if not isinstance(component, dict) or component.get("key") != PROJECT:
                    raise ValueError("measure-response-invalid")
                rows = component.get("measures", [])
                if not isinstance(rows, list):
                    raise ValueError("measure-response-invalid")
                found = [row for row in rows if isinstance(row, dict) and row.get("metric") == key]
                value = found[0].get("value") if len(found) == 1 else None
                period_index = None
                if not isinstance(value, str) and len(found) == 1:
                    periods = found[0].get("periods")
                    if isinstance(periods, list):
                        period_values = [(index, period.get("value")) for index, period in enumerate(periods)
                                         if isinstance(period, dict) and isinstance(period.get("value"), str)]
                        if len(period_values) == 1:
                            period_index, value = period_values[0]
                if isinstance(value, str):
                    result["measures"][key] = {"status": "observed", "value": value}
                    if period_index is not None:
                        result["measures"][key]["period_index"] = period_index
                else:
                    result["measures"][key] = unverified("measure-missing-or-ambiguous")
            except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as error:
                result["measures"][key] = unverified(str(error) or "measure-observation-failed")
        try:
            issue_doc = api.get("/api/issues/search", {
                "componentKeys": PROJECT, "pullRequest": pull_request, "ps": 500,
                "additionalFields": "_all"})
            issues = issue_doc.get("issues") if isinstance(issue_doc, dict) else None
            if isinstance(issues, list):
                count = sum(1 for item in issues if isinstance(item, dict)
                            and "TASK-069 controlled probe" in str(item.get("message", "")))
                result["issue"] = {"status": "observed" if count == 1 else "not_observed",
                                    "matching_issues": count,
                                    "note": "not_observed is inconclusive when indexing or PR filtering is unverified"}
            else:
                result["issue"] = unverified("issue-search-response-invalid")
        except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as error:
            result["issue"] = unverified(str(error) or "issue-observation-failed")
        try:
            verify_current_analysis(api, task_id, analysis_id, pull_request, revision)
        except (OSError, ValueError, KeyError, TypeError, json.JSONDecodeError) as error:
            result["analysis"] = unverified(str(error) or "analysis-observation-failed")
            result["issue"] = unverified("analysis-changed-or-unavailable-during-observation")
            result["measures"] = {
                key: unverified("analysis-changed-or-unavailable-during-observation") for key in METRICS}
    if stage != "control":
        comparable = (isinstance(baseline, dict) and baseline.get("stage") == "control"
                      and baseline.get("revision") == revision
                      and type(baseline.get("pull_request")) is int
                      and baseline["pull_request"] == int(pull_request)
                      and isinstance(baseline.get("analysis"), dict)
                      and baseline["analysis"].get("status") == "verified"
                      and baseline["analysis"].get("revision") == revision
                      and result["analysis"]["status"] == "verified")
        for key in METRICS:
            current = result["measures"][key]
            prior_measures = baseline.get("measures") if isinstance(baseline, dict) else None
            prior = prior_measures.get(key, {}) if isinstance(prior_measures, dict) else {}
            if comparable and current.get("status") == "observed" and prior.get("status") == "observed":
                current["comparison"] = "changed" if current["value"] != prior["value"] else "no_change"
            else:
                current["comparison"] = "unverified"
    return result


def write_observation(args):
    baseline = read_json(Path(args.baseline)) if args.baseline else None
    result = observe(args.stage, args.pull_request, args.revision, args.report_task,
                     args.scan_outcome, os.environ.get("SONAR_TOKEN", ""), baseline)
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"TASK-069 {args.stage} observation: {result['analysis']['status']}")


def parse_args(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command")
    build_parser = commands.add_parser("build")
    build_parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    guard = commands.add_parser("guard")
    guard.add_argument("--repository", required=True)
    guard.add_argument("--ref", required=True)
    guard.add_argument("--sha", required=True)
    guard.add_argument("--pull-request", required=True)
    observe_parser = commands.add_parser("observe")
    observe_parser.add_argument("--stage", choices=("control", "issue", "coverage"), required=True)
    observe_parser.add_argument("--pull-request", required=True)
    observe_parser.add_argument("--revision", required=True)
    observe_parser.add_argument("--report-task", required=True)
    observe_parser.add_argument("--scan-outcome", required=True)
    observe_parser.add_argument("--baseline")
    observe_parser.add_argument("--output", required=True)
    return parser.parse_args(argv)


def main(argv=None):
    try:
        args = parse_args(sys.argv[1:] if argv is None else argv)
        if args.command in (None, "build"):
            output = build(args.output)
        elif args.command == "guard":
            if not re.fullmatch(r"[1-9][0-9]*", args.pull_request):
                raise ValueError("probe-dispatch-refused")
            validate_dispatch(args.repository, args.ref, args.sha, args.pull_request,
                              github_pr(args.repository, args.pull_request))
            print("TASK-069 dispatch identity verified")
            return 0
        else:
            write_observation(args)
            return 0
    except (OSError, ValueError, json.JSONDecodeError, subprocess.CalledProcessError, AttributeError) as error:
        print(f"TASK-069 probe generation failed: {error}", file=sys.stderr)
        return 1
    print(f"TASK-069 probe reports written under {output.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
