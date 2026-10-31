# desapp-grupo-m-2026s2
UNQ-Desarrollo de Aplicacion- Alquimistas

## Football Player Market application

This repository contains the Phoenix foundation for Football Player Market. PostgreSQL is the authoritative durable store; Redis is only a replaceable connectivity/read-optimization dependency and never authoritative.

### Prerequisites

- macOS or Linux, Git, and `curl`
- Erlang/OTP 29.0.6 (ERTS 17.0.6)
- Elixir 1.20.3 with Mix
- Hex and Rebar (the preparation commands install them if absent)
- Phoenix dependencies locked by `mix.lock`; `phx_new` is not needed to build the checked-in application
- Network access during preparation only
- Docker Engine 27+ or current Docker Desktop with Compose v2
- TCP ports 4000, 5432, and 6379 free on loopback

### Local PostgreSQL and Redis

Defaults are tracked in `.env.example`; they work without editing files and are unsafe for shared or production environments. Override them through environment variables or copy them to an untracked `.env`.

Run the nine lifecycle actions in order as needed:

```bash
cp .env.example .env                         # configure
./scripts/local_services.sh start            # start
./scripts/local_services.sh inspect          # inspect
./scripts/local_services.sh ready             # verify readiness, bounded to 30 seconds
mix infrastructure.database.setup             # prepare database and migrate
mix infrastructure.database.migrate           # rerun ordered migrations safely
mix infrastructure.verify                     # application connectivity for both dependencies
./scripts/local_services.sh stop              # stop while preserving data
./scripts/local_services.sh restart           # converge containers to running, then wait until healthy
./scripts/local_services.sh reset --confirm   # DESTRUCTIVE: remove only repository-scoped volumes
```

The verifier reports PostgreSQL and Redis independently, prints only host/port/database targets, and exits nonzero if either fails. There is intentionally no public health endpoint. Test databases are restricted to `football_market_test` plus `MIX_TEST_PARTITION`; unsafe overrides fail before connection or schema mutation.

For occupied ports, stop the conflicting process or override `POSTGRES_PORT`/`REDIS_PORT` consistently. Authentication, invalid configuration, unavailable service, readiness timeout, and migration failures name the affected category without printing passwords. Lifecycle mutations are serialized for this repository, and restart converges stopped or stale containers back to the declared Compose state before readiness succeeds. Routine start, stop, and restart preserve both named volumes; only the explicitly confirmed reset deletes them.

The supported baseline is exact. Select the pinned toolchain in your version manager, then run:

```bash
./scripts/check_toolchain.sh
```

The check exits nonzero and names the mismatch when Elixir, OTP, ERTS, Mix, or Erlang is absent or unsupported. Do not continue on a mismatch.

### Development demonstration catalog

After migrating a development database, explicitly load the fixed fictional 2026–2027 catalog with:

```bash
mix catalog.seed
```

The first run reports `total=44 created=44 reused=0` with 5 leagues, 5 seasons, 10 teams, 4 positions, and 20 players. Repeating it reports `created=0 reused=44` and preserves existing identities, literal normalized-equivalent values, timestamps, and relationships. PostgreSQL must be reachable; Redis, a football provider, and network access are not required.

This command is enabled only by checked-in development and test configuration. It is never called by application startup, `mix setup`, Ecto aliases, migrations, releases, or deployment, and production/unknown environments fail before database access. Failures are nonzero and expose only the categories `disabled`, `validation`, `conflict`, and `persistence`; the causes `invalid_manifest`, `alternate_identity`, `misplaced_relationship`, `attribute_mismatch`, `relationship_mismatch`, `database`, `write_failed`, `concurrent_write`, and `database_unavailable`; an allowlisted entity; and a manifest-owned identity. Any unknown internal failure becomes the generic `persistence/write_failed` result. Resolve conflicts in the named local record; retry a `concurrent_write` after the other seed run finishes; investigate local PostgreSQL for `database` or `database_unavailable` failures. The complete isolated-database and timing procedure is in [`specs/006-development-seed-data/quickstart.md`](specs/006-development-seed-data/quickstart.md).

### API documentation

With Phoenix running (`mix phx.server`), open [the interactive API documentation](http://127.0.0.1:4000/docs) or retrieve [the OpenAPI 3 JSON description](http://127.0.0.1:4000/openapi.json). Both are public. The page documents the two catalog routes and three quote routes; executing any operation requires one valid credential.

In `/docs`, choose **Bearer JWT** or **API key**, enter your own credential in the masked field, open an operation, and select **Try it out** then **Execute**. The page sends `Authorization: Bearer <JWT>` or `X-API-Key: <key>` for the selected method. Switching methods clears the field. Leave it empty to see the generic 401 and `WWW-Authenticate: Bearer realm="api"`. The credential is not part of the documentation URL or saved in browser storage. These placeholders are not functional credentials; there is no public login or key-issuance HTTP route.

For a reproducible local walkthrough with short-lived test credentials, install Node 24, npm, and Chromium, then run:

```bash
npm ci --prefix tools/openapi
node tools/openapi/validate.mjs priv/static/openapi.json
npm test --prefix tools/openapi
MIX_ENV=test mix test test/football_market_web/openapi_contract_test.exs test/football_market_web/openapi_browser_test.exs
```

The browser test starts an isolated loopback server, discovers all five catalog and quote operations and all five list parameters within three minutes, executes JWT → API key → JWT requests, verifies 401 with no credential, and closes Chromium and the server. It reports header presence and status without printing credential values. See the [TASK-013 quickstart](specs/013-openapi-cp1-contracts/quickstart.md) for the full check sequence.

### Player quote reads

The protected quote API accepts the same JWT or API-key authentication as the catalog:

| GET path | Result |
| --- | --- |
| `/api/players/:player_id/quotes/current` | Current persisted quote |
| `/api/players/:player_id/quotes/history` | Complete immutable history, oldest sequence first, including issuance |
| `/api/players/:player_id/quotes/at?date=YYYY-MM-DD` | Last quote effective through the end of that UTC date |

Single results use `{"data": quote}`; history uses `{"data": [quote, ...]}` without pagination. Prices are exact decimal strings with two places. Each quote retains its original UTC timestamp and strategy/configuration/calculation identities; initial issuance has nullable performance metadata. Dated reads carry the prior quote through gaps, return `quote_not_found` before issuance, and accept future dates. No read calculates quotes or contacts providers.

Authentication errors return 401. Invalid or ambiguous dates return 400 `invalid_date` before player lookup. Malformed or unknown players return 404 `player_not_found`; existing players without a quote return an empty history or 404 `quote_not_found` for a single result. Storage failures return 503 `temporarily_unavailable`. See `/docs` for complete schemas and examples.

### Player statistics freshness

`GET /api/players/:player_id` preserves the catalog object in `data` and includes `statistics_status`. It reports the exact configured provider and league-season coverage, the last complete accepted check, expiry, import progress, and independent valuation progress. Catalog list/search reads never enqueue refreshes. Opening detail always checks PostgreSQL, including after a cached search.

Configure trusted source options in the application configuration; HTTP callers cannot choose sources, mappings, timeouts, or retry policies:

```elixir
config :football_market, FootballMarket.Statistics.Freshness,
  ttl_seconds: 86_400,
  cooldown_seconds: 3_600,
  refresh_options_by_scope: %{
    {"PL", 2025, 2026} => [source_ref: "approved-statistics-source"]
  }
```

The reference must resolve through `FootballMarket.Synchronization`'s existing trusted `sources` configuration. Existing optional `fixture_ref`, mapping and bounded policy options may be supplied by the operator for that exact scope. No source is configured by default: detail still returns local data with refresh state `unconfigured`. The current configured adapter boundary uses fixture artifacts; `source_mode: "fixture"` explicitly means non-live data. A `fresh` result describes the accepted-check TTL, not verified real-time source accuracy. This feature does not authorize live scraping or bypass access/coverage checks.

Never-checked or expired scopes queue one existing statistics-import job. Players in the same provider/league-season share that work. Repeated reads reuse queued, executing and retry-wait work without adding trigger records; admission contention reports `busy`. Complete changed, unchanged, replay and empty checks renew the timestamp atomically; failures and incomplete responses do not. Local detail never waits for provider execution. Enqueue/configuration failures remain visible while local data stays available.

After bounded retries exhaust a transient failure, automatic requests wait for the configured cooldown or a longer provider retry hint. Permanent access, malformed-data, immutable-history and unconfirmed-publication failures remain `blocked` for unchanged inputs. An operator can correct the configured input or use the existing trusted manual request interface; detail exposes no force-refresh or permission-changing operation.

`statistics_status.valuation` follows the latest changed import affecting this player and aggregates its weekly calculation requests. New no-change checks do not hide outstanding work. A successful import can still have pending or failed valuation; completed valuation may include explicit `no_quote` results and does not promise a new price. Existing quote endpoints retain their original immutable quote timestamps.

### Prepare, compile, and test

From a clean checkout, run these commands in order:

```bash
mix local.hex --if-missing --force
mix local.rebar --if-missing --force
mix deps.get --locked
mix assets.setup
mix assets.build
mix compile --warnings-as-errors
mix compile --warnings-as-errors
mix test
test/scripts/verify_foundation_test.sh
```

Only the preparation commands (`local.hex`, `local.rebar`, `deps.get`, and first-time asset setup) require downloads. Compilation and tests must not fetch dependencies. A missing package, unavailable network during preparation, compiler warning, or failing assertion produces a nonzero exit.

### Correlation and JSON logging

Application runtime logs use one JSON object per line in development, test and
production. Existing levels remain unchanged (tests default to warnings). Build
and command output is not a JSON log stream. Records contain UTC `timestamp`,
`level`, `message`, and approved event fields. New lifecycle records never include
raw paths/query strings, headers, parameters, job arguments, provider payloads or
exception messages. Existing Phoenix parameter filtering remains in force.

HTTP responses retain `x-request-id`. Plug reuses an incoming 20–200-byte ID or
generates one; this is diagnostic context, never authorization. Normal requests
emit `http.request.start` and `http.request.stop`; error rendering supplies a
single terminal fallback `http.request.exception` when no stop was emitted.
Terminal records include method, template route when available, status and
`duration_ms`. Static serving is instrumented too.

Synchronization runs preserve the originating `correlation_id`, including when
later requests coalesce. Background runs generate their own ID. Job metadata
carries that root through durable retries, recovery, delayed calculation dispatch
and quote calculations. Legacy rows use stable domain-ID fallbacks; unrelated
jobs use their job identity. Context never enters business input digests or
uniqueness keys. Apply the nullable synchronization correlation migration before
starting this application revision; existing rows need no rewrite and older
application code can ignore the extra column.

`job.start`, `job.stop` and `job.exception` include job ID, worker, queue, attempt,
execution state and available duration/queue time in milliseconds. They report
**Oban transport execution**, not whether an import or valuation succeeded; use
the existing durable run/calculation states for that domain outcome. Quote
`calculation_request_id` is distinct from the HTTP `request_id`.

For a local request, send a UUID in `x-request-id`, then filter the JSON stream:

```sh
curl -i -H 'x-request-id: 11111111-1111-4111-8111-111111111111' http://localhost:4000/docs
jq 'select(.correlation_id == "11111111-1111-4111-8111-111111111111")' application.jsonl
```

### Continuous integration quality baseline

GitHub Actions runs Quality baseline, End-to-end profile, and SonarCloud for pull requests targeting `main` and pushes to `main`. The always-reporting `ThinFlow required` job aggregates those three results and passes only when every constituent succeeds. Configure that stable job as the required status for the latest PR head; merge remains human-controlled. The jobs use locked build dependencies plus ephemeral PostgreSQL and Redis services and do not enforce releases or deployments.

To reproduce the job locally, use Elixir 1.20.3 with Erlang/OTP 29.0.6, make PostgreSQL and Redis available with the test defaults documented above (ports 5432 and 6379), prepare the locked dependencies, and run:

```bash
./scripts/check_toolchain.sh
mix deps.get --locked
MIX_ENV=test mix deps.compile
MIX_ENV=test sh scripts/credo_ci.sh
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
scripts/ci_unit_tests.sh
```

These commands are non-mutating quality checks. They require PostgreSQL and Redis for the complete discovered suite, with no production credentials or live football provider.

### CP1 test profiles and coverage

CP1 test evidence is separate from the locked three-category quality baseline. Run the focused profiles against deterministic local fixtures with:

```bash
mix test.unit
mix test.integration
```

Each profile audits every default-discovered `test/**/*_test.exs` module before running it. A module has exactly one `:unit` or `:integration` tag: tests asserting HTTP, browser/public-contract, or Ecto/PostgreSQL boundaries are integration; isolated behavior is unit. The runners include selected performance tests, require a nonzero completed count and profile sentinel, reject skips, and retain no credential-bearing diagnostics.

Architecture and dependency assertions run on every branch. Historical plan-diff assertions apply to numbered Agentflow task branches, where missing or contradictory ownership still fails closed. Ordinary maintenance branches have no task-plan owner and run the same complete test profiles without requiring generated workflow metadata.

The integration profile requires Node.js 24.x, the locked OpenAPI packages, and Playwright Chromium. Prepare them once with:

```bash
npm ci --prefix tools/openapi
tools/openapi/node_modules/.bin/playwright-core install --with-deps --only-shell chromium
```

Missing or mismatched prerequisites fail closed with a safe category; the browser regression is never skipped. For an informational native Mix coverage report, both profiles must pass and all non-generated inputs must be tracked (staged or unstaged changes are supported), then run:

```bash
mix test.cp1_coverage
```

It publishes a fresh ignored `cover/cp1/<base-head>-<run-id>/` directory with `report.html`, native source pages, and a snapshot manifest. The manifest binds base HEAD, the full tracked binary-diff hash, inventory hash, and both profile receipts; nonempty diffs are labelled working-tree snapshots. Coverage has threshold zero: it is a report, never a CI or merge gate. See the [CP1 quickstart](specs/014-cp1-test-coverage-profiles/quickstart.md) for failure behavior and prerequisites.

### SonarCloud analysis and CP1 gate

The separate `SonarCloud analysis and CP1 gate` check runs for every internal pull-request revision targeting `main` (including drafts) and every push to `main`. In a pull request, open the check from the Checks view and follow its findings link: the summary deliberately separates the exact-head PR analysis from the current published `main` count. The latter is contextual and does not predict the post-merge count. On `main`, the gate first requires the latest published analysis revision to equal the triggering commit.

CP1 passes only when SonarCloud's native scan and publication succeed and the primary branch reports 0–9 `open_issues`; 10 or more fails. The scanner analyzes repository-owned `lib` and `assets/js` source plus `test`, excluding only `_build`, `deps`, vendored assets, generated static assets, digested JavaScript, and source maps. No coverage setting or coverage threshold is part of this integration.

Before enabling the required check, a maintainer must import/bind the repository as `CorreaSebastianEmanuel_desapp-grupo-m-2026s2` in the `correasebastianemanuel` SonarCloud organization, make `main` primary, disable SonarCloud automatic analysis, and add `SONAR_TOKEN` as a protected GitHub Actions secret. The workflow never places that token in an argument, URL, persisted file, or summary. The organization does not yet exist in SonarCloud's public project index, so hosted publication remains a deployment prerequisite rather than locally fabricated evidence.

Failure diagnostics are intentionally classified. `threshold` means the published count is 10 or greater; `stale-analysis` means a `main` result is not for the triggering SHA; `authentication`/`authorization` means the protected secret or its access must be corrected; `configuration` means project/branch binding is wrong; `service`/`network` may be rerun after availability recovers; and `malformed-response` requires API-contract review. Superseded runs are canceled and never govern a newer SHA. Use GitHub's **Re-run failed jobs** only for the same revision; a code update automatically creates the governing replacement run.

Local deterministic verification requires no SonarCloud credentials:

```bash
python3 -m unittest test/scripts/sonar_checkpoint_gate_test.py
MIX_ENV=test mix test test/ci/sonarcloud_contract_test.exs
```

### Start, verify, stop, and restart

Start Phoenix in the foreground:

```bash
mix phx.server
```

In another terminal, run the bounded HTTP oracle. It retries for no more than 30 seconds and requires both HTTP 200 and the application-owned marker `Football Player Market`:

```bash
./scripts/verify_foundation.sh
```

Stop the foreground server with `Ctrl+C`, then `a` when the Erlang shell asks whether to abort. It should exit within 10 seconds. Confirm that nothing remains reachable:

```bash
if curl --silent --show-error --max-time 2 http://127.0.0.1:4000/ >/dev/null; then
  echo "error: port 4000 is still serving" >&2
  exit 1
else
  echo "server stopped and port 4000 is released"
fi
```

Repeat `mix phx.server`, run `./scripts/verify_foundation.sh` again, and stop it a second time to prove restartability.

Common failures are explicit: use `lsof -nP -iTCP:4000 -sTCP:LISTEN` when the port is occupied; rerun preparation when dependencies or asset binaries are missing; inspect the Phoenix terminal when the HTTP oracle times out or receives a bad status/marker. The development endpoint binds only to `127.0.0.1`, requires no credentials, and does not start PostgreSQL or Redis.

## Agentic SDD

This repository includes a local Spec Kit workflow using an authenticated Codex CLI installation.

The complete workflow diagram and presentation notes are available in [`docs/METODOLOGIA_AGENTICA.md`](docs/METODOLOGIA_AGENTICA.md).

```bash
./setup
./agentflow                         # menu
./agentflow backlog
./agentflow next                    # recommend the next dependency-ready task
./agentflow create "Task title" --outcome "Observable result" --checkpoint CP1
./agentflow start TASK-001
./agentflow status TASK-001
./agentflow metrics TASK-001          # usage by stage, without raw logs
./agentflow feedback TASK-001 "Use Phoenix 1.8" --stage architecture
./agentflow history TASK-001
./agentflow resume TASK-001
./agentflow verify TASK-001
./agentflow complete TASK-001       # manual completion for local-only runs
```

New tasks default to ThinFlow: a compact outcome `spec.md`, one accountable
builder, deterministic checks selected from the actual diff, and one fresh
independent evaluator. Plans, task breakdowns, handoffs, and duplicate reports
are optional rather than readiness gates. `start` creates the task branch and,
after current local receipts plus terminal `evaluation.md` PASS, commits, pushes,
and opens one PR. The exact PR head must still pass `ThinFlow required` and a
person decides whether to merge. Use `--no-pr` only for an explicitly local run,
and start from a clean, current `main` branch.

For an explicit pre-merge canary, keep the migration branch clean and run
`./agentflow start TASK-NNN --base BRANCH`. The task receives a separate stacked
PR targeting that branch. After the migration merges, retarget the canary PR to
`main` and revalidate its exact head before merge.

Agentflow associates tasks with versioned feature ownership, independently of directory numbers. An exact `**Feature Branch**` declaration in the canonical specification is sufficient; optional backlog frontmatter `feature_directory: specs/055-example` must name an immediate child of `specs/` and agree with that declaration. Duplicate, malformed, conflicting, missing or escaping associations are refused. Declaration-free legacy layouts work only with exactly one equal-number candidate and no contradictory ownership. Session pointers and directory timestamps do not establish ownership. Equal-number specifications with a validated branch belonging to another task are excluded from legacy candidates. A new task with no own feature can still begin its product stage; later verification, publication and completion require its own feature.

Task frontmatter uses unindented lowercase scalar keys immediately followed by `:`. Values may be balanced single/double quoted; blank lines, full-line comments and unknown scalar fields are supported. Unsupported forms such as `feature_directory : specs/099-other`, `Status: blocked`, indented/quoted keys, structured YAML and duplicate keys refuse every ownership/state operation before changing backlog or session state. The same parser guards dependency reads and already-done completion retries.

ThinFlow publication and completion require the resolved feature's contained
`evaluation.md` to end on its final nonempty line with exactly `Verdict: PASS`.
Invoke `complete` only after human review or merge and after the exact PR head
passes `ThinFlow required`; completion atomically sets `status: done` and
`active_run: none`. Saved Agentflow 2.3 tasks retain their two-report contract.
Dependency reconciliation and already-completed retries use the same validated
task/branch ownership boundary.

Manual deliveries of TASK-027 and TASK-056 are reconciled through explicit retrospective records and fresh independent acceptance; see [manual-delivery reconciliation](docs/AGENTFLOW_MANUAL_DELIVERIES.md) before continuing an existing branch.

`next` considers only `todo` tasks with no unfinished dependencies. It recommends deterministically by earliest checkpoint, then `critical`/`high`/`medium`/`low` priority, then task ID, and lists any other tasks that can be started in parallel.

Agentflow prints every stage, a heartbeat every 20 seconds, and concise agent/check/usage outcomes. Agent payloads remain in local logs; human gates retain interactive stdin and prompt fragments. Use `AGENTFLOW_CONSOLE=full` for explicit full console diagnostics. Noninteractive Codex agents cannot consume piped gate answers. Runtime output is saved to `.agentflow/runs/TASK-NNN.live.log`; `status` reports the current stage and last activity. If interrupted with `Ctrl+C`, continue the preserved Spec Kit run with `./agentflow resume TASK-NNN`.

Human feedback is versioned in `backlog/feedback/TASK-NNN.md`. ThinFlow routes
one classified, grouped repair to the same builder and then regenerates checks
and the independent evaluation; another blocker requires a human decision, a
different approach, or a task split. Two check failures with the same material
digest refuse a third attempt. `history` shows feedback and saved stage results.
Legacy 2.3 snapshots keep their original stage order, artifacts, and three-cycle
feedback policy; `resume` never upgrades a captured run.

See [ThinFlow](docs/THINFLOW.md) and [verification](docs/AGENT_VERIFICATION.md)
for the executable policy and compatibility with saved 2.3 runs.

The builder reads the compact contract and uses focused tests while iterating.
The repository policy then runs the selected checks once the candidate is
stable. The evaluator reads the contract, diff, implementation, risk selection,
and named receipts directly; it runs only targeted evidence needed for a
concrete discrepancy or uncovered risk. For changed HTTP behavior that can mean
real requests against the application. Missing runtime or evidence is a blocker,
never an implicit skip.

### Windows PowerShell

Install Python 3, Git for Windows (including Git Bash), `uv`, and Codex CLI. Then run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup.ps1
.\agentflow.ps1
.\agentflow.ps1 backlog
.\agentflow.ps1 start TASK-001
.\agentflow.ps1 complete TASK-001
```

Git Bash is required because the checked-in Spec Kit integration uses its portable shell scripts. The backlog, specs, workflow, and agent sessions are otherwise identical on macOS, Linux, and Windows.

### Elixir static analysis

Credo is pinned to 1.7.19 for development/test only and is excluded from runtime loading.
Run the default-priority standard at the repository root:

```bash
MIX_ENV=test mix credo --format flycheck
```

The named default configuration includes all maintained Elixir in lib/, config/, priv/,
scripts/, test/ and root Elixir files. Stock rules and default priorities are inherited;
no suppressions, baseline, disabled rules or increased thresholds are allowed.

The committed [`config/credo_inventory.json`](config/credo_inventory.json) records every
maintained tracked `.ex` and `.exs` path plus each exact archived-probe exclusion and its
reason. New maintained source must be staged before refreshing that inventory. Review the
diff, then reconcile the Git inventory against Credo's actual valid analysis inputs:

```bash
git add path/to/new_source.ex
MIX_ENV=test mix run --no-start scripts/credo_inventory.exs --write-inventory
git diff -- config/credo_inventory.json
MIX_ENV=test mix run --no-start scripts/credo_inventory.exs
MIX_ENV=test sh scripts/credo_ci.sh
```

The standard CLI remains `MIX_ENV=test mix credo --format flycheck`; it uses default-priority
rules. The wrapper runs that command and the effective-input oracle, preserving both exit
statuses and full path lists in `tmp/credo-ci/evidence.json` and `credo.log`. CI uploads
these files from the required Quality baseline job for 14 days under an artifact name bound
to the triggering revision and run attempt. Evidence reports checked-out `revision`
separately from `trigger_revision`; local dirty content is labelled and included in the
source digest. The exclusion paths and individual reasons are listed in the committed
inventory so reviewers can audit the complete boundary.

Zero Credo findings do not establish absence of bugs and do not establish equivalence to
SonarCloud's native Java analysis.

### Portfolio analytics (TASK-057)

Authenticated `GET /api/portfolio/allocation` returns current investor positions, quote identity/time, market value and fractional weights. `GET /api/portfolio/history?from=2026-10-01&to=2026-10-29` returns daily UTC value, remaining cost basis, cumulative purchase expenditure/sale proceeds/net invested and realized/unrealized/total profit. Use the existing Bearer JWT or X-API-Key; ownership cannot be selected through parameters. Responses are private and non-cacheable.

History defaults to 30 calendar days including today; explicit ranges allow at most 366 inclusive days. Only `to` means its preceding 30 days; only `from` ends today. Dates must be single ISO calendar dates; future/reversed/oversized ranges return 400. Today is partial, with `cutoff_at` bounded by `as_of`; past points close at the end of their UTC day. Trades before the range establish opening holdings and lifetime flows/profit. Closed positions retain realized profit. Holdings are reconstructed from the user's purchases/sales, excluding initial issuer inventory and cash.

Values use the existing weighted-average cost rule and authoritative quote sequence ordering. Prices effective after a cutoff never participate; eligible prices carry forward. Historical values use currently retained effective facts, not an archival record of database knowledge. A missing quote produces null affected values and dependent totals/weights, with `missing_quote_player_ids`; an empty portfolio has true zero totals. Money is serialized as decimal strings (derived precision retained; quote prices have two places), never floats. Weights round half-up to 18 decimal places and can have a rounding residual. Purchases are flows, not profit; the API does not claim a percentage return. TASK-058 owns charts.

Sobelow security analysis is required in Quality baseline and therefore in
`ThinFlow required`. Run `python3 scripts/sobelow_ci.py` locally; focused real
analyzer controls use `python3 -m unittest discover -s test/scripts -p sobelow_ci_test.py`.
See the [TASK-074 scope, blocking policy and individual finding triage](specs/074-required-sobelow-security-analysis-for-elixir-prs/spec.md).
Revision-bound, non-sensitive evidence is uploaded from `tmp/sobelow-ci/` for 14 days.
