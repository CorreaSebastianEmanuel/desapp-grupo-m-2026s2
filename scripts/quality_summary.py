#!/usr/bin/env python3
"""Render validated existing quality evidence into the GitHub Actions summary."""
from contextlib import contextmanager
import hashlib
import html
import json
import math
import os
import re
from pathlib import Path
from urllib.parse import quote

ROOT = Path(__file__).resolve().parents[1]


class EvidenceError(ValueError):
    pass


def diagnostic_text(evidence):
    errors = evidence.get("errors", [])
    if not isinstance(errors, list) or any(not isinstance(value, str) for value in errors):
        raise EvidenceError("invalid-diagnostics")
    return ", ".join(errors)


def table_text(value):
    return re.sub(r"[\r\n]+", " ", str(value)).replace("|", "\\|")[:300]


def read_json(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError("duplicate-key")
            result[key] = value
        return result

    try:
        value = json.loads(Path(path).read_text(encoding="utf-8"), object_pairs_hook=unique)
    except (OSError, UnicodeError, json.JSONDecodeError, ValueError):
        raise EvidenceError("missing-or-malformed-report") from None
    if not isinstance(value, dict):
        raise EvidenceError("invalid-report-shape")
    return value


def outcome(evidence):
    if not isinstance(evidence, dict):
        raise EvidenceError("invalid-report-shape")
    status = evidence.get("status")
    if status == "passed":
        return "Approved"
    if status == "findings":
        return "Failed due to findings"
    if status == "error":
        return "Analyzer execution/configuration error"
    if status == "failed":
        errors = diagnostic_text(evidence).split(", ")
        if errors and set(errors) <= {
                "standard-credo-cli-failed", "unaccepted-security-findings"}:
            return "Failed due to findings"
        return "Analyzer execution/configuration error"
    raise EvidenceError("unknown-analyzer-outcome")


def finding_link(server, repository, revision, finding):
    if not isinstance(finding, dict):
        raise EvidenceError("invalid-finding-shape")
    path, line = finding.get("file"), finding.get("line")
    if (not isinstance(path, str) or not path or "\\" in path or
            not re.fullmatch(r"[A-Za-z0-9_./-]+", path) or
            path.startswith("/") or ".." in Path(path).parts):
        raise EvidenceError("invalid-finding-path")
    if type(line) is not int or line < 1:
        line_text = "line unavailable"
        anchor = ""
    else:
        line_text = f"line {line}"
        anchor = f"#L{line}"
    url = (f"{server}/{repository}/blob/{revision}/"
           f"{quote(path, safe='/')}" + anchor)
    rule = finding.get("rule") or finding.get("type") or finding.get("kind")
    if not isinstance(rule, str) or not rule.strip():
        rule = "rule/warning kind unavailable"
    rule = re.sub(r"[\r\n]+", " ", rule).strip()[:160]
    return f"[{html.escape(path)}:{line_text}]({url}) — {html.escape(rule)}"


def findings_rows(rows, server, repository, revision):
    if not isinstance(rows, list):
        raise EvidenceError("invalid-findings-list")
    return [finding_link(server, repository, revision, row) for row in rows]


def render(env=None, root=ROOT):
    env = os.environ if env is None else env
    revision = env.get("QUALITY_REVISION") or env.get("GITHUB_SHA", "")
    server = env.get("GITHUB_SERVER_URL", "https://github.com").rstrip("/")
    repository = env.get("GITHUB_REPOSITORY", "")
    if len(revision) != 40 or any(ch not in "0123456789abcdef" for ch in revision.lower()):
        raise EvidenceError("invalid-revision")
    if not repository or "/" not in repository:
        raise EvidenceError("invalid-repository")

    rows = []
    details = []
    artifacts = []

    def add(name, status, version, scope, errors=""):
        rows.append((name, status, version, scope, errors or "—"))

    @contextmanager
    def section(name, report=None, version="—", version_key=None):
        row_start, detail_start = len(rows), len(details)
        try:
            yield
        except (EvidenceError, OSError) as error:
            del rows[row_start:]
            del details[detail_start:]
            diagnostics = [str(error) if isinstance(error, EvidenceError) else type(error).__name__]
            if isinstance(report, dict):
                if version_key and isinstance(report.get(version_key), str):
                    version = report[version_key]
                try:
                    diagnostics.append(diagnostic_text(report))
                except EvidenceError as invalid:
                    diagnostics.append(str(invalid))
            add(name, "Analyzer execution/configuration error", version,
                "scope unavailable or invalid", "; ".join(filter(None, diagnostics)))

    credo = {}
    with section("Credo", credo, version_key="credo_version"):
        credo_step = env.get("CREDO_OUTCOME", "skipped")
        credo_path = root / "tmp/credo-ci/evidence.json"
        if credo_step in ("success", "failure"):
            try:
                credo.update(read_json(credo_path))
            except EvidenceError:
                if credo_step == "success":
                    raise
                add("Credo", "Analyzer execution/configuration error", "—", "—", "required report unavailable")
                credo = None
            if credo is None:
                pass
            else:
                result = outcome(credo)
                if credo_step == "failure" and result == "Approved":
                    result = "Analyzer execution/configuration error"
                if credo.get("revision") != revision or credo.get("complete") is not True:
                    raise EvidenceError("stale-or-incomplete-credo-report")
                effective = credo.get("effective")
                if (not isinstance(effective, list) or not effective or
                        any(not isinstance(path, str) or not path for path in effective)):
                    raise EvidenceError("missing-credo-scope")
                if not isinstance(credo.get("credo_version"), str) or credo["credo_version"] == "unknown":
                    raise EvidenceError("missing-credo-version")
                if (type(credo.get("cli_exit_status")) is not int or
                        type(credo.get("oracle_exit_status")) is not int or
                        not isinstance(credo.get("source_digest"), str) or
                        not re.fullmatch(r"[0-9a-f]{64}", credo["source_digest"])):
                    raise EvidenceError("incomplete-credo-execution")
                cli_log = (root / "tmp/credo-ci/cli.log")
                found = []
                if cli_log.is_file():
                    for line in cli_log.read_text(errors="replace").splitlines():
                        # Native flycheck positions are optional; the tag is not a rule ID.
                        match = re.fullmatch(
                            r"(?P<file>[A-Za-z0-9_./-]+)(?::(?P<line>[0-9]+))?"
                            r"(?::[0-9]+)?: (?P<kind>[A-Za-z][A-Za-z -]*): .+", line)
                        if match:
                            rule = re.search(r"\[([A-Za-z][A-Za-z0-9_.]+)\]$", line)
                            found.append({"file": match["file"],
                                          "line": int(match["line"]) if match["line"] else None,
                                          "rule": rule[1] if rule else
                                          f"rule unavailable; warning kind {match['kind']}"})
                linked = findings_rows(found, server, repository, revision)
                details.extend(f"- {item}" for item in linked)
                if result == "Approved" and (credo["cli_exit_status"] != 0 or credo["oracle_exit_status"] != 0):
                    raise EvidenceError("credo-outcome-report-mismatch")
                if result == "Failed due to findings" and (not found or credo["oracle_exit_status"] != 0):
                    result = "Analyzer execution/configuration error"
                if result != "Approved" and not found:
                    details.append("- Credo findings: file, line, and rule metadata unavailable in retained output.")
                add("Credo", result, credo.get("credo_version", "version unavailable"),
                    f"{len(effective)} effective files ({credo.get('rule_level', 'rule level unavailable')})",
                    diagnostic_text(credo))
                if credo.get("credo_version"):
                    details.append(f"- Credo native version: `{credo['credo_version']}`; default-priority rules.")
        else:
            add("Credo", "Not executed/skipped" if credo_step == "skipped" else "Analyzer execution/configuration error",
                "—", "—", f"workflow step outcome: {credo_step}")

    sobelow = {}
    with section("Sobelow", sobelow, version_key="sobelow_version"):
        sobelow_step = env.get("SOBELOW_OUTCOME", "skipped")
        if sobelow_step in ("success", "failure"):
            try:
                sobelow.update(read_json(root / "tmp/sobelow-ci/evidence.json"))
            except EvidenceError:
                if sobelow_step == "success":
                    raise
                add("Sobelow", "Analyzer execution/configuration error", "—", "—", "required report unavailable")
                sobelow = None
            if sobelow is not None:
                if sobelow.get("revision") != revision or not isinstance(sobelow.get("scan"), dict):
                    raise EvidenceError("stale-or-incomplete-sobelow-report")
                if sobelow.get("sobelow_version") != "0.18.1":
                    raise EvidenceError("unexpected-sobelow-version")
                result = outcome(sobelow)
                if sobelow_step == "failure" and result == "Approved":
                    result = "Analyzer execution/configuration error"
                scan = sobelow["scan"]
                for count in ("discovered", "scanned", "ignored", "unreadable", "unparseable", "pending"):
                    if type(scan.get(count)) is not int or scan[count] < 0:
                        raise EvidenceError("incomplete-sobelow-scope")
                if (not scan["scanned"] or scan["discovered"] != scan["scanned"] + scan["ignored"] or
                        scan["unreadable"] or scan["unparseable"] or scan["pending"]):
                    raise EvidenceError("incomplete-sobelow-scope")
                blocking = sobelow.get("blocking")
                accepted = sobelow.get("accepted")
                if not isinstance(blocking, list) or not isinstance(accepted, list):
                    raise EvidenceError("incomplete-sobelow-findings")
                if (result == "Failed due to findings" and not blocking) or (result == "Approved" and blocking):
                    raise EvidenceError("sobelow-outcome-report-mismatch")
                add("Sobelow", result, sobelow.get("sobelow_version", "version unavailable"),
                    f"{scan.get('scanned', 'scope unavailable')} scanned Elixir files; {scan.get('ignored', 'unknown')} ignored",
                    diagnostic_text(sobelow))
                for kind in ("blocking", "accepted"):
                    findings = sobelow.get(kind, [])
                    details.extend(f"- {item}" for item in findings_rows(findings, server, repository, revision))
        else:
            add("Sobelow", "Not executed/skipped" if sobelow_step == "skipped" else "Analyzer execution/configuration error",
                "—", "—", f"workflow step outcome: {sobelow_step}")

    summary = {}
    with section("Dialyzer", summary):
        dialyzer_step = env.get("DIALYZER_OUTCOME", "skipped")
        if dialyzer_step in ("success", "failure"):
            summary.update(read_json(root / "tmp/dialyzer-ci/summary.json"))
            expected_versions = {"otp": "29.0.6", "elixir": "1.20.3",
                                 "dialyzer": "6.0.2", "dialyxir": "1.4.8"}
            if (summary.get("revision") != revision or summary.get("status") not in ("passed", "failed") or
                    (dialyzer_step == "success" and summary.get("status") != "passed") or
                    summary.get("versions") != expected_versions):
                raise EvidenceError("stale-or-incomplete-dialyzer-summary")
            if dialyzer_step == "failure":
                add("Dialyzer workflow step", "Failed", "Dialyzer 6.0.2 / Dialyxir 1.4.8",
                    "dev/test model and application phases", "workflow step outcome: failure")
            for profile in ("dev", "test"):
                for phase in ("model", "application"):
                    evidence = {}
                    with section(f"Dialyzer {profile}/{phase}", evidence, "Dialyzer 6.0.2 / Dialyxir 1.4.8"):
                        evidence.update(read_json(root / f"tmp/dialyzer-ci/{profile}/{phase}/evidence.json"))
                        result = outcome(evidence)
                        if type(evidence.get("files")) is not int or evidence["files"] < 1:
                            raise EvidenceError("incomplete-dialyzer-scope")
                        blocking = evidence.get("blocking")
                        accepted = evidence.get("accepted")
                        if not isinstance(blocking, list) or not isinstance(accepted, list):
                            raise EvidenceError("incomplete-dialyzer-findings")
                        if (result == "Failed due to findings" and not blocking) or (result == "Approved" and blocking):
                            raise EvidenceError("dialyzer-outcome-report-mismatch")
                        add(f"Dialyzer {profile}/{phase}", result, "Dialyzer 6.0.2 / Dialyxir 1.4.8",
                            f"{evidence.get('files', 'scope unavailable')} analyzed files",
                            diagnostic_text(evidence))
                        for kind in ("blocking", "accepted"):
                            details.extend(f"- {item}" for item in findings_rows(
                                evidence.get(kind, []), server, repository, revision))
        else:
            for profile in ("dev", "test"):
                for phase in ("model", "application"):
                    add(f"Dialyzer {profile}/{phase}",
                        "Not executed/skipped" if dialyzer_step == "skipped" else "Analyzer execution/configuration error",
                        "—", "—", f"workflow step outcome: {dialyzer_step}")

    with section("TASK-067 coverage"):
        coverage_path = root / "cover/application/status.json"
        coverage_outcome = env.get("APPLICATION_COVERAGE_OUTCOME", "skipped")
        if coverage_outcome == "success":
            status = read_json(coverage_path)
            if status.get("state") != "complete" or not isinstance(status.get("report_path"), str):
                raise EvidenceError("incomplete-coverage-status")
            relative = Path(status["report_path"])
            if relative.is_absolute() or ".." in relative.parts:
                raise EvidenceError("invalid-coverage-path")
            report_path = root / "cover/application" / relative
            if not report_path.resolve().is_relative_to((root / "cover/application").resolve()):
                raise EvidenceError("invalid-coverage-path")
            try:
                report_bytes = report_path.read_bytes()
            except OSError:
                raise EvidenceError("missing-coverage-report") from None
            if hashlib.sha256(report_bytes).hexdigest() != status.get("report_sha256"):
                raise EvidenceError("stale-coverage-report")
            try:
                report = json.loads(report_bytes)
            except json.JSONDecodeError:
                raise EvidenceError("malformed-coverage-report") from None
            if (not isinstance(report, dict) or report.get("head") != revision or
                    report.get("status") != "complete" or report.get("run_id") != status.get("run_id") or
                    report.get("snapshot_digest") != status.get("snapshot_digest")):
                raise EvidenceError("stale-or-incomplete-coverage-report")
            if (not re.fullmatch(r"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}",
                                 str(report.get("run_id"))) or
                    not re.fullmatch(r"[0-9a-f]{64}", str(report.get("snapshot_digest")))):
                raise EvidenceError("invalid-coverage-identity")
            totals = report.get("totals")
            included = report.get("included")
            if (not isinstance(totals, dict) or not isinstance(included, list) or not included or
                    any(not isinstance(file, dict) or not isinstance(file.get("path"), str) or
                        not file["path"] for file in included)):
                raise EvidenceError("invalid-coverage-report")
            if (any(type(totals.get(key)) is not int or totals[key] < 0
                    for key in ("covered", "uncovered", "executable")) or
                    totals["covered"] + totals["uncovered"] != totals["executable"] or
                    totals["executable"] < 1 or type(totals.get("percentage")) not in (int, float) or
                    not math.isfinite(totals["percentage"]) or not 0 <= totals["percentage"] <= 100 or
                    round(totals["covered"] * 100 / totals["executable"], 2) != totals["percentage"]):
                raise EvidenceError("invalid-coverage-counts")
            toolchain = report.get("toolchain")
            native_version = toolchain.get("elixir") if isinstance(toolchain, dict) else None
            if not isinstance(native_version, str) or not native_version.strip():
                raise EvidenceError("missing-coverage-toolchain")
            add("TASK-067 coverage", "Approved", native_version or "native version unavailable", f"{len(included)} application files",
                f"{totals.get('covered')}/{totals.get('executable')} executable lines; {totals.get('percentage')}%")
            details.append(f"- Coverage provenance: run `{report.get('run_id')}`, snapshot `{report.get('snapshot_digest')}`, "
                           f"{totals.get('uncovered')} uncovered lines. Coverage measures test execution, not bug absence.")
        else:
            coverage_status = "Not executed/skipped" if coverage_outcome == "skipped" else "Analyzer execution/configuration error"
            diagnostic = "no current report"
            if coverage_outcome == "failure" and coverage_path.is_file():
                failed = read_json(coverage_path)
                if failed.get("state") == "failed":
                    diagnostic = f"TASK-067 collector failed: {failed.get('error_category', 'category unavailable')}"
            add("TASK-067 coverage", coverage_status, "—", "no current report", diagnostic)

    value = env.get("UNIT_OUTCOME", "skipped")
    add("Audited unit/integration profile execution", "Approved" if value == "success" else
        "Not executed/skipped" if value == "skipped" else "Failed", "—", "existing audited profile receipts", value)
    receipt_outcome = env.get("PROFILE_RECEIPTS_OUTCOME", "skipped")
    add("Profile receipt verification", "Approved" if receipt_outcome == "success" else
        "Not executed/skipped" if receipt_outcome == "skipped" else "Failed", "—", "unit/integration receipt components", receipt_outcome)

    for label, outcome_key, url_key in (
            ("Credo evidence", "CREDO_ARTIFACT_OUTCOME", "CREDO_ARTIFACT_URL"),
            ("Sobelow evidence", "SOBELOW_ARTIFACT_OUTCOME", "SOBELOW_ARTIFACT_URL"),
            ("Dialyzer evidence", "DIALYZER_ARTIFACT_OUTCOME", "DIALYZER_ARTIFACT_URL"),
            ("TASK-067 coverage report", "COVERAGE_ARTIFACT_OUTCOME", "COVERAGE_ARTIFACT_URL")):
        artifact_outcome = env.get(outcome_key, "skipped")
        artifact_url = env.get(url_key, "")
        artifact_prefix = f"{server}/{repository}/actions/runs/"
        if artifact_outcome == "success" and artifact_url.startswith(artifact_prefix) and not re.search(r"\s", artifact_url):
            add(f"Retained report: {label}", "Approved", "—", "14-day Actions artifact", artifact_url)
            artifacts.append((label, artifact_url))
        else:
            state = "Not executed/skipped" if artifact_outcome == "skipped" else "Analyzer execution/configuration error"
            add(f"Retained report: {label}", state, "—", "14-day Actions artifact",
                "artifact URL unavailable" if artifact_outcome == "success" else artifact_outcome)

    lines = ["## Elixir quality evidence", "", f"Revision: `{revision}`", "",
             "| Analysis | Outcome | Native version | Analyzed scope / measurement | Diagnostics |",
             "| --- | --- | --- | --- | --- |"]
    lines.extend("| " + " | ".join(table_text(value) for value in row) + " |" for row in rows)
    lines.extend(["", "### Findings and provenance", ""])
    lines.extend(details or ["No file-level findings were reported by the available analyzers."])
    lines.extend(["", "### Capability and gap matrix", "",
                  "| Area | Evidence | Limit |", "| --- | --- | --- |",
                  "| Maintainability | Credo default-priority checks | Findings are rule-specific; zero findings do not establish bug absence. |",
                  "| Types/contracts | Dialyzer model and application analyses | Bounded Erlang type inference; not a complete contract proof. |",
                  "| Security | Sobelow strict analysis | Bounded security rules and reviewed exact exceptions; not exhaustive. |",
                  "| Coverage | TASK-067 application-only native executable-line measurement | Test-execution measurement, not correctness or bug absence; excludes E2E and nested BEAM execution. |",
                  "| SonarCloud | Existing JavaScript LCOV and supported-language analysis | TASK-069 observed Elixir coverage ignored and issue visibility unproven; generic imports remain disabled. No Java-equivalence claim. |",
                  "", "### Retained reports", ""])
    lines.extend(f"- [{name}]({url})" for name, url in artifacts)
    if not artifacts:
        lines.append("- Artifact links are unavailable because the upload steps did not publish artifacts.")
    lines.extend(["", f"Required analysis result: {'Approved' if all(row[1] == 'Approved' for row in rows) else 'Failed closed'}"])
    return "\n".join(lines) + "\n"


def main():
    try:
        rendered = render()
        summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
        if not summary_path:
            raise EvidenceError("summary-output-unavailable")
        with open(summary_path, "a", encoding="utf-8") as summary:
            summary.write(rendered)
        if "Required analysis result: Approved" not in rendered:
            return 1
    except EvidenceError as error:
        summary_path = os.environ.get("GITHUB_STEP_SUMMARY")
        if summary_path:
            with open(summary_path, "a", encoding="utf-8") as summary_file:
                summary_file.write(
                    "\n## Elixir quality evidence\n\n"
                    f"Summary validation failed closed: `{error}`. Required analyses are not approved.\n"
                )
        print(f"QUALITY_SUMMARY status=error category={error}", file=__import__("sys").stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
