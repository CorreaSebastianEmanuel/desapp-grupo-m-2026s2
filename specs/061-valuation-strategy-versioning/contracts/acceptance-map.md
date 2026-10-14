# Executable acceptance map — TASK-025

Check IDs below are commands in [verification.json](../verification.json). All named test paths are implemented. Development receipts must remain current; QA independently challenges the assertions rather than treating mappings as proof. Spec has 24 numbered scenarios and 23 FR/SC identifiers, with no named AC identifiers. Every scenario/edge case is required; broad FR mappings do not replace these assertions.

| Spec scenario | Concrete assertion responsibility | Check IDs |
|---|---|---|
| US1.1 | storage_test: balanced full formula/config/reference/mapping/derived requirements/time, UUID and no activation | versions |
| US1.2 | storage_test: all position groups retained, union references, no overall requirement, absent groups included | versions, rules-codec |
| US1.3 | rules_test/storage_test: unknown formula; missing/malformed weights/groups/references/mapping; duplicates/improper lists/extra keys; zero write/change | rules-codec, versions |
| US1.4 | rules_test: zero metrics/all-zero nonempty valid and required; omission changes requirements; empty sets rejected | rules-codec |
| US1.5 | codec_test/durability_test: signed fractions/huge integers/Decimals, typed canonical round-trip in fresh application and varied contexts; invalid references rejected | rules-codec, durability |
| US1.6 | storage_test/durability_test: full get/list/current identity, unknown vs empty vs outage; stable UUID ordering for tied creation times | versions, durability |
| US2.1 | activation_test/concurrency_test: no preset; explicit nil expectation activates exactly one supported version and records time/order | selection |
| US2.2 | activation_test/managed_test: switch A to B, record predecessor/target, retain usable A and select B next | selection, managed |
| US2.3 | activation_test: restoration uses existing A identity plus a new change, no version edit/save | selection |
| US2.4 | activation_test: malformed/unknown/unsupported target or stale expectation leaves selection/history intact | selection |
| US2.5 | concurrency_test: committed distinct-backend competing targets permit one change; first activation too; reader complete old/new; no-op matching succeeds once, stale still conflicts | selection |
| US2.6 | durability_test/scope_test: ordered history/identity survive fresh applications/provider outage; saving another version does not change either | durability, architecture |
| US3.1 | managed_test: before facts fix A, balanced score 1.000000 and exact saved UUID/formula/common evidence | managed |
| US3.2 | managed_test: trace/barrier after resolution, activate B, original calculation remains A and next becomes B with full coherent rules | managed |
| US3.3 | managed_test: explicit inactive A gives 1.000000, active B gives 2.000000 and no implicit activation | managed |
| US3.4 | managed_test: position-aware split 2+2 goals gives 4.000000, concentrated four gives 2.000000, no averaging/subtotal rounding | managed |
| US3.5 | outcomes_test: no active distinct; valid inactive works; unknown UUID/unsupported formula/storage outage have no fallback | managed, architecture |
| US3.6 | outcomes_test/scope_test: every override rejected before facts; unmapped position/player/empty/unknown metrics remain distinct; failed evaluation creates no versions/changes | managed, architecture |
| US4.1 | replay_test/durability_test: preserve original envelope, switch/late facts/restart; original membership with A reproduces 1.000000 while fresh evaluation may differ | replay, durability |
| US4.2 | immutability_test: direct SQL/Repo update/delete including unused/inactive rules/identity/time; reject truncate and cascade paths; new save preserves old | versions |
| US4.3 | replay_test/storage_test: absent-group weight and unused mapping changes yield distinct retained versions; equal scores cannot authorize substitution | replay, versions |
| US4.4 | replay_test: UUID/formula/config/reference/requirements/mapping mismatch rejects before original-fact scoring | replay |
| US4.5 | replay_test: missing original version/facts, unavailable formula, altered facts/features/score and malformed nested descriptor fail distinctly | replay |
| US4.6 | canonical_test/storage_test: ≥20 multi-metric/mapping permutations retain same canonical rules/scores/common evidence with different UUIDs; identity tie order stable | replay, versions |

## Additional edge/critic regressions

- `codec_test`/`durability_test`: integer 1 versus Decimal 1 differs in evidence, equivalent Decimal encodings agree; negative zero normalizes; no context precision/rounding leak, including large coefficients and extreme exponents. Stored numeric strings do not widen the public API. Decoder rejects schema/shape corruption without atom/module loading.
- `rules_test`/`outcomes_test`: zero-weight unknown metrics still block applicable rows; all four saved groups/reference union required; absent groups remain absent, known zero remains measured. Full validation happens before football selection, including empty histories.
- `immutability_test`/`storage_test`: insert rollback leaves no partial rule/version; duplicate UUID rejected; record counts and full byte/canonical snapshots unchanged after rejected mutations; history and anchor protected. Unsupported stored formula fixtures remain inspectable but cannot be activated/evaluated. Distinct-backend direct insert races, disconnected history inserts and unsupported write-isolation requests fail, preventing stale pre-lock snapshot acceptance.
- `concurrency_test`: order assigned after anchor lock, time ties do not reorder; exercise A→B→A then delayed A expectation succeeding. Guarantee applies to competing targets from one uninterrupted state, not all ABA cycles. Use barriers and distinct backend IDs, never shared Sandbox/sleeps as race proof.
- `durability_test`: fresh child BEAM applications reconstruct exact rules and history from committed private-schema storage; parent retains only original envelope in trusted ignored harness input. Child timeout/failure/assertion failure fails check. No trigger disabling, protected fixture deletion, production DB use or quote retention.
- `scope_test`: trace actual provider/external/event/job boundaries and SQL statements for all reads/saves/activation/evaluate/replay success/failure paths. Reads/score/replay issue zero mutations; save writes only version, activation only change; no quote/financial/fact/catalog writes. Isolate real storage failure and assert visible failure, not no-active/empty/insufficient data.
- Role-separated AST/inventory assertions preserve original pure-engine restrictions and legacy 058/059/060 allowances; arbitrary modules/atoms/unplanned files/public routes/jobs/cache/presets remain excluded. Existing pure APIs remain compatible; future market orchestration must call managed evaluation.

## Product invariants and checkpoint obligations

Exact money/quote arithmetic is protected by inherited formula regressions plus typed rule round-trip. Append-only history and original reproducibility are directly tested; token supply/trading remain untouched, asserted by SQL/architecture exclusions. Local rule/fact reads need no provider. TASK-026 owns quote version/effective date/retention and atomic downstream integrations; TASK-027/033 own quote exposure/ranking. Configurable strategy/versioning is this task's CP2 prerequisite only. Existing full unit/integration/browser profiles run once each per final owner/QA stage; preserve CI/coverage and add no default historical CP1 report. No affected HTTP interface exists, so runtime HTTP assertions are inapplicable; migrated PostgreSQL/Redis readiness remains mandatory.
