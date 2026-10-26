# Independent QA — TASK-036

Executed 2026-10-26 in a fresh QA agent session after the implementation owner
froze the final inputs. QA changed only this report. This manual delivery does
not assert an Agentflow product, development or verification run.

Base HEAD: `0f6e38db63012ac8a0aa9db0189298f985bae310`; branch:
`036-correlation-ids-and-structured-logging`. All 41 frozen changed/new input
files remained identical through the final checks. Their sorted path/content
snapshot SHA-256 is
`43618d255c2232e6658c280c1e4447bfffda6aca97089f029238209469613122`.

## Executed evidence

All eight manifest commands were executed fresh, sequentially, after the final
compatibility repairs. Environment:

```sh
PATH=/tmp/task027-elixir/bin:$PATH
ERL_FLAGS='+S 4:4'
MIX_ENV=test
MIX_TEST_PARTITION=task036qa
POSTGRES_PORT=55427
REDIS_PORT=6379
CREDO_CI_OUTPUT_DIR=tmp/credo-ci-task036qa
```

Toolchain verification independently confirmed Elixir 1.20.3, OTP 29.0.6 and
Node 24.16.0. PostgreSQL, Redis, Docker and bundled Chromium were available.
The first preparation created and migrated the new QA database through
`20261026000100`; final preparation confirmed current migrations.

| Command | Final result | Seconds |
|---|---|---:|
| `mix format --check-formatted` | exit 0 | 0.57 |
| `mix compile --warnings-as-errors` | exit 0 | 0.39 |
| `sh scripts/credo_ci.sh` | exit 0; complete input reconciliation | 6.16 |
| `node tools/openapi/validate.mjs priv/static/openapi.json` | exit 0 | 0.17 |
| `mix test.prepare` | exit 0 | 0.50 |
| `sh scripts/test_profile.sh unit` | 583 expected/discovered/executed/passed | 110.91 |
| `sh scripts/test_profile.sh integration` | 540 expected/discovered/executed/passed | 433.83 |
| `sh scripts/test_profile.sh e2e` | 3 expected/discovered/executed/passed | 28.05 |

The 1,126 cases comprise unit: 245 ExUnit, 313 Python, 8 Node and 17 shell;
integration: 531 ExUnit and 9 shell; E2E: 3 ExUnit runtime journeys. Fresh native
profile receipts share inventory SHA-256
`a001c7c4048c976ca4cc3447f334ecb978419a0f1195b0c7ef94f181a292eea5`.

Additional checks passed: the actual production coverage oracle reconciled all
519 source roles; canonical branch/task resolution and artifact applicability
were valid; `active_run` was `none`; TASK-029 and TASK-033 files were byte-for-byte
identical to `main`. An isolated build omitted the application's compiled
artifacts and successfully rebuilt it (25.84 seconds, dependency artifacts
copied and rebuilt as Mix required). Its actual default runtime handler emitted
two valid UTC JSON lines for Unicode/string and report messages, omitting private
metadata, without custom capture formatting (0.54 seconds). Application sources
were unchanged by the later compatibility repairs.

Earlier failures are preserved: initial unit discovery stopped before test
execution because the new support helper lacked inventory classification. An
earlier full integration attempt failed two stale assertions: the former
single-queue E2E configuration and the historical configuration hash guard.
The owner repaired these with exact allowances and refusal probes. Independent
targeted confirmation passed all 8 affected harness cases before the final full
round above. Logs, result records, snapshots and genuine native profile receipts
are retained in `/tmp/task036-qa-20261026/`; no historical receipts were reused.

## Acceptance assessment

- **FR-001:** Formatter tests cover typed allowlisted fields, UTC timestamps,
  quotes/newlines, Unicode, malformed bytes, reports and standard truncation.
  Runtime smoke verifies the installed default handler. Configuration review
  confirms environment levels remain unchanged and formatter loading follows
  compilation.
- **FR-002:** HTTP tests cover normal/static, unauthorized/unmatched, malformed
  JSON and genuine raised 500 responses, with one terminal record. Incoming,
  generated and rejected IDs retain Plug's policy. Encoded route literals,
  overlapping requests and HEAD verify safe template/method reporting.
- **FR-003:** Persistence assertions cover origin admission, coalescing,
  unchanged input/digest and inspection shape, retry/recovery, nullable legacy
  roots, preserved metadata and delayed downstream lineage after deleting the
  root job. Source review confirms every existing enqueue boundary is annotated
  and scan lookups are batched.
- **FR-004/FR-005:** Job tests exercise start/stop/exception state, cross-process
  reporting, concurrent isolation, caller restoration, stable legacy fallback,
  malformed optional data and retained subscriptions. Provider subprocesses
  receive approved context only. The new E2E scenario uses real HTTP and Oban
  consumers for import, dispatch and quote calculation, then an actual Oban
  timeout. It checks linked JSON events and absence of JWT/private arguments.
  Lifecycle handlers make no database queries or exception-message disclosures.
- **FR-006:** The migration adds only the nullable correlation column. Review
  confirms unchanged worker results, argument/uniqueness policies, financial
  writes, retry budgets and provider deadlines. Full profiles retain the
  existing financial, authentication, immutability and provider regressions.
- **FR-007:** Tooling tests, exact scope/refusal guards and both source/test
  inventories pass. Canonical ownership and friends' records remain intact.
  Independent final review, publication and human merge remain separate gates.

The implementation uses small formatter/context helpers, dedicated HTTP and
Oban adapters, and a separate Ecto lineage adapter. No unresolved application,
architecture or QA finding remains for the specified scope.

Verdict: PASS
