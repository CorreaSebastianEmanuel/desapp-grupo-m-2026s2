# Implementation Plan: Statistics Ingestion Pipeline

**Branch**: `021-statistics-ingestion-pipeline` | **Date**: 2026-10-16 | **Spec**: [spec.md](spec.md)
**Task**: TASK-021 | **Checkpoint**: CP2

## Summary

Extend the existing Providers → Synchronization/Oban → Statistics boundary to accept a complete explicitly selected league-season result atomically. Retain immutable facts, first-acceptance provenance, complete-check state and a fenced delivery receipt; changes create durable downstream calculation intent, dispatched only after commit. Reconcile the narrow substitute-position exception at provider validation and storage without reopening TASK-020 or changing accepted facts.

Behavior is spec.md plus authoritative `backlog/feedback/TASK-021.md`. Critic resolutions and durable extensions are recorded in `docs/adr/0028-atomic-statistics-ingestion-and-position-evidence.md`. Settled stack/access/identity decisions remain ADR-0010/0013/0018/0019/0025; no technology survey or research agents.

## Technical Context

- **Language/version**: Elixir ~> 1.20.3; Phoenix ~> 1.8.13; Ecto SQL ~> 3.13; Oban ~> 2.24.2, as declared in mix.exs; no dependency change.
- **Storage/platform**: local PostgreSQL; one modular Phoenix application. Existing Redis is only an infrastructure dependency, never an ingestion ledger or cache in this task.
- **Tests**: ExUnit unit/integration module tags, deterministic provider/scraper fixtures, PostgreSQL constraints and independent committed connections for races; supervised actual Oban/restart probes. Existing browser E2E remains in the integration profile.
- **Performance**: bounded provider deadline and TASK-019 persisted retry/concurrency policy; one complete season per request, no new latency SLA. Fetch outside publication transaction; serialize acceptance per local season and use indexed season/player/kickoff lookups.
- **Scope/constraints**: supported league-season only, no date-subset masquerading as season completeness; no new HTTP route, permission, infrastructure, catalog sync, TTL/read API, quote/scoring/trading/chart/order behavior. Live transport remains denied.
- **Resolved unknowns**: current DTO lacks completeness/participation evidence, storage rejects unknown positions, runtime is catalog-specific, and Valuation lacks durable calculation requests. Local inspection and solutions are in research.md. No unresolved clarification remains.

## Constitution Check

| Principle | Before design | After design |
|---|---|---|
| I Specification first | spec and current feedback read; no unresolved product decision | Every FR/SC and all 14 story scenarios covered below and in verification.json |
| II Domain integrity | ADR-0010 immutable facts retained | No fact updates/deletes; exact integer counts; nil distinct from zero; no financial or quote writes |
| III Modular simplicity | reuse modular monolith and existing provider/runtime | narrow shared runtime operation dispatch, no second scheduler/provider/service; persistence isolated from DTOs |
| IV Executed evidence | implementation must write failing tests first | all checks planned, not claimed executed; offline independent oracles and real DB/process probes mandatory |
| V Independent verification | approved product behavior; no new human decision | implementation owner runs manifest before fresh QA and final review; both must end Verdict: PASS |

No constitution waiver. ADR-0028 records contract extensions, not an exception to invariants. CP2 contribution is safe statistical inputs and durable work supporting valuation; required charts, conditional orders and broader frontend delivery remain separate backlog work. Preserve CI/coverage infrastructure; do not add historical CP1 coverage report or rerun full profiles via a second aggregate command.

## Project Structure

```text
lib/football_market/
  providers/{types,performances,validator}.ex          # shared contract extension
  providers/scraping/{source,translator}.ex            # safe evidence translation
  synchronization.ex                                 # request_statistics
  synchronization/{input,run,store,recovery,execution_guard,dispatcher}.ex
  synchronization/delivery_receipt.ex                 # operation-neutral receipt API
  workers/{catalog_sync,statistics_import,calculation_dispatch}.ex
  statistics.ex                                      # existing reads/strict direct writes
  statistics/{input,performance}.ex                   # guarded position evidence
  statistics/ingestion.ex                            # trusted worker orchestration
  statistics/ingestion/{publisher,identity,canonical,positions,provenance,scope_check,outcome,calculation_intent}.ex
  valuation/calculation_requests.ex                   # durable request acceptance only
priv/repo/migrations/20261016000100_extend_statistics_position_evidence.exs
priv/repo/migrations/20261016000200_create_statistics_ingestion.exs
priv/repo/migrations/20261016000300_extend_synchronization_operations.exs
config/synchronization.exs
config/config.exs
test/football_market/statistics/ingestion/             # acceptance/integrity/recovery cases
test/football_market/providers/ingestion_contract_test.exs
test/football_market/synchronization/statistics_test.exs
test/support/statistics_ingestion/{case,fixtures,runtime_probe}.ex
test/fixtures/statistics_ingestion/{documents,inventory,expected}.exs
```

Existing catalog receipt module remains a compatibility wrapper; keep its table name, migrate additively, and regression-test catalog jobs. No historical migration edits. Reversible internal module splits are allowed within these responsibilities; no behavioral expansion.

## Design and Implementation Boundary

### Admission and execution (FR-001/002/012/014)

Add `Synchronization.request_statistics(scope, options)` to the trusted local context. Extend the existing runtime with an explicit operation (`catalog` default for legacy callers, `statistics` for this path), worker dispatch, operation-qualified active uniqueness, locks, receipts and recovery. Keep existing schedule definitions catalog-only; this feature adds manual trusted statistics requests, not schedule configuration or freshness triggers. Include operation, full canonical safe input equality, selected source/fixture content digest and identity mapping in retained input; incompatible active inputs return scope_busy. No provider resolution by name, module name from job args, fallback or mutable source adoption. Secrets are resolved only at execution; every portion/publication rechecks TASK-055 assessment.

Reuse TASK-019 one-shot delivery, finite begun-attempt ledger (default 3; waits 60/300 seconds), timeout, max(local wait, retry-after), session execution guards and fenced recovery. Interrupted final delivery with a confirmed receipt finalizes without another retrieval. Unconfirmed exhausted work stays visibly failed. Extend recovery by operation rather than introducing a second recovery loop. Statistics and catalog runs cannot coalesce; different league-seasons cannot suppress each other. Serialize statistics publication across sources for one local season; source-specific successful checks remain distinct.

### Complete result and identity (FR-003/005/006/007)

Extend the sole Providers result with explicit optional completeness evidence; statistics ingestion requires it, legacy catalog consumers retain their behavior. Evidence must identify requested normalized scope, full collection/terminal witness, expected eligible match identities and detail coverage, safe assessment revision/reference, plus explicit complete-empty attestation when no eligible facts exist. TASK-055 Source builds it from its existing independently assessed witnesses; never from count, HTTP success or synthesized live claims. Generic fixtures supply independently expected evidence. Unknown/missing witnesses or a partial interval fail before writes. Validate all retained required facts and resolve catalog bindings before publication; no entity creation/catalog reconciliation here.

Use existing qualified catalog source bindings for league, season, team and player (ADR-0019). Resolve only exact provider/kind/scope/source-ID bindings or explicit prevalidated trusted mappings already bound to accepted input. Never match names. Persist match bindings in a statistics-specific typed table. TASK-020 identity is season + normalized match_identity; use a versioned deterministic safe identity encoded from qualified provider match source identity, with explicit mapping required to join an already existing unbound match. No heuristic cross-provider merge. Performance identity remains local player + match, not result-local ref. Validate scope/team/season and all restrictive FKs under transaction; reject binding retargeting and unknown required identities. Result-local refs, list order and retrieval timestamp are not immutable football content.

### Substitute reconciliation and deterministic history (FR-008–011)

Extend provider performance with optional participation evidence. Legacy recognized direct positions remain accepted. Only an explicitly evidenced `substitute_entered` lacking trusted event-time position may pass provider validation with nil position. Missing starter/other role positions still fail; `usualPosition` is never evidence. Source translation admits this discriminator only under verified field semantics; controlled synthetic fixtures label the exception as synthetic and do not establish live feasibility.

Publication takes a fixed set of already committed accepted performances before inserting any rows in the proposed batch. Filter same local player/season, known position and kickoff strictly less than subject; count distinct prior matches once, including accepted derived known positions. Equal kickoff contributes nothing. The entire proposed batch is excluded, regardless of list order. This follows spec's 'already accepted' assumption; the critic's proposal to count newly proposed rows would change that rule. Persist basis IDs, per-position frequencies, selected position or unknown reason and policy version for each new derived row. A fresh season batch can therefore yield unknown substitutes even if it contains earlier starters. Subsequent imports cannot backfill or recalculate that immutable position.

On replay compare source immutable material against the retained source material and reuse the accepted position evidence; do not rederive using today's enlarged history. Genuine source changes, including a later supplied direct position for an accepted unknown, conflict. Optional metrics remain nil or validated nonnegative integer, never default zero; test all nine keys in Statistics.Input.metrics/0.

Add nullable position_id only under a database-enforced closed position-evidence state, documented in data-model.md. Legacy rows receive a schema default `legacy_direct` classification without updating their content or disabling immutability triggers; legacy/direct writes still require known position. All Statistics public writes and ingestion publication take the same local-season transaction advisory lock before fact insertion; batch writes acquire season locks in sorted order. Read history once after this lock and before writes. Existing immutable triggers, composite season FKs, count checks and player/match uniqueness stay active. Reads expose unknown safely; existing valuation treats missing position using its established outcome rules, never guesses a group.

### Atomic publication, replay and provenance (FR-004–007/012/015)

Fetch/normalize outside transaction. In the existing delivery execution guard, begin transaction; lock operation-qualified receipt, local-season advisory lock and source scope-check row in a consistent order also used by recovery. Resolve identities, compare canonical source facts with accepted rows, freeze history, validate/derive all candidates, then insert only new facts and first-acceptance provenance. Never use upsert-update or ignore conflicting rows. A constraint race re-reads for exact equality or aborts as conflict; transient serialization/deadlock failures consume bounded attempts.

In the same commit: append accepted observation/check with changed/unchanged/replay/complete-empty outcome, update source-season last_checked_at/accepted check pointer, confirm fenced receipt, and insert unique calculation intent for changes. Failure rolls all these back. Persist safe failed attempt outcome separately after rollback; it never advances successful-check state. Empty is an accepted outcome with zero facts; unchanged is a newly retrieved complete equivalent result; replay is the same retained delivery/source-material identity. All successful kinds may renew complete-check time. First provenance never changes; a replay/new observation links existing facts without overwriting origin. New facts only attach to the run/check that first accepted them.

Fixture metadata: stable ID, repository-relative contained sanitized artifact reference, SHA-256 actual bytes, origin, capture/creation date, expected case/rules and explicit non_live marker. No arbitrary filesystem read or retained raw live response; reject drift against admitted digest. Provider provenance retains label, UTC retrieval instant, qualified binding and accepted run/check. Restrict all provenance/evidence rows against update/delete; only operational state/pointers may change. Errors use closed categories/templates, not exception/transport text. Local reads never call Providers.

### Downstream calculation (FR-013)

Current Valuation has deterministic evaluation, but no durable request API. Add only `Valuation.CalculationRequests.accept(intent_id, accepted_check_id, changed_performance_ids)` with a unique intent ID and safe persisted request state. Publisher records an outbox intent atomically; existing dispatcher ticks enqueue a one-shot calculation dispatch job after commit. That worker calls the receiving domain request boundary idempotently, records delivery state separately and uses bounded retry/recovery for dispatch failure. Crash after accept/before acknowledgment reuses the same ID. Pending/failed dispatch is independently inspectable and cannot relabel or roll back accepted import. Do not invoke evaluate_managed, select a strategy/week, execute a formula or insert quotes here. A retained request is a request, never a completed quote. Future quote orchestration consumes it under its own task; no no-op success receiver or pretend calculation.

## Verification and Incremental Delivery

Tests precede every behavior change. Unit tests cover canonical equality, witness validation, role exception, history mode and safe errors. Integration tests cover atomic facts/check/receipt/provenance, complete-empty vs missing evidence, repeat unchanged checks, all conflict paths, DB constraints, real committed concurrent requests, bounded retries and terminated worker/application recovery. Test-only failpoints are disabled outside test. Independent expected fixtures are authored before translator/publisher behavior; transport spy must report exactly zero network requests and no real credentials.

`verification.json` is the executable authority. Preflight prepares the guarded test DB, verifies PostgreSQL and Redis using owned clients, and fails if either is unavailable. Run formatting, test-environment compilation with warnings-as-errors, unit profile once and integration profile once after final edits. No redundant mix test/full coverage run. Tests added here must have the proper module-level profile tag and participate in existing audited profiles. Existing provider/scraper/catalog/synchronization/statistics/valuation and browser regressions run in those profiles. No affected HTTP endpoint: runtime HTTP assertions are inapplicable, runtime_required=false; do not fabricate a route merely to satisfy a conditional gate. Actual Oban/process/service runtime assertions remain mandatory inside integration.

| Story | Scenario coverage and independent test locations |
|---|---|
| US1.1 | Two-match accepted source, exact fact/check counts, provenance, intent and worker receipt: `acceptance_test.exs`, `synchronization/statistics_test.exs`. |
| US1.2 | Unproven scope, missing terminal/identity/detail witness, hostile fixture rollback, invalid required positions and immutable conflicts leave facts/check/pointer/receipt unchanged: `completeness_test.exs`, `provenance_test.exs`, `acceptance_test.exs`, `ingestion_contract_test.exs`, `integrity_test.exs`. |
| US1.3 | Identical and later-retrieved unchanged results retain facts and first lineage while checks/observations advance: `acceptance_test.exs`, `replay_test.exs`. |
| US1.4 | Explicit complete-empty is accepted separately; missing empty attestation and absent completeness are rejected: `acceptance_test.exs`, `completeness_test.exs`. |
| US2.1 | Same-material replay after retrieval changes preserves facts/provenance and appends observations: `replay_test.exs`, `canonical_test.exs`. |
| US2.2 | Match, position, metric and catalog-target changes conflict and do not advance the successful check: `acceptance_test.exs`, `canonical_test.exs`. |
| US2.3 | Independent committed admission and publication races, incompatible input fencing, distinct scopes, operation-qualified redelivery and worker confirmation recovery: `concurrency_test.exs`, `synchronization/statistics_test.exs`, `synchronization/concurrency_test.exs`. |
| US2.4 | Actual worker termination before publication, final-attempt termination after confirmed publication, bounded policy exhaustion and input drift refusal: `recovery_test.exs`, `synchronization/statistics_test.exs`, `synchronization/recovery_test.exs`, `synchronization/input_test.exs`. |
| US3.1 | Sanitized synthetic fixture fingerprint, origin/date/case/rules/non-live marker and provider-qualified first lineage: `provenance_test.exs`, `acceptance_test.exs`. No live-source readiness is claimed. |
| US3.2 | Safe provider qualification and closed error fields without raw payloads or credentials: `ingestion_contract_test.exs`, `provenance_test.exs`. |
| US3.3 | All nine metrics preserve nil independently from explicit zero through persistence and local reads: `metrics_test.exs`, `ingestion_contract_test.exs`. |
| US3.4 | Provider-supplied direct starter position remains direct; a trusted direct entrant position overrides derived history: `ingestion_contract_test.exs`, `positions_test.exs`, `acceptance_test.exs`. |
| US3.5 | Same-season strictly earlier match-count mode retains exact basis IDs/frequencies; current/later/equal/other-season/other-player and all proposed rows are excluded: `positions_test.exs`. |
| US3.6 | Tie and insufficient-history positions stay unknown after later history; existing valuation reports its established missing-position result: `positions_test.exs`. |
| Cross-cutting | provider boundary exception and strict starters, raw-write DB guards, local reads under provider refusal, calculation outbox crash and independent status: ingestion_contract_test.exs, integrity_test.exs, isolation_test.exs, calculation_test.exs |

Implementation runs every manifest check through agentflow_check.py (reuse only as documented) before QA. QA reruns independently and challenges every scenario; final review uses fresh QA plus targeted risk checks. No tests executed or PASS verdict asserted during architecture. MVP is US1 safe atomic import, but feature completion requires all three P1 stories and downstream gates.

### Verification failure diagnostics

The existing profile runner intentionally suppresses raw ExUnit output. TASK-021 adds a narrow diagnostic summary to the runner and check adapter: stage, failure count, and allowlisted test file/line only. It never forwards assertion messages or values. The two supporting tests are `test/ci/test_profile_runner_contract_test.exs` and `test/scripts/agentflow_evidence_test.py`; their exact paths are included in the feature's scope inventory. This preserves the existing profile checks and retry limits while making failures actionable.

## Supporting Artifact Applicability

```json artifact-applicability
{
  "schema_version": 1,
  "research": {"required": true, "reason": "Resolve concrete existing-contract, batch-history and missing downstream-request gaps by local inspection."},
  "data_model": {"required": true, "reason": "Add immutable evidence/provenance, import check/outbox structures and operation-qualified runtime metadata."},
  "contracts": {"required": true, "reason": "Extend provider DTO, trusted statistics request and downstream domain request interfaces; no HTTP change."},
  "quickstart": {"required": true, "reason": "Feature-specific deterministic offline ingestion and worker/recovery validation require setup and expected outcomes."}
}
```

## Complexity Tracking

No constitutional violations. Additive metadata and a minimal request outbox are necessary to satisfy atomic provenance, stable replay and FR-013; immediate post-commit calls alone lose requests on process death. Detailed rationale and rejected alternatives: ADR-0028.
