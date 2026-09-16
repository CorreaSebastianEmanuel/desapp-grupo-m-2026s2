import io
import json
import pathlib
import sys
import unittest
from contextlib import redirect_stderr, redirect_stdout
from unittest import mock
from urllib.error import HTTPError, URLError

ROOT = pathlib.Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

import sonar_checkpoint_gate as gate  # noqa: E402

FIXTURES = pathlib.Path(__file__).parent / "fixtures" / "sonarcloud"
SHA = "a" * 40
TOKEN = "SONAR_FIXTURE" + "_TOKEN_DO_NOT_PRINT"


def fixture(name):
    return (FIXTURES / name).read_bytes()


class FakeTransport:
    def __init__(self, responses):
        self.responses = list(responses)
        self.requests = []

    def get(self, url, headers, timeout):
        self.requests.append((url, headers, timeout))
        response = self.responses.pop(0)
        if isinstance(response, BaseException):
            raise response
        return response


class GateTest(unittest.TestCase):
    def invoke(self, responses, *extra):
        transport = FakeTransport(responses)
        stdout, stderr = io.StringIO(), io.StringIO()
        args = ["--project", "example_project", "--branch", "main", "--mode", "pr", *extra]
        with mock.patch.dict("os.environ", {"SONAR_TOKEN": TOKEN}, clear=False):
            with redirect_stdout(stdout), redirect_stderr(stderr):
                code = gate.main(args, transport=transport, sleep=lambda _: None)
        output = stdout.getvalue() + stderr.getvalue()
        self.assertNotIn(TOKEN, output)
        return code, output, transport

    def test_interface_and_exit_taxonomy_are_stable(self):
        self.assertEqual(gate.EXIT_OK, 0)
        self.assertEqual(gate.EXIT_THRESHOLD, 2)
        self.assertEqual(gate.EXIT_AUTH, 3)
        self.assertEqual(gate.EXIT_CONFIGURATION, 4)
        self.assertEqual(gate.EXIT_SERVICE, 5)
        self.assertEqual(gate.EXIT_NETWORK, 6)
        self.assertEqual(gate.EXIT_MALFORMED, 7)
        self.assertEqual(gate.EXIT_STALE, 8)
        self.assertEqual(gate.MAX_ATTEMPTS, 3)
        self.assertEqual(gate.REQUEST_TIMEOUT_SECONDS, 10)

    def test_boundary_counts(self):
        for name in ("measure_0.json", "measure_9.json", "measure_numeric_string.json"):
            code, output, _ = self.invoke([fixture(name)])
            self.assertEqual(code, 0, output)
            self.assertIn("checkpoint: PASS", output)
            self.assertIn("Current primary-branch CP1 count", output)
        for name in ("measure_10.json", "measure_11.json"):
            code, output, _ = self.invoke([fixture(name)])
            self.assertEqual(code, gate.EXIT_THRESHOLD, output)
            self.assertIn("diagnostic: threshold", output)

    def test_invalid_measures_fail_closed(self):
        names = ["measure_absent.json", "measure_duplicate.json", "measure_decorated_string.json",
                 "measure_float.json", "measure_negative.json", "measure_malformed.json"]
        for name in names:
            code, output, _ = self.invoke([fixture(name)])
            self.assertEqual(code, gate.EXIT_MALFORMED, (name, output))
            self.assertIn("diagnostic: malformed-response", output)

    def test_main_requires_matching_latest_revision_before_measure(self):
        code, output, transport = self.invoke(
            [fixture("analysis_matching.json"), fixture("measure_9.json")],
            "--mode", "main", "--expected-revision", SHA,
        )
        self.assertEqual(code, 0, output)
        self.assertEqual(len(transport.requests), 2)
        self.assertIn("/api/project_analyses/search?", transport.requests[0][0])
        self.assertIn("ps=1", transport.requests[0][0])
        self.assertIn("/api/measures/component?", transport.requests[1][0])
        self.assertIn("metricKeys=open_issues", transport.requests[1][0])

    def test_stale_missing_duplicate_and_malformed_analysis_fail(self):
        cases = [("analysis_stale.json", gate.EXIT_STALE), ("analysis_missing.json", gate.EXIT_MALFORMED),
                 ("analysis_duplicate.json", gate.EXIT_MALFORMED), ("analysis_malformed.json", gate.EXIT_MALFORMED)]
        for name, expected in cases:
            code, output, transport = self.invoke([fixture(name)], "--mode", "main", "--expected-revision", SHA)
            self.assertEqual(code, expected, (name, output))
            self.assertEqual(len(transport.requests), 1)

    def test_auth_and_not_found_are_immediate_and_classified(self):
        for status, expected, label in [(401, gate.EXIT_AUTH, "authentication"),
                                        (403, gate.EXIT_AUTH, "authorization"),
                                        (404, gate.EXIT_CONFIGURATION, "configuration")]:
            error = HTTPError(f"https://example.invalid/?token={TOKEN}", status, TOKEN, {"Authorization": TOKEN}, None)
            code, output, transport = self.invoke([error])
            self.assertEqual(code, expected, output)
            self.assertIn(f"diagnostic: {label}", output)
            self.assertEqual(len(transport.requests), 1)

    def test_transient_failures_retry_with_bounds_and_recover(self):
        error429 = HTTPError("https://example.invalid", 429, "rate limit", {}, None)
        error500 = HTTPError("https://example.invalid", 500, "server", {}, None)
        code, output, transport = self.invoke([error429, error500, fixture("measure_9.json")])
        self.assertEqual(code, 0, output)
        self.assertEqual(len(transport.requests), gate.MAX_ATTEMPTS)

        code, output, transport = self.invoke([error500, error500, error500])
        self.assertEqual(code, gate.EXIT_SERVICE, output)
        self.assertEqual(len(transport.requests), gate.MAX_ATTEMPTS)
        self.assertIn("diagnostic: service", output)

    def test_network_timeout_and_exception_text_are_redacted(self):
        for error in (URLError(f"network token={TOKEN}"), TimeoutError(TOKEN)):
            code, output, transport = self.invoke([error, error, error])
            self.assertEqual(code, gate.EXIT_NETWORK, output)
            self.assertEqual(len(transport.requests), gate.MAX_ATTEMPTS)
            self.assertIn("diagnostic: network", output)

    def test_authorization_header_and_url_are_not_printed(self):
        code, output, transport = self.invoke([fixture("measure_9.json")])
        self.assertEqual(code, 0, output)
        self.assertIn("branch=main", transport.requests[0][0])
        self.assertEqual(transport.requests[0][1]["Authorization"], f"Bearer {TOKEN}")
        self.assertNotIn("token=", output.lower())
        self.assertNotIn("Authorization", output)


if __name__ == "__main__":
    unittest.main()
