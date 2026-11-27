# Independent evaluation — TASK-092 repair

Reviewed Feedback 1, the compact spec, task, REVIEW.md, governing documents, repair diff against HEAD and affected implementation, tests, inventories, and ThinFlow evidence. This review focuses on the Dialyzer repair; unaffected acceptance surfaces were inspected without repeating the previous full review. No implementation edits, delegation, or workflow-log inspection were performed.

## Acceptance and evidence

| Acceptance / feedback | Assessment | Evidence |
| --- | --- | --- |
| Durable snapshots and asynchronous first valuation; issuance-only eligibility | PASS | Recovery admits accepted snapshots with selected configuration/mapping and no performance quote. The affected first-publication integration case passed, starting from issuance-only state and draining Oban. No page/provider path changed in this repair. |
| Selected configuration, exact conversion, immutable evidence and notification | PASS | First-publication case asserts selected version/mapping, exact 2.50 price, sequence 1, retained facts, score string, successful replay and one quote-linked event. `Result.outcome/2` normalizes every scored outcome to Decimal before `Engine.evidence/3`. |
| Competing requests, retries, recovery and nightly overlap | PASS, unaffected | Repair changes only score serialization. Player-before-request locks, lease fencing, canonical-calculation reuse and initial eligibility remain intact. Existing separate-connection/barrier and interrupted-completion tests remain present; not rerun on this repair. |
| Later statistics wait for close; nightly/TTL behavior | PASS, unaffected | Admission and close rules are unchanged by the repair; existing later-import and nightly-overlap tests remain intact. No new daytime admission path is introduced. |
| Missing configuration/mapping/data, nonpositive outcomes and bound-version retries | PASS | Existing pending/configuration and retry controls remain unchanged. Targeted no-quote case passed for missing metrics, zero score and rounded-to-zero conversion, checking evidence and replay plus absence of financial changes. Missing-score failures use `no_score_evidence/3`, which omits the score key. |
| Architecture, UI distinction, regression scope and inventories | PASS | Repair stays inside Quotes and strengthens existing integration cases. UI, purchase, ranking, order and configuration boundaries are unchanged. Existing cases remain registered in profile/coverage/Credo inventories; workflow scope adds the feedback and lesson paths. |
| Separate preload/refresh follow-up | PASS, unaffected | TASK-093 remains todo, depends on TASK-092 and captures preload, scheduling, startup recovery, deduplication/rate limits and automatically updating preparing cards. No follow-up implementation added. |
| Feedback: native Dialyzer repair without suppressions or gate changes | PASS | Removed only the unreachable nil comparison at `engine.ex:313`. Scored outcomes always carry Decimal; unscored failures retain their separate persistence/evidence path. Analyzer scripts, exceptions, formula and CI policy are unchanged. Native evidence and current application recheck are detailed below. |

## Risk, boundaries and deterministic evidence

High risk remains appropriate for financial publication and concurrent confirmation. Current selection covers 27 material paths, has no unmapped paths, and requires `ci-contracts`, `harness-tests`, `format`, `compile`, and `unit-profile`.

Executed `scripts.thinflow.readiness(..., require_evaluation=False)`: current branch/task, selection, policy, material digest and all check evidence hashes match. Digest: `e0fa500eeac688a59609dfdf54d60cd53328d61381bd27a3cf7b6de1179f2cf0`. Inspected deterministic outputs: 27 CI-contract tests passed; 387 harness tests passed; unit receipt reports 717 expected/discovered/executed/passed, complete. Format and compile have successful exit codes and empty output. `git diff --check` passed.

Read native model/application reports in `tmp/dialyzer-ci` and independently reclassified them using the unchanged classifier and exact exceptions: dev/model 1435 files, 144 existing exceptions; test/model 1425 files, 123 exceptions; dev/application 299 files, 6 exceptions; test/application 378 files, 12 exceptions. All have zero blocking findings and no errors. Tool versions match the repository pins. Probe evidence distinguishes an invalid contract, a corrected contract, an unknown function and an analyzer error. These are native artifacts, not workflow summaries.

No financial formula, floating-point operation, history rewrite, authorization surface, external IO, web persistence access or new dependency is introduced by the repair. Existing atomic confirmation and conditional-order event publication are preserved.

## Targeted independent checks

The selected unit profile excludes the changed integration assertions. To cover this concrete gap, ran:

```sh
MIX_ENV=test MIX_OS_CONCURRENCY_LOCK=0 mix test \
  test/football_market/quotes/initial_test.exs:45 \
  test/football_market/quotes/initial_test.exs:111
```

Result: **2 passed, 6 excluded**, exit 0, seed 135823. These two cases exercise positive score serialization/replay, missing-score evidence, zero score and rounded-to-zero conversion.

To verify the specific hosted Dialyzer discrepancy against the current source, reran only the existing `dialyzer_ci.analyze` application phase for dev and test, with the repository exception file. Evidence directory: `/tmp/task092-qa-dialyzer-ttznf5uf`. Result: **dev/application PASS** (299 files, 6 existing exceptions, zero blocking findings/errors) and **test/application PASS** (378 files, 12 existing exceptions, zero blocking findings/errors), process exit 0. Full model analysis and the full test suite were not rerun.

## Blocking findings

None.

## Advisory findings

None.

## Residual risks

This repair review does not rerun unaffected concurrency, browser or full integration suites. Hosted checks must still validate the exact PR head, including coverage. Preload and scheduled refresh remain TASK-093 scope. Human merge is required for completion.

Verdict: PASS
