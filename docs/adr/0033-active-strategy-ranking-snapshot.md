# ADR-0033: Active strategy ranking snapshot

**Status**: Accepted for TASK-033 architecture within approved product decision
**Date**: 2026-10-26

## Context

TASK-033 needs ranking eligibility tied to committed successful performance quotes and a consistent view during activation. Product challenge identifies success-state and concurrency-test ambiguity. ADR-0023 owns immutable configuration selection; ADR-0029 owns confirmed performance history. No new product decision or infrastructure is needed.

## Decision

Provide Ranking.read/0 backed by one owned PostgreSQL REPEATABLE READ, READ ONLY transaction; fix the snapshot at its first data SELECT. Read active configuration through the existing decoder, then select latest matching successful confirmed quote per issued player by effective time/sequence. Sort price descending then canonical UUID ascending. Reject an incompatible enclosing transaction rather than weaken the snapshot. Activation keeps its existing READ COMMITTED write path.

Successful eligibility uses immutable quote_calculations.status=successful plus market_quotes linkage, protected by the existing deferred matching/confirmation guards. Evaluation delivery acknowledgement and execution-request leases are irrelevant. No quote recalculation, fallback or schema change.

Expose the fixed authenticated read at GET /api/ranking with exact decimal strings; distinguish HTTP 200 empty/nonempty, 409 no active configuration and safe 503 infrastructure failure. Keep existing 401 authentication. Full wire details belong to specs/069-active-strategy-player-ranking/contracts/ranking.md. This extends the market read interface, not its permission model.

## Consequences and alternatives

A reader pinned before activation may return the complete old result; activation committed before the first SELECT must be reflected. Controlled committed-connection tests prove both schedules and new-quote visibility. READ ONLY and no-effect assertions protect product invariants. Separate READ COMMITTED queries could mix snapshots; selection locks block unrelated activation; duplicating active selection/decoding in giant SQL creates another authority boundary. No mutable ranking table/cache, strategy pointer, new worker or dependency is justified. These are durable feature boundary decisions, with no deviation from the architecture baseline.

## Feedback 3 implementation and regression boundary

Current human feedback authorizes repairs within the settled design, not a product deviation. Apply all eligibility predicates before latest-per-player selection; one select per Ecto query level, with explicit subqueries for projected aliases and final order. Keep exact active-version success and snapshot semantics.

The finite additional test/harness allowance is `test/football_market_web/openapi_contract_test.exs`, `tools/openapi/browser.mjs`, and `test/football_market/synchronization/scope_test.exs`, with matching workflow-scope assertions/allowances and actual inventory membership maintenance. Assert the exact catalog-plus-ranking operations/statuses and preserve credential, refusal, precision and failure checks. Assert merged QuoteRecovery configuration without feature-directory special cases. No worker/configuration or shared QuotesCase change is permitted.

Repair ranking-owned fixture/runtime calls and dynamic Repo ownership; snapshots and faults must use the same owned store as HTTP. Preserve validated schema cleanup and prior process/application state. Focused regressions and actual runtime must pass before freezing sources and invoking the single complete CI wrapper. Retain nine obligations and both profile audits, with runtime before profiles; no historical CP1 coverage report or extra full-profile pass. Alternatives rejected: broaden application scope, weaken inherited guard assertions, modify shared fixture contracts, or spend complete profile runs rediscovering known local failures. Details and commands belong to the feature plan/tasks/quickstart.
