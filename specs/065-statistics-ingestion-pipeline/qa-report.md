# QA Report — TASK-021 (specs/065-statistics-ingestion-pipeline)

Scope: specs/065-statistics-ingestion-pipeline. QA executed all manifest checks independently via `python3 scripts/agentflow_check.py CHECK_ID --stage qa` with no `--reuse`, on the developer-remediated tree (QA-01/02/03 per backlog/feedback/TASK-021.md). No implementation code was modified. Probe artifacts were rolled back; the test database was left empty (leagues=0, performances=0, basis=0).

## Manifest checks (fresh, stage qa)

| Check | Result | Elapsed | Evidence |
|---|---|---|---|
| preflight | PASS | 2.3s | `.agentflow/runs/checks/...065.../qa/preflight/ba556269….log`; DB prepare + infrastructure.verify OK |
| format | PASS | 1.5s | `qa/format/e594e61e….log` |
| compile | PASS | 0.8s | `qa/compile/ce51d9d1….log`; warnings-as-errors |
| unit | PASS | 34.8s | `qa/unit/7fea5211….log`; `CP1_PROFILE_RECEIPT profile=unit audit_count=58 status=complete` |
| integration | PASS | 363.8s | `qa/integration/32bb14b7….log`; `CP1_PROFILE_RECEIPT profile=integration audit_count=117 status=complete` |

Integration attempt 1 failed in 1.5s with `category=node-runtime` (Node 24 missing from PATH — documented prerequisite in handoffs/develop.md). Input was corrected (`PATH=/Users/ezequielgonzalez/.nvm/versions/node/v24.21.0/bin:$PATH`) and the retry stayed within the two-failure budget. Windows were historical consideration only. All 14 remedied/regression checks above are fresh — zero receipt reuse.

## Previously cited findings (feedback 4) — re-audited independently

| Finding | Re-audit evidence | Verdict found |
|---|---|---|
| QA-01: replay prevalidation omitted match mappings; retargeted mappings silently accepted and advanced the successful pointer | `lib/football_market/statistics/ingestion/publisher.ex:50-59` resolves teams/players then validates every match mapping; `:75-76` rolls back `:immutable_conflict` on changed canonical material. Regression `test/football_market/statistics/ingestion/replay_test.exs:73` retargets `match-1` to an alternate match on both replay and unchanged imports; asserts `immutable_conflict`, MatchBinding unchanged at `:124`, `last_accepted_check_id` unchanged at `:125`, check count unchanged at `:126`. | Remediated |
| QA-02: integrity test encoded records with `Jason.encode!`, storing a JSONB string; typed maps + positive control + non-object rejection required | `test/football_market/statistics/ingestion/integrity_test.exs:94-126` passes typed Elixir maps bound as `$8::jsonb` and rejects nil participation, missing/nil policy_version; `:128-146` is a positive control accepted as JSONB object. Additional live-DB probe (transaction, rolled back): frequencies as non-object JSONB → `ERROR invalid participation evidence` (23514); encoded-string JSONB → rejected; valid typed object → accepted. Enforced by `priv/repo/migrations/20261016000100…:95` (`jsonb_typeof(frequencies) = 'object'`). | Remediated (also at DB level via probe) |
| QA-03: migration validated evidence only on performance INSERT; a late child basis row against an already-committed subject could change explanation unvalidated | Migration adds `statistics_position_basis_insert_guard` (`…00100…:69-85`): rejects basis rows for `derived_history/unknown_history` subjects without provenance, i.e., already-committed facts. Regression `test/football_market/statistics/ingestion/positions_test.exs:235-275`: committed substitute with insufficient_history, then raw child INSERT to its basis raises `Postgrex.Error` and leaves 0 basis rows. Probe used committed state from separate transactions (import committed first, then raw INSERT on independent committed connection). | Remediated |

## Spec challenge (all FR/SC and 14 scenarios)

Spot-checked concrete evidence against each FR/SC group in verification.json; audited unit (58 modules) and integration (117 modules) profiles completed.

| Spec area | Evidence (fresh integration unless noted) |
|---|---|
| US1.1-1.4 complete/unchanged/empty acceptance, atomicity | `ingestion/acceptance_test.exs`, `completeness_test.exs` (exact counts, provenance, intent, receipt, rollback boundaries) |
| US2.1-2.4 replay/conflict/races/controlled failures, no mutation of accepted facts | `replay_test.exs`, `canonical_test.exs`, `concurrency_test.exs` (independent committed connections via `Sandbox.unboxed_run`), `recovery_test.exs` + `support/statistics_ingestion/runtime_probe.ex` (killed worker before/after publication, bounded retries, confirmed final attempts with no retrieval #4), `synchronization/statistics_test.exs` |
| US3.1-3.6 lineage, unknown vs zero, direct/derived/tie/no-history positions | `provenance_test.exs` (fixture ID/SHA-256/origin/date/case/non_live marker), `metrics_test.exs:12` all nine optional metrics independent nil-vs-zero, `positions_test.exs` (unique prior-match mode, exact basis IDs/freqs, equal-kickoff exclusion, proposed batch exclusion, tie/insufficient unknown, no backfill), `integrity_test.exs` raw write guards |
| FR-013/SC-006 calc request separate from quotes | `calculation_test.exs:11` no quote writes; `:82` unordered multi-performance identity normalization (develop regression); `:138`, `:181` (redelivery), `:313` bounded budget |
| FR-015/SC-007 no provider calls in local reads, zero live traffic | `isolation_test.exs:32-43` transport counter == 1 on provider failure while `list_player_history/1` result is byte-equal before/after; no credentials anywhere in fixture evidence |

## Runtime applicability

`verification.json` declares `runtime_required=false`. Verified correct: `git status --porcelain lib/football_market_web priv/football_market` is empty; the diff touches no router, controller, or endpoint; FR-015 forbids new public APIs. No HTTP endpoint was exposed or changed, so no curl-based runtime check applies. Real PostgreSQL, Oban, and work/process runtime are exercised inside integration as required.

## Residual risks and observations (non-blocking)

1. `integrity_test.exs` does not include a literal JSONB non-object `frequencies` variant; the rejection is enforced at the database trigger level (probe A/B2 above verified live with `23514 invalid participation evidence`), which is stronger than a test that would only duplicate the constraint. No behavioral gap.
2. Probe tables were created with a supported league code inside transactions; all rolled back — verify no `qa-probe` residue (confirmed: empty counts).

## Word-fidelity inputs

Reports were regenerated after this completed re-audit; the prior stale FAIL texts are superseded. This verdict governs `qa-report.md` and `handoffs/qa.md`.

Verdict: PASS
