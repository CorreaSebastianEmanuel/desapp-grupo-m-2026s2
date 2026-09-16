#!/usr/bin/env python3
"""Fail-closed SonarCloud whole-project issue gate."""

import argparse
import json
import os
import re
import sys
import time
from dataclasses import dataclass
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

EXIT_OK = 0
EXIT_THRESHOLD = 2
EXIT_AUTH = 3
EXIT_CONFIGURATION = 4
EXIT_SERVICE = 5
EXIT_NETWORK = 6
EXIT_MALFORMED = 7
EXIT_STALE = 8
MAX_ATTEMPTS = 3
REQUEST_TIMEOUT_SECONDS = 10
BACKOFF_SECONDS = (1, 2)


class GateFailure(Exception):
    def __init__(self, code, diagnostic, message):
        super().__init__(message)
        self.code = code
        self.diagnostic = diagnostic
        self.message = message


class UrlLibTransport:
    def get(self, url, headers, timeout):
        request = Request(url, headers=headers, method="GET")
        with urlopen(request, timeout=timeout) as response:
            return response.read()


@dataclass(frozen=True)
class Options:
    project: str
    branch: str
    mode: str
    expected_revision: str | None
    base_url: str
    token: str


def parser():
    cli = argparse.ArgumentParser(description=__doc__)
    cli.add_argument("--project", required=True)
    cli.add_argument("--branch", default="main")
    cli.add_argument("--mode", choices=("pr", "main"), required=True)
    cli.add_argument("--expected-revision")
    cli.add_argument("--base-url", default="https://sonarcloud.io")
    cli.add_argument("--token-env", default="SONAR_TOKEN")
    return cli


def parse_options(argv):
    args = parser().parse_args(argv)
    token = os.environ.get(args.token_env, "")
    if not token:
        raise GateFailure(EXIT_AUTH, "authentication", "required analysis credential is unavailable")
    if args.mode == "main" and not args.expected_revision:
        raise GateFailure(EXIT_CONFIGURATION, "configuration", "main analysis requires an expected revision")
    if args.expected_revision and not re.fullmatch(r"[0-9a-fA-F]{40}", args.expected_revision):
        raise GateFailure(EXIT_CONFIGURATION, "configuration", "expected revision must be a full Git SHA")
    return Options(args.project, args.branch, args.mode, args.expected_revision,
                   args.base_url.rstrip("/"), token)


def api_get(options, path, params, transport, sleep):
    url = f"{options.base_url}{path}?{urlencode(params)}"
    headers = {"Authorization": f"Bearer {options.token}", "Accept": "application/json"}
    for attempt in range(MAX_ATTEMPTS):
        try:
            raw = transport.get(url, headers, REQUEST_TIMEOUT_SECONDS)
            try:
                return json.loads(raw)
            except (json.JSONDecodeError, UnicodeDecodeError, TypeError):
                raise GateFailure(EXIT_MALFORMED, "malformed-response", "service returned invalid JSON")
        except HTTPError as error:
            if error.code == 401:
                raise GateFailure(EXIT_AUTH, "authentication", "analysis service rejected the credential")
            if error.code == 403:
                raise GateFailure(EXIT_AUTH, "authorization", "credential cannot read project analysis")
            if error.code == 404:
                raise GateFailure(EXIT_CONFIGURATION, "configuration", "project or branch was not found")
            if error.code != 429 and not 500 <= error.code <= 599:
                raise GateFailure(EXIT_SERVICE, "service", f"analysis service returned HTTP {error.code}")
            if attempt == MAX_ATTEMPTS - 1:
                raise GateFailure(EXIT_SERVICE, "service", "analysis service remained unavailable after bounded retries")
        except (URLError, TimeoutError, OSError):
            if attempt == MAX_ATTEMPTS - 1:
                raise GateFailure(EXIT_NETWORK, "network", "analysis service was unreachable after bounded retries")
        sleep(BACKOFF_SECONDS[attempt])
    raise AssertionError("retry loop exhausted unexpectedly")


def latest_revision(options, transport, sleep):
    document = api_get(options, "/api/project_analyses/search",
                       {"project": options.project, "branch": options.branch, "ps": 1},
                       transport, sleep)
    analyses = document.get("analyses") if isinstance(document, dict) else None
    if not isinstance(analyses, list) or len(analyses) != 1:
        raise GateFailure(EXIT_MALFORMED, "malformed-response", "latest published analysis is missing or ambiguous")
    revision = analyses[0].get("revision") if isinstance(analyses[0], dict) else None
    if not isinstance(revision, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", revision):
        raise GateFailure(EXIT_MALFORMED, "malformed-response", "latest analysis has no valid revision")
    return revision.lower()


def open_issue_count(options, transport, sleep):
    document = api_get(options, "/api/measures/component",
                       {"component": options.project, "branch": options.branch, "metricKeys": "open_issues"},
                       transport, sleep)
    component = document.get("component") if isinstance(document, dict) else None
    if not isinstance(component, dict) or component.get("key") != options.project or component.get("branch") != options.branch:
        raise GateFailure(EXIT_MALFORMED, "malformed-response", "measure identity does not match the requested project and branch")
    measures = component.get("measures")
    matching = [item for item in measures if isinstance(item, dict) and item.get("metric") == "open_issues"] if isinstance(measures, list) else []
    if len(matching) != 1:
        raise GateFailure(EXIT_MALFORMED, "malformed-response", "open_issues measure is missing or ambiguous")
    value = matching[0].get("value")
    if not isinstance(value, str) or not re.fullmatch(r"0|[1-9][0-9]*", value):
        raise GateFailure(EXIT_MALFORMED, "malformed-response", "open_issues must be one non-negative integer")
    return int(value)


def evaluate(options, transport, sleep):
    revision = None
    if options.mode == "main":
        revision = latest_revision(options, transport, sleep)
        if revision != options.expected_revision.lower():
            raise GateFailure(EXIT_STALE, "stale-analysis", "latest published analysis does not match the triggering revision")
    count = open_issue_count(options, transport, sleep)
    label = "Integrated main analysis" if options.mode == "main" else "Current primary-branch CP1 count"
    findings = f"{options.base_url}/project/issues?id={options.project}&branch={options.branch}&resolved=false"
    print(f"heading: {label}")
    print(f"project: {options.project}")
    print(f"branch: {options.branch}")
    if revision:
        print(f"revision: {revision}")
    print(f"metric: open_issues")
    print(f"count: {count}")
    print("threshold: fewer than 10")
    print(f"findings: {findings}")
    if count >= 10:
        raise GateFailure(EXIT_THRESHOLD, "threshold", f"open issue count {count} does not satisfy the checkpoint")
    print("checkpoint: PASS")
    return EXIT_OK


def main(argv=None, *, transport=None, sleep=time.sleep):
    try:
        options = parse_options(sys.argv[1:] if argv is None else argv)
        return evaluate(options, transport or UrlLibTransport(), sleep)
    except GateFailure as failure:
        print(f"diagnostic: {failure.diagnostic}", file=sys.stderr)
        print(f"result: FAIL — {failure.message}", file=sys.stderr)
        return failure.code


if __name__ == "__main__":
    raise SystemExit(main())
