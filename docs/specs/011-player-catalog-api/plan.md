# Implementation Plan: Player Catalog List and Detail API

**Branch**: `011-player-catalog-api` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/011-player-catalog-api/spec.md`

## Summary

Add authenticated `GET /api/players` and `GET /api/players/:player_id` routes to the existing Phoenix modular monolith. Controllers remain transport-only; the `Catalog` context owns validation-neutral list/detail operations, Ecto queries read PostgreSQL with complete hierarchy joins, and a dedicated cursor module encrypts and authenticates versioned keyset anchors. The list uses `lower(btrim(display_name)), id` ordering, fetches `page_size + 1`, and never contacts provider adapters or Redis.

## Technical Context

**Language/Version**: Elixir 1.20.3 / Erlang-OTP runtime supported by the repository

**Primary Dependencies**: Phoenix 1.8.13, Ecto SQL 3.13, Postgrex, Plug/Phoenix cryptographic primitives, Jason

**Storage**: Authoritative PostgreSQL tables from TASK-005; one expression index on player catalog order. No cursor table, cache, Redis, job, or provider dependency.

**Testing**: ExUnit with `ConnCase`, `CatalogCase`, SQL sandbox, deterministic fixtures, and query/adapter probes

**Target Platform**: Phoenix HTTP service on Linux-compatible deployment

**Project Type**: Modular-monolith web service

**Performance Goals**: For a deterministic 100,000-player fixture, separately report p95 for first-page, continuation-page, and detail HTTP requests over 100 measured sequential requests after 10 warm-ups; target each p95 below 2 seconds. This is diagnostic evidence for SC-008, not a CP1 release gate or capacity/concurrency claim.

**Constraints**: Authenticate before parameter parsing or persistence; default page size 25 and maximum 100; exact JSON shapes; stable keyset replay only while ordering data is unchanged; no provider/cache calls; no OpenAPI publication in this task.

**Scale/Scope**: 100,000 locally persisted players; two read-only routes; one representation; one cursor contract; list/filter work remains in TASK-012.

## Constitution Check

### Pre-design gate

- **Specification before implementation — PASS**: `spec.md` is testable and approved human feedback fixes bounded cursor pagination as mandatory.
- **Domain integrity — PASS**: the feature is read-only and derives league/season through persisted team relationships; it changes no trading, money, token, quote, or audit rule.
- **Modular simplicity — PASS**: Phoenix controllers call the existing `Catalog` context, which owns Ecto queries. No service, cache, worker, or provider path is added.
- **Evidence-based quality — PASS**: contract, context, integration, security, mutation, and diagnostic performance tests are planned.
- **Independent verification — PASS**: product challenge and decision are present; the human pagination decision is authoritative and no unresolved material choice remains.

### Post-design gate

**PASS**. Research resolves every technical unknown. Contracts make field types, nullability, error precedence, cursor scope, replay, mutation limitations, and benchmark evidence explicit. ADR 0007 records the durable cursor convention. No constitutional exception or unjustified complexity remains.

## Design Decisions

### Request flow and boundaries

1. Add the routes inside an `/api` scope using the existing `:api_protected` pipeline. `AuthenticateAPI` therefore halts unauthenticated requests before controller parameter handling.
2. `PlayerController` checks exact query multiplicity and syntax, maps context results to the contract, and renders only public fields. It does not build Ecto queries, decode cursor payloads, or contact adapters.
3. `FootballMarket.Catalog.list_player_page/1` and `get_player/1` form the domain/persistence boundary. The page operation accepts a validated size and decoded anchor, fetches one extra ordered row, and returns records plus continuation state.
4. `FootballMarket.Catalog.PlayerCursor` owns cursor encryption/decryption, version and endpoint scope, anchor validation, and uniform `:invalid_cursor` failures. It is configured from the existing endpoint secret and a dedicated salt; it is not actor-bound because catalog results are identical for every authorized actor.
5. A view/JSON module serializes the same player representation for list and detail. Associations must already be loaded by the context.

### Pagination algorithm

- Canonical ordering is `lower(btrim(players.display_name)) ASC, players.id ASC`; add a matching expression index.
- A cursor payload contains only `{version: 1, scope: "players:list", normalized_display_name, player_id}` and is encrypted and authenticated. It is opaque, endpoint/version scoped, portable between valid authenticated users, and rejected on any decode, integrity, shape, type, scope, or version failure.
- For a continuation, query strictly greater than the decoded tuple. The anchor row need not exist, so deletion does not invalidate the cursor.
- Fetch `page_size + 1`, return at most `page_size`, and derive `has_more` from the extra row. Encode the last returned row only when another row exists.
- Reusing one cursor across requests is valid. Multiple `cursor` occurrences in one query string are invalid; the same multiplicity rule applies to `page_size`. Validate multiplicity before Phoenix's decoded map could discard duplicates.
- Ignore unknown query keys and prove they cannot filter, search, or otherwise alter the page; only `page_size` and `cursor` are interpreted.
- This is not snapshot pagination. Inserts strictly after the anchor can appear; inserts before it do not. Ordering-key edits and deletions during traversal can cause gaps or duplicates. Tests cover insertion behavior and continuation after anchor deletion; the unchanged-catalog guarantees remain exact.

### Serialization and failures

All IDs are canonical JSON UUID strings; codes, names, `display_name`, and `catalog_identity` are non-empty JSON strings; years are JSON integers; no representation field is nullable. `catalog_identity` is the local season-scoped TASK-005 identity and is neither a provider identifier nor persistence metadata. Invalid/missing UUID detail IDs share the exact 404 response. Invalid list parameters share no decoded details. The contract in `contracts/player-catalog-api.md` is normative for transport shape.

### Rejected alternatives

- **Offset pagination or an unbounded list**: cannot provide bounded, mutation-tolerant traversal or satisfy approved feedback.
- **Snapshot/materialized cursor sessions**: stronger mutation isolation is outside the spec and adds persistence, cleanup, expiry, and ownership semantics disproportionate to CP1.
- **Plain signed cursor**: integrity alone still reveals cursor contents, contradicting the no-cursor-content exposure requirement.
- **Actor-bound cursor**: adds no protection to a shared catalog and prevents legitimate replay across supported authenticated clients.
- **Reuse `Catalog.list_players/1` filtering API**: its current `id` ordering and filtering contract are for domain lookup, not the exact HTTP pagination contract; a focused page query avoids silently changing existing callers or pulling TASK-012 forward.
- **Make SC-008 a hard gate**: local p95 without a production hardware/concurrency baseline cannot support a release-capacity claim; the fixed diagnostic protocol makes regressions visible without inventing a CP1 SLA.

## Project Structure

### Documentation (this feature)

```text
specs/011-player-catalog-api/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── player-catalog-api.md
└── handoffs/
    └── architecture.md

docs/adr/
└── 0007-encrypted-stateless-keyset-cursors.md
```

### Source Code (repository root)

```text
lib/
├── football_market/
│   ├── catalog.ex
│   ├── catalog/query.ex
│   └── catalog/player_cursor.ex
└── football_market_web/
    ├── router.ex
    └── controllers/
        ├── player_controller.ex
        └── player_json.ex

priv/repo/migrations/
└── *_add_player_catalog_order_index.exs

test/
├── football_market/catalog/
│   ├── player_pagination_test.exs
│   └── player_cursor_test.exs
└── football_market_web/controllers/
    ├── player_controller_test.exs
    ├── player_catalog_security_test.exs
    └── player_catalog_performance_test.exs
```

**Structure Decision**: Extend the existing catalog context and Phoenix web adapter. Persistence ordering stays in `Catalog.Query`; cursor mechanics are isolated from controllers; response rendering stays in the web layer. Provider modules and Redis remain outside the call graph.

## Verification Strategy

- Unit-test cursor round trips, version/scope/type validation, tampering, malformed input, and non-disclosure.
- Context-test ordering, duplicate/case-variant names, minimum/default/maximum bounds, page-size changes, exact boundary, after-final cursor, replay, insertion before/after anchor, anchor deletion, hierarchy preloads, and zero duplicate/gap traversal on unchanged data.
- Controller-test both credential methods, authentication precedence, duplicate/blank/malformed supported parameters, behavior-neutral unknown parameters, malformed/absent IDs, exact success/error keys and types, and empty pages.
- Install provider/cache probes that fail the test if invoked; assert unauthenticated requests never execute a catalog query.
- Run the fixed 100,000-row diagnostic protocol and report its three p95 values without treating it as a concurrency or production-capacity guarantee.
- Run `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, focused tests, and the complete `MIX_ENV=test mix test` suite during implementation.

## Complexity Tracking

No constitution violations require justification.
