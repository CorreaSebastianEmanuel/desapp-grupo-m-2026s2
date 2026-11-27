# TASK-018 validation guide

Implementation supplies all planned source, migration and test paths. Execute checks through verification.json; passing development receipts do not replace independent QA/review.

## Prerequisites and setup

Use repository-pinned Elixir/OTP, Docker and existing PostgreSQL/Redis. Browser regression profile additionally needs repository Node 24, tools/openapi locked packages and installed Playwright Chromium; follow the executable prerequisites in scripts/test_profile.sh. No source credentials, live calls or access activation.

Current TASK-018 operational feedback supplies the pinned Elixir 1.20.3/OTP-29 installation at `/private/tmp/task018-elixir-1.20.3/bin`. Prepend that directory to PATH for every development, QA and review check. Use a non-login shell so PATH is preserved. This corrects the prior toolchain failure input; keep existing attempt history and all acceptance requirements unchanged.

The default shell selects Node 20 and fails the integration profile's Node 24 prerequisite. Use the existing `/Users/ezequielgonzalez/.nvm/versions/node/v24.21.0/bin` installation ahead of the default Node path for browser checks; no package or browser requirements are removed.

```sh
export PATH="/private/tmp/task018-elixir-1.20.3/bin:/Users/ezequielgonzalez/.nvm/versions/node/v24.21.0/bin:$PATH"
sh scripts/check_toolchain.sh
sh scripts/local_services.sh start
sh scripts/local_services.sh ready
MIX_ENV=test mix infrastructure.verify
MIX_ENV=test mix test.prepare
```

Initialize configured positions using test fixtures within test setup, never silently broaden production vocabulary. Existing accepted source labels/fixtures stay unchanged. Concurrent tests use separate connections and scoped committed test data; never reset the service volume.

The development run uses the repository's existing `MIX_TEST_PARTITION=task018_ingestion` mechanism for database checks. A failed early concurrency cleanup left a test-only GK position in the default test database; automatic review rejected deleting it. The isolated partition keeps that database intact and restores independent fixtures for the existing Catalog regressions. Each relevant manifest check declares this partition; QA uses the same partition with its own fresh checks. Cleanup of the default database fixture requires human authorization. No production database or provider configuration changes.

## Executable owner verification

After all source/design edits, run each manifest check once through `python3 scripts/agentflow_check.py CHECK_ID --reuse` in manifest order. Fresh service checks set reuse=false. QA uses `--stage qa` without reuse. Stop after two unchanged failures; diagnose evidence, not repeat profiles. Run `python3 scripts/workflow_artifact_probe.py develop --readiness` only after owner checklist completion/current receipts. No historical CP1 coverage report or duplicate final all-tests invocation. Focused acceptance tests are deliberate feature checks; the two full profiles each run once.

## Story acceptance matrix

Numbered scenarios below refer to spec.md; there are no separate AC IDs in that document.

| Scenario | Planned executable test file (under test/football_market/catalog/ingestion/) | Assertion |
|---|---|---|
| US1.1 | publication_test.exs, matrix_test.exs | Five leagues/two seasons, exact independently expected relationships/bindings/counts |
| US1.2 | identity_test.exs | Addition/name/position/transfer changes preserve UUID/catalog identity |
| US1.3 | publication_test.exs | Missing portions/duplicates/invalid relations and injected write failures leave zero partial state |
| US1.4 | isolation_test.exs | Local search/filter/detail reads work with source unavailable, zero calls |
| US2.1 | replay_test.exs | Ten exact repeats return original reference, zero new rows/evidence |
| US2.2 | canonical_test.exs, replay_test.exs | Reordering/references do not alter identity; later observation changes only evidence |
| US2.3 | identity_test.exs | Same names distinct; qualified ID provider/kind/season separation |
| US2.4 | identity_test.exs | Unbound collision and unmapped replacement fail whole import |
| US2.5 | identity_test.exs | Explicit replacement maps stable IDs; invalid/foreign/collapsing instructions fail |
| US2.6 | concurrency_test.exs | Same/different delivery overlap at revision 0/n, shared missing league across seasons |
| US3.1 | retention_test.exs, replay_test.exs | Stale no-op; accepted old replay never restores facts; future-clock limitation |
| US3.2 | retention_test.exs | Omitted entities/relationships/bindings retained |
| US3.3 | retention_test.exs | Complete empty accepted; unknown/unsupported/incomplete remain failures |
| US3.4 | retention_test.exs | Equal instant with different facts/provider/fixture conflicts |
| US3.5 | outcome_test.exs, publication_test.exs | Every provider category/retry delay safely preserved, failure rollback |
| US3.6 | outcome_test.exs, isolation_test.exs | Offline attribution, deny-only live blocker, no readiness/freshness/quote effects |

Additional critic/edge evidence: reconciliation_test.exs and publication_test.exs prove case/whitespace uniqueness, valid bound-team name/code swaps, collision with omitted teams, row-order independence for bound rename/transfer and same-name additions. concurrency_test.exs uses explicit barriers and independent observer to assert old-or-complete-new visibility; failpoints cover before/after each write class. replay_test.exs simulates lost reply after commit. isolation_test.exs asserts unrelated scopes, event-time matches/performances, users and credentials unchanged, and excludes financial writes. outcome_test.exs includes timeout/late completion and no automatic retry.

`matrix_test.exs` runs the entire five-league/two-season fixture matrix twice in separate SQL Sandbox owners with rolled-back fixtures, compares independently expected records/counts/statuses and normalized semantic evidence (excluding fresh random UUIDs/local acceptance times). Do not derive expected facts from the production canonicalizer. Tests assert zero external network attempts and no required credentials; use existing fixture adapter, not a live substitute.

## Expected evidence

Each manifest ID exits 0 with assertions exercised; owner check receipts remain local. Two profiles must include all new modules with exactly one module-level profile tag. QA reports all story scenarios and adversarial boundaries with fresh evidence. Final QA/review end `Verdict: PASS` only after actual execution. CP2 catalog support does not establish completion of charts, additional conditional orders, valuation or permitted live statistics.
