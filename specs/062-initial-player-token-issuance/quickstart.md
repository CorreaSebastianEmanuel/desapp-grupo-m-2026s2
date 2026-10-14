# Validation guide — TASK-028

The implementation and named assertion tests are present; current receipts establish execution results. See contracts/initialization.md for exact outcomes and data-model.md for DB obligations.

## Prerequisites and services

Use the pinned repository Elixir/Erlang toolchain, dependencies, PostgreSQL/Redis and Node 24/installed Playwright Chromium required by the existing integration runner (`tools/openapi/package-lock.json`). Keep credentials in the local environment; do not print connection/password values or include them in manifest argv. Test DB isolation guard remains authoritative.

From repository root:

```sh
sh scripts/local_services.sh start
python3 scripts/agentflow_check.py toolchain --reuse
python3 scripts/agentflow_check.py database_prepare --reuse
python3 scripts/agentflow_check.py service_preflight --reuse
```

The last two operations also appear in the final manifest: preparatory local runs are not passing final receipts. PostgreSQL/Redis unavailability, absent migrations or browser prerequisites fail visibly. Never reset volumes, truncate financial history or delete committed audit fixtures.

## Final developer execution

Finish all implementation/design edits before these checks. Run the exact manifest entries through the evidence helper in order:

```sh
python3 scripts/agentflow_check.py toolchain --reuse
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py database_prepare --reuse
python3 scripts/agentflow_check.py service_preflight --reuse
python3 scripts/agentflow_check.py prefix_regression --reuse
python3 scripts/agentflow_check.py unit_profile --reuse
python3 scripts/agentflow_check.py integration_profile --reuse
python3 scripts/workflow_artifact_probe.py develop --readiness
```

Fresh service/database checks have reuse=false. Final unit/integration profiles run once each for unchanged inputs. Do not run coverage_report.sh or mix test.cp1_coverage as an additional local CP2 gate; preserve their existing CI behavior. If a receipt is stale after a source/design correction, rerun affected checks under the helper's current-fingerprint policy. Stop after two unchanged failures and diagnose; do not bypass the helper. Mark implementation/check tasks only after required files and passing checks exist; only downstream QA/review stay unchecked.

## Required asserted scenarios

| Probe | Expected evidence |
|---|---|
| First initialization, fresh player + designated existing user | issued; one quote of exact 1, one issuance of 100, original owner's holding 100, other owners zero, original value 100, retained IDs/version/dates. |
| Multiple players; display-name refresh; season identities | 100 per stable player; same market recipient; no display-name-derived mint; distinct season IDs remain distinct supplies. |
| Retry after valid redistribution 80/20 and 0/100; additional dated quote | already_completed, same original evidence; exact unchanged holdings, all quotes and balance sentinels. |
| Duplicate concurrent calls / different-player first recipients | Distinct pg_backend_pid connections and barriers; one player issuance, same success identity; conflicting captured recipient cannot issue another player. |
| Pre-commit failures after each insert; lost acknowledgement | First case leaves no new rows/recipient/balance changes then retry issues once; committed lost response reloads and returns existing issuance. |
| Retry during atomic transfer; first issuance during quote insert | Coordinated player locks block; snapshots observe before or after complete transfer, never torn aggregate; quote-first rejects unissued history, issuance-first leaves one valid original plus later quote. |
| Missing player, empty/multiple/nonexistent designation, wrong assertions, recipient change | Specific safe failure; no account created or financial change; same validation on already-issued player. |
| Orphan/contradictory history, 120/-20 holdings, wrong player quote | inconsistent_state, no repair. Production DB constraints reject ordinary impossible writes; pure/isolated legacy fixtures test defensive validator. |
| Ordinary UPDATE/DELETE/TRUNCATE of evidence; fractional/negative/inflating holding writes | Guard/constraint failure with original evidence unchanged; wrong-owner first-commit inserts fail; valid atomic transfer conserves 100. |
| Explicit migration prefix with a different populated search_path | Migration succeeds; destination contains the single lock row 1; source lock rows and all account/market snapshots remain unchanged. Permanent storage_test prefix_regression also executes in integration_profile. |
| Restart/fresh clients without providers/statistics/active strategy | Reload retained evidence/recipient and successful validated retry using new application instance; no duplicated state. |

All probes live in files mapped by traceability.md and execute in the audited profiles. Transactions/races run in guarded, unique test schemas with distinct clients; no shared-sandbox pseudo-concurrency. No HTTP endpoint is affected, so no synthetic HTTP runtime check is included. If implementation adds an endpoint, stop the scope expansion and reconcile approved spec/plan/manifest including actual readiness/status/header/body assertions.

## Independent QA and CP2 demo

QA reruns each manifest entry independently with `--stage qa`, never --reuse. It challenges every traceability row, verifies no skipped cases, and starts real dependencies. Review uses that fresh QA evidence and targeted checks for remaining risks. Reports end exactly in Verdict: PASS only on success.

For the CP2 demo, trusted operator code designates one **existing** user, initializes a **fresh unquoted** player, shows original evidence with get_initial_issuance, then hands the player to downstream valuation/trading. Demonstrate rejection of an unissued player with prior quotes. Do not promise all catalog entries become tradable or claim this feature completes charts, conditional orders or browser market E2E.
