#!/usr/bin/env python3
"""Fail-closed CP1 acceptance record generator (standard library only)."""

import argparse
import datetime as dt
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from urllib.parse import urlparse, parse_qs
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHA_RE = re.compile(r"^[0-9a-f]{40}$")
CLASSES = {"automated", "demonstrated", "hosted"}
PASS = "PASS"
NON_PASSING = "NOT PASSING"
RECEIPT_FIELDS = {"kind", "status", "candidate_sha", "observed", "reference", "project", "branch", "analysis_status", "analysis_id", "retrieved_at", "metric", "open_issues", "profiles", "runs", "coverage"}
PROHIBITED_KEYS = re.compile(r"password|secret|token|authorization|verification|payload|raw|trace|sql", re.I)
PROHIBITED_CONTENT = re.compile(r"(?im)(bearer\s+[a-z0-9._~-]{12,}|eyJ[a-z0-9_-]+\.[a-z0-9_-]+\.[a-z0-9_-]+|(?:x-api-key|password|api_key_secret|verification_value|provider_payload|secret_hash)[\"\']?\s*[:=]|\$argon2|CP1_PROFILE_(?:SECRET|HASH)_SENTINEL|^\+ |SELECT .* FROM |-----BEGIN .*PRIVATE KEY-----)")


class InvalidEvidence(ValueError):
    pass


def load_json(path):
    with Path(path).open(encoding="utf-8") as handle:
        return json.load(handle)


def validate_reference(value):
    if not isinstance(value, str) or not value or any(c in value for c in "\\\n\r<>`|"):
        raise InvalidEvidence("invalid-reference")
    url = urlparse(value)
    if url.scheme:
        if (url.scheme != "https" or url.hostname not in {"github.com", "sonarcloud.io"} or
            url.username or url.password or url.fragment or
            set(parse_qs(url.query)) - {"id", "branch", "analysisId"}):
            raise InvalidEvidence("invalid-reference")
    elif value.startswith("/") or ".." in Path(value).parts or url.query or url.fragment:
        raise InvalidEvidence("invalid-reference")


def validate_manifest(manifest):
    if (not isinstance(manifest, dict) or
        set(manifest) != {"schema_version", "generator_version", "traceability", "obligations"} or
        type(manifest["schema_version"]) is not int or manifest["schema_version"] != 1 or
        not isinstance(manifest["generator_version"], str) or
        not re.fullmatch(r"\d+\.\d+\.\d+", manifest["generator_version"])):
        raise InvalidEvidence("invalid-manifest")
    traceability = manifest["traceability"]
    expected_traceability = {"requirements": {f"FR-{n:03d}" for n in range(1, 22)},
                             "success_criteria": {f"SC-{n:03d}" for n in range(1, 10)}}
    if not isinstance(traceability, dict) or set(traceability) != set(expected_traceability):
        raise InvalidEvidence("invalid-traceability")
    for key, expected in expected_traceability.items():
        entries = traceability[key]
        if (not isinstance(entries, list) or not all(isinstance(item, str) for item in entries) or
            len(entries) != len(expected) or set(entries) != expected):
            raise InvalidEvidence("invalid-traceability")
    obligations = manifest["obligations"]
    # These are the governing CP1 contracts, not user-selectable gate aliases.
    governing = {
        "repository": ("hosted", "repository", set()),
        "quality_build": ("automated", "quality_build", {"format", "compile_warnings_as_errors", "unit_profile"}),
        "sonarcloud": ("hosted", "sonarcloud", set()),
        "jwt_authentication": ("demonstrated", "demo", {"JWT_VALID_LOGIN", "JWT_INVALID_LOGIN", "JWT_PROTECTED_ACCESS"}),
        "openapi": ("demonstrated", "demo", {"OPENAPI_JSON_PUBLIC", "OPENAPI_UI_PUBLIC", "OPENAPI_JWT_REQUEST", "OPENAPI_API_KEY_REQUEST"}),
        "catalog_model": ("demonstrated", "demo", {"SEED_FIRST", "SEED_SECOND", "SEED_RELATIONSHIPS"}),
        "unit_tests": ("automated", "tests", {"unit_profile", "integration_profile", "coverage_report"}),
        "user_creation": ("demonstrated", "demo", {"USER_CREATE", "USER_DUPLICATE"}),
        "api_key": ("demonstrated", "demo", {"API_KEY_ISSUE", "API_KEY_VERIFY", "API_KEY_PROTECTED_ACCESS", "API_KEY_REVOKE", "API_KEY_REVOKED_REJECTED"}),
        "player_catalog": ("demonstrated", "demo", {"CATALOG_LIST", "CATALOG_DETAIL", "CATALOG_CONTINUATION", "CATALOG_FILTER_LEAGUE", "CATALOG_FILTER_TEAM", "CATALOG_FILTER_POSITION", "CATALOG_FILTER_COMBINED", "CATALOG_EMPTY", "CATALOG_INVALID"}),
    }
    if (not isinstance(obligations, list) or not all(isinstance(row, dict) and isinstance(row.get("id"), str) for row in obligations)):
        raise InvalidEvidence("invalid-obligation-membership")
    ids = [row["id"] for row in obligations]
    if len(ids) != 10 or len(set(ids)) != 10 or set(ids) != set(governing):
        raise InvalidEvidence("invalid-obligation-membership")
    for row in obligations:
        allowed = {"id", "criterion", "evidence_class", "required_receipt", "references", "supporting_regressions"}
        if set(row) - allowed or not {"id", "criterion", "evidence_class", "required_receipt", "references"} <= set(row):
            raise InvalidEvidence("invalid-obligation-schema")
        evidence_class, receipt, regressions = governing[row["id"]]
        declared = row.get("supporting_regressions", [])
        if (not isinstance(row["criterion"], str) or not row["criterion"].strip() or
            row["evidence_class"] != evidence_class or row["required_receipt"] != receipt or
            not isinstance(declared, list) or not all(isinstance(item, str) for item in declared) or
            len(declared) != len(regressions) or set(declared) != regressions or
            not isinstance(row["references"], list) or not row["references"]):
            raise InvalidEvidence("invalid-obligation-schema")
        for reference in row["references"]:
            validate_reference(reference)
    return obligations


def scan_safe(value, key=""):
    if key and PROHIBITED_KEYS.search(key):
        raise InvalidEvidence("unsafe-evidence")
    if isinstance(value, dict):
        for child_key, child in value.items():
            scan_safe(child, child_key)
    elif isinstance(value, list):
        for child in value:
            scan_safe(child)
    elif isinstance(value, str) and PROHIBITED_CONTENT.search(value):
        raise InvalidEvidence("unsafe-evidence")


def validate_receipts(document, candidate):
    if not isinstance(document, dict) or set(document) != {"candidate_sha", "provenance", "receipts"} or not isinstance(document["receipts"], list):
        raise InvalidEvidence("invalid-receipt-envelope")
    if document["candidate_sha"] != candidate or document["provenance"] not in {"committed", "working-tree-snapshot"}:
        raise InvalidEvidence("stale-evidence")
    scan_safe(document)
    receipts = {}
    for receipt in document["receipts"]:
        if not isinstance(receipt, dict):
            raise InvalidEvidence("invalid-receipt-schema")
        if set(receipt) - RECEIPT_FIELDS or not {"kind", "status", "candidate_sha", "observed", "reference"} <= set(receipt):
            raise InvalidEvidence("invalid-receipt-schema")
        if not isinstance(receipt["observed"], str) or not receipt["observed"]:
            raise InvalidEvidence("invalid-observation")
        scan_safe(receipt)
        validate_reference(receipt["reference"])
        kind = receipt["kind"]
        if kind in receipts:
            raise InvalidEvidence("duplicate-receipt")
        if kind not in {"repository", "quality_build", "sonarcloud", "demo", "tests"}:
            raise InvalidEvidence("unknown-receipt")
        if receipt["candidate_sha"] != candidate:
            raise InvalidEvidence("mixed-sha")
        if receipt["status"] not in {PASS, NON_PASSING}:
            raise InvalidEvidence("non-pass-receipt")
        base_fields = {"kind", "status", "candidate_sha", "observed", "reference"}
        extra_fields = {"sonarcloud": {"project", "branch", "analysis_status", "analysis_id", "retrieved_at", "metric", "open_issues", "profiles"},
                        "demo": {"runs"}, "tests": {"profiles", "coverage"}}
        if set(receipt) - base_fields - extra_fields.get(kind, set()):
            raise InvalidEvidence("invalid-receipt-schema")
        receipts[kind] = receipt
    if set(receipts) != {"repository", "quality_build", "sonarcloud", "demo", "tests"}:
        raise InvalidEvidence("missing-receipt")
    sonar = receipts["sonarcloud"]
    sonar_valid = (sonar.get("project") == "CorreaSebastianEmanuel_desapp-grupo-m-2026s2" and sonar.get("branch") == "main" and
                   sonar.get("analysis_status") == "completed" and type(sonar.get("open_issues")) is int and
                   0 <= sonar["open_issues"] <= 9 and isinstance(sonar.get("profiles"), list) and bool(sonar["profiles"]) and all(isinstance(p, str) and p for p in sonar["profiles"]) and sonar.get("metric") == "open_issues" and
                   bool(sonar.get("analysis_id")) and bool(sonar.get("retrieved_at")))
    if sonar["status"] == PASS:
        try:
            dt.datetime.strptime(sonar["retrieved_at"], "%Y-%m-%dT%H:%M:%SZ")
        except (ValueError, TypeError, KeyError):
            raise InvalidEvidence("invalid-sonar-timestamp")
    if sonar["status"] == PASS and not sonar_valid:
        raise InvalidEvidence("sonarcloud-non-pass")
    if receipts["demo"]["status"] == PASS:
        runs = receipts["demo"].get("runs", [])
        if len(runs) != 2:
            raise InvalidEvidence("missing-demo-runs")
        for demo in runs:
            validate_demo(demo, candidate)
    if receipts["tests"]["status"] == PASS:
        validate_profiles(receipts["tests"].get("profiles"))
        validate_coverage(receipts["tests"].get("coverage", {}), candidate)
    return receipts



BEHAVIORS = "SEED_FIRST SEED_SECOND SEED_RELATIONSHIPS USER_CREATE USER_DUPLICATE JWT_VALID_LOGIN JWT_INVALID_LOGIN JWT_PROTECTED_ACCESS API_KEY_ISSUE API_KEY_VERIFY API_KEY_PROTECTED_ACCESS API_KEY_REVOKE API_KEY_REVOKED_REJECTED CATALOG_LIST CATALOG_DETAIL CATALOG_CONTINUATION CATALOG_FILTER_LEAGUE CATALOG_FILTER_TEAM CATALOG_FILTER_POSITION CATALOG_FILTER_COMBINED CATALOG_EMPTY CATALOG_INVALID OPENAPI_JSON_PUBLIC OPENAPI_UI_PUBLIC OPENAPI_JWT_REQUEST OPENAPI_API_KEY_REQUEST".split()
SEED_COUNTS = dict(leagues=5, seasons=5, teams=10, positions=4, players=20, total=44)


def validate_demo(demo, candidate, require_committed=True):
    fields = {"schema_version", "kind", "status", "candidate_sha", "observed", "reference", "provider_access", "seed_assertions", "elapsed_seconds", "behaviors", "provenance", "snapshot_sha256"}
    scan_safe(demo)
    if (not isinstance(demo, dict) or set(demo) != fields or demo["schema_version"] != 1 or
        demo["kind"] != "demo" or demo["status"] != PASS or demo["candidate_sha"] != candidate or
        demo["provider_access"] is not False or demo["seed_assertions"] != [SEED_COUNTS, SEED_COUNTS] or
        type(demo["elapsed_seconds"]) is not int or not 0 <= demo["elapsed_seconds"] <= 1200 or
        demo["behaviors"] != BEHAVIORS or demo["observed"] != "all behavior IDs passed"):
        raise InvalidEvidence("invalid-demo-receipt")
    if (demo["provenance"] not in {"committed", "working-tree-snapshot"} or
        not re.fullmatch(r"[0-9a-f]{64}", demo["snapshot_sha256"]) or
        (require_committed and (demo["provenance"] != "committed" or demo["snapshot_sha256"] != hashlib.sha256(candidate.encode()).hexdigest()))):
        raise InvalidEvidence("uncommitted-demo-receipt")
    validate_reference(demo["reference"])


def validate_profiles(profiles):
    if not isinstance(profiles, list) or len(profiles) != 2:
        raise InvalidEvidence("invalid-profile-receipts")
    for profile, name in zip(profiles, ["unit", "integration"]):
        if (set(profile) != {"profile", "audit_count", "status"} or profile["profile"] != name or
            profile["status"] != "complete" or type(profile["audit_count"]) is not int or profile["audit_count"] <= 0):
            raise InvalidEvidence("invalid-profile-receipts")


def validate_coverage(coverage, candidate):
    if (set(coverage) != {"candidate_sha", "snapshot_label", "inventory_sha256", "source_count", "report_reference"} or
        coverage["candidate_sha"] != candidate or coverage["snapshot_label"] != "committed revision" or
        not re.fullmatch(r"[0-9a-f]{64}", coverage["inventory_sha256"]) or
        type(coverage["source_count"]) is not int or coverage["source_count"] <= 0):
        raise InvalidEvidence("invalid-coverage-receipt")
    if coverage["inventory_sha256"] != hashlib.sha256((ROOT / "config/cp1_coverage_inventory.exs").read_bytes()).hexdigest():
        raise InvalidEvidence("stale-coverage-inventory")
    validate_reference(coverage["report_reference"])


def local_receipts(directory, candidate):
    directory = Path(directory)
    runs = [load_json(directory / f"tmp/cp1-demo-{name}.json") for name in ["first", "second"]]
    for demo in runs:
        validate_demo(demo, candidate)
    manifests = list(directory.glob("cover/cp1/*/manifest.json"))
    if len(manifests) != 1:
        raise InvalidEvidence("missing-or-ambiguous-coverage")
    report = load_json(manifests[0])
    scan_safe(report)
    report_fields = {"metadata", "threshold", "executed_lines", "executable_lines", "percentage", "sources"}
    if set(report) - report_fields or not {"metadata", "executable_lines", "sources"} <= set(report):
        raise InvalidEvidence("invalid-coverage-schema")
    if type(report["executable_lines"]) is not int or report["executable_lines"] <= 0:
        raise InvalidEvidence("invalid-coverage-schema")
    metadata = report["metadata"]
    if set(metadata) - {"base_head", "diff_sha256", "inventory_sha256", "snapshot_label", "profiles", "generated_at", "elixir", "otp"}:
        raise InvalidEvidence("invalid-coverage-schema")
    if metadata["base_head"] != candidate or metadata["snapshot_label"] != "committed revision" or metadata["diff_sha256"] != hashlib.sha256(b"").hexdigest():
        raise InvalidEvidence("stale-coverage")
    profiles = metadata["profiles"]
    validate_profiles(profiles)
    report_path = manifests[0].with_name("report.html")
    if not report_path.is_file() or not report.get("sources") or report.get("executable_lines", 0) <= 0:
        raise InvalidEvidence("missing-coverage-report")
    inventory = (ROOT / "config/cp1_coverage_inventory.exs").read_text()
    expected_sources = set(re.findall(r'path: "([^"]+)"', inventory))
    if {source["path"] for source in report["sources"]} != expected_sources or len(report["sources"]) != len(expected_sources):
        raise InvalidEvidence("invalid-coverage-scope")
    for source in report["sources"]:
        if set(source) - {"path", "module", "rationale", "executable_lines", "executed_lines", "unexecuted_lines", "source_report", "lines"}:
            raise InvalidEvidence("invalid-coverage-schema")
        reference = source["source_report"]
        validate_reference(reference)
        if not (manifests[0].parent / reference).is_file():
            raise InvalidEvidence("missing-source-report")
    coverage = {"candidate_sha": candidate, "snapshot_label": metadata["snapshot_label"],
                "inventory_sha256": metadata["inventory_sha256"], "source_count": len(report["sources"]),
                "report_reference": str(report_path.relative_to(directory))}
    validate_coverage(coverage, candidate)
    for path in local_artifacts(directory, coverage):
        scan_artifact(path)
    return runs, profiles, coverage


def scan_artifact(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise InvalidEvidence("unsafe-local-artifact")
    scan_safe(load_json(path) if path.suffix == ".json" else path.read_text())


def local_artifacts(source, coverage):
    source = Path(source)
    report = source / coverage["report_reference"]
    manifest = report.with_name("manifest.json")
    return ([source / f"tmp/cp1-demo-{name}.json" for name in ["first", "second"]] +
            [report, manifest] + [report.parent / row["source_report"] for row in load_json(manifest)["sources"]])


def verify_local_evidence(receipts, source, candidate):
    if source is None:
        raise InvalidEvidence("missing-local-evidence")
    runs, profiles, coverage = local_receipts(source, candidate)
    by_kind = {r["kind"]: r for r in receipts["receipts"]}
    if (by_kind["demo"].get("runs") != runs or by_kind["tests"].get("profiles") != profiles or
        by_kind["tests"].get("coverage") != coverage):
        raise InvalidEvidence("local-evidence-mismatch")
    return runs, profiles, coverage


def verify_references(manifest, receipts, source):
    references = [ref for row in manifest["obligations"] for ref in row["references"]]
    references += [row["reference"] for row in receipts["receipts"] if row["status"] == PASS]
    for reference in references:
        validate_reference(reference)
        if not urlparse(reference).scheme:
            path = ROOT / reference
            if not path.is_file() and source is not None:
                path = Path(source) / reference
            if not path.is_file():
                raise InvalidEvidence("inaccessible-reference")
            if path.suffix == ".json":
                if reference == "priv/static/openapi.json":
                    schema = load_json(path)
                    # This exact placeholder describes a public header, not a capture.
                    auth = schema.get("components", {}).get("securitySchemes", {}).get("ApiKeyAuth", {})
                    if auth.get("description") == "X-API-Key: <key>. Supply only this method when selected. Header name case-insensitive; key value exact.":
                        auth.pop("description")
                    scan_safe(schema)
                else:
                    scan_artifact(path)


def git_snapshot():
    sha, provenance = git_candidate()
    scope = ["config", "lib", "test", "scripts", "tools/openapi", "priv", "assets", ".github", ".tool-versions", "mix.exs", "mix.lock", ".formatter.exs", ".gitignore"]
    digest = hashlib.sha256(sha.encode())
    digest.update(subprocess.check_output(["git", "diff", "--binary", "--full-index", "HEAD", "--", *scope], cwd=ROOT))
    untracked = subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard", "-z", "--", *scope], cwd=ROOT)
    for name in sorted(filter(None, untracked.split(b"\0"))):
        digest.update(name + b"\0")
        digest.update((ROOT / os.fsdecode(name)).read_bytes())
    return {"candidate_sha": sha, "provenance": provenance, "snapshot_sha256": digest.hexdigest()}


def git_candidate():
    sha = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip()
    dirty = bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip())
    return sha, "working-tree-snapshot" if dirty else "committed"


def record(manifest, receipts_doc, candidate, collected_at):
    if not SHA_RE.fullmatch(candidate):
        raise InvalidEvidence("invalid-candidate")
    obligations = validate_manifest(manifest)
    receipts = validate_receipts(receipts_doc, candidate)
    provenance = receipts_doc["provenance"]
    rows = []
    for obligation in obligations:
        receipt = receipts[obligation["required_receipt"]]
        rows.append({"id": obligation["id"], "criterion": obligation["criterion"], "observed": receipt["observed"],
                     "outcome": PASS if provenance == "committed" and receipt["status"] == PASS else NON_PASSING, "evidence_class": obligation["evidence_class"],
                     "provenance": {"candidate_sha": candidate, "kind": provenance}, "references": [receipt["reference"], *obligation["references"]],
                     "supporting_regressions": obligation.get("supporting_regressions", [])})
    manifest_bytes = json.dumps(manifest, sort_keys=True, separators=(",", ":")).encode()
    return {"schema_version": 1, "generator_version": manifest["generator_version"], "manifest_sha256": hashlib.sha256(manifest_bytes).hexdigest(),
            "candidate_sha": candidate, "provenance": provenance, "collected_at": collected_at,
            "overall_result": PASS if provenance == "committed" and all(row["outcome"] == PASS for row in rows) else NON_PASSING,
            "obligations": rows}


def markdown(result):
    lines = ["# CP1 Acceptance Record", "", f"- Candidate: `{result['candidate_sha']}`", f"- Provenance: `{result['provenance']}`",
             f"- Collected: `{result['collected_at']}`", f"- Generator: `{result['generator_version']}`", f"- Manifest SHA-256: `{result['manifest_sha256']}`",
             f"- Overall result: **{result['overall_result']}**", "", "| Obligation | Class | Outcome | Observed | Evidence |", "|---|---|---|---|---|"]
    for row in result["obligations"]:
        refs = "<br>".join(f"[{index + 1}]({ref})" for index, ref in enumerate(row["references"]))
        lines.append(f"| `{row['id']}` | {row['evidence_class']} | {row['outcome']} | {row['observed']} | {refs} |")
    for row in result["obligations"]:
        lines.extend(["", f"## {row['id']}", "", f"Criterion: {row['criterion']}", f"Provenance: `{row['provenance']['kind']}` at `{row['provenance']['candidate_sha']}`."])
    return "\n".join(lines) + "\n"


def publish_local(source, candidate, output):
    source, output = Path(source), Path(output)
    runs, profiles, coverage = local_receipts(source, candidate)
    report = source / coverage["report_reference"]
    paths = local_artifacts(source, coverage)
    output.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=".cp1-staging-", dir=output.parent))
    try:
        for path in paths:
            if path.is_symlink():
                raise InvalidEvidence("unsafe-local-artifact")
            scan_artifact(path)
            target = staging / path.relative_to(source)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(path, target)
        if output.exists():
            shutil.rmtree(output)
        os.replace(staging, output)
    except Exception:
        shutil.rmtree(staging, ignore_errors=True)
        shutil.rmtree(output, ignore_errors=True)
        raise


def atomic_publish(output, result, receipts_doc=None, local_directory=None):
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    staging = Path(tempfile.mkdtemp(prefix=".cp1-staging-", dir=output.parent))
    try:
        (staging / "acceptance.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        (staging / "acceptance.md").write_text(markdown(result), encoding="utf-8")
        if receipts_doc is not None:
            scan_safe(receipts_doc)
            (staging / "receipts.json").write_text(json.dumps(receipts_doc, indent=2) + "\n")
        if local_directory is not None:
            _, _, coverage = local_receipts(local_directory, result["candidate_sha"])
            source = Path(local_directory)
            for path in local_artifacts(source, coverage):
                scan_artifact(path)
                target = staging / path.relative_to(source)
                target.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(path, target)
        scan_safe(load_json(staging / "acceptance.json"))
        if output.exists():
            shutil.rmtree(output)
        os.replace(staging, output)
    except Exception:
        shutil.rmtree(staging, ignore_errors=True)
        raise


def main(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument("command", nargs="?", choices=["validate", "stage-local"])
    parser.add_argument("--manifest", default=ROOT / "config/cp1_acceptance.json", type=Path)
    parser.add_argument("--receipts", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--candidate-sha")
    parser.add_argument("--collected-at")
    parser.add_argument("--local-evidence", type=Path)
    args = parser.parse_args(argv)
    try:
        git_sha, git_provenance = git_candidate()
        candidate = args.candidate_sha or git_sha
        if not SHA_RE.fullmatch(candidate):
            raise InvalidEvidence("invalid-candidate")
        if args.command == "stage-local":
            if candidate != git_sha or git_provenance != "committed":
                raise InvalidEvidence("uncommitted-local-evidence")
            publish_local(args.local_evidence, candidate, args.output)
            print("cp1-local: PASS")
            return 0
        if args.receipts is None:
            raise InvalidEvidence("missing-receipts")
        receipt_path = args.receipts / "receipts.json" if args.receipts.is_dir() else args.receipts
        receipts = load_json(receipt_path)
        if candidate != git_sha:
            raise InvalidEvidence("candidate-checkout-mismatch")
        if git_provenance != "committed":
            receipts["provenance"] = git_provenance
        collected = args.collected_at or dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
        manifest = load_json(args.manifest)
        result = record(manifest, receipts, candidate, collected)
        verify_references(manifest, receipts, args.local_evidence)
        if result["provenance"] == "committed" and any(r["status"] == PASS for r in receipts["receipts"] if r["kind"] in {"demo", "tests"}):
            verify_local_evidence(receipts, args.local_evidence, candidate)
            for row in result["obligations"]:
                kind = next(o["required_receipt"] for o in manifest["obligations"] if o["id"] == row["id"])
                if kind == "demo":
                    row["references"] = ["tmp/cp1-demo-first.json", "tmp/cp1-demo-second.json", *row["references"]]
                elif kind == "tests":
                    row["references"].insert(0, next(r["coverage"]["report_reference"] for r in receipts["receipts"] if r["kind"] == "tests"))
        atomic_publish(args.output, result, receipts, args.local_evidence if receipts["receipts"] and any(r.get("runs") for r in receipts["receipts"]) else None)
        print(f"cp1-acceptance: {result['overall_result']}")
        return 0 if result["overall_result"] == PASS else 1
    except (InvalidEvidence, OSError, json.JSONDecodeError, subprocess.SubprocessError, TypeError, KeyError, ValueError) as exc:
        shutil.rmtree(args.output, ignore_errors=True)
        try:
            manifest = load_json(args.manifest)
            candidate = args.candidate_sha if args.candidate_sha and SHA_RE.fullmatch(args.candidate_sha) else "0" * 40
            collected = args.collected_at or dt.datetime.now(dt.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
            failure = {"schema_version": 1, "generator_version": manifest.get("generator_version", "unknown"),
                       "manifest_sha256": hashlib.sha256(json.dumps(manifest, sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
                       "candidate_sha": candidate, "provenance": "unverified", "collected_at": collected,
                       "overall_result": NON_PASSING, "failure_category": str(exc) if isinstance(exc, InvalidEvidence) else "invalid-input", "obligations": [
                         {"id": row["id"], "criterion": row["criterion"], "observed": "evidence validation failed",
                          "outcome": NON_PASSING, "evidence_class": row["evidence_class"],
                          "provenance": {"candidate_sha": candidate, "kind": "unverified"},
                          "references": row["references"], "supporting_regressions": row.get("supporting_regressions", [])}
                         for row in validate_manifest(manifest)]}
            atomic_publish(args.output, failure)
        except Exception:
            shutil.rmtree(args.output, ignore_errors=True)
        print("cp1-acceptance: NOT PASSING (invalid-evidence)", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
