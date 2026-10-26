# Safe browser prerequisite diagnostics

Scope: existing integration/E2E Chromium launch preflight only, authorized by TASK-029 feedback 2. Existing profile outcome remains `CP1_PROFILE_OUTCOME status=failed category=browser-prerequisite`; diagnostic detail never changes failure into success or creates a passing receipt.

Producer wire record (one complete line on stderr):

```text
PROFILE_SAFE_DIAGNOSTIC category=browser-prerequisite cause=<allowlisted-cause>
```

Closed cause enum: `executable-missing`, `dependency-missing`, `permission-denied`, `launch-timeout`, `launch-failed`. No free-text suffix, path, command, environment value, exception message or stack is allowed. Successful launch emits no failure cause and closes the browser. Node module resolution failure is dependency-missing. Classify private launch errors conservatively: explicit missing browser executable, including Playwright's “Executable doesn't exist” -> executable-missing; explicit missing module/shared-library/host dependency, including “Host system is missing dependencies” -> dependency-missing; explicit access denial -> permission-denied; explicit timeout -> launch-timeout; all other errors -> launch-failed. Never assert a guessed root cause from a generic browser-closed message. Supervisor timeout of this specific preflight may emit launch-timeout; keep existing timeout outcome/cleanup behavior.

scripts/test_profile_runner.py retains raw output only in its existing private transient capture and forwards complete matching records with a strict anchored allowlist. Unknown causes, injected fields, extra text, ANSI/control characters and malformed records are dropped. Existing openapi-browser stage records continue unchanged. scripts/agentflow_check.py safe_failure_diagnostics() recognizes only the same closed records and adds optional `browser_prerequisite_causes` (list of enum strings) to its result. Preserve existing stages/failure_counts/locations keys and behavior when no new record exists. Do not serialize raw child text into helper output or receipts.

Regression oracles: every enum survives producer -> supervisor -> safe helper output; a mixed unknown error falls back to launch-failed; success emits no cause; launch/preflight timeout remains failure; secret-sentinel raw messages, forged enum values, trailing text/newline injections and paths never escape; existing diagnostic records and failure receipt invalidation/retry budgets remain intact. Use controlled injected errors and subprocess fixtures, not a deliberately broken installed browser. Native Python tests belong to the existing unit profile; integration/E2E perform the real launch. Owner reruns via the existing verification helper before QA.

Native regression ownership: `test/scripts/test_profile_runner_test.py` covers all five producer causes, clean launch, strict supervisor forwarding and supervisor timeout; `test/scripts/agentflow_evidence_test.py` covers consumer allowlisting and legacy diagnostic compatibility. Their cases are registered under the existing unit profile in `config/test_profiles.json`.

## Effective sandbox protocol (feedback 7)

`AGENTFLOW_CODEX_SANDBOX_MODE` is launcher-owned child metadata, with exactly `read-only`, `workspace-write` or `danger-full-access`. It is not a browser cause and does not replace the existing cause enum. Resolve once before spawn: explicit `--sandbox VALUE`, `--sandbox=VALUE`, `-s VALUE` or attached `-sVALUE`; then invocation `-c/--config sandbox_mode=...`; then the user's configured root `sandbox_mode` in the existing Codex config; finally workspace-write if absent. Parse configuration with TOML, never dump it. Reject malformed, duplicate or contradictory policy declarations and unsupported policy-affecting combinations before spawn, using a fixed safe failure message. Do not guess around a profile/project policy override: either resolve its effective policy unambiguously or refuse launch. Existing assignment validation continues to reject unmanaged profiles. Preserve existing supported approval options without allowing them to override the forwarded mode silently.

Emit exactly one explicit sandbox argument for the resolved mode in the actual child argv, normalize redundant mode configuration, and set the child variable to the same value, overwriting stale inherited metadata. Record only `sandbox_mode: <closed-mode>` in the existing agent-start metadata; no free text, config contents, raw args or paths. This records launcher resolution, not independent provider attestation. Historical launches without the field remain unknown. Never rewrite user config or automatically change mode following a launch failure. Network access injection remains compatible with workspace-write; it does not establish the sandbox mode. Codex rejects `--approve-for-me` with an explicit sandbox; because that preset selects workspace-write, remove it only when the resolved mode is danger-full-access and otherwise preserve it.

Integration and E2E declare this variable in retry_env with CHROMIUM_PATH. Missing/invalid metadata must fail before the profile command starts, not receive a passing receipt or an invented default. The helper hashes the selected mode using the existing identity implementation. Changing mode invalidates reuse and starts a distinct real environment scope; unchanged-mode third failures stay blocked. QA records and uses its own actual selection; developer evidence cannot substitute for QA.

Regression ownership: test/scripts/agentflow_models_test.py uses fake child argv/environment capture and injected config paths for default/configured/explicit selection and enum-only metadata; test/scripts/agentflow_evidence_test.py covers mode identity, missing/invalid refusal, no raw config leakage, unaffected retry limits and independent stages. Register additions under the existing unit profile, not a second full-profile check.

## Safe profile discrepancy detail (feedback 10)

Profile reconciliation failures may report an opaque identity using this legacy closed record:

```text
PROFILE_DISCREPANCY id=<24-lowercase-hex> [line=<0..1000000>]
```

The legacy marker carries no details beyond the registered opaque ID and an optional bounded source line. Detailed registered-case information uses the separate closed record:

```text
PROFILE_CASE_DIAGNOSTIC id=<24-lowercase-hex> runner=<python|node|shell|exunit> file=test/<safe-relative-path> case=<registered-case-id|redacted> state=<failed|skipped|incomplete> cause=<assertion|error|skipped|incomplete> line=<0..1000000> started=<count> passed=<count> failed=<count> skipped=<count>
```

The case file and conventional registered `test.*` ID make the discrepancy actionable. An unusual or nonconventional label is rendered as `redacted`; no raw arbitrary label crosses the boundary. Python assertion/error events may include the source line from that test file; assertion text, exception text, stack traces, child output, environment values and paths outside `test/` remain private. Counts describe observed lifecycle events only and never change pass/fail or receipt behavior. The CI and Agentflow consumers accept only the bounded opaque marker and the separate anchored detailed format; malformed, extra-field, traversal, control-character or secret-suffixed records are dropped. `test_profile_components.py` emits only the closed Python outcome and source line, while `test_profile_runner.py` adds registered identity and lifecycle counts.

Native regressions live in `test/scripts/ci_unit_tests_test.sh` (wrapper output allowlist), `test/scripts/test_profile_runner_test.py` (producer/supervisor), `test/scripts/agentflow_evidence_test.py` (consumer allowlist), and `test/scripts/agentflow_models_test.py` (approval preset preservation and conflicting sandbox policies). They run in the existing unit profile.

## Failed Mix lifecycle summary (TASK-029 recovery)

When a `mix test` child exits nonzero, the supervisor may emit one aggregate record after collecting its private event file:

```text
PROFILE_EVENT_SUMMARY profile=<unit|integration|e2e> step=tests started=<count> passed=<count> failed=<count> skipped=<count>
```

Each count is the number of observed lifecycle events for that state, capped at 1,000,000. This is aggregate evidence only; it does not identify unique cases, infer an assertion cause, or alter profile status/receipt behavior. Zero counts mean the event file contained no recognized lifecycle events for that failed Mix test invocation. The record contains no child output, case identity, path, environment value, or exception text. Consumers accept only the exact anchored format and bounded closed profile/step/count fields; malformed, oversized, control-character, or suffixed records are dropped. Existing case diagnostics remain the only source of registered case identity.

Native regressions in `test/scripts/test_profile_runner_test.py` cover failed tests and failure before any lifecycle event without leaking sentinels; `test/scripts/agentflow_evidence_test.py` covers consumer bounds and malformed-record rejection. They use the existing unit inventory.

## Stage projection boundary (TASK-029 T048–T050)

The stage runner may retain a registered profile discrepancy only as the complete identity plus its closed `state`/`cause` and bounded `failure_line`, `started`, `passed`, `failed`, and `skipped` values. Every numeric field is at most 1,000,000 at the CI wrapper, stage-command, journal-summary, and evidence-recovery boundaries. Legacy identity-only records remain accepted for compatibility, but recovered optional line numbers above the bound are rejected. `profile_event_summaries` retain only the exact profile, `step=tests`, and four integer counts, with no more than ten records and each count bounded to 1,000,000. `_safe_command` validates these shapes before journaling; `summarize_stage` revalidates direct journal data and may recover the same records from the private evidence parser. Invalid fields and unrelated payload data are omitted. Stage diagnostics never change check outcome, receipt behavior, or expose raw child output.

`test/scripts/agentflow_stage_checks_test.py` exercises producer-to-summary preservation, malformed-record rejection, and evidence-only lifecycle recovery. TASK-029 grants only `scripts/agentflow_stage_checks.py` and `scripts/profile_safe_diagnostics.py` in addition to the named stage tests; the exact-path guard continues to refuse neighboring scripts/tests.
