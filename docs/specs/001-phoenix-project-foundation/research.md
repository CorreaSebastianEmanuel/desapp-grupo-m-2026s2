# Research: Phoenix Project Foundation

## Supported toolchain

**Decision**: Pin the foundation baseline to Phoenix/phx_new 1.8.13, Elixir 1.20.3, and Erlang/OTP 29.0.3, with dependencies committed in `mix.lock`.

**Rationale**: Phoenix's current official installation guide documents Phoenix 1.8.13 and requires Elixir 1.17+ and OTP 25+. Its current release guide demonstrates Elixir 1.20.3 and OTP 29.0.3. A single exact baseline makes clean-checkout evidence finite and reproducible; broader compatibility belongs in TASK-003 CI.

**Alternatives considered**: Loose minimum versions were rejected because they leave the acceptance population undefined. Older Phoenix 1.7 was rejected because the foundation should not start on a superseded line when the current maintained line is compatible with the architecture.

**Evidence**: Phoenix 1.8.13 installation documentation and Hex release metadata, consulted 2026-09-08.

## Generated Phoenix profile

**Decision**: Use a standard Phoenix HTML/LiveView application with Bandit, assets, gettext, Ecto/Postgrex-ready structure, and framework telemetry. Omit mailer and LiveDashboard. Do not add Oban, Redis, OpenAPI, authentication, external adapters, or product contexts.

**Rationale**: LiveView is mandated by `docs/ARCHITECTURE.md`, and the generated web surface supplies the smallest realistic application test. Official `phx.new` options explicitly support excluding mailer/dashboard and retaining or excluding Ecto. Keeping Ecto avoids immediate TASK-002 churn while still permitting database-independent startup when Repo is not supervised.

**Alternatives considered**: API-only generation omits the required future UI direction. A full untrimmed generator retains unused surfaces. `--no-ecto` makes the current task smaller in isolation but conflicts with the immediately following persistence task.

## Database-independent startup

**Decision**: Keep `FootballMarket.Repo` and PostgreSQL dependency/configuration, but omit the Repo child from the TASK-001 supervision tree. The default route must use no repository-backed plug, query, or template data.

**Rationale**: This directly resolves the author's TASK-002 boundary and the critic's health ambiguity. Endpoint readiness then proves the shipped foundation itself is healthy while PostgreSQL and Redis are stopped.

**Alternatives considered**: Requiring PostgreSQL expands scope; retrying a missing database while serving HTTP creates misleading degraded startup; eliminating Ecto causes immediate rework.

## Test and runtime oracles

**Decision**: The baseline test traverses the endpoint with `Phoenix.ConnTest` and asserts status 200 and the application-owned text `Football Player Market`. Runtime validation performs the equivalent real HTTP check on loopback, with a 30-second readiness limit. Shutdown has a 10-second exit limit, verifies the port is no longer serving, then repeats startup.

**Rationale**: These checks distinguish a working app page from a generic server/error page and cover regression detection, readiness, clean termination, and restart without introducing domain logic.

**Alternatives considered**: Arithmetic/unit placeholders and status-only assertions are vacuous. An unbounded manual browser check is not repeatable. A new health endpoint would add a contract owned more appropriately by TASK-038.

## Clean-checkout evidence

**Decision**: Verify in a fresh isolated clone without project-local dependencies/build outputs. Allow installed global tools, network access, and package caches. Separate dependency preparation from compilation. Have an independent reviewer follow README commands and perform an intentional assertion failure in a disposable copy.

**Rationale**: This is strict enough to detect hidden repository state while remaining proportionate; disabling all global caches would test the package network rather than the repository.

**Alternatives considered**: Maintainer-worktree-only execution risks hidden state. Fully cold machine/container provisioning exceeds TASK-001 and overlaps CI/environment tasks.
