# Independent QA — TASK-018

Active feature resolved from `.specify/feature.json`. Read spec, plan, tasks, architecture/development handoffs, verification manifest, current TASK-018 feedback and applicable TASK-005/TASK-055 feedback. Inspected tracked diffs and every new ingestion source, schema, migration and test file. Implementation was not modified; no developer receipts were reused.

## Reproduction and evidence

Commands and exit codes are recorded in `qa-evidence/results.json`; complete bounded-check output is retained in `qa-evidence/<check-id>.log`. Run directly from the repository:

```sh
export PATH="/private/tmp/task018-elixir-1.20.3/bin:/Users/ezequielgonzalez/.nvm/versions/node/v24.21.0/bin:$PATH"
python3 specs/057-idempotent-catalog-ingestion/qa-evidence/run_manifest.py
MIX_ENV=test MIX_TEST_PARTITION=task018_ingestion mix test --warnings-as-errors specs/057-idempotent-catalog-ingestion/qa-evidence/adversarial_test.exs
```

The runner executes the manifest argv/env unchanged, sequentially, stopping on failure. PostgreSQL/Redis preflight independently reported ready and `infrastructure.verify` reported both OK. Additional QA probes: `adversarial.log`, **6 passed**.

## Acceptance evidence matrix

Check IDs below identify executed commands, logs and inspected assertions, not development summaries. US numbers refer to spec scenarios.

| Acceptance | Independent evidence and relevant assertions |
|---|---|
| US1.1 | publication, matrix: exact initial counts, typed bindings/membership and player/team/season/league/position joins across five leagues/two seasons. |
| US1.2 | identity: addition, rename, position change, transfer retain UUID/catalog identity in both row orders. |
| US1.3 | publication: malformed/duplicate relationships rejected; interruptions after catalog, bindings and observation leave exact prior snapshots; provider-contract rejects incomplete results. |
| US1.4 | isolation: local filter/detail reads during source outage, no `:source_called`; concurrency observer sees no partial hierarchy. |
| US2.1 | replay, matrix: ten replays per delivery preserve reference, records and evidence; applied counts/bindings are zero. |
| US2.2 | canonical, replay: independently encoded resolved facts; collection/reference permutations replay; later identical facts preserve row timestamps. |
| US2.3 | identity, matrix, adversarial: same-name players distinct; season/provider qualification; same source ID across kinds and different-case player IDs retain separate identities. |
| US2.4 | identity: unbound name and unmapped replacement conflict with unchanged snapshots. |
| US2.5 | identity, adversarial: trusted replacement appends bindings with stable IDs; duplicate/extra/foreign/wrong-kind/collapsing instructions fail. |
| US2.6 | concurrency: separate backend PIDs/barriers; equivalent first deliveries converge; differing revision-zero/revision-n deliveries have one winner; shared league across seasons. |
| US3.1 | retention, replay: stale observation rejected; old accepted replay never restores transferred facts; future-clock limitation preserved. |
| US3.2 | retention, identity: omitted teams/players/bindings remain; retained-team collisions reject whole updates. |
| US3.3 | retention, outcomes, adversarial: empty initial/update catalogs accepted with zero team/player changes; unknown/unsupported/invalid remain failures. |
| US3.4 | retention, adversarial: same instant with changed fixture, facts or provider conflicts without writes. |
| US3.5 | outcomes, adversarial, publication: all safe categories/retry flags/delay preserved, including against accepted state; safe exception templates, no partial success. |
| US3.6 | isolation: actual selected offline scraper has explicit fixture lineage; live request remains unsupported with unchanged state. |

| Requirements / success criteria | Additional coverage |
|---|---|
| FR-001–002 | Existing provider port/request/vocabulary; publication plus existing constraints regressions; invalid canonical names probed independently. |
| FR-003–007 | Typed FK/scope constraints, conservative adoption, immutable bindings, explicit instructions, stable transfers; identity/publication/adversarial. |
| FR-008–009 | Additive omission, empty success, all-or-none publication and observer isolation; retention/publication/concurrency. |
| FR-010–013 | Independent canonical encoding, full equality after digest lookup, replay/revision/time precedence, membership/count lineage; canonical/replay/concurrency/retention/publication. |
| FR-014–017 | Safe recoveries, no retry/late publication, offline lineage, local-only reads and deterministic evidence; outcomes/isolation/matrix/provider-contract plus probes. |
| SC-001–002 | Two five-league/two-season runs; 20 observations/50 bindings per run; ten replays and re-references. |
| SC-003–004 | Exact rollback snapshots, single concurrent winner, stable transfer identities and untouched historical/account state. |
| SC-005–007 | Explicit statuses/counts/recovery/fixture evidence; zero-call local reads; two controlled runs compare semantic outcomes/rows/observations. |

Write-set inspection confirms Catalog/evidence-only writes; matches, performances, accounts and credentials remain unchanged in isolation assertions. Financial tables not yet implemented are not fabricated as evidence. No provider transport/default, scheduling, statistics freshness or quote write was added.

HTTP runtime obligation: **not applicable**. The complete production diff adds an internal domain/persistence API and migrations; no controller, router, HTTP contract or endpoint changes. Existing browser regression remains required through the integration profile.

## Check outcome and limits

All **17 manifest checks exited 0**, totaling **275.205 seconds**. Focused results: canonical 4, publication/constraint regressions 15, identity 8, replay 4, concurrency 5, retention 3, outcomes 5, isolation 3, matrix 1, provider-contract 28 passed. Profiles independently reported `unit audit_count=38 status=complete` and `integration audit_count=48 status=complete`; their executable contract checks completion, nonzero tests, no skipped tests and browser prerequisites. Supplemental probes: 6 passed.

No acceptance blockers. Verification is deterministic offline evidence, not live readiness. The documented default-test-database fixture remains untouched; checks use `task018_ingestion`. Migration rollback against shared services was not executed. QA-only artifacts were whitespace-checked after creation.

Verdict: PASS
