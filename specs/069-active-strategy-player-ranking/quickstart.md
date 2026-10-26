# Ranking validation and demo

Use the repository's supported Elixir/OTP runtime and locked dependencies; retain the existing OpenAPI Node toolchain. Start local PostgreSQL/Redis with the existing compose configuration (`docker compose up -d`), then run `MIX_ENV=test mix infrastructure.verify` and `MIX_ENV=test mix test.prepare`. Never reset a shared database or disable immutable guards.

Implementation adds owned committed ranking fixtures based on existing quote/configuration helpers. No production strategy, calibration preset or live provider is needed. Fixture setup must create issued players, actual immutable saved configurations and fully confirmed quotes through existing contracts; no direct partial successful rows. Cleanup follows existing isolated-schema helpers, with no deletion of protected shared histories.

Run manifest checks in `verification.json` order with `python3 scripts/agentflow_check.py CHECK_ID --reuse`; the preflight and runtime entries are configured to execute fresh. After every development check passes, run `python3 scripts/workflow_artifact_probe.py develop --readiness`. QA uses `python3 scripts/agentflow_stage_checks.py --stage qa` without reuse.

For the bounded feature demonstration, execute the manifest's assertion-based runtime check after its prerequisites:

```bash
python3 scripts/agentflow_check.py runtime --reuse
```

The runtime script starts an actual local listener, waits for readiness, creates isolated committed fixtures and requests GET /api/ranking over TCP with the existing authentication mechanism. It asserts a nonempty deterministic ranking with exact prices/quote IDs, then empty, no-active and storage-failure cases in isolated stores; invalid authentication returns 401. See contracts/ranking.md for response bodies and headers. No raw credentials appear in output. Services/listener unavailable is failure, never skip/success.

For interactive inspection, implementation may use that same fixture harness locally and inspect the returned JSON; do not add demo endpoints or seed production data. The assertion script is the reproducible feature demo and is independent of provider availability. The manifest’s single `ci_profiles` check executes `scripts/ci_unit_tests.sh` with `MIX_ENV=test`, running both complete profiles once and verifying their receipts; do not also run separate full profiles; no historical CP1 report is required for this CP2 read. Overall chart/order/browser delivery remains outside TASK-033.

Feedback 2: the manifest scopes `AGENTFLOW_TOOLCHAIN_REQUIRED` to an empty string only for `ci_profiles`. This restores contextual pin detection for disposable launcher fixtures while the real `.tool-versions` still requires pinned tools. Never set it to `false`, change unrelated tooling/tests, erase prior failures or retry old inputs. Use the helpers with the repaired manifest; current feedback supersedes the earlier development handoff’s unrelated-tooling repair suggestion.

## Feedback 3 focused repair controls (implementation stage)

After regression-first repairs and service preparation, run the existing affected files explicitly before a complete profile. Keep `MIX_ENV=test` and the real pinned workspace preflight; focused controls do not replace the CI wrapper.

```bash
MIX_ENV=test mix test test/football_market/ranking/selection_test.exs test/football_market/ranking/order_test.exs test/football_market/ranking/snapshot_test.exs test/football_market/ranking/safety_test.exs test/football_market_web/controllers/ranking_controller_test.exs
MIX_ENV=test mix test test/football_market_web/openapi_contract_test.exs test/football_market_web/openapi_browser_test.exs test/football_market/synchronization/scope_test.exs test/ci/workflow_scope_test.exs
node tools/openapi/validate.mjs priv/static/openapi.json
python3 scripts/agentflow_check.py runtime
```

The runtime helper requires current preceding manifest checks; run missing prerequisites through their helpers first. Expected controls: exact active/latest selection and order, both committed snapshot schedules, exact three protected OpenAPI operations and statuses, intact catalog credential/error controls, merged QuoteRecovery cron, and finite workflow scope. Runtime must pass all HTTP outcomes against correctly selected owned stores, with boolean assertions and failure-safe cleanup. Known failures must be repaired before complete profiles. Then finish inventories/source edits and run the full manifest once through the helper; final runtime remains fresh, before `ci_profiles`. Preserve the historical failed attempts; no old-input third attempt. This session only plans those repairs and does not claim runtime acceptance.
