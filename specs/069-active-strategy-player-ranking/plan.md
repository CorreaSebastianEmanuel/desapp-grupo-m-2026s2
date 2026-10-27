# Implementation Plan: Active Strategy Player Ranking

**Branch**: `033-active-strategy-player-ranking` | **Date**: 2026-10-26 | **Spec**: [spec.md](spec.md)
**Task**: TASK-033 | **Checkpoint**: CP2

## Direct completion — 2026-10-27

The user authorized completion on the existing branch without Agentflow orchestration or another feedback cycle. Preserve the original decisions and historical evidence; run the existing checks directly, one stable full CI pass, independent QA and a fresh final review. Main is integrated through `d1a0d76` (including TASK-027, TASK-056 and TASK-036). The inherited API guards now cover six operations and TASK-056's player-detail response. Remaining changes close QA B1/B2 using existing confirmed-quote helpers and the ranking-owned HTTP probe; no application redesign or scope expansion.

## Summary

Expose one authenticated local ranking read through `FootballMarket.Ranking.read/0` and `GET /api/ranking`. Select each issued player's latest successful performance quote for the exact active saved configuration, then sort price descending and canonical UUID ascending. Return configuration identity and consecutive positions. Preserve sparse results and distinguish absent activation from infrastructure failure.

## Technical Context

- Language: Elixir ~> 1.20.3, existing OTP application and locked dependencies.
- Dependencies: Phoenix 1.8, Ecto SQL/Postgrex, Decimal, Jason; use existing API authentication. No new dependency, cache, worker or external adapter.
- Storage: authoritative PostgreSQL; existing `market_quotes`, `quote_calculations`, `market_issuances`, valuation configuration versions and append-only selection changes. No migration or persisted ranking.
- Testing: ExUnit, existing unit/integration profile discovery and actual HTTP listener. Deterministic locally committed fixtures; no live football service.
- Platform/type: existing modular Phoenix monolith on the supported local Linux toolchain.
- Performance/scope: one complete unpaginated ranking; database selects one row per eligible player. No new latency SLA or speculative index/cache. UUID ordering and numeric ordering stay in PostgreSQL; never sort monetary strings or floats.
- Constraints: read-only repeatable snapshot, exact decimal JSON strings, existing immutable quote/configuration contracts. No new strategy activation, quote creation, individual history endpoint, frontend or CP3 cache.
- Unknowns: resolved through focused repository inspection in research.md; no external technology research needed.

## Constitution Check

Pre-design: PASS. Approved spec and product decision define behavior; critic findings need implementation boundaries only. Feedback 1–3 in `backlog/feedback/TASK-033.md` is authoritative: preserve existing implementation and tests; repair verification integration and the finite implementation/test boundaries described below; product behavior remains fixed. Current policy explicitly omits a default historical CP1 coverage report.

Post-design: PASS. Domain rules stay in Ranking, SQL in Ranking.Reader, authentication/serialization in web adapters. Read-only transaction enforces zero product writes. Exact Decimal/UUID/time contracts retain precision and immutable history. Test-first tasks and executable verification precede independent QA/review. No new infrastructure or constitution exception. ADR-0033 records the durable snapshot/interface boundary, extending ADR-0023/0029 without changing their write contracts.

## Phase 0: Decisions and critic resolution

1. Successful means `quote_calculations.status = 'successful'`, joined by `market_quotes.calculation_id`, with exact configuration and player linkage. The quote/evaluation deferred constraints in migrations `20261018000000` and `20261018001100` guarantee committed confirmation, matching positive price/effective time and one evaluation event. Request/delivery state is not the success oracle; pending delivery remains eligible. Do not weaken guards to manufacture incomplete positive fixtures.
2. Use one owned `REPEATABLE READ, READ ONLY` transaction. Set isolation before any data SELECT; snapshot linearizes at the first active-configuration SELECT, not BEGIN or HTTP arrival. Reuse Configurations.active/0 on the same Repo connection, then query quotes. Activation committed before the first SELECT must be seen; activation committed after it may produce the complete old snapshot. Tests control both schedules and an intervening quote commit. Never activate inside the read transaction or borrow an incompatible caller transaction silently.
3. Use protected market-read API policy on a separate `/api/ranking` route, avoiding `/api/players/:player_id` ambiguity. No browser UI or pagination/filter semantics are introduced. Stable errors and exact response are in contracts/ranking.md.

## Phase 1: Implementation boundary

`Ranking.read/0` owns one read operation. `Ranking.Reader` establishes the read-only snapshot and calls the existing configuration read, preserving a missing serialization anchor or bad configuration as infrastructure failure. Reject an already active transaction with a safe storage-unavailable outcome rather than accepting a READ COMMITTED caller snapshot; test harness must use committed fixtures/owned connections. Catch only known database/connection failures at this boundary; never broadly turn arbitrary exceptions into empty success or log credentials/raw exception details.

Keep all eligibility predicates on the quote/calculation join before DISTINCT ON. Project once at each query level: computed projected aliases may be read only through an explicit subquery, never as schema fields on the original query. Do not compose a second select onto an already selected Ecto query. An outer subquery orders the selected rows and projects the response fields.

Within that snapshot, query issued players joined to performance quotes and successful calculations, bound to active version UUID and matching strategy/formula version. Require positive price, nonnull calculation/configuration and positive sequence, excluding initial issuance explicitly. Match calculation and quote player/configuration/price/effective time. `DISTINCT ON (player_id)` ordered by player ID, effective_at DESC, performance_sequence DESC chooses the latest eligible row across all seasons; outer order is numeric unit_price DESC, player_id ASC. Enumerate the resulting total order from 1. UUID canonical text ordering agrees with PostgreSQL UUID byte order. Return selected quote IDs, exact Decimal prices and UTC microsecond times; do not read mutable display metadata to determine order.

No join to calculation-request execution or evaluation delivery state. No requirement that a quote's strategy remain the player's most recent overall quote. Config UUID is the saved version identity; do not invent a second configuration revision number.

Controller delegates to Ranking and renders the documented shape; existing AuthenticateAPI protects it before any ranking query. Update `priv/static/openapi.json` and validate with the existing locked OpenAPI tool. No credential values or infrastructure details in bodies/logs. Use a JSON renderer independent of persistence structs.

## Project Structure

```text
lib/football_market/ranking.ex                  # domain result/error boundary
lib/football_market/ranking/reader.ex           # snapshot and query
lib/football_market_web/controllers/ranking_controller.ex
lib/football_market_web/controllers/ranking_json.ex
lib/football_market_web/router.ex               # protected route
priv/static/openapi.json                        # external API schema
test/support/ranking_case.ex                   # owned committed store and fixtures
test/football_market/ranking/selection_test.exs
test/football_market/ranking/order_test.exs
test/football_market/ranking/snapshot_test.exs
test/football_market/ranking/safety_test.exs
test/football_market_web/controllers/ranking_controller_test.exs
 scripts/verify_ranking_runtime.exs
```

Documentation in this directory: research.md, data-model.md, contracts/ranking.md, quickstart.md, verification.json, tasks.md and bounded handoffs. Existing ADR-0023, ADR-0029 and new docs/adr/0033-active-strategy-ranking-snapshot.md own durable decisions.

## Validation and checkpoint coverage

Tests must first fail for the missing ranking behavior. Selection fixtures use the real confirmation path or equivalent complete constraint-valid transactions: active/inactive same-formula configurations, initial-only, no_quote/failure outcomes, no history, positive successful performance, cross-season recency, equal-time different sequences. Do not insert impossible failed quotes by disabling constraints. Known expected quote IDs and exact prices are the oracle.

Race tests use two actual committed connections and explicit message barriers, no timing sleeps: pin reader snapshot, commit activation and new quote on writer, resume reader; separately commit before reader's first SELECT. Assert configuration and every selected quote. Missing anchor/database outage remains error. Use READ ONLY plus before/after identities/counts for quote, configuration/selection, audit, holdings/issuance, calculation/evaluation/request and Oban rows; provider spy raises on any call. Verify total token supply stays 100, stored prices/history unchanged and no jobs enqueued.

Manifest maps all 11 FR and 5 SC IDs; the spec has numbered story scenarios but no AC IDs. Their matrix is in tasks.md. The `ci_parity` check validates the wrapper contract before expensive checks (zero native profile runs). The single `ci_profiles` obligation runs `scripts/ci_unit_tests.sh` with `MIX_ENV=test` and `AGENTFLOW_TOOLCHAIN_REQUIRED=""`, executing unit and integration once each and verifying their receipts; new ranking ExUnit tests are integration-tagged and discovered there. The dedicated socket HTTP script uses explicit execution in `runtime`, lives outside ExUnit discovery, and is not rediscovered by either profile. Targeted runtime proof before source freeze and a fresh final runtime are intentional; full profiles execute only once per final attempt. OpenAPI lint, format, compile and strict Credo remain mandatory. No CP1 coverage report or duplicate complete-profile pass. E2E profile/browser scope is unchanged: this adds an API, no frontend journey. CP2 ranking is delivered here; charts/orders and overall checkpoint acceptance stay with their owning tasks.

Implementation owner executes every manifest check after final edits, then readiness; QA reruns fresh independently and challenges semantic mappings. Final review follows QA PASS and checks scope, precision, invariants and checkpoint evidence. Only those two downstream tasks can be deferred. Architecture validation proves document/manifest structure only, not application behavior.

## Mechanical integration allowances

Implementation may update the new feature entry in `test/support/workflow_scope.ex`, with a matching assertion in `test/ci/workflow_scope_test.exs`; existing feature scopes remain unchanged. Feedback 3 additionally permits exactly `test/football_market_web/openapi_contract_test.exs`, `tools/openapi/browser.mjs`, and `test/football_market/synchronization/scope_test.exs` for the inherited guard repairs below. The existing `test/football_market_web/openapi_browser_test.exs` is an execution target, not an additional modification allowance. Refresh `config/credo_inventory.json` for actual new Elixir inputs, `config/application_coverage_inventory.json` for actual new application modules, and `config/test_profiles.json` for newly added integration tests with `python3 scripts/test_inventory.py update --profile integration`. Keep exclusions, historical CP1 denominator, existing assignments, thresholds and CI unchanged. These inventories are maintenance prerequisites, not new full-profile report obligations. Stage new files only if required by the existing tracked-input inventory oracle; no commit or publication is part of this stage.

## Feedback repair and resumption

Feedback 1 changes verification integration only. Replace separate `unit`/`integration` obligations and every FR/SC reference with `ci_profiles`; keep one cheap `ci_parity` obligation first, followed by preflight, format, compile, Credo, OpenAPI, runtime, `ci_profiles` and diff (nine checks). This preserves both complete profiles without duplicate executions. Runtime retains its own fresh service verification and real HTTP assertions. No historical CP1 coverage report is added.

Preserve the existing code/tests and `handoffs/develop.md` evidence. Its current residual fixture/assertion matrix, committed-connection race tests and unexecuted HTTP evidence remain mandatory unfinished implementation work in T003–T016, followed by all final checks. Do not rewrite product artifacts or reconstruct old red evidence: on resumption, add a regression that exposes each missing assertion before repairing behavior, retain genuine earlier evidence, and never mark a task complete from file existence. Architecture checks establish structural alignment only.

Feedback 2 corrects only `ci_profiles.env.AGENTFLOW_TOOLCHAIN_REQUIRED` to the empty string. The workflow-only forced `true` flag leaked into disposable launcher fixtures without `.tool-versions`, preventing their stub from launching. `scripts/agentflow_preflight.py:evaluate` still invokes pinned-toolchain checks whenever the real workspace has `.tool-versions`; empty restores that contextual policy, while `false` would bypass it and is forbidden here. Keep the wrapper argv, MIX_ENV, all tests and real service/toolchain checks unchanged. Do not edit tooling or unrelated launcher tests. This is a scoped verification input repair, not a new architecture deviation; ADR-0033 remains authoritative.

Preserve the two previous failed attempts and the existing development handoff as historical evidence. The corrected relevant environment input permits a repaired attempt through the helpers; do not retry the old input or manufacture/reset receipts. Before finalizing architecture, run cheap CI parity, the focused launcher regression under the corrected environment and an assertion-based contextual policy probe for pinned and unpinned workspaces. These bounded checks do not replace the implementation owner's complete manifest/readiness or independent QA. Read the current feedback before resumption; the old development handoff's suggestion to repair unrelated tooling is superseded by Feedback 2.

## Feedback 3: bounded repair before complete profiles

Current human feedback is authoritative; this is the third and final authorized repair cycle. Preserve previous evidence and all nine manifest obligations. Do not run a fourth feedback cycle or retry unchanged failed inputs. No new product decision, dependency, worker, configuration, shared quote helper or financial write is authorized. ADR-0033 records this finite boundary.

1. **Query and fixtures:** repair the Ecto select/subquery boundary described above in `lib/football_market/ranking/reader.ex`. Diagnose using the real integration profile environment, preserving latest-eligible selection and exact ordering. In ranking tests use `QuotesCase.rules(f.base)` (or a ranking-owned wrapper accepting the nested fixture); `rules` expects `%{position: ...}`, not the nested quote fixture or bare position. Keep shared `test/support/quotes/case.ex` unchanged. RankingCase must retain and return its owned `%{schema, repo}` alongside the quote fixture so committed reader/writer tests actually use the intended connections; the current nested quote fixture does not supply `repo`. Correct the enclosing transaction assertion to match Repo.transaction's outer `{:ok, inner_result}` rather than mistaking it for the domain result. Preserve both committed race schedules and their explicit quote/configuration oracles.
2. **Published contract:** in `test/football_market_web/openapi_contract_test.exs`, assert the exact catalog-plus-ranking protected route set and explicit per-operation response sets, including ranking 200/401/409/503. Unknown operations must fail; preserve catalog parameters, auth, error, precision and rejection assertions. In `tools/openapi/browser.mjs`, locate operations by stable operation ID or exact path/method; assert the exact three operations, expand ranking for status discovery, and retain catalog try-out, credential switching, no credential leakage/storage, origin and failed asset/contract checks. Assert ranking discovery and its exact response statuses without expanding browser product behavior.
3. **Merged worker guard:** `test/football_market/synchronization/scope_test.exs` must assert the current merged QuoteRecovery cron configuration independently of feature-directory labels. Preserve every other boundary assertion. No `config/` behavior, Oban worker or scheduling change is permitted.
4. **Runtime:** use an owned schema matching the existing client's `valuation_test_[a-f0-9]+` validation; do not loosen shared validation. Call `QuotesCase.rules(%{position: base.position})` and real `Quotes.Mappings.save/3`. Match `[entry]` separately, then send a boolean to `assert!`. Set the process's dynamic Repo and HTTP plug's Repo to the same owned store before each fixture, request, fault and before/after snapshot. Switching the plug's application environment alone does not switch the script process. Snapshot each outcome in its correct store, retaining all contract assertions. Cleanup must stop the owned listener/Repo processes, restore prior dynamic Repo/application environment/provider state, and drop only validated, created, owned schemas, even after partial setup failures; never delete shared history. Keep all new utilities in RankingCase or the runtime script.

Implementation sequence: add or correct regression oracles first (retain actual prior red evidence), repair fixtures/query and finite guards, run bounded controls for each known failure, and execute actual HTTP runtime before the complete wrapper. Required focused controls are the five ranking test files plus OpenAPI contract/browser, synchronization scope and workflow-scope tests (explicit paths in tasks.md), OpenAPI validation, and the runtime script after infrastructure verification. A targeted test invocation is not another full profile. Fix every focused failure before finalizing inventories/source inputs. Then freeze source/design inputs and execute one complete manifest through the helper. Runtime precedes `ci_profiles` in the dependency chain so known HTTP defects cannot first surface after a costly profile pass. Its final invocation remains fresh. Do not weaken assertions or interpret file existence as task completion.

## Complexity Tracking

No constitution violations. Read-only multi-query snapshot reuses the active configuration decoder rather than introducing a mutable active pointer or a parallel configuration reader. No cache, index or schema work is currently justified.

## Supporting artifact applicability

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve concrete confirmation-success and snapshot boundaries raised by the critic using current code."},
  "data_model": {"required": true, "reason": "Define new ephemeral ranking result and existing persisted joins; no schema migration."},
  "contracts": {"required": true, "reason": "Add an authenticated ranking HTTP interface and domain result contract."},
  "quickstart": {"required": true, "reason": "Describe service setup and feature-specific socket runtime demonstration/assertions."}
}
```
