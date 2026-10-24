# Safe browser prerequisite diagnostics

Scope: existing integration/E2E Chromium launch preflight only, authorized by TASK-029 feedback 2. Existing profile outcome remains `CP1_PROFILE_OUTCOME status=failed category=browser-prerequisite`; diagnostic detail never changes failure into success or creates a passing receipt.

Producer wire record (one complete line on stderr):

```text
PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=<allowlisted-cause>
```

Closed cause enum: `executable-missing`, `dependency-missing`, `permission-denied`, `launch-timeout`, `launch-failed`. No free-text suffix, path, command, environment value, exception message or stack is allowed. Successful launch emits no failure cause and closes the browser. Node module resolution failure is dependency-missing. Classify private launch errors conservatively: explicit missing browser executable -> executable-missing; explicit missing module/shared-library/host dependency -> dependency-missing; explicit access denial -> permission-denied; explicit timeout -> launch-timeout; all other errors -> launch-failed. Never assert a guessed root cause from a generic browser-closed message. Supervisor timeout of this specific preflight may emit launch-timeout; keep existing timeout outcome/cleanup behavior.

scripts/test_profile_runner.py retains raw output only in its existing private transient capture and forwards complete matching records with a strict anchored allowlist. Unknown causes, injected fields, extra text, ANSI/control characters and malformed records are dropped. Existing openapi-browser stage records continue unchanged. scripts/agentflow_check.py safe_failure_diagnostics() recognizes only the same closed records and adds optional `browser_prerequisite_causes` (list of enum strings) to its result. Preserve existing stages/failure_counts/locations keys and behavior when no new record exists. Do not serialize raw child text into helper output or receipts.

Regression oracles: every enum survives producer -> supervisor -> safe helper output; a mixed unknown error falls back to launch-failed; success emits no cause; launch/preflight timeout remains failure; secret-sentinel raw messages, forged enum values, trailing text/newline injections and paths never escape; existing diagnostic records and failure receipt invalidation/retry budgets remain intact. Use controlled injected errors and subprocess fixtures, not a deliberately broken installed browser. Native Python tests belong to the existing unit profile; integration/E2E perform the real launch. Owner reruns via the existing verification helper before QA.

Native regression ownership: `test/scripts/test_profile_runner_test.py` covers all five producer causes, clean launch, strict supervisor forwarding and supervisor timeout; `test/scripts/agentflow_evidence_test.py` covers consumer allowlisting and legacy diagnostic compatibility. Their cases are registered under the existing unit profile in `config/test_profiles.json`.
