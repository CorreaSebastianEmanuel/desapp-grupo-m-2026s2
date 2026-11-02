# Independent evaluation — TASK-082

Re-review of Feedback 1 (B1–B3). Inspected the compact spec, task, feedback, REVIEW.md, repository principles, current diff, rate-limit repair, affected adapter/tests, and local ThinFlow candidate evidence. Focused on the pacing repair and touched boundaries; the previously reported idle-time defect is resolved and is not reissued. No implementation changes, other agents, external HTTP calls or full-suite rerun.

## Acceptance / evidence matrix

| Acceptance | Evidence / assessment |
| --- | --- |
| Runtime-only credential; reject invalid configuration before admission; secrecy and local reads | Config tests cover five runtime scopes and missing/malformed secrets. New integrity test rejects invalid source tokens without creating jobs. Successful worker test checks job argument allowlist and credential-free inspection; Input material excludes provider state. Existing local-read behavior is preserved. |
| Complete competition/season, unique nonempty teams/squads, valid identities/positions and bindings | Adapter translation plus existing Validator/Catalog/Provenance reject incomplete or malformed facts before Publisher. Registered adapter tests validate multi-team bindings, empty squad and unknown position. No repair bypass of validation found. |
| Failure preserves prior catalog; conflicts stay unpublished; omissions remain | New worker 503 test preserves the accepted catalog and schedules durable retry. New publish/update/conflict test retains omitted player binding, updates the bound player, and leaves conflicting identity unpublished. Existing atomic Publisher remains authoritative. |
| Idempotent replay/update; requested league only; protected state unchanged | New durable initial/replay/update test passes and checks stable player counts/bindings, unrelated BL1 players, nonempty quotes/issuance/holdings, matches/performance and balance sentinel snapshots. Code introduces no financial/statistics writers or deletion path. |
| Daily/manual admission, Oban worker, publication, inspection; later resource retry classification/delay | Five runtime schedules and documented operator calls reuse existing admission/worker. Error tuples now survive team translation. Registered unit cases cover later 429/503/timeout; focused durable 503 test passes with unavailable category, 90-second delay and retry_wait. Previous B2 is resolved. |
| Shared durable pacing across workers/restarts/retries and resets; <=10 requests per rolling minute | PostgreSQL credential-digest state replaces process-local accounting. `ProviderRateLimit.reserve/3` reads `clock_timestamp()` after acquiring the credential row lock and clamps eligibility to the maximum of that time, `next_allowed_at`, and `blocked_until`; unused intervals no longer accumulate after idle periods. The registered idle regression backdates both timestamps by ten minutes, performs twelve reservations, and requires increasing waits after the first admission. Existing shared-caller and long-reset coverage remains. No blocking pacing defect found. |
| Required deterministic source-specific coverage | New runtime and durable-path cases are registered. The recorded focused rate-limit/integrity run reports 11 passed, including the aged-idle regression. This addresses the earlier absence of source-specific durable coverage (previous B3). |

## Risk and deterministic evidence

High risk remains appropriate: authenticated external catalog identity changes and a new PostgreSQL pacing table. ThinFlow recomputation via `scripts.thinflow.readiness(Path.cwd(), "TASK-082", require_evaluation=False)` passed: current candidate material/selection matches the receipt and every required check artifact hash verifies. No unmapped paths. Required selection: `ci-contracts`, `harness-tests`, `format`, `compile`, `unit-profile`; all five receipt entries report success. Linked unit evidence records 697 expected/discovered/executed/passed cases; harness evidence records 382 tests, OK. Semantic review of test_profiles.json found only added cases/helper, with no removed or changed existing entries. `git diff --check` passed.

The selected unit profile does not execute the new integration cases. The recorded focused run of `provider_rate_limit_test.exs` and synchronization `integrity_test.exs` reports **11 passed**, exit 0, and includes the idle regression. The prior sandboxed probe documented B1 before repair: twelve consecutive reservations returned `{:ok, 0}` after ten minutes idle. The new regression now exercises the same aged-row condition and verifies pacing waits.

The recorded focused command used pinned Elixir 1.20.3/OTP 29 and `MIX_ENV=test mix run --no-start --no-compile` with QA-only script `.agentflow/runs/thinflow/TASK-082/qa-repair-targeted.exs`; it starts the application with a two-connection test pool and loads test_helper plus the affected test files. A fresh rerun in this evaluator session could not initialize because the local no-compile build lacks `FootballMarket.Observability.JSONFormatter`; the recorded focused output and current passing ThinFlow receipt were reviewed. No candidate implementation/configuration was edited. Probe source/output are evaluator evidence, not workflow logs.

## Findings

No blocking findings. The earlier B1 pacing finding is resolved by the database-clock clamp and aged-idle regression described above. B2 retry metadata preservation and B3 source-specific durable-path evidence remain resolved; neither is repeated.

Advisory: a fresh focused rerun in this evaluator session could not initialize due to a missing compiled `FootballMarket.Observability.JSONFormatter` module under `--no-compile`. The saved focused run and current ThinFlow receipt provide successful evidence; hosted exact-head CI remains the next authoritative check.

## Architecture, security and residual risks

External translation, domain reconciliation and atomic persistence remain separated. The pacing facade selects an infrastructure backend; PostgreSQL retains only a SHA-256 credential key and timestamps. Fixed HTTPS origin, disabled redirects, TLS verification, bounded response validation and credential-free durable job arguments remain intact. No new web endpoint or financial/statistics mutation was found.

Live provider credentials/entitlement/payload compatibility, hosted exact-head CI and human merge are unverified. Season rollover still requires the documented restart. Protected-state tests do not seed nonempty orders/transactions; preservation there is supported by unchanged publication code rather than a new nonempty-state assertion. Concurrent in-flight reservations encountering a later provider reset are not directly exercised by the new tests. These coverage limits do not create blocking findings. The candidate is ready for CI and human merge review.

Verdict: PASS
