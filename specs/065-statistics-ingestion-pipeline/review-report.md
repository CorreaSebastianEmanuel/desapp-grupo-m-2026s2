# Review Report — TASK-021 Statistics Ingestion Pipeline (final review, 2026-10-17)

**Scope**: independent final review per T032 after Feedback 7. Canonical artifacts read in full (spec/plan/tasks, verification.json, data-model, contracts, handoffs/architecture, handoffs/develop, backlog/feedback/TASK-021.md Feedbacks 4–7, fresh qa-report.md), plus the feature diff (`64816f6..HEAD` + working tree) and implementation code. Stale review artifacts and product-debate handoffs excluded. Per Feedback 7, no full re-run: fresh QA evidence (all manifest checks exit 0 today, 606/606 warnings-as-errors suite, zero committed residue) treated as reproducible.

## 1. Architecture and design

- Boundary integrity holds: Providers → Synchronization/Oban → Statistics; no new HTTP route, permission, cache, Redis ledger, or quote/scoring/chart behavior. `valuation/calculation_requests.ex` accepts and deduplicates intents with conflicting-membership rollback and unique-violation replay handling; it never invents completion state (FR-013).
- `positions.ex` implements the fixed committed-history rule exactly: same player/season, known position, strictly earlier kickoff, one vote per match, unique mode or explicit unknown (`tie`/`insufficient_history`), policy v1 basis retained. Position-ID sorting is only deterministic traversal; ties still resolve unknown (FR-011).
- `publisher.ex` locks consistently (receipt → season advisory → scope/replay rows), reads history once after the season lock, and classifies outcomes before advancement. QA-01 remediation (lines 50–59, 554–590) re-resolves every team/player binding and validates each match mapping against existing bindings and retained input on replay, rolling back `:immutable_conflict`; conflicting mappings can no longer bypass prevalidation or advance the pointer.
- Closed outcome/error categories with a total `status/1` mapping; unexpected reasons degrade to `persistence_failure` without leaking detail (FR-012/FR-007).

## 2. Security

- Provenance stores only closed, source-qualified identities plus sanitized fixture references with SHA-256 of actual bytes and a mandatory `non_live` marker; no raw payload, credential, or exception fields.
- Static check: zero `Exception.message`/`inspect`/`IO` leakage in `lib/football_market/statistics/**` and the calculation handoff; zero `Providers.` references in the local read path — FR-015 isolation is structural.
- Fixture paths are fixed constants, not caller-supplied (no path-escape surface); all atom conversions use `to_existing_atom`.

## 3. Targeted check (discrepancy resolved)

The uncommitted `dispatcher.ex` `:repo` option raised one uncovered risk: whether it globally retargets the default Repo. Verified against Ecto (`deps/ecto/lib/ecto/repo.ex:314`): `put_dynamic_repo` is `Process.put`, process-local only; the dispatcher's `init/1` affects itself, and the default catalog flow is unchanged elsewhere. No behavioral risk; no test rerun needed.

## 4. Maintainability observations (non-blocking)

1. `publisher.fixture_artifact!/1` reads `test/fixtures/...` and evaluates the inventory from lib code. This matches the approved fixture-provenance design (fixed repo-relative artifact, digest-drift rejection) and fixtures are non-live development-only, but it couples production code to test-tree paths; a future task should relocate the admitted inventory if fixtures ever leave the repo.
2. `StatisticsIngestion.Case` mutates the global `FootballMarket.Synchronization` app env during owned-store tests; `after`-restoration plus 606/606 green is acceptable, but that race window is inherent to the sanctioned `Synchronization.Case` pattern too.
3. `verification.json` maps SC-005 (traceability) evidence to `metrics_test.exs`; behavior is independently covered by `provenance_test.exs`, so this is mapping granularity, not a coverage gap (same class as QA residual note 1).

## 5. Checkpoint coverage and QA evidence

All FR-001..016 and SC-001..007 are bound in `verification.json`; QA independently challenged every scenario. QA-01/02/03 were re-verifiably remediated and re-audited; the Feedback 6 CI-isolation defect was fixed without reverting them. Coverage CI preserved; no historical CP1 report added.

Backlog impact: none — Remediations (replay mapping validation, typed JSONB evidence, committed-basis trigger validation, per-test owner schemas, additive dispatcher `:repo`) are self-contained within TASK-021 and change no contract consumed by TASK-056 freshness reads or the future quote-orchestration consumer of `valuation_calculation_requests`.

Ready for human merge with T031 re-checks confirmable and T032 closed by this report.

Verdict: PASS