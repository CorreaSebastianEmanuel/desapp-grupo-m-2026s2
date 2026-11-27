# Implementation Plan: Idempotent Catalog Ingestion

**Branch**: `018-idempotent-catalog-ingestion` | **Date**: 2026-10-08 | **Spec**: [spec.md](spec.md)
**Task**: TASK-018 · CP2. Directory/branch numbering does not establish task ownership; use `.specify/feature.json` and the spec's explicit TASK-018 declaration.

## Summary

Add `FootballMarket.Catalog.Ingestion` as a trusted internal domain entry point consuming the merged `Providers.catalog/2`. Reconcile one complete league-season, with durable typed source bindings, provider-neutral player identities and append-only accepted observations. Fetch outside the database transaction; reconcile and publish inside one scope-coordinated transaction. Replay is exact semantic delivery equivalence; unchanged football facts are a separate comparison. No ingestion endpoint, scheduling, live activation or financial work is added.

## Technical Context

**Language/Version**: Elixir ~> 1.20.3 / repository-pinned OTP (`.tool-versions`).
**Dependencies**: Existing Phoenix 1.8, Ecto SQL 3.13, Postgrex, Jason, Providers and selected Scraping adapter; no dependency additions.
**Storage**: Existing PostgreSQL 17.6; Redis remains an existing test prerequisite, never the acceptance ledger.
**Testing**: ExUnit pure unit and actual database integration modules, deterministic independent fixtures; existing separate profiles and browser regressions remain intact.
**Platform/Type**: Existing modular Phoenix application; internal domain/persistence feature.
**Performance Goals**: No new latency SLA. Provider retrieval/normalization obeys the existing timeout; no transaction is held while fetching. Publication is bounded by the finite complete response and existing database timeouts, with no automatic retry.
**Constraints**: Five supported leagues, season-specific current affiliation, configured positions, additive reconciliation, no secret/raw-payload evidence. All source operations offline during acceptance.
**Scale/Scope**: One league-season per attempt; full candidate held in memory. No batching/partial publication or streaming API. Extremely large source responses are a later measured concern, not a new paging protocol.
**Unknowns**: None remain; feature-specific database choice is documented in research.md and ADR-0019.

## Constitution Check

Pre-design and post-design: PASS against principles I–V. Spec and approved decision determine behavior; FR-001–017 and SC-001–007 map to executable checks. Domain integrity is preserved by catalog-only writes and unrelated-state assertions. Existing monolith/provider boundary remains; new PostgreSQL constraints and acceptance tables extend persistence only. Tests precede each behavior; final owner checks precede fresh independent QA/review. No unresolved material human choice, new permission or infrastructure. Durable extension: [ADR-0019](../../docs/adr/0019-atomic-catalog-reconciliation.md). No constitution exception.

## Project Structure

```text
specs/057-idempotent-catalog-ingestion/
  plan.md research.md data-model.md quickstart.md verification.json tasks.md
  contracts/ingestion.md
  handoffs/architecture.md handoffs/tasks.md
lib/football_market/catalog/ingestion.ex
lib/football_market/catalog/ingestion/
  canonical.ex reconciler.ex publisher.ex outcome.ex
  scope.ex source_binding.ex observation.ex observation_binding.ex
priv/repo/migrations/20261008000000_create_catalog_ingestion_tables.exs
priv/repo/migrations/20261008000100_make_team_business_keys_deferrable.exs
test/support/ingestion_fixtures.ex
test/football_market/catalog/ingestion/
  canonical_test.ex reconciliation_test.ex publication_test.ex
  identity_test.ex replay_test.ex concurrency_test.ex
  retention_test.ex outcome_test.ex isolation_test.ex matrix_test.ex
```

All listed source/test/migration paths are planned artifacts, created by the implementation owner. Existing Catalog schemas/contexts retain ownership; adjust Team constraint handling only as required by the new constraints. Web/Providers DTOs are never Ecto schemas. No changes to provider transport, runtime publication gates or defaults.

## Phase 0: Feature-specific Research

See research.md: inspect existing provider provenance, normalized uniqueness indexes and profile discovery. Only investigate PostgreSQL's ability to defer normalized team uniqueness; settled architecture follows ADR-0002/0013/0016/0017/0018. No research agents or technology survey.

## Phase 1: Design and Publication Algorithm

1. Normalize request with `Providers.Request.normalize(:catalog, request)`. Validate trusted instruction shape without exposing it to adapters. Read accepted scope revision before provider retrieval; absent scope is revision **0**. The database scope key is canonical league code/start/end, independent of whether a season exists.
2. Call existing `Providers.catalog/2` exactly once, passing explicitly selected provider and the configured persisted position vocabulary. Preserve safe provider categories/delay/retry guidance verbatim. Failure/timeout ends the attempt without publication. The ingestion entry point cannot accept a caller-forged successful Result as a public shortcut; tests inject only the existing provider port/runtime.
3. Canonicalize validated facts: resolve result-local references to qualified source keys; replace position refs with canonical codes; include supplied mutable fields and resolved relationships. Sort collections by opaque qualified binding keys. Preserve source-ID case, TASK-005 normalization and UTC microsecond instant. Encode a versioned fixed-field nested-array representation with Jason and hash SHA-256; retain the safe canonical representation for equality verification, avoiding digest-only identity.
4. Enter `Repo.transaction` at READ COMMITTED. Acquire a transaction advisory lock on a deterministic signed 64-bit SHA-256 prefix of canonical scope (fixed namespace, versioned encoding). Collision causes extra serialization only. No global lock or scheduler dependency. Read current scope/evidence after the lock. Exact accepted delivery lookup comes **first**, returning original evidence and zero applied counts even after intervening updates. Supplied trusted instructions are still checked for validity/contradictions; invalid instructions cannot hide behind replay. Replay does not require resupplying the original mapping/new declarations when existing bindings already prove identity.
5. If captured revision differs, return concurrent-change unless exact accepted delivery already converged. If revision matches, reject an older unaccepted instant as stale, then an equal instant with differing delivery as conflict. Different fixture/provider attribution is non-equivalent even if football facts match. A future accepted instant can block genuine later retrievals; document/test safe stale outcomes without clock correction.
6. Resolve all bound identities first, then explicit instructions and conservative adoption/creation. New player identity is generated opaque UUID text, independent of names/source IDs. Resolve every incoming candidate against the whole retained scope before writing. Reject cross-scope targets, contradictory/collapsing bindings, team single-key collisions and incompatible canonical names/position vocabulary. Detect unbound-name conflicts against pre-publication existing records independently of row order; distinct new sourced same-name players remain distinct. Replacement source requires explicit mapping or new declaration for each incoming player. Every instruction must reference an incoming source key; duplicates, extra keys and contradictions fail.
7. Validate final candidate uniqueness using TASK-005 normalized keys, including omitted retained teams. Both keys must agree to adopt an unbound existing team; bound teams may exchange keys if the final state is valid. Deferrable constraints on stored normalized team columns preserve database enforcement and existing constraint names (ADR-0019). Defer only those two constraints for publication, not all constraints. Force them IMMEDIATE before acceptance finishes; map failures safely after rollback. Existing primary/composite/FK constraints remain immediate.
8. Create missing canonical league/season using conflict-safe insert-do-nothing on existing **nondeferrable** business keys, then re-read and verify canonical compatibility. Different seasons can share a missing league safely without overwriting it. Never upsert teams through deferred constraints. Lock affected existing rows in stable table/UUID order, revalidate candidate facts after locks, and update only actual changed fields; concurrent legacy catalog mutations must cause rollback or revalidation, never bypass final constraints. Domain ingestion writes share the scope lock; broad legacy mutation serialization is outside scope.
9. Write changed catalog rows, typed bindings, observation and observation-binding membership together; increment revision exactly once per newly accepted observation, including valid empty and later unchanged observations. Count only incoming league/season/team/player entities, separately by kind; exclude configured positions and omitted entities. Bindings/evidence are not entity-update counts. No-op rows retain timestamps. New binding counts are separate from the incoming entity change counts. Empty observations still bind league/season. Each incoming binding links to this observation; old evidence and membership remain immutable.
10. Commit before returning accepted-with-changes or accepted-unchanged. New bindings without changed football rows yield accepted-unchanged with new revision/evidence. Persistence exceptions become template-based safe persistence failure, never SQL/exception text. Lost reply can be retried through exact delivery replay. No retries/backoff and no late provider completion can invoke publisher.

Data-model.md defines storage constraints; contracts/ingestion.md defines safe internal interfaces. Successful evidence stores normalized safe facts/digest and lineage, never source documents. Scope pointers are mutable; observations and observation membership append-only. Existing match/financial/audit tables are never ingestion write targets.

## Validation and Checkpoint Coverage

Tests are first for US1 publication, US2 identity/replay/concurrency and US3 ordering/retention/outcomes. Each test module carries one profile tag: pure tests `:unit`, real persistence/concurrency/read isolation `:integration`. Concurrent tests use genuinely separate database connections and committed disposable fixtures with safe cleanup; shared SQL Sandbox owner alone cannot prove locks or visibility. Barriers control overlap instead of timing sleeps. Observer connection sees either old complete state or new complete state, including after injected failure. Fail after catalog/bindings/evidence writes; assert rollback, and simulate response loss after commit.

The acceptance matrix in quickstart.md maps all 16 numbered story scenarios to tests. Five-league/two-season fixtures and full exact/case/whitespace uniqueness rules satisfy upstream human feedback. Assert match facts/event teams unchanged and unrelated users/API keys immutable; inspect publisher write-set to exclude token, money, quote, order and audit mutations (future tables are not fabricated solely to test non-writes). Profile regressions preserve actual browser E2E rather than claiming database tests are browser E2E. This task supports CP2 catalog inputs; charts, trading, valuation, scheduling and TTL retain downstream ownership. No CP1 snapshot gate.

`verification.json` is the owner's executable acceptance map. Its whitespace check covers tracked staged/unstaged changes against HEAD and every nonignored untracked file; new files cannot escape verification before publication. Owner completes every non-gate task and all checks before QA. QA independently runs checks and challenges expected outcomes; review uses fresh QA and targeted risk checks. No HTTP routes are added or changed: runtime_required=false; existing local read APIs are checked through domain/database tests with zero provider calls. If implementation changes an HTTP interface, stop scope expansion and update authorized spec/design/runtime manifest before proceeding.

## Complexity Tracking

No constitution violations. New scope/binding/observation tables and two deferred normalized constraints are necessary for atomic identity and valid final-state swaps; alternatives and consequences are in ADR-0019.

## Development corrections

- See quickstart.md/current feedback for the actual pinned Elixir/OTP and Node PATH. Database checks use the existing `task018_ingestion` test partition after an early failed cleanup left a default-database fixture; automatic review rejected removing that fixture. The default database remains intact. No new service or production configuration.
- Canonical safe arrays are stored under the JSONB wrapper `{"v1": [...]}` for Ecto's map field; hashing uses the fixed array itself and replay compares the full wrapper. Binding addition counts are derived from immutable observation membership rather than duplicated storage.
- Publication verification also runs existing Catalog constraint regressions. The manifest's whitespace Python argv was corrected to executable quoting while retaining the tracked/untracked whitespace obligation.
- Existing statistics/provider scope guards now recognize this active feature's exact planned paths. Their provider purity and statistics isolation checks remain intact; these two regression test files are the necessary test-harness boundary extension. No provider implementation changes.
