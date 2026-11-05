# Independent evaluation — TASK-090

Reviewed the compact spec, task, REVIEW.md, constitution, product/architecture/checkpoint/workflow guidance, applicable Elixir/Ecto/quality guidance, HEAD-to-worktree diff and implementation. No TASK-090 feedback file or previous evaluation exists. This evaluator did not implement the candidate, delegate review, change implementation, or inspect workflow logs.

## Acceptance and evidence

| Acceptance item | Evidence and assessment |
| --- | --- |
| Project-wide disposition | PASS. The spec covers all maintained areas with concrete ownership and retention reasons; ARCHITECTURE.md records the resulting map. The diff implements the identified defects across Quotes, web, both publishers, scraping, synchronization, schemas and workers. Unchanged Accounts, Market settlement/portfolio, Valuation, Ranking and Observability retain distinct authentication, transaction, pure calculation, snapshot and logging roles. Config/assets/priv/Mix tasks/scripts/tools/root entrypoints keep their external contracts; no migration, dependency, process or product feature was added. |
| Quotes separation and financial invariants | PASS. Admission, ImportRequests, Engine and Replay replace the mixed facade implementation. Compared transferred function bodies with HEAD: changes are owner qualification, visibility and retained-fact helper relocation. Engine retains player-before-request locks, database wall-clock lease checks, fences and atomic confirmation/event creation. Binding and retry ownership remain intact. Focused admission, concurrency, recovery and replay tests passed, including lease expiry while waiting on the player lock. |
| Workspace and local operations | PASS. WorkspaceLive retains lifecycle, navigation and subscriptions; destination modules own loading/events and Pages owns rendering. All five extracted HEEx templates occur unchanged in the original after whitespace normalization; event clause membership is preserved. LocalOperations owns Repo/Redis/Oban IO; LocalOperationsProjection owns labels. Router, browser actor conversion and administrator/local-route guards remain intact. Focused navigation, portfolio/trading, conditional-order and local-admin tests passed. |
| Ingestion and provider boundaries | PASS. Publishers retain receipt/scope/season locking and acceptance transactions; Records and Observations participate without independent commits or provider calls. Transferred persistence functions preserve their bodies and ordering. Focused publication, receipt, acceptance and provenance tests passed. Source retains assessment/completeness orchestration; PlayerProfile interprets documents; Document validates acquisition/deadlines; Budget owns shared leases. HttpTransport now depends on Budget and retains its HTTPS allowlist/streaming controls. Existing provider characterization/security assertions are retained and strengthened. |
| Removal, consolidation and namespace alignment | PASS. Maintained caller/config/supervision/reflection references do not require the empty root or ConditionalOrderProjection. Expiry projection is inlined at its sole runtime caller. Ten moved schema module definitions match HEAD modulo whitespace; persisted identities are unchanged. CatalogSync and StatisticsImport delegate to Synchronization.Execution; Oban worker names, queues, timeouts and cron references persist. QuoteClose and QuoteRecovery are separate files with retained runtime identities. |
| Regression checks, inventories and analyzer identities | PASS. Coverage/Credo inventories enumerate the resulting owners, exact workflow scope is updated, and source-bound analyzer exceptions move with their code without broadening policy. Current ThinFlow evidence validates successfully. Supplemental targeted integration checks and current hosted-equivalent Credo passed; Sobelow source digest and accepted identities, plus affected dev/test Dialyzer source/lock/message identities, were independently reconciled. |

## Deterministic evidence integrity

Recomputed ThinFlow selection and material digest with `readiness(..., require_evaluation=False)`: high risk, no unmapped paths, current branch/task, digest `93114eb16caafb052b67d4fc330a1f4479e84b12f78e33cb1f40fa5e58cc76b0`. Verified all five ordered receipt rows and evidence hashes in `.agentflow/runs/thinflow/TASK-090/candidate.json`: ci-contracts, harness-tests, format, compile and unit-profile passed. Read the named deterministic check evidence: 27 CI contract tests, 382 harness tests, and a complete unit receipt with expected/discovered/executed/passed = 712. Silent formatter/compiler output is consistent with those commands; neither is a substitute for runtime regression evidence. Policy and hosted gates are unchanged.

The selected local unit profile leaves extracted integration surfaces uncovered. To resolve that concrete risk, ran one focused command with `MIX_ENV=test MIX_PUBSUB_DISABLED=1 mix test` on these existing files:

- `test/football_market/quotes/{admission,concurrency,replay,recovery}_test.exs`
- `test/football_market/catalog/ingestion/{publication,delivery_receipt}_test.exs`
- `test/football_market/statistics/ingestion/{acceptance,provenance}_test.exs`
- `test/football_market_web/live/{local_admin_live,workspace_navigation,conditional_orders_live,portfolio_live}_test.exs`

Result: **57 passed**, seed 500490, 110.5 seconds. These checks cover extracted transactions and financial UI behavior; the full suite was not rerun.

The saved Credo snapshot was stale against current sources. Confirmed this with the repository snapshot command, then resolved the discrepancy by running `CREDO_CI_OUTPUT_DIR=tmp/credo-ci-task090-qa MIX_PUBSUB_DISABLED=1 bash scripts/credo_ci.sh`: **passed**, complete, 688 maintained/effective files, no errors. Fresh evidence is in that output directory. Recomputed the current Sobelow digest and reclassified all seven exact accepted findings with zero blocking findings. Reclassified native dev/test Dialyzer reports against current exception identities and verified source hashes and lock identity: seven/thirteen accepted findings, zero blocking. These targeted evidence checks do not claim a fresh full Dialyzer run.

## Blocking findings

None.

## Advisory findings

None requiring a code change. The stale supplemental Credo evidence was resolved during evaluation and is not an outstanding finding.

## Residual risks

This is a broad mechanical reorganization. Focused integration checks do not establish exhaustive browser, concurrency or external-provider equivalence. Static/dynamic reference review cannot prove the absence of arbitrary external module consumers. Full hosted quality/integration/E2E requirements still apply to the exact PR head; human merge remains required. This verdict establishes candidate readiness for those gates, not task completion or permission to merge.

## Re-review — valuation inventory repair

Reviewed the repair delta against the compact spec, TASK-090, REVIEW.md and repository guidance. This re-review covers the three changed files since the evaluated implementation commit `833ad3c`; the preceding evaluation records the original implementation review and its evidence. Resolved surfaces were not re-audited.

The repair adds `calculation_request.ex` to the exact valuation source inventory and registers `test/football_market/valuation/scope_test.exs` in TASK-090's workflow scope. Inspected the moved Ecto schema against its former definition in `statistics/ingestion/schemas.ex`: module identity, table, primary key and fields are unchanged. The schema is correctly grouped with existing persistence/configuration inventory entries; all pure-valuation AST, forbidden dependency and immutable-fact assertions remain unchanged. The spec records this repair without adding behavior or weakening a gate.

Fresh independent execution: `MIX_ENV=test MIX_PUBSUB_DISABLED=1 mix test test/football_market/valuation/scope_test.exs test/ci/workflow_scope_test.exs` completed with **12 passed**, seed 864487. The initial sandbox attempt stopped before tests because Mix's TCP filesystem lock was denied; the authorized retry completed successfully.

Validated current candidate evidence through `thinflow.readiness(..., require_evaluation=False)`: ready, high risk, no unmapped paths, all five required checks present with matching evidence hashes. Current material digest is `b1864ebd304971e3dda35e2f4e5f06e240aea9673227532a4e8997b55f564789`, superseding the original digest above. Inspected the named receipt/log evidence: 27 CI contract tests, 382 harness tests, formatter/compiler success, and the complete unit profile with 712 expected/discovered/executed/passed. These are saved candidate results, not newly rerun full profiles.

Blocking findings: none. The repaired candidate is ready for exact-head hosted CI and human merge. Hosted checks and human merge remain outstanding delivery requirements.

Verdict: PASS
