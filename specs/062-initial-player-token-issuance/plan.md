# Implementation Plan: Initial Player Token Issuance

**Branch**: `062-initial-player-token-issuance` | **Date**: 2026-10-14 | **Spec**: [spec.md](spec.md)
**Backlog**: TASK-028, CP2. The spec's `028-...` label is descriptive legacy metadata; `.specify/feature.json` and setup-plan resolve this delivery to `062-...`. Do not rename the feature or amend approved behavior.

## Summary

Add an internal Market context that initializes an existing season-specific player once: 100 integer tokens, all assigned to one existing designated market-wide recipient, at an exact one-credit quote. PostgreSQL commits recipient fixation, quote, holding and issuance together. Locks coordinate duplicate requests and future financial writers. Valid retries identify retained issuance; invalid or contradictory state fails without repair. No web route, public CLI, ingestion hook, balance account, trade, worker or performance quote calculation is added.

Read `contracts/initialization.md` for invocation/outcomes and writer coordination, `data-model.md` for integrity, and ADR-0024 for durable design decisions. Approved product-decision requires no new human choice; no TASK-028 feedback file exists at planning time. Later recorded feedback takes precedence.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3` from mix.exs; existing Erlang/toolchain pinned by repository checks.
**Dependencies**: Existing Phoenix 1.8, Ecto SQL 3.13, Postgrex and Decimal (already available). No dependency change. Phoenix/LiveView remain outside this feature's execution path.
**Storage**: Existing PostgreSQL; UUID identities, integer quantities, unbounded NUMERIC/Ecto Decimal credits and UTC microsecond timestamps. No Redis financial authority or Oban work.
**Testing**: ExUnit with one module-level `:unit` or `:integration` tag per module, existing audited profiles, real independent PostgreSQL connections and fresh BEAM processes. Controlled fixtures replace future trading/valuation behavior and external providers.
**Platform/Type**: Existing local modular Phoenix monolith on Linux; internal trusted domain capability.
**Performance goals**: No invented latency SLA. Bounded one-player initialization; aggregate holdings for that player. A market lock serializes initialization only; trades/quotes acquire the player lock.
**Constraints**: Fixed supply/price, exact credits, immutable evidence, atomic/idempotent operation; non-configurable public financial facts; no prerequisite on statistics/provider/configuration.
**Scale/Scope**: One issuance per existing `players.id`, separate supply per season-specific record. Explicit per-player setup; no catalog-wide automation.
**Unknowns**: All concrete questions resolved by local code inspection in research.md. No technology survey or research delegation needed.

## Constitution Check

Pre-design evaluation and post-design re-evaluation both pass as a design assessment:

| Principle | Evidence / boundary |
|---|---|
| I Specification first | FR-001–014, SC-001–006 and every story scenario mapped in traceability.md and verification.json; test tasks precede the corresponding implementation. |
| II Domain integrity | Deferred conserved holdings total; integers/nonnegative holdings; exact NUMERIC; one issuance; restrictive FKs; append-only quote/issuance/recipient guards; coherent retry validation. No balance mutations/trades. |
| III Modular simplicity | Market façade → pure rules / persistence store → Repo. Existing catalog/users reused; no controllers, provider adapter or infrastructure added. |
| IV Evidence quality | Formatting, warnings-as-errors compile, service preflight, both audited test profiles exactly once per final source set. DB race, failure, immutability and restart assertions belong to integration profile. |
| V Independent verification | Implementation owner executes every manifest check; QA reruns independently; final review uses fresh QA evidence with targeted extra checks for uncovered risks. Only T025/T026 are downstream gates. |

These are design conclusions, not claims of implementation checks passing. No constitution exception. ADR-0024 records the fixed initial rule's separation from performance-strategy selection and shared quote persistence boundary.

## Phase 0: Focused research

Reuse docs/ARCHITECTURE.md, ADR-0002/0003 (existing identities), ADR-0010 (immutable DB facts), ADR-0020/0023 (valuation evidence/selection). Local inspection confirms users have no roles/balance field, and there is no quote/holding store. Select the contract below without extending Accounts or Valuation. research.md records alternatives and code evidence. No unresolved material decision.

## Phase 1: Design

### Trusted boundary and designation

`FootballMarket.Market.initialize_player(player_id)` loads the internal application setting `:initial_issuance_recipients`, expected as exactly one existing UUID. Default absence fails safely. A compatibility assertion-map argument may assert recipient/quantity/unit_price but never select defaults or change the allocation. Reject unknown options and floats. No route or new Mix task exposes it; trusted operator code invokes the context using existing local identities. Capture a valid designation once per call; transactionally compare it with immutable `market_initial_recipients` and every existing issuance's recipient before any success. A concurrent designation change takes effect on a later invocation; competing captured values cannot both establish different recipients.

### Transaction and linearization

Use READ COMMITTED, reject unsupported isolation for writes/retries and an initialization call already inside a caller transaction, and run one top-level Repo transaction. This prevents a successful response before durable commit; evidence retrieval may run within a read transaction. Acquire seeded `market_initialization_locks.id=1 FOR UPDATE`, then the requested `players.id FOR UPDATE`; validate user existence under key-share protection. All quote and holding mutations acquire the same player lock through DB guards. Read all validation facts after the locks; snapshots cannot straddle a coordinated transfer. Multiple-player future writers lock players in ascending UUID order; initialization always takes the market lock first. Do not implement those future writers here.

Validate current designation, assertion inputs, player existence, recipient consistency and all retained state before deciding first versus already-completed. If any applicable failure exists, report it; no mandatory precedence among multiple errors. A first issuance requires no holdings/quotes. Insert the singleton recipient only on first success, then initial quote, superuser holding and issuance; defer linked invariants until commit. Recheck canonical facts and commit. The deferred insertion guard also verifies that the first committed holdings are all 100 for the original recipient, not just a conserved total held by another account. Unique player issuance/initial quote plus DB recipient checks backstop duplicate context calls. The supply is the immutable issuance quantity plus conserved holdings aggregate, not a redundant mutable supply counter.

After commit, return `issued` with durable evidence. Retried committed operations return `already_completed` only after fresh validation. Pre-commit exceptions rollback all new rows, including first recipient fixation; storage/lock errors return an explicit storage failure, never success. Lost acknowledgement after commit retains rows; retry identifies them. Do not compensate by deleting history. SC-003's interrupted cases mean uncompleted attempts per US2 scenario 3/FR-006; the critic's post-commit case is governed by FR-008/009.

### Persistence enforcement and inconsistency

See data-model.md for named constraints/guards. DB enforcement prevents ordinary invalid writes while pure consistency validation also detects contradictory legacy/corrupt snapshots: 120/-20 holdings, unknown identities, noncanonical issuance value, quote linked to a different player, missing/contradictory timestamps/version, wrong market recipient, or missing evidence. A zero holding (or absent row) for the original recipient after a valid redistribution is permitted if the aggregate remains 100. Detect, never reconcile. Controlled inconsistent fixtures use pure snapshots and a test-owned legacy namespace; do not disable production guards, delete audit rows or mutate shared financial fixtures.

All affected DB guards use schema-qualified migration-prefix references so private-schema/fresh-client tests remain isolated. Append-only UPDATE/DELETE/statement TRUNCATE guards cover quotes, issuances and fixed recipient; protect the seeded lock from removal. Holdings are mutable future inventory; changing player/owner keys requires delete/insert under player locks and deferred conservation. No destructive operations are validation commands. Ordinary DB DML is protected; a database owner disabling constraints/DDL is outside the application trust boundary.

### Shared quote boundary and downstream ordering

`market_quotes` is the single durable quote table introduced here for the fixed initialization rule. Future TASK-026 must extend/reuse it with its required performance evidence, configuration binding and current quote selection; this feature does not implement those behaviors. Test-only later quotes use fixture rule IDs, never a second store. The fixed initialization rule `initial_issuance`/`1` is independent of an active performance strategy; sample one DB UTC instant after locks for effective/completion time (not exact commit-clock time). Initial inventory value is derived exactly as 100 × 1; retain no float representation.

CP2 setup initializes each fresh eligible player **before** performance valuation. A quoted but unissued player is rejected; no backfill/top-up/ingestion automation. TASK-029/030 must coordinate holdings and conserve supply; all future quote writers use the same player lock. This feature supplies a CP2 market prerequisite, not the full charts/additional-feature/browser-E2E deliverable.

## Project Structure and implementation boundary

Documentation: plan.md, research.md, data-model.md, contracts/initialization.md, quickstart.md, traceability.md, tasks.md, verification.json, handoffs/architecture.md, handoffs/tasks.md in this feature; docs/adr/0024-atomic-initial-player-issuance.md.

Exact allowed source/test changes (new unless explicitly existing):

```text
config/config.exs                                  # existing: fail-closed empty designation only
lib/football_market/market.ex                      # trusted façade
lib/football_market/market/input.ex                # pure assertion/designation validation
lib/football_market/market/consistency.ex          # pure snapshot integrity
lib/football_market/market/error.ex                # typed safe failures
lib/football_market/market/store.ex                # all Repo/SQL operations
lib/football_market/market/initialization_lock.ex
lib/football_market/market/initial_recipient.ex
lib/football_market/market/holding.ex
lib/football_market/market/quote.ex
lib/football_market/market/issuance.ex
priv/repo/migrations/20261014000000_create_initial_player_issuance.exs
test/support/market_case.ex                       # fixtures, committed namespace, barriers, restart
test/football_market/market/input_test.exs         # unit
test/football_market/market/consistency_test.exs   # unit
test/football_market/market/issuance_test.exs      # integration
test/football_market/market/storage_test.exs      # integration
test/football_market/market/durability_test.exs   # integration
test/football_market/market/retry_test.exs         # integration
test/football_market/market/concurrency_test.exs   # integration
test/football_market/market/rollback_test.exs      # integration
test/football_market/market/rejection_test.exs     # integration
test/football_market/market/scope_test.exs          # integration
test/football_market/statistics/scope_test.exs     # existing: exact active-feature allowance only
test/football_market/providers/scope_test.exs      # existing: exact active-feature allowance only
```

No mix.exs/dependency, web/router/OpenAPI, Accounts schema, Catalog ingestion, Valuation implementation, CI or coverage inventory changes. Exact scope extensions preserve legacy feature allowances and fail on an unknown feature/unplanned path. Scope test checks production dependency direction, table write inventory, no account/credential/balance writes, no provider/valuation invocation, no jobs/events and no HTTP interface. Supporting fixtures may observe a test-only balance-sentinel table; production has no balances today. This preserves FR-005 without inventing funding or purchasing.

## Verification and delivery boundary

verification.json maps all 20 canonical FR/SC identifiers. Spec has numbered acceptance scenarios, no AC identifiers; traceability.md maps all 16 scenarios and edge cases to named test files. Developer checks: format, compile, test DB preparation, application-client service preflight, audited unit profile and audited integration profile. New tests execute through these profiles, with failure/assertion evidence rather than duplicate standalone feature runs. Profiles include existing regressions and browser smoke; they are not proof of complete CP2 browser trading/chart E2E. Do not invoke historical `mix test.cp1_coverage`/coverage_report.sh as another CP2 gate; preserve existing CI/coverage infrastructure. No feature HTTP endpoint is declared or changed, so runtime_required is false; real DB connection/commit/restart assertions still run in integration.

Architecture validates artifact readiness and executable mapping only. The implementation owner must create every planned test and execute all final manifest checks, completing T001–T024 before independent QA. QA T025 and review T026 must end with Verdict: PASS before delivery can complete. Architecture does not implement, commit, push or publish.

## Complexity Tracking

No unjustified constitution violations. One initialization singleton lock is deliberate market-recipient serialization, not a new service. Quote/history guards and deferred supply checks enforce existing invariants. No extra infrastructure.
