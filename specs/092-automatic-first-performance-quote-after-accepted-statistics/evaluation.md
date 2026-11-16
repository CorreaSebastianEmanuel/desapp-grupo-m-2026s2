# Independent evaluation — TASK-092

Reviewed the compact spec, task, REVIEW.md, governing product/architecture/checkpoint/constitution documents, complete candidate diff, implementation, tests, inventories and current ThinFlow receipt. No TASK-092 feedback file or previous evaluation was present. Implementation was not modified; no other evaluator was invoked and no workflow logs were inspected.

## Acceptance and evidence

| Acceptance | Assessment | Evidence |
| --- | --- | --- |
| Durable accepted snapshots, asynchronous recovery, issuance-only eligibility, local reads | PASS | Existing `CalculationRequests.accept/3` and `Membership.record_import!/1` retain immutable snapshot ownership; `Recovery.admit_initial!/0` admits imports with an active selection and existing mapping. Existing minute-based QuoteRecovery enqueues Oban without a page visit. InitialTest first-publication case drains the queue from issuance-only state. No provider/read-path changes. |
| Selected configuration, exact conversion, evidence, confirmation and notifications | PASS | InitialTest asserts selected version/mapping, exact 2.50 price, sequence 1, retained facts, successful replay and one quote-keyed evaluation event. Existing `Store.confirm!/6` retains atomic quote/event/order wake publication. |
| Concurrent first publication, retries, recovery and overlapping close | PASS | InitialTest uses separate database connections and observed lock waits; exactly one daytime quote/event survives competing snapshots. The loser returns to pending with no consumed attempt. Separate overlap case preserves nightly admission. Injected persistence/completion failures verify bound-version retries and reuse after confirmation. |
| Subsequent imports wait for close; existing nightly/TTL behavior | PASS | InitialTest later-changes case retains an unattempted pending request until close. Existing ImportTest manual-close case and RecoveryTest nightly TTL case pass. TTL admission identity and latest-snapshot/latest-quote selection are unchanged. |
| Missing configuration/mapping, insufficient/nonpositive inputs and binding | PASS | InitialTest covers pending requests until configuration/mapping exists, missing metrics, zero score, conversion rounded to zero and later positive facts; protected financial state stays unchanged for no-quote outcomes. Retry preserves the selected version after activation changes. Mapping/configuration write-once database guards remain intact. |
| Architecture, UI wording, regression contracts and inventories | PASS | Web changes project domain state through LocalOperations/components; recovery and financial persistence remain in Quotes. Updated architecture/UI distinguish initial preparation from subsequent close. Targeted purchase eligibility, active-version ranking, conditional-order quote locking, administration activation and both preparation-message tests pass. New migration/test paths and all ten new cases are registered in maintained inventories; workflow scope matches candidate paths. |
| Separate dependent preload/refresh delivery | PASS | TASK-093 depends on TASK-092 and captures preload, scheduling, startup recovery, deduplication/rate limits, local reads and automatically updated preparing cards. Those acquisition/scheduling behaviors are not implemented in this diff. |

## Risk, boundaries and deterministic evidence

High risk is correct for asynchronous financial publication and concurrency. Deterministic selection matches all 25 changed paths, has no unmapped paths, and selects `ci-contracts`, `harness-tests`, `format`, `compile`, and `unit-profile`. No policy or CI gate was weakened.

Validated `.agentflow/runs/thinflow/TASK-092/candidate.json` with `scripts.thinflow.readiness(..., require_evaluation=False)`: current task/branch, selection, policy and material digest match, every selected check completed with exit 0, and every evidence file matches its recorded SHA-256. Material digest: `385dbcec96077a4c82f8ab98cfaf5ae7942f1241b5d66c74b4e6c3547bbe1549`. Checked deterministic check output: 27 CI-contract tests passed; 387 harness tests passed; unit receipt reports 717 expected/discovered/executed/passed and complete. Formatter/compiler output is silent, consistent with successful check-only commands. `git diff --check` also passed.

Confirmation still takes the player lock before the request lock, rechecks the live lease, and fences initial eligibility before new calculation persistence. Existing canonical calculations are reused for interrupted completion. Closing may grant write-once nightly admission to running/retrying initial work; confirmation reads that current admission under lock. UUID parameters are bound in recovery SQL. No new external IO, web persistence access, authorization surface, credential handling, floating-point pricing or historical rewrites were introduced.

## Targeted independent check

The selected unit profile does not execute the new integration-tagged financial tests. To resolve that uncovered publication/concurrency risk and check affected contracts, ran only this focused selection, with `MIX_ENV=test MIX_OS_CONCURRENCY_LOCK=0`:

```sh
mix test \
  test/football_market/quotes/initial_test.exs \
  test/football_market/quotes/import_test.exs \
  test/football_market/quotes/recovery_test.exs:129 \
  test/football_market/market/purchases/rejection_test.exs:51 \
  test/football_market/ranking/selection_test.exs:7 \
  test/football_market/market/conditional_orders/quote_order_test.exs \
  test/football_market_web/live/administration_live_test.exs:72 \
  test/football_market_web/live/local_admin_live_test.exs:120 \
  test/football_market_web/live/portfolio_live_test.exs:413
```

Result: **21 passed, 38 excluded**, exit 0, seed 683553, 77.1 seconds. Private-schema tests execute the migrations and use committed separate connections for financial races. The full suite was not rerun.

## Blocking findings

None.

## Advisory findings

None.

## Residual risks

The independent run covers selected integration cases, not the complete integration/browser suite or a live provider deployment. Recovery remains asynchronous on the existing minute schedule. Initial preload and automatically updating preparing cards remain TASK-093 scope. Readiness here permits CI and human review; the exact PR head must still pass hosted `ThinFlow required`, and completion still requires human merge.

Verdict: PASS
