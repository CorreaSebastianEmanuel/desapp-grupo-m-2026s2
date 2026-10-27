"""Strictly map profile failure markers to registered test identities."""
from __future__ import annotations

import hashlib
import json
import re
from pathlib import Path

_MARKER = re.compile(r"^PROFILE_DISCREPANCY id=([0-9a-f]{24})(?: line=([0-9]{1,8}))?$")
_CASE_DIAGNOSTIC = re.compile(
    r"^PROFILE_CASE_DIAGNOSTIC id=([0-9a-f]{24}) runner=(exunit|python|node|shell) "
    r"file=((?:test|tools)/[A-Za-z0-9_./-]{1,220}) case=([A-Za-z0-9_.:-]+|redacted) "
    r"state=(failed|skipped|incomplete) cause=(assertion|error|skipped|incomplete) "
    r"line=([0-9]{1,8}) started=([0-9]{1,8}) passed=([0-9]{1,8}) "
    r"failed=([0-9]{1,8}) skipped=([0-9]{1,8})$"
)
_RUNNERS = {"exunit", "python", "node", "shell"}
_PROFILES = {"unit", "integration", "e2e"}
_CONVENTIONAL_CASE_ID = re.compile(r"test(?:\.[A-Za-z0-9_]+)+$")
_CATEGORIES = {"usage", "timeout", "resource-cleanup", "browser-prerequisite", "test-failure",
               "component-failure", "docker-prerequisite", "execution-membership",
               "inventory-or-service-prerequisite", "profile"}
_SAFE_CATEGORY = re.compile(r"^(?:PROFILE_SAFE_DIAGNOSTIC category=openapi-browser stage=[a-z-]+|CP1_PROFILE_OUTCOME status=failed category=[a-z-]+|CI_PROFILE status=failed category=profile)$")
_PROFILE_FAILURE = re.compile(r"^CI_PROFILE_DIAGNOSTIC profile=(unit|integration) category=(" + "|".join(sorted(_CATEGORIES)) + r")$")
_PROFILE_STEP = re.compile(r"^PROFILE_STEP_DIAGNOSTIC profile=(unit|integration|e2e) step=(prepare|tests|audit|cleanup|component) partition=(regular|committed-[0-9]{1,3}|unknown)$")
_PROFILE_EVENT_SUMMARY = re.compile(
    r"^PROFILE_EVENT_SUMMARY profile=(unit|integration|e2e) step=tests "
    r"started=([0-9]{1,7}) passed=([0-9]{1,7}) failed=([0-9]{1,7}) skipped=([0-9]{1,7})$"
)
_BROWSER_DIAGNOSTIC = re.compile(
    r"^PROFILE_BROWSER_DIAGNOSTIC cause=(executable-missing|dependency-missing|permission-denied|"
    r"launch-timeout|launch-failed) stage=(integration|e2e)$")
_MEMBERSHIP_DIAGNOSTIC = re.compile(
    r"^PROFILE_MEMBERSHIP_DIAGNOSTIC profile=(unit|integration|e2e) "
    r"phase=(committed-file-audit|nonce-validation|event-reconciliation|coverage-audit) "
    r"reason=(invalid-shape|duplicate-files|outside-profile|nonce-mismatch|empty-expected|"
    r"extra-events|unexpected-state|missing-events|duplicate-events|missing-sidecar|"
    r"missing-partition|partition-mismatch|missing-export) "
    r"expected=([0-9]{1,8}) observed=([0-9]{1,8}) "
    r"missing_started=([0-9]{1,8}) missing_passed=([0-9]{1,8}) "
    r"extra=([0-9]{1,8}) duplicate=([0-9]{1,8}) invalid_state=([0-9]{1,8}) "
    r"wrong_nonce=([0-9]{1,8})$")
_MEMBERSHIP_EXTRA = re.compile(
    r"^PROFILE_MEMBERSHIP_EXTRA profile=(unit|integration|e2e) "
    r"runner=(exunit|python|node|shell) file=((?:test|tools)/[A-Za-z0-9_./-]{1,220})$")


def registered_profiles(root: Path) -> dict[str, dict]:
    data = json.loads((root / "config/test_profiles.json").read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("schema_version") != 1 or not isinstance(data.get("entries"), list):
        return {}
    result = {}
    for item in data["entries"]:
        if not isinstance(item, dict):
            continue
        ident, runner, file, case_id, profile = (item.get(key) for key in ("id", "runner", "file", "case_id", "profile"))
        if (not isinstance(ident, str) or not re.fullmatch(r"[0-9a-f]{24}", ident) or
            runner not in _RUNNERS or profile not in _PROFILES or
            not isinstance(file, str) or not re.fullmatch(r"(?:test|tools)/[A-Za-z0-9_./-]{1,220}", file) or
            ".." in Path(file).parts or not isinstance(case_id, str) or
            not 1 <= len(case_id) <= 500 or any(ord(ch) < 32 for ch in case_id)):
            continue
        calculated = hashlib.sha256("\0".join((runner, file, case_id)).encode()).hexdigest()[:24]
        if ident == calculated and ident not in result:
            result[ident] = {"id": ident, "runner": runner, "file": file,
                             "case_id": case_id if _CONVENTIONAL_CASE_ID.fullmatch(case_id) else "redacted",
                             "profile": profile}
    return result


def parse_profile_diagnostics(root: Path, evidence: Path) -> dict:
    """Return only validated registered identities; never copy source lines."""
    try:
        resolved_root = root.resolve()
        resolved = evidence.resolve(strict=True)
        safe_root = (resolved_root / ".agentflow/runs/checks").resolve()
        if not resolved.is_relative_to(safe_root) or resolved.stat().st_size > 16 * 1024 * 1024:
            return {}
        registered = registered_profiles(resolved_root)
        found = {}
        categories = set()
        browser_diagnostics = set()
        membership_diagnostics = set()
        membership_extra_sources = set()
        profile_failures = set()
        profile_steps = set()
        profile_event_summaries = set()
        with resolved.open("r", encoding="utf-8", errors="replace") as stream:
            for line in stream:
                value = line.rstrip("\r\n")
                safe_category = _SAFE_CATEGORY.fullmatch(value)
                if safe_category:
                    token = value.split("category=", 1)[1].split()[0]
                    if token in _CATEGORIES:
                        categories.add(token)
                profile_failure = _PROFILE_FAILURE.fullmatch(value)
                if profile_failure:
                    profile_failures.add((profile_failure.group(1), profile_failure.group(2)))
                profile_step = _PROFILE_STEP.fullmatch(value)
                if profile_step:
                    profile_steps.add(profile_step.groups())
                event_summary = _PROFILE_EVENT_SUMMARY.fullmatch(value)
                if event_summary:
                    fields = event_summary.groups()
                    counts = tuple(int(item) for item in fields[1:])
                    if all(count <= 1_000_000 for count in counts):
                        profile_event_summaries.add((fields[0], "tests", *counts))
                browser = _BROWSER_DIAGNOSTIC.fullmatch(value)
                if browser:
                    browser_diagnostics.add((browser.group(1), browser.group(2)))
                membership = _MEMBERSHIP_DIAGNOSTIC.fullmatch(value)
                if membership:
                    fields = membership.groups()
                    membership_diagnostics.add((fields[0], fields[1], fields[2],
                        *(int(value) for value in fields[3:])))
                extra = _MEMBERSHIP_EXTRA.fullmatch(value)
                if extra and ".." not in Path(extra.group(3)).parts:
                    source = (extra.group(1), extra.group(2), extra.group(3))
                    if any((item["runner"], item["file"]) == source[1:] for item in registered.values()):
                        membership_extra_sources.add(source)
                match = _MARKER.fullmatch(value)
                if (match and match.group(1) in registered and
                        (match.group(2) is None or int(match.group(2)) <= 1_000_000)):
                    identity = dict(registered[match.group(1)])
                    if match.group(2) and int(match.group(2)) > 0:
                        identity["failure_line"] = int(match.group(2))
                    found[match.group(1)] = identity
                    if len(found) >= 100:
                        break
                case = _CASE_DIAGNOSTIC.fullmatch(value)
                if case:
                    fields = case.groups()
                    identity = registered.get(fields[0])
                    numeric = [int(item) for item in fields[6:]]
                    if (identity and identity["runner"] == fields[1] and identity["file"] == fields[2]
                        and fields[3] in (identity["case_id"], "redacted")
                        and ".." not in Path(fields[2]).parts and all(item <= 1000000 for item in numeric)):
                        found[fields[0]] = {
                            **identity, "state": fields[4], "cause": fields[5],
                            "failure_line": numeric[0] or None, "started": numeric[1],
                            "passed": numeric[2], "failed": numeric[3], "skipped": numeric[4],
                        }
                        if len(found) >= 100:
                            break
        result = {}
        if found:
            result["profile_discrepancies"] = [found[key] for key in sorted(found)]
        if categories:
            result["profile_categories"] = sorted(categories)
        if profile_failures:
            result["profile_failures"] = [dict(profile=profile, category=category)
                                           for profile, category in sorted(profile_failures)]
        if profile_steps:
            result["profile_steps"] = [dict(profile=profile, step=step, partition=partition)
                                       for profile, step, partition in sorted(profile_steps)]
        if profile_event_summaries:
            result["profile_event_summaries"] = [
                dict(profile=profile, step=step, started=started, passed=passed, failed=failed, skipped=skipped)
                for profile, step, started, passed, failed, skipped in sorted(profile_event_summaries)]
        if browser_diagnostics:
            result["profile_browser_diagnostics"] = [
                {"cause": cause, "stage": stage} for cause, stage in sorted(browser_diagnostics)]
        if membership_diagnostics:
            result["profile_membership_diagnostics"] = [dict(
                profile=value[0], phase=value[1], reason=value[2], expected=value[3], observed=value[4],
                missing_started=value[5], missing_passed=value[6], extra=value[7], duplicate=value[8],
                invalid_state=value[9], wrong_nonce=value[10]) for value in sorted(membership_diagnostics)]
        if membership_extra_sources:
            result["profile_membership_extra_sources"] = [dict(profile=profile, runner=runner, file=file)
                for profile, runner, file in sorted(membership_extra_sources)]
        return result
    except (OSError, ValueError, TypeError, json.JSONDecodeError):
        return {}
