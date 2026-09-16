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

### Continuous integration quality baseline

GitHub Actions runs the stable `Quality baseline` job for pull requests targeting `main` and pushes to `main`. It uses only locked, non-secret build dependencies and an ephemeral PostgreSQL test database. TASK-003 intentionally enforces exactly three categories: formatting, warnings-as-errors compilation, and the complete unit test suite. It does not enforce coverage, SonarCloud, end-to-end or architecture checks, releases, or deployments.

To reproduce the job locally, use Elixir 1.20.3 with Erlang/OTP 29.0.6, make PostgreSQL available with the test defaults documented above, prepare the locked dependencies, and run:

```bash
./scripts/check_toolchain.sh
mix deps.get --locked
MIX_ENV=test mix deps.compile
mix format --check-formatted
MIX_ENV=test mix compile --warnings-as-errors
scripts/ci_unit_tests.sh
```

These commands are non-mutating quality checks. They require no production credentials, Redis instance, or live football provider.

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
./agentflow create "Task title" --checkpoint CP1
./agentflow start TASK-001
./agentflow status TASK-001
./agentflow feedback TASK-001 "Use Phoenix 1.8" --stage architecture
./agentflow history TASK-001
./agentflow resume TASK-001
./agentflow verify TASK-001
./agentflow complete TASK-001       # manual completion for local-only runs
```

`start` runs seven fresh-agent stages: product specification, an independent product challenge, architecture synthesis, validated task planning, implementation, adversarial QA, and final review. Between product challenge and architecture, an automated decision probe pauses for a human check only when an unresolved choice materially affects product behavior, business rules, scope, permissions, security, data integrity, or a difficult-to-reverse technical decision. Routine and reversible choices continue automatically. Multiple perspectives are used at decision and verification boundaries; implementation keeps one owner to avoid conflicting edits. When both verification gates pass it commits the generated feature branch, pushes it, and creates a GitHub PR. A failed or rejected gate leaves the task blocked so feedback can rewind it to the affected stage. Merge remains human-controlled. Reviewed dependencies no longer block later tasks; after entering the later task's feature branch, Agentflow checks GitHub and changes each dependency whose PR was merged to `done`. Use `complete` only for manual or local-only completion. Use `--no-pr` for a local-only run. Start from a clean, up-to-date `main` branch.

`next` considers only `todo` tasks with no unfinished dependencies. It recommends deterministically by earliest checkpoint, then `critical`/`high`/`medium`/`low` priority, then task ID, and lists any other tasks that can be started in parallel.

Agentflow prints every stage, a heartbeat every 20 seconds, and underlying CLI output in real time. It keeps stdin attached so permission or authentication prompts remain interactive. Runtime output is saved to `.agentflow/runs/TASK-NNN.live.log`; `status` reports the current stage and last activity. If interrupted with `Ctrl+C`, continue the preserved Spec Kit run with `./agentflow resume TASK-NNN`.

Agents exchange structured handoffs under the active feature's `handoffs/` directory. Human feedback is versioned in `backlog/feedback/TASK-NNN.md`; adding feedback rewinds the preserved workflow to the selected affected stage. `history` shows feedback, handoffs, and stage results. A task accepts at most three feedback cycles before it must be resolved or split, preventing unbounded autonomous loops.

Each agent receives only the canonical artifacts and handoffs required by its role. Handoffs are short, delta-only records rather than copies of specifications, plans, tasks, or reports. Agents do not inspect workflow/live logs during delivery; Agentflow checks canonical plan, task, development, and QA artifacts with token-free probes before dispatching the next agent. A failed QA verdict stops the flow before final review. QA remains exhaustive, while final review validates passing QA evidence and reruns only targeted checks needed for an uncovered risk or discrepancy.

Final review also records a lightweight `Backlog impact:` assessment from the evidence already in scope. It does not scan the full backlog by default. The reviewer inspects directly related future tasks only when the completed work reveals a concrete change to requirements, architecture, dependencies, priority, or scope; isolated changes without downstream effects record `none`. Review recommends follow-up but never edits backlog tasks automatically.

QA executes applicable checks rather than only inspecting code. When a task exposes or changes HTTP endpoints, QA must start the application and exercise the affected endpoints with real HTTP requests (such as `curl`), including specified success and failure cases. An unavailable runtime is reported as a blocker, not skipped.

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
