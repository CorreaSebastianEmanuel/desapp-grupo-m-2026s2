# Implementation Plan: Valuation Strategy Configuration and Versioning

**Branch**: `025-valuation-strategy-configuration-and-versioning` | **Date**: 2026-10-13 | **Spec**: [spec.md](spec.md)
**Owner**: TASK-025, CP2. Product decision: [handoffs/product-decision.md](handoffs/product-decision.md). Authoritative formula feedback: [TASK-024 Feedback 1](../../backlog/feedback/TASK-024.md).

## Summary

Persist complete immutable configurations for the two existing formulas, explicitly activate one market-wide version, and bind managed evaluation/replay to one saved identity. Use existing Ecto/PostgreSQL, exact arithmetic and common reproduction evidence. Add typed exact JSONB rules and database immutability/selection guards; retain formula helpers unchanged. [ADR-0023](../../docs/adr/0023-immutable-valuation-configurations-and-selection.md) resolves the critic's numeric, concurrency and enforcement findings. No HTTP interface or production numerical preset is introduced.

## Technical Context

**Language/Version**: pinned Elixir 1.20.3 / OTP 29.0.6 (`.tool-versions`).
**Primary Dependencies**: existing Phoenix 1.8, Ecto SQL 3.13, Postgrex, Decimal and Jason; no dependency changes.
**Storage**: authoritative PostgreSQL; three new tables: versions, singleton serialization lock, append-only selection changes. JSONB contains typed exact rules, never floats or fixed-scale numeric configuration values.
**Testing**: ExUnit; pure modules tagged `:unit`, SQL/durable/race tests tagged `:integration`. Existing audited integration profile includes actual Chromium/browser tests. Final full profiles execute once each in development and independently in QA.
**Target Platform**: existing local Linux application and documented PostgreSQL/Redis services. Redis is a preflight obligation, never rule authority.
**Project Type**: modular Phoenix application with a trusted internal Elixir feature surface.
**Performance Goals**: no new latency/throughput guarantee; indexed UUID/latest-change reads and short serialized activation transaction. No selection lock during football reads.
**Constraints**: exact integer/Decimal semantics without a new numeric ceiling; no default activation; explicit expected identity; append-only history; no provider access or unrelated writes.
**Scale/Scope**: two reviewed formulas, many immutable versions, one market selection, four P1 stories. TASK-026/027/033 retain quote conversion/retention, exposure and ranking.
**Unknowns**: none unresolved. Feature-specific local findings are in [research.md](research.md); settled technology is referenced rather than researched again.

## Constitution Check

| Principle | Before research | After design |
|---|---|---|
| Specification first | PASS: full spec, challenge, decision and current feedback read; no unresolved material decision | PASS: every story/FR/SC has tasks and executable acceptance mapping |
| Domain integrity | PASS: original facts/evidence and exact arithmetic inherited | PASS: typed codec, DB guards, original-version replay; no quote/trading/supply mutations |
| Modular simplicity | PASS: existing monolith/database suffice | PASS: pure rules/codec/registry, isolated persistence, managed facade; no new services |
| Evidence quality | PASS: FR-016 requires test-first behavioral coverage | PASS: persistence, restart, real race and no-effect assertions plus existing profiles |
| Independent verification | PASS: no additional product approval required | PASS: owner runs manifest before independent QA/review with terminal PASS |

These are design-gate outcomes, not claims that future implementation tests passed. No constitution violation remains. ADR-0023 extends database enforcement consistently with ADR-0010, without amending product behavior.

## Project Structure

### Documentation (this feature)

`specs/061-valuation-strategy-versioning/`: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/configuration-context.md`, `contracts/acceptance-map.md`, `quickstart.md`, `verification.json`, `tasks.md`, `handoffs/architecture.md`, `handoffs/tasks.md`. Durable decision: `docs/adr/0023-immutable-valuation-configurations-and-selection.md`.

### Exact implementation inventory

New production/migration files:

```text
lib/football_market/valuation/configurations.ex
lib/football_market/valuation/configurations/registry.ex
lib/football_market/valuation/configurations/rules.ex
lib/football_market/valuation/configurations/codec.ex
lib/football_market/valuation/configurations/version.ex
lib/football_market/valuation/configurations/selection_lock.ex
lib/football_market/valuation/configurations/selection_change.ex
lib/football_market/valuation/configurations/store.ex
lib/football_market/valuation/managed.ex
lib/football_market/valuation/managed_types.ex
priv/repo/migrations/20261013000000_create_valuation_configurations.exs
```

Modified production: `lib/football_market/valuation.ex` (managed entrypoints/explicit-helper documentation), `lib/football_market/valuation/request.ex` (reusable rule-only structural validation). Preserve existing signatures/outcomes and formula semantics. No changes to Balanced, PositionAware, DecimalMath, Scoring, Replay or common descriptor structs are planned.

New tests/support:

```text
test/support/valuation_configuration_case.ex
test/football_market/valuation/configurations/rules_test.exs
test/football_market/valuation/configurations/codec_test.exs
test/football_market/valuation/configurations/storage_test.exs
test/football_market/valuation/configurations/activation_test.exs
test/football_market/valuation/configurations/concurrency_test.exs
test/football_market/valuation/configurations/durability_test.exs
test/football_market/valuation/configurations/immutability_test.exs
test/football_market/valuation/configurations/managed_test.exs
test/football_market/valuation/configurations/outcomes_test.exs
test/football_market/valuation/configurations/replay_test.exs
test/football_market/valuation/configurations/canonical_test.exs
test/football_market/valuation/configurations/scope_test.exs
```

Modified tests: `test/football_market/valuation/scope_test.exs`, `test/football_market/statistics/scope_test.exs`, `test/football_market/providers/scope_test.exs`. Boundary: **33 paths** (11 new production/migration, two existing production, 13 new test/support, three existing architecture tests, four legacy metadata tests). Feature docs/ADR are outside this code inventory. No profile/CI/dependency/catalog/statistics/provider/web/financial implementation edits. Amend the plan with concrete evidence before any boundary change.

**Evidence-based boundary adjustment (2026-10-13)**: the unchanged integration profile failed because retained guarded namespaces make four legacy metadata queries return duplicate names across schemas. The supplemental diagnostic receipt is `handoffs/check-integration-diagnostic.json` (295/299 integration assertions passed). Add only `test/football_market/catalog/constraints_test.exs`, `test/football_market/accounts/persistence_test.exs`, `test/football_market/catalog/player_catalog_index_test.exs`, and `test/football_market/catalog/ingestion/publication_test.exs` to the inventory. Restrict their metadata assertions to `current_schema()` while preserving exact names, index expressions, uniqueness and deferrability assertions. No account/catalog production behavior or cleanup changes. Retain protected test namespaces. The temporary diagnostic manifest check is removed after correction; `legacy-metadata` verifies these regressions and the unchanged audited full profile remains mandatory.

**Structure decision**: keep configuration persistence under valuation while separating it from the inherited read-only engine. Preserve the common scope test's original engine AST restrictions; add separate exact lifecycle inventory and module-role checks. Grant Repo/write/time access only to persistence, never formulas/codec/rules. Statistics/Providers worktree allowances gain this feature's exact 33 paths; retain 058/059/060 inventories and negative unrelated-path checks.

## Phase 0: Focused Local Research

Local inspection established typed canonical evidence, reusable validation coupled to subject/week, exact engine purity inventories and automatically discovered profile tags. [research.md](research.md) resolves these concrete design questions. Reuse ADR-0020/21/22 and the common valuation contract; no technology survey, research agent or external dependency choice is needed.

## Phase 1: Design and Contracts

### Complete versions and exact persistence (US1)

`Registry` resolves only `{balanced,1}` and `{position_aware,1}` through reviewed code clauses. Persist names/versions, never modules. Lookup/listing decode rules without requiring current formula support. `Rules` invokes existing formula validation/requirements and a reusable Request rule-only helper, with no fabricated player/week. Require an explicit nonempty proper mapping and atom-key rule maps; pair collections where a map is required fail before conversion, so duplicate keys cannot disappear. Requirements are derived; caller-supplied requirements and unexpected keys fail validation.

`Store.create` validates all reusable rules before writes, then checks every mapping position exists using Catalog.Position key-share reads within its creation transaction. Insert one UUID version atomically. No catalog writes or new catalog deletion restriction: after save, retained mapping UUIDs do not depend on current labels or continued existence of unused positions. The codec stores integers separately from normalized Decimal sign/coefficient/exponent strings, full group settings and unused mapping entries. Decode whitelists keys/groups/metrics; no atom interning/module loading. Corrupt storage or unsupported codec schema stays a visible storage failure, never empty rules or a football outcome.

Lookup/listing expose full versions and active identity from one consistent read snapshot. Order by `created_at ASC, id ASC`; UUID order breaks timestamp ties. Malformed identities fail validation, unknown valid ones return not-found. Reads do not create versions or selection. Database guards establish immutability even without an update/delete API.

### Serialized append-only activation (US2)

Migration seeds one protected lock row, **no configuration or selection**. Activation validates target/expected identities, locks that row inside a short transaction, reads latest change, compares expected identity, resolves supported target, and either returns a matching no-op or appends one change. Stale expectations conflict before no-op success. Database UPDATE/DELETE/TRUNCATE guards protect versions/history; restrictive foreign keys prevent cascades.

Activation and history insertion use READ COMMITTED isolation; the insertion guard rejects a different transaction isolation level rather than accepting a stale pre-lock snapshot. The volatile insertion trigger locks the singleton and then reads the current predecessor in a fresh command snapshot, so ordinary direct insert paths cannot forge disconnected history. Read-only consistent snapshots may use a single SQL statement or REPEATABLE READ, but never write selection history there. Allocate stable order only **after** acquiring the lock; sequence gaps are allowed. Target must be nonnull and differ from predecessor. The insertion guard samples PostgreSQL transaction_timestamp() as microsecond UTC effective time, permitting equal times within one transaction, visible only on commit; order is authoritative when times tie and does not claim exact commit-clock timestamps or football-week applicability. Active identity is the highest committed change, avoiding a mutable pointer/history inconsistency. MVCC readers see complete old/new selection.

Expected identity is value comparison: A can match after A→B→A. Test this cycle and competing targets from one uninterrupted state. Do not invent a revision token or claim rejection of every intervening change.

### Managed version fixation (US3)

Add `evaluate_managed(subject_week, selector)` and `replay_managed(envelope)` to Valuation. Existing explicit helpers remain compatible building blocks, documented for formula/conformance use; production market consumers use managed calls. Selector is `:active` or `{:version, uuid}`. Request has exactly player, season and UTC week bounds; caller rules/module overrides fail before football reads. Resolve a complete immutable version once, verify formula support/derived requirements, reconstruct existing Definition/Request, then invoke existing evaluate. Release any selection transaction before facts and never re-resolve activation.

`ManagedResult` returns configuration UUID, strategy identity/formula version, score/prepared and a `ManagedDescriptor` envelope holding that UUID and unchanged common Descriptor. This is strategy-independent binding of existing evidence, not a second scorer-specific format. No result write/descriptor table. Successful evidence must canonically match the referenced version.

### Original recovery and replay (US4)

Load the envelope's original version independently of activation. Compare formula identity/version, full canonical config, references, requirements and mapping before authoritative original-membership replay. Missing saved original is unavailable-replay; unsupported formula remains unsupported; mismatch is inconsistent-replay. Preserve inherited fact/feature/score tamper checks and infrastructure failure visibility, with no broad rescue/substitution.

Restart acceptance holds the complete envelope outside restarted runtime Repo clients, then reloads stored rules and replays after switching/late facts. TASK-026 owns production descriptor retention and quote/version integrity. Whole-envelope substitution with another legitimate result remains outside the trust boundary, as in ADR-0020.

## Verification Strategy and Checkpoint Coverage

Every behavior has tests before corresponding source changes (FR-016): DB mutation attempts, canonical exactness after reconnect, empty installation, competing commits, no-op/stale activation, in-flight selection fixation and replay after late facts. Race tests require distinct PostgreSQL backend IDs and actual commits; shared Sandbox ownership is insufficient. Ordinary tests roll back. Committed durability/race tests use a guarded isolated test-only schema with dynamic test Repo clients and matching search paths. The helper validates the configured test DB, creates a unique suite-owned schema and runs existing migrations there, including the new migration. Use the same namespace for migration and every connection, restore dynamic Repo per process and stop owned clients. Retain the namespace in the disposable test DB instead of disabling guards/deleting immutable fixtures. No destructive database command is required.

First-activation races start in an empty private schema. In-flight tests use trace/message barriers at completion of Store resolution before Statistics selection, not sleeps or production callback injection. Durability tests launch separate fresh BEAM application instances against the committed isolated schema, terminating/restarting the child between writes and reads/replay. New clients must reload solely from storage, with no retained Version struct. The parent supplies only the original descriptor through a trusted test-generated temporary fixture; no production descriptor codec/storage is added. Child exit status and asserted results must propagate to ExUnit. Keep bulk exact-arithmetic/permutation vectors in memory, with compact counts/checksums if evidence is retained.

[contracts/acceptance-map.md](contracts/acceptance-map.md) covers all 24 numbered scenarios and edge cases. [verification.json](verification.json) maps every identifier (17 FR and six SC; no AC IDs occur). Final owner checks include pinned toolchain, formatting, warning-free compile, guarded migrated PostgreSQL/Redis readiness, targeted suites, architecture and unit/integration profiles once each. Preserve CI/coverage infrastructure; historical CP1 coverage is not an extra CP2 gate. Targeted acceptance suites do not constitute extra full-profile executions.

No HTTP obligation exists: neither spec nor contracts expose/change endpoints. Set `runtime_required: false`; actual services still must pass preflight. CP2 configurable-strategy/versioning prerequisites are covered; quotes/trading/ranking/charts/conditional orders and complete CP2 delivery remain downstream. Exact arithmetic, immutable rules/history, inherited replay and zero unrelated writes protect relevant product invariants.

Implementation runs manifest checks through `scripts/agentflow_check.py` before QA. Finish source/design edits before final receipts; explicit `--reuse` is only for current intact developer evidence, never QA. Red tests diagnose missing behavior: make the authorized source correction before retrying and preserve attempts. Two unchanged failures stop repeated execution, not corrective development. QA reruns independently; review uses fresh QA evidence with targeted discrepancy checks. Only downstream Independent QA/Final review tasks may defer.

## Complexity Tracking

No constitution exceptions. Typed storage, DB guards and a serialization row are the minimum mechanisms for exact durable evidence, unused-version immutability and first activation. ADR-0023 records alternatives and limits; no new service/plugin system.
