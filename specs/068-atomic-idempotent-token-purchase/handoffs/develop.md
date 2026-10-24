# TASK-029 Development handoff

## Changes and decisions

- Reject NUL bytes in purchase request keys during domain validation, before PostgreSQL text persistence; align the purchase contract and add unit, controller, and real HTTP unchanged-snapshot assertions.
- Preserve safe discrepancy-only diagnostics in `safe_failure_diagnostics`; add strict allowlist coverage. The configured Chrome executable exists and is executable, and repository `TMPDIR` is writable. Keep browser launch mandatory; no bypass or raw Playwright output was used.

## Checks

Successful current-input helper checks: `toolchain`, `prepare`, `services`, `format`, `compile`, `credo`, `openapi`, `inventory`, `unit`, `assets`, and `purchase-runtime`. The runtime receipt asserts NUL-key `400 invalid_request` and unchanged financial snapshots. Total helper-reported execution time across all attempts was 856.477 seconds (14m 16.5s). Evidence is under `.agentflow/runs/checks/a51aee7448d14823adfa2fce949af473/068-atomic-idempotent-token-purchase/develop/`; current successful receipt IDs: toolchain `c9f8e8b4bc0e47cd9b2727b17523c16c`, prepare `5e3267988d264abc98b918f5deead936`, services `93cb54812e34467c8bbfe1f531e5e2a7`, format `b1ddbeb9acf5490783e036f18f904383`, compile `bb55a1026b3a4ccfab25a24b3cf07964`, credo `e64314b0dcc74ce28f54a283feb8f37d`, openapi `b17b0455402c46c4963121c2f6213df7`, inventory `13f914b021f24cbaa867eff68ec1a697`, unit `adf8f4fe68ed44d89635db9eac383db5`, assets `c2873b89044c4e0ca0d920384ccd8ddb`, purchase-runtime `69b68c0dbc0f4d9c82ede35e7c39a891`.

`integration` failed twice and reached its retry limit: first `launch-failed`, then `permission-denied` (latest evidence `integration/b5859d08c70a49f7b4b3e7adc17efc59.log`). `e2e` failed twice and reached its retry limit: first `permission-denied`, then `launch-failed` (latest evidence `e2e/2398b08b4db8424bb800d8abd3953af0.log`). Browser stderr remains withheld by the profile runner, so the underlying OS denial could not be narrowed under the context policy. Both browser gates remain required.

`python3 scripts/workflow_artifact_probe.py develop --readiness` failed closed with `Incomplete implementation task: T027`; T027/T028 remain unchecked.

## QA guidance

After the configured browser launch succeeds under the manifest's `TMPDIR` and `CHROMIUM_PATH`, rerun all manifest checks through `agentflow_check.py` to refresh source-current receipts, then pass the development readiness gate before independent QA. Challenge all purchase invariants, including NUL-key refusal and discrepancy-only safe output.
