# Architecture Handoff: Phoenix Project Foundation

## Synthesis decision

Build one root-level Phoenix 1.8.13 modular monolith (`football_market` / `FootballMarket`) with a real default HTML/LiveView-capable web surface and a `Phoenix.ConnTest` contract test. Preserve Ecto/PostgreSQL-ready structure but defer Repo supervision and all database contact to TASK-002 under ADR-001. The application must start and satisfy its HTTP oracle while both PostgreSQL and Redis are unavailable.

This accepts the product author's narrow scope and the critic's demand for operationally precise evidence. Where they compete, clean healthy startup wins over conventional generated Repo supervision, while retaining Ecto wins over removing and immediately regenerating persistence structure.

## Decisions

- Use one OTP application, not an umbrella or separate frontend/backend.
- Pin the validation baseline to Elixir 1.20.3, OTP 29.0.3, and Phoenix/phx_new 1.8.13; commit `mix.lock`.
- Retain HTML, LiveView readiness, assets, gettext, Bandit, Ecto/Postgrex structure, and basic framework telemetry.
- Remove/omit mailer and LiveDashboard; add no Oban, Redis, OpenAPI, JWT/authentication, provider, catalog, valuation, trading, or audit behavior.
- Do not supervise `FootballMarket.Repo` in TASK-001. The default page cannot query it.
- Bind development HTTP to `127.0.0.1:4000`; use application-owned marker `Football Player Market`.
- Define “meaningful test” as a Phoenix endpoint request asserting HTTP 200 and that marker.
- Separate package preparation from compilation. Verification uses a fresh clone without `_build`, `deps`, generated assets, `.env`, credentials, or external services.
- Bound readiness at 30 seconds and shutdown at 10 seconds; prove the port stops serving and that restart succeeds.
- Treat FR-009 as a negative boundary rule. Do not create empty future-layer scaffolding.

## Assumptions

- macOS and Linux are the TASK-001 validation platforms; broader matrix evidence is deferred to TASK-003.
- Global Git/Elixir tooling, Hex/Rebar, package caches, and network access during preparation are permitted clean-fixture state.
- Phoenix-managed asset tooling does not require a separately installed Node runtime for the chosen generated profile.
- One isolated lifecycle plus one disposable intentional-failure run is proportionate evidence for the spec's deterministic percentage statements.
- No human feedback overrides these choices; the active run explicitly records that no human feedback has been submitted.

## Risks and mitigations

- **Generator drift**: Pin phx_new/Phoenix and dependency locks; review generated output against the allowed-component list.
- **Inert Repo accidentally started**: Test with PostgreSQL unavailable and inspect the supervision tree/application configuration.
- **False-positive reachability**: Assert both 200 and the application-owned body marker through ConnTest and real HTTP.
- **Hidden local state**: repeat from an isolated clone with project build/dependency outputs absent.
- **Port/process leakage**: use bounded stop plus post-stop connection failure and restart.
- **Security leakage**: loopback binding, no committed credentials, development-only generated secret semantics, no dashboard exposure.
- **Future TASK-002 omission**: ADR-001 names TASK-002 as the explicit superseding task and plan maps the handoff.
- **Exact toolchain availability**: prerequisite check fails clearly; TASK-003 may broaden the supported matrix after CI evidence.

## Evidence

- `spec.md` requires compilation, a regression-detecting test, documented clean startup, no later behavior, and visible failures.
- `handoffs/product.md` assigns PostgreSQL/Redis provisioning to TASK-002 and CI to TASK-003 while asking architecture to resolve generated database assumptions.
- `handoffs/product-challenge.md` identifies the missing database, clean-fixture, meaningful-test, readiness, shutdown, scope, and security oracles adopted here.
- `docs/ARCHITECTURE.md` mandates a modular Phoenix application with LiveView and Ecto/PostgreSQL, business rules outside web code, and ADRs for deviations.
- `docs/PRODUCT.md` provides protected domain invariants; this foundation introduces no domain state.
- `docs/CHECKPOINTS.md` places the repository/test foundation in CP1 while later tasks own the remaining CP1 capabilities.
- `.specify/memory/constitution.md` favors the smallest modular design, explicit evidence, and independent verification.
- Official Phoenix 1.8.13 documentation permits a database-free application via generator choices, documents optional generated components, and states the supported Elixir/OTP minimums; Hex lists 1.8.13 as the current release on 2026-09-08.
- Active Agentflow inputs and the critic handoff state that no human feedback has been recorded.

## Rejected alternatives

- PostgreSQL in TASK-001: crosses backlog ownership and needs human scope approval.
- `--no-ecto`: locally smaller but causes immediate TASK-002 rework and weakens baseline alignment.
- Repo retries while serving the page: hides unhealthy startup behind HTTP reachability.
- Static/API-only shell: does not establish the mandated LiveView-capable path.
- Full generator defaults: unnecessary mailer/dashboard surface.
- Empty future contexts/adapters/workers: speculative structure without behavior.
- Health endpoint: TASK-038 owns health checks; the default-page smoke contract is sufficient here.

## Implementation guidance

1. Generate/integrate the pinned Phoenix application under the names above, preserving existing repository governance files and human changes.
2. Make the minimum generator edits needed to match the allowed-component list and ADR-001; do not hand-build future architecture layers.
3. Replace generic generated branding with the stable marker and add the endpoint-level test before broader edits.
4. Document exact prepare, compile, test, start, probe, stop, and restart commands in README, including version and failure checks.
5. Ensure finite commands return nonzero on failure; use a bounded probe for the long-running server.
6. Run formatting, warnings-as-errors compilation, tests, real HTTP lifecycle with PostgreSQL/Redis unavailable, intentional failing assertion in a disposable copy, and isolated-checkout repetition. Record outputs; never infer a pass.
7. Keep TASK-002 activation steps out of implementation, but leave Repo naming/configuration coherent and reference ADR-001 for the next owner.

## Durable deviation

`adrs/001-defer-repository-activation.md` is the sole architecture deviation. It is a deliberate sequencing decision: PostgreSQL remains authoritative in the target architecture, but Repo activation is deferred until its environment-owning task. No new service or permanent alternate persistence mechanism is approved.
