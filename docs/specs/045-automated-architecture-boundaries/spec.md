## Outcome

Automated unit tests detect direct dependencies that violate the application's established web, domain, persistence, worker, cache, and provider-adapter boundaries.

## Acceptance

- [x] An AST-based unit test scans application source, including `lib/football_market_web.ex`, and passes for the current dependency graph.
- [x] The scanner detects forbidden module references introduced by imports, simple or grouped aliases, and fully qualified references.
- [x] Web code may call domain contexts and web support, but may not directly depend on Ecto persistence APIs, the repository, workers, providers, or ranking cache.
- [x] Domain contexts may not depend on web execution modules. Startup and observability composition files remain exempt. Contexts may reference `FootballMarketWeb.Endpoint` only as the application key in `Application.fetch_env!(:football_market, FootballMarketWeb.Endpoint)[:secret_key_base]`.
- [x] Workers may call sync, domain contexts, and Oban APIs, but may not directly access Ecto persistence, providers, cache, or web modules.
- [x] Provider adapters may use shared provider support and external libraries, but not application domain, web, worker, persistence, or cache modules.
- [x] Ranking cache may use its configuration value type and external cache adapter, but not persistence, web, workers, or provider modules.
- [x] Mutation controls reject representative forbidden dependencies for each guarded layer, and positive controls preserve allowed uses.
- [x] The repository remains the Ecto persistence adapter.

## Scope

Add focused unit coverage for the listed dependency rules using the current source layout and named module boundaries.

## Non-goals

Move schemas or repository calls, change runtime behavior, add architecture tooling dependencies, refactor application modules, or enforce dependencies among domain contexts beyond the listed rules.

## Risk

Medium: an incorrect rule could reject a legitimate edge or miss a dependency. AST-based mutation and positive controls reduce this risk.

## Decisions

- Treat `FootballMarket.Sync` as the worker-facing orchestration boundary and allow workers to call domain contexts directly.
- Keep Ecto schemas and repository access inside domain context files; this task guards callers from bypassing those contexts.
- Treat application startup and observability wiring as composition edges. Permit the Endpoint reference only in the exact signed-cursor secret configuration read stated in Acceptance.
