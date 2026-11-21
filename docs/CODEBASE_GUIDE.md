# Codebase Guide (for Developers New to Elixir)

This guide explains how the **Football Player Market** application is organized so you can read, navigate, and modify any feature — even if you have never written Elixir or Phoenix before.

---

## 1. Five-Minute Elixir & Phoenix Glossary

If you know TypeScript, Python, Java, or Go, here is how Elixir concepts map to what you already know:

| Elixir / Phoenix syntax | Familiar equivalent | What it means here |
|---|---|---|
| `defmodule Foo.Bar do ... end` | Class / namespace (`Foo.Bar`) | A container for functions. Almost every logic file defines **one module with the matching filename**. |
| `def name(args)` / `defp name(args)` | `public` / `private` function | `def` is callable from outside the module; `defp` is private to that file. |
| `defdelegate foo(a), to: Other` | Pass-through wrapper method | Top-level context files (like `market.ex`) delegate to focused implementation files. |
| `a \|> f() \|> g()` | `g(f(a))` (pipe operator) | Passes the result on the left as the **first argument** to the next function. |
| `{:ok, value}` / `{:error, reason}` | Result / Either type | Functions return tagged tuples instead of throwing exceptions for expected failures. |
| `with {:ok, a} <- f(), {:ok, b} <- g(a) do ... end` | Early-return chain | Runs steps in order and stops immediately on the first non-matching `{:error, ...}`. |
| `Repo.transaction(fn -> ... end)` | SQL transaction block | Runs Ecto queries atomically in PostgreSQL; `Repo.rollback(reason)` aborts it. |
| `schema "table_name" do ... end` | ORM model / DB entity | Ecto schemas live together in `<context>/schemas.ex` for each domain. |
| **Context** (`lib/football_market/<name>.ex`) | Service / Domain Facade | The public API boundary of a business domain (e.g., `Market`, `Catalog`, `Quotes`). |
| **Controller** (`lib/football_market_web/controllers/`) | REST HTTP handler | Parses HTTP params, calls a Context, and returns JSON or HTML. |
| **LiveView** (`lib/football_market_web/live/`) | Server-rendered reactive UI | Renders interactive HTML over WebSockets (`mount`, `handle_params`, `handle_event`). |
| **Oban Worker** (`lib/football_market/workers/`) | Background job queue worker | Runs durable, retryable jobs stored in PostgreSQL (`perform/1`). |

---

## 2. How Requests and Background Jobs Flow

```text
Browser (LiveView) ──┐
                     ├──▶ Domain Context Facade ──▶ Logic Module ──▶ Ecto Schema ──▶ PostgreSQL
REST API Controller ─┘    (e.g., Market, Quotes)    (1 file = 1 mod)   (schemas.ex)
                                                                            ▲
Oban Background Workers ──▶ Domain Context Facade ──────────────────────────┘
  (sync / quotes / orders)

External Football Data  ──▶ Providers Adapter (read-only) ──▶ Catalog / Statistics Ingestion
```

**Core design rule:** Business logic and database transactions never live in controllers or LiveViews. Every domain owns its own folder under `lib/football_market/` and exposes its public API through its top-level facade file (`lib/football_market/<domain>.ex`).

---

## 3. Where Do I Find…?

| If you want to understand or change… | Open this file |
|---|---|
| HTTP routes & LiveView URLs | `lib/football_market_web/router.ex` |
| User registration, login, JWTs, API keys, browser sessions | `lib/football_market/accounts.ex` → `accounts/{authentication,browser_sessions,schemas}.ex` |
| Leagues, seasons, teams, positions, players, local search | `lib/football_market/catalog.ex` → `catalog/{query,player_cursor,scouting,schemas}.ex` |
| Demo seed data (`mix catalog.seed`) | `lib/football_market/catalog/development_seed.ex` & `development_seed_manifest.ex` |
| Initial 100-token issuance per player | `lib/football_market/market/initialization.ex` |
| Buying and selling player tokens (atomic + idempotent) | `lib/football_market/market/trading.ex` |
| User portfolio holdings, credit balance, initial inventory | `lib/football_market/market/portfolio.ex` |
| Paginated transaction history | `lib/football_market/market/transaction_history.ex` |
| Portfolio allocation weights & daily P&L chart history | `lib/football_market/market/analytics.ex` |
| Conditional buy orders (create / list / cancel / evaluate) | `lib/football_market/market/conditional_orders.ex` |
| Background order evaluation loop & recovery | `lib/football_market/market/order_evaluation.ex` |
| Match & player performance statistics storage & freshness | `lib/football_market/statistics.ex` → `statistics/{freshness,input,query,ingestion.ex}` |
| Weekly player valuation formulas (`balanced`, `position_aware`) | `lib/football_market/valuation.ex` → `valuation/{balanced,position_aware,scoring,configurations}.ex` |
| Converting valuation scores into market quotes & nightly close | `lib/football_market/quotes.ex` → `quotes/{mappings,engine,closing,recovery,reader}.ex` |
| Player market ranking (active valuation strategy) | `lib/football_market/ranking.ex` |
| Scheduled sync runs, retries, and Postgres advisory guards | `lib/football_market/synchronization.ex` → `synchronization/{store,execution,scheduler,dispatcher}.ex` |
| External data providers (FotMob scraper & Football-Data.org) | `lib/football_market/providers.ex` → `providers/{scraping.ex,football_data_org.ex,runtime.ex}` |
| Background Oban workers | `lib/football_market/workers/{sync_workers,quote_workers,order_workers}.ex` |
| Structured JSON logs & correlation IDs | `lib/football_market/observability.ex` & `lib/football_market_web/request_logger.ex` |
| REST API controllers & JSON serializers | `lib/football_market_web/controllers/{market_controllers,player_controller,conditional_order_controller,api_json}.ex` |
| Main interactive workspace UI (players, trading, portfolio, orders) | `lib/football_market_web/live/workspace_live.ex` → `live/workspace/{players,trading,portfolio,orders,helpers}.ex` |
| Strategy admin page & local dev operations dashboard | `lib/football_market_web/live/{administration_live,local_admin_live}.ex` |

---

## 4. Directory Structure of `lib/`

```text
lib/
├── football_market.ex                  # Root app module
├── football_market/
│   ├── application.ex                  # OTP supervision tree (Repo, PubSub, Oban, Endpoint)
│   ├── repo.ex                         # PostgreSQL Ecto repository
│   ├── accounts.ex + accounts/         # Auth, JWTs, API keys, browser sessions
│   ├── catalog.ex + catalog/           # Leagues, seasons, teams, players, scouting, ingestion
│   ├── market.ex + market/             # Issuance, trading, portfolio, analytics, conditional orders
│   ├── statistics.ex + statistics/     # Match performances, freshness TTLs, ingestion
│   ├── valuation.ex + valuation/       # Deterministic weekly scoring, strategy versions, replay
│   ├── quotes.ex + quotes/             # Score-to-price conversion, nightly close, quote history
│   ├── ranking.ex                      # Read-only market ranking for active strategy
│   ├── synchronization.ex + synchronization/ # Durable sync runs, retry policy, advisory locks
│   ├── providers.ex + providers/       # External read-only provider adapters (FotMob, Football-Data)
│   ├── workers/                        # Oban background workers grouped by domain (3 files)
│   ├── observability.ex                # Telemetry hooks, correlation IDs, JSON log formatter
│   └── infrastructure/                 # Env config, Redis/rate-limit adapters, local admin snapshot
└── football_market_web/
    ├── router.ex                       # All HTTP and LiveView routes
    ├── endpoint.ex                     # Plug pipeline & static assets
    ├── plugs/                          # API auth & browser session/origin plugs
    ├── controllers/                    # REST API controllers, JSON views, login/docs pages
    ├── live/                           # WorkspaceLive (+ 5 tab modules), AdministrationLive, LocalAdminLive
    └── components/                     # Reusable HEEx UI components & charts
```

---

## 5. Conventions Worth Knowing

1. **Every domain has a `<context>/schemas.ex`** — open that file first whenever you want to see the PostgreSQL tables and columns for a domain.
2. **All money and valuation math uses `Decimal` or exact integer ratios** — floating-point math is intentionally avoided everywhere financial or scoring accuracy matters.
3. **Database locking order is deliberate** — trading locks `Player` → `User` (sorted by UUID) → `CreditBalance` (sorted by UUID) so concurrent transactions cannot deadlock.
4. **Tests mirror `lib/`** — unit tests run without external services (`MIX_ENV=test mix test --only unit`), and integration tests exercise real PostgreSQL and Oban (`sh scripts/test_profile.sh integration`).
