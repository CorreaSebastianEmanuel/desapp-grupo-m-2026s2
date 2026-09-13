# Implementation Plan: Phoenix Project Foundation

**Branch**: `001-phoenix-project-foundation` | **Date**: 2026-09-08 | **Spec**: `specs/001-phoenix-project-foundation/spec.md`

**Input**: Feature specification from `specs/001-phoenix-project-foundation/spec.md`

## Summary

Establish one root-level Phoenix application named `football_market` with an application-owned default page, a meaningful `Phoenix.ConnTest` smoke test, and exact contributor lifecycle documentation. Retain Ecto/PostgreSQL-ready modules and configuration, but do not supervise or contact the repository in TASK-001; TASK-002 activates persistence. Keep LiveView and standard asset plumbing because the architecture requires a responsive LiveView application later, while excluding mailer, dashboard, Oban, Redis, OpenAPI, authentication, provider, catalog, valuation, and trading behavior.

## Technical Context

**Language/Version**: Elixir 1.20.3 on Erlang/OTP 29.0.3; Phoenix/phx_new 1.8.13

**Primary Dependencies**: Phoenix 1.8.13, Phoenix LiveView, Bandit, Ecto SQL/Postgrex (configured but not started), standard Phoenix asset tooling; versions locked by `mix.lock`

**Storage**: PostgreSQL is the future authoritative store, but no database or persistent entity is active in TASK-001

**Testing**: ExUnit with `Phoenix.ConnTest`; standard command `mix test`

**Target Platform**: Local development on macOS or Linux with the exact toolchain above; loopback HTTP on `127.0.0.1:4000`

**Project Type**: Single modular web application (Phoenix modular monolith)

**Performance Goals**: Application becomes HTTP-ready within 30 seconds after dependencies are prepared; documented lifecycle completes within 10 minutes after prerequisites are installed

**Constraints**: Clean checkout; no PostgreSQL, Redis, credentials, prior build state, or machine-specific paths; finite lifecycle checks fail nonzero; development endpoint binds to loopback

**Scale/Scope**: One application shell, one public default route, at least one web-boundary test, and contributor setup documentation; zero business entities or later-backlog capabilities

## Constitution Check

*GATE: Passed before Phase 0 and re-checked after Phase 1.*

- **Specification before implementation — PASS**: the plan traces the three contributor outcomes and resolves the database, environment, test, readiness, shutdown, and generated-component ambiguities raised by the product challenge.
- **Domain integrity — PASS**: no domain or financial behavior is introduced; all product invariants remain untouched.
- **Modular simplicity — PASS WITH ADR-001**: one Phoenix application is used. Ecto structure is retained but Repo supervision is deferred to TASK-002 so TASK-001 has no undeclared service dependency. The temporary baseline deviation is recorded in `adrs/001-defer-repository-activation.md`.
- **Evidence-based quality — PASS**: compilation, ExUnit, an intentional-failure check, bounded real HTTP probing, shutdown, restart, and isolated-checkout reproduction are specified.
- **Independent verification — PASS**: artifacts expose exact oracles for later QA and final review; this planning step does not claim checks have run.
- **Safety and delivery — PASS**: no credentials, external writes, business data, destructive workflow, or non-loopback development binding is introduced.

Post-design re-check: the data model is explicitly empty, the HTTP contract is foundation-only, and the quickstart does not activate deferred infrastructure. No unresolved clarification or unjustified constitution violation remains.

## Product/Critic Synthesis

The author is correct that the smallest product outcome is compile, regression detection, and local reachability, with TASK-002 and TASK-003 retaining database-environment and CI ownership. The critic is correct that a conventional generated Repo can make “reachable” ambiguous and that subjective oracles would permit a vacuous pass. The selected solution preserves the author's boundary while adopting the critic's concrete verification requirements:

- Startup is database-independent, but Ecto/Postgrex structure remains ready for TASK-002.
- “Clean checkout” means a fresh clone with `_build`, `deps`, and generated asset outputs absent; global language tools and network-backed package caches are allowed, but no running PostgreSQL/Redis or application process is allowed.
- Preparation is separate (`mix deps.get`, then asset setup if required); compilation and tests must not fetch dependencies implicitly.
- A meaningful test sends a request through the Phoenix endpoint and asserts HTTP 200 plus a stable application-owned marker, `Football Player Market`.
- Readiness is a retrying HTTP probe capped at 30 seconds; stop is foreground interrupt, process exit within 10 seconds, failed post-stop probe, and successful restart.
- The lifecycle is independently repeated from an isolated checkout; one complete clean run plus the intentional-failure run is proportionate evidence for TASK-001. “100%” applies to those deterministic attempts, not an undefined global population.

### Rejected alternatives

- **Require PostgreSQL in TASK-001**: rejected because it transfers TASK-002's explicit outcome into this task and requires human-approved scope/dependency changes.
- **Generate with `--no-ecto`**: rejected because TASK-002 immediately needs Ecto/PostgreSQL and removing it now creates avoidable foundation churn against the architecture baseline.
- **Supervise Repo and tolerate connection errors**: rejected because endpoint reachability would misrepresent application health and make clean startup dependent on timing/retry behavior.
- **API-only or static Plug shell**: rejected because LiveView is an established application requirement and the default Phoenix HTML boundary supplies the smallest representative runtime surface.
- **Keep every generated optional component**: rejected; mailer and dashboard add unused dependencies/surfaces, while Oban, Redis, OpenAPI, and domain contexts are owned by later tasks.
- **Add empty domain/adapter/cache/worker namespaces**: rejected as speculative scaffolding. Boundaries are enforced when behavior exists, not demonstrated with empty modules.
- **Broaden the OS/version matrix now**: rejected because TASK-003 owns CI portability. This task documents one narrow reproducible toolchain while keeping ordinary Phoenix portability.

## Clean-Checkout Verification Fixture

- Fresh isolated clone of the feature branch; no copied untracked files.
- Delete/verify absence of project-local `_build/`, `deps/`, and generated asset output before preparation.
- Permitted global state: Git, exact Erlang/OTP and Elixir versions, Hex/Rebar installation, Node-free Phoenix-managed asset binaries, network access, and read-through package caches.
- Forbidden state: application-specific environment variables, credentials, a running app instance, PostgreSQL, Redis, or prebuilt project artifacts.
- Package unavailability and unsupported tool versions must fail preparation visibly and nonzero.
- Port 4000 occupancy must make startup/probing fail visibly; documentation may instruct choosing a free alternative port, but the verification fixture uses 4000.

## Project Structure

### Documentation (this feature)

```text
specs/001-phoenix-project-foundation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── foundation-http.md
├── adrs/
│   └── 001-defer-repository-activation.md
└── handoffs/
    └── architecture.md
```

### Source Code (repository root)

```text
assets/                         # Phoenix-managed JS/CSS source only
config/                         # environment and endpoint configuration
lib/
├── football_market.ex         # future domain application namespace
├── football_market/
│   ├── application.ex         # supervision tree; Repo excluded in TASK-001
│   └── repo.ex                # inert Ecto repository contract for TASK-002
└── football_market_web/
    ├── components/            # generated presentation components
    ├── controllers/           # default page only
    ├── endpoint.ex
    ├── router.ex
    └── telemetry.ex           # generated framework telemetry only
priv/static/                    # tracked static inputs, not generated build output
test/
├── football_market_web/controllers/page_controller_test.exs
├── support/conn_case.ex
└── test_helper.exs
mix.exs
mix.lock
README.md
```

**Structure Decision**: Use a single root-level Phoenix OTP application, not an umbrella. Today’s controller/template layer contains only the default page. Future domain contexts go under `lib/football_market/`; web code calls those contexts and never persistence/adapters directly. Workers, Redis cache, and provider adapters are introduced only by their owning backlog tasks.

## CP1 Dependency Compatibility

- TASK-002 activates `FootballMarket.Repo`, database config, and local PostgreSQL/Redis environment without renaming the OTP application.
- TASK-003 reuses `mix format --check-formatted`, `mix compile --warnings-as-errors`, and `mix test` as the initial CI commands.
- TASK-005 onward places domain contexts below `lib/football_market/`; HTTP and LiveView entry points stay below `lib/football_market_web/`.
- TASK-007–013 add authentication, API keys, JWT, REST/OpenAPI, and catalog contracts without changing the default application identity or test runner.
- This task does not attempt to satisfy all CP1 deliverables; it supplies their compiling/testable base.

## Complexity Tracking

No constitution violations require justification. ADR-001 documents sequencing within the mandated architecture, not a permanent replacement architecture.
