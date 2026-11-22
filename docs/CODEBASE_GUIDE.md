# Codebase Guide (for Developers New to Elixir)

This guide explains how the **Football Player Market** application is organized so a single developer can read, navigate, and modify any feature quickly — even if you have never written Elixir or Phoenix before.

---

## 1. Five-Minute Elixir & Phoenix Glossary

If you know TypeScript, Python, Java, or Go, here is how Elixir concepts map to what you already know:

| Elixir / Phoenix syntax | Familiar equivalent | What it means here |
|---|---|---|
| `defmodule Foo.Bar do ... end` | Class / namespace (`Foo.Bar`) | A container for functions. Each domain lives in **one self-contained `.ex` file** (except `market/`, which has 4). |
| `def name(args)` / `defp name(args)` | `public` / `private` function | `def` is callable from outside the module; `defp` is private to that module. |
| `a \|> f() \|> g()` | `g(f(a))` (pipe operator) | Passes the result on the left as the **first argument** to the next function. |
| `{:ok, value}` / `{:error, reason}` | Result / Either type | Functions return tagged tuples instead of throwing exceptions for expected failures. |
| `with {:ok, a} <- f(), {:ok, b} <- g(a) do ... end` | Early-return chain | Runs steps in order and stops immediately on the first non-matching `{:error, ...}`. |
| `Repo.transaction(fn -> ... end)` | SQL transaction block | Runs Ecto queries atomically in PostgreSQL; `Repo.rollback(reason)` aborts it. |
| `schema "table_name" do ... end` | ORM model / DB entity | Ecto schemas sit at the top of each domain file (or in `market/schemas.ex`). |
| **Context** (`lib/football_market/<domain>.ex`) | Service / Domain module | Owns both the database schemas and public business logic for that domain. |
| **Controller** (`lib/football_market_web/controllers/`) | REST HTTP handler | Parses HTTP params, calls a Context, and returns JSON or HTML. |
| **LiveView** (`lib/football_market_web/live/`) | Server-rendered reactive UI | Renders interactive HTML over WebSockets (`mount`, `handle_params`, `handle_event`). |
| **Oban Worker** (`lib/football_market/workers.ex`) | Background job queue worker | Runs durable, retryable jobs stored in PostgreSQL (`perform/1`). |

---

## 2. How Requests and Background Jobs Flow

```text
Browser (LiveView) ──┐
                     ├──▶ Domain Context File ──▶ Ecto Repo ──▶ PostgreSQL
REST API Controller ─┘    (schemas + logic)
                                                                    ▲
Oban Background Workers (`workers.ex`) ──▶ Domain Context File ─────┘
  (sync / quotes / orders)

External Football Data  ──▶ `providers.ex` (read-only) ──▶ `catalog.ex` / `statistics.ex`
```

**Core design rule:** Business logic and database transactions never live in controllers or LiveViews. Every domain owns a single top-level file under `lib/football_market/` (with `market/` split into 4 focused files: schemas, trading, portfolio, orders).

---

## 3. Where Do I Find…?

| If you want to understand or change… | Open this file |
|---|---|
| HTTP routes & LiveView URLs | `lib/football_market_web/router.ex` |
| User registration, login, JWTs, API keys, browser sessions | `lib/football_market/accounts.ex` |
| Leagues, seasons, teams, positions, players, local search, catalog import | `lib/football_market/catalog.ex` |
| Demo seed data (`mix catalog.seed`) | `lib/football_market/catalog_seed.ex` |
| Market tables (balances, holdings, trades, conditional orders) | `lib/football_market/market/schemas.ex` |
| Initial 100-token issuance & atomic buy/sell trading | `lib/football_market/market/trading.ex` |
| User portfolio holdings, credit balance, history, allocation, P&L chart | `lib/football_market/market/portfolio.ex` |
| Conditional buy orders (create, cancel, background evaluation) | `lib/football_market/market/orders.ex` |
| Match & player performance statistics, freshness TTL, import | `lib/football_market/statistics.ex` |
| Weekly player valuation formulas (`balanced`, `position_aware`) & strategy config | `lib/football_market/valuation.ex` |
| Converting valuation scores into market quotes & nightly close | `lib/football_market/quotes.ex` |
| Player market ranking (active valuation strategy) | `lib/football_market/ranking.ex` |
| Sync orchestration & local ops snapshot/commands | `lib/football_market/sync.ex` |
| External data providers (FotMob scraper & Football-Data.org) | `lib/football_market/providers.ex` |
| All Oban background workers | `lib/football_market/workers.ex` |
| Structured JSON logs, correlation IDs & telemetry | `lib/football_market/observability.ex` |
| All `/api/*` REST endpoints & JSON responses | `lib/football_market_web/controllers/api_controller.ex` |
| API authentication & browser session/origin plugs + LiveView auth hook | `lib/football_market_web/auth.ex` |
| Main interactive workspace UI (players, trading, portfolio, orders) | `lib/football_market_web/live/workspace_live.ex` |
| Strategy admin page (`/admin`) & local dev ops dashboard (`/__local/ops`) | `lib/football_market_web/live/admin_live.ex` |
| UI components, layouts, charts & workspace cards | `lib/football_market_web/components/{core_components,app_components}.ex` |
| Mix CLI tasks (`catalog.seed`, `infrastructure.*`) | `lib/mix/tasks/tasks.ex` |

---

## 4. Complete Directory Structure of `lib/` (31 `.ex` files)

```text
lib/
├── football_market/
│   ├── application.ex                      # OTP supervision tree (Repo, PubSub, Oban, Endpoint)
│   ├── repo.ex                             # PostgreSQL Ecto repository
│   ├── observability.ex                    # Telemetry hooks, correlation IDs, JSON log formatter
│   ├── accounts.ex                         # Users, passwords, JWTs, API keys, browser sessions
│   ├── catalog.ex                          # Leagues, seasons, teams, positions, players, search, import
│   ├── catalog_seed.ex                     # Idempotent development seed dataset
│   ├── statistics.ex                       # Match performances, freshness TTLs, idempotent import
│   ├── valuation.ex                        # Deterministic Decimal scoring (`balanced`, `position_aware`), configs
│   ├── quotes.ex                           # Score-to-quote mapping, atomic publish, nightly close
│   ├── ranking.ex                          # Read-only market ranking for active strategy
│   ├── providers.ex                        # External read-only provider adapters (FotMob, Football-Data)
│   ├── sync.ex                             # Sync triggers, execution, and local ops snapshot
│   ├── workers.ex                          # All 9 Oban background workers
│   └── market/
│       ├── schemas.ex                      # Market Ecto schemas (balances, holdings, trades, orders)
│       ├── trading.ex                      # Market facade, 100-token issuance, atomic/idempotent buy & sell
│       ├── portfolio.ex                    # Holdings, balances, history, allocation weights, P&L chart
│       └── orders.ex                       # Conditional orders CRUD & Oban evaluation loop
├── football_market_web.ex                  # Phoenix web helpers & macros
├── football_market_web/
│   ├── endpoint.ex                         # HTTP endpoint, static files, session cookie
│   ├── router.ex                           # All HTTP and LiveView routes
│   ├── auth.ex                             # API JWT/key plug, browser session/origin plugs, LiveView auth
│   ├── telemetry.ex                        # Metrics, VM poller, structured HTTP request logging
│   ├── gettext.ex                          # Gettext backend
│   ├── controllers/
│   │   ├── api_controller.ex               # All `/api/*` REST actions & JSON serializers
│   │   ├── pages.ex                        # Public docs (`/api/docs`, `/openapi.json`), home & error views
│   │   └── session_controller.ex           # Browser sign-in / sign-out / registration
│   ├── live/
│   │   ├── workspace_live.ex               # Main workspace UI (players, trading, portfolio, orders)
│   │   ├── admin_live.ex                   # Valuation strategy admin & local ops LiveViews
│   │   └── workspace/pages/*.html.heex     # 5 LiveView page templates
│   └── components/
│       ├── core_components.ex              # Reusable inputs, tables, buttons & page layouts
│       ├── app_components.ex               # Workspace shell, portfolio charts & order cards
│       └── layouts/root.html.heex          # Root HTML layout
└── mix/tasks/
    └── tasks.ex                            # `mix catalog.seed` & `mix infrastructure.*` tasks
```

---

## 5. Conventions Worth Knowing

1. **Schemas sit at the top of each domain file** — open any domain file (or `market/schemas.ex`) to immediately see its PostgreSQL tables, fields, and validations before reading the business functions below.
2. **All money and valuation math uses `Decimal` or exact integer cents** — floating-point math is avoided everywhere financial or scoring accuracy matters.
3. **Database locking order is deliberate** — trading locks `Player` → `User` (sorted by UUID) → `CreditBalance` (sorted by UUID) so concurrent transactions cannot deadlock.
4. **Tests are organized cleanly by domain** — 17 readable Elixir test files under `test/` cover unit (`--only unit`), PostgreSQL-backed integration (`--only integration`), and end-to-end (`--only e2e`) journeys.
