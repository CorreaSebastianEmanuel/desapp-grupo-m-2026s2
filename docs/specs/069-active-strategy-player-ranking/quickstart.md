# Ranking validation and demo

Use the repository's supported Elixir/OTP runtime and locked dependencies; retain the existing OpenAPI Node toolchain. Start local PostgreSQL/Redis with the existing compose configuration (`docker compose up -d`), then run `MIX_ENV=test mix infrastructure.verify` and `MIX_ENV=test mix test.prepare`. Never reset a shared database or disable immutable guards.

Implementation adds owned committed ranking fixtures based on existing quote/configuration helpers. No production strategy, calibration preset or live provider is needed. Fixture setup must create issued players, actual immutable saved configurations and fully confirmed quotes through existing contracts; no direct partial successful rows. Cleanup follows existing isolated-schema helpers, with no deletion of protected shared histories.

The user authorized direct completion after the three feedback cycles. Run checks directly; do not restart Agentflow. The retained manifest and historical reports describe earlier attempts.

For the bounded feature demonstration, run the assertion-based HTTP probe after service preparation:

```bash
MIX_ENV=test mix run scripts/verify_ranking_runtime.exs
```

The runtime script starts an actual local listener, waits for readiness, creates isolated committed fixtures and requests GET /api/ranking over TCP with the existing authentication mechanism. It asserts a nonempty deterministic ranking with exact prices/quote IDs, then empty, no-active and storage-failure cases in isolated stores; invalid authentication returns 401. See contracts/ranking.md for response bodies and headers. No raw credentials appear in output. Services/listener unavailable is failure, never skip/success.

The probe verifies four-player numeric/UUID ordering, full configuration identity and identical repeated responses, then empty/error outcomes and no persisted effects or provider calls. No demo endpoint or production seeds are needed. Chart/order/browser presentation remains outside TASK-033.

Use `ERL_FLAGS='+S 4:4'` on this local host to bound connection pools. Keep `AGENTFLOW_TOOLCHAIN_REQUIRED=''` for the CI wrapper: contextual toolchain detection still enforces the real workspace's pinned versions, while disposable launcher fixtures do not inherit a forced flag. Never set it to `false`.

## Feedback 3 focused repair controls (implementation stage)

After regression-first repairs and service preparation, run the existing affected files explicitly before a complete profile. Keep `MIX_ENV=test` and the real pinned workspace preflight; focused controls do not replace the CI wrapper.

```bash
MIX_ENV=test mix test test/football_market/ranking/selection_test.exs test/football_market/ranking/order_test.exs test/football_market/ranking/snapshot_test.exs test/football_market/ranking/safety_test.exs test/football_market_web/controllers/ranking_controller_test.exs
MIX_ENV=test mix test test/football_market_web/openapi_contract_test.exs test/football_market_web/openapi_browser_test.exs test/football_market/synchronization/scope_test.exs test/ci/workflow_scope_test.exs
node tools/openapi/validate.mjs priv/static/openapi.json
MIX_ENV=test mix run scripts/verify_ranking_runtime.exs
```

Expected controls include cross-season history, effective-time precedence over sequence, failed calculations, both snapshot schedules, all seven protected OpenAPI operations, credentials, and the merged QuoteRecovery configuration. After focused checks pass and source/inventories stabilize, independently run format, warnings-as-errors compilation, strict Credo, OpenAPI and inventory validation, the HTTP probe, `scripts/ci_unit_tests.sh` once, and `sh scripts/test_profile.sh e2e` once. Keep CI and independent QA/review gates; no historical CP1 report or duplicate full-profile pass is required. Preserve earlier failures and repeat checks only for changed inputs or diagnosed failures.
