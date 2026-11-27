# Feature-specific research — TASK-026

No technology survey or external research is required. The concrete unknowns below were resolved against current code, not historical run logs.

## Accepted membership at queue time

- Decision: Add immutable full-week snapshot children within the existing Publisher acceptance transaction/season lock; retain intent/check lineage and changed IDs for compatibility.
- Evidence: `statistics/ingestion/publisher.ex` inserts `CalculationIntent` with only new performance IDs; `valuation/calculation_requests.ex` validates and persists these same IDs. They do not represent all accepted performances in the week.
- Rationale: Delayed dispatch otherwise merges late membership and loses the first accepted identity (critic finding 1, FR-008/010).
- Alternatives: Selecting latest at worker execution loses original membership; using changed IDs alone mis-scores partial weeks; second import runtime duplicates ADR-0028. Legacy reconstruction must prove membership or fail explicitly.

## Managed evaluation over pinned originals

- Decision: Add a narrow fixed-version/pinned-membership managed entrypoint using original verification, Request, Preparation and Scoring; retain the existing managed descriptor and typed exact evidence conventions.
- Evidence: `valuation/managed.ex` resolves a version before `Valuation.evaluate`, but `valuation/statistics_reader.ex:select` selects current weekly history. `valuation/replay.ex` already verifies original facts through `originals` and rebuilds Preparation. `valuation/decimal_math.ex` supplies context-independent integer/coefficient techniques.
- Rationale: Retain original membership while preserving the approved formula and trust boundary. Missing data needs an error envelope because Preparation can return before building a descriptor.
- Alternatives: New scoring engine violates FR-003; calling today's evaluate on retry violates FR-004. Serializing executable Erlang terms violates ADR-0023 conventions.

## Shared quote confirmation and delivery

- Decision: Extend `market_quotes` with performance calculation linkage/sequence, protected conversion mapping/evidence and an atomic unique quote-evaluation outbox; no evaluator yet.
- Evidence: `market/quote.ex` has price/time/rule fields only. Migration `20261014000000_create_initial_player_issuance.exs` allows noninitial rules, protects quote history and acquires player locks. `workers/calculation_dispatch.ex` delivers intents separately from import completion. ADR-0024 explicitly delegates performance retention to TASK-026.
- Rationale: Reuse shared history; DB constraints/fencing, not Oban uniqueness, guarantee one result/event through acknowledgement loss. TASK-060 owns consumption deduplication (critic finding 2).
- Alternatives: Parallel performance quote store fragments history; timestamp-only latest ordering is ambiguous; immediate callback loses work after crash. Unconsumed events must remain pending.

Durable decision: `docs/adr/0029-pinned-quote-calculations-and-durable-followup.md`. Established stack/formulas and storage policies remain ADR-0020–0024/0028-owned. Outcome classification resolves critic finding 3 in `contracts/calculation.md` without changing approved scoring behavior.
