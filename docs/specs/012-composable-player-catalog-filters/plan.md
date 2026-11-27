# Implementation Plan: Composable Player Catalog Filters

**Branch**: `012-composable-player-catalog-filters` | **Date**: 2026-09-28 | **Spec**: [spec.md](spec.md)

**Input**: TASK-012 spec, product challenge and decision, and current TASK-012 human feedback (none recorded).

## Summary

Extend the protected TASK-011 player list with optional league, team, and position UUID filters. Validate and normalize them at the web boundary, apply their intersection within the existing ordered PostgreSQL keyset query before its limit, and bind continuation cursors to the effective filter set. Keep the exact unfiltered v1 cursor format valid. No new endpoint, provider call, cache, entity, or infrastructure is needed.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3`; existing Phoenix application

**Primary Dependencies**: Phoenix 1.8, Ecto SQL 3.13, Postgrex, Jason, Erlang crypto already in use

**Storage**: PostgreSQL TASK-005 catalog hierarchy and TASK-011 expression order index; no new persisted state planned

**Testing**: ExUnit, ConnCase/DataCase/CatalogCase, SQL sandbox, deterministic catalog fixtures, existing provider and catalog probes

**Target Platform**: Linux-compatible Phoenix HTTP service with local PostgreSQL

**Project Type**: Modular monolith web API

**Performance Goals**: SC-006: at least 95% of measured first and continuation filtered pages finish within two seconds over 100,000 local players. Use the fixed protocol below; report failure if unmet.

**Constraints**: TASK-010 authentication precedes all validation and reads; existing page size 1–100, ordering, response shape, and non-snapshot semantics; valid unknown IDs return empty pages; no provider, Redis, job, UI, detail, or OpenAPI changes

**Scale/Scope**: Three optional UUID filters and their combinations on the existing list route; five supported leagues and at least two seasons in validation data

## Constitution Check

### Pre-design gate

- **Specification before implementation — PASS**: TASK-012 has a testable spec and independent product challenge. Its decision records no outstanding human check or conflicting feedback.
- **Domain integrity — PASS**: Read-only filters use existing catalog identities and the authoritative team → season → league relationship. Financial and trading rules are untouched.
- **Modular simplicity — PASS**: Extend the existing web, catalog query, and cursor modules; no new service, storage, cache, worker, or provider path.
- **Evidence-based quality — PASS**: Plan includes contract, unit, integration, security, compatibility, and measured latency evidence.
- **Independent verification — PASS**: Implementation remains subject to separate QA and final review; no product decision is needed for these reversible design choices.

### Post-design gate

**PASS**. Research resolves the cursor and performance choices. The contract covers precedence, compatibility, ID discovery, and cursor scope. ADR 0008 records the durable filtered-cursor convention. No constitutional exception is required.

## Design

### Request and query flow

1. Keep `GET /api/players` in the protected router pipeline. In `PlayerController.index/2`, inspect raw query pairs before Phoenix's decoded map can collapse duplicates. Validate in fixed order: `page_size`, `league_id`, `team_id`, `position_id`, then `cursor`. For each filter, reject repeated, bracket-structured, blank, whitespace-padded, or malformed values with its exact `invalid_*_id` code. Ignore unrelated keys. Normalize valid UUID letter case with `Ecto.UUID.cast/1` after exact lexical validation; absent keys remain absent. The resulting filter map has only the three supported atom keys.
2. Pass the validated filter map, page size, and raw cursor to `Catalog.list_player_page/1`. The catalog context decodes and compares the cursor's effective filter set before querying; mismatch or any decode failure returns `:invalid_cursor` without catalog rows. Page size is deliberately outside cursor identity.
3. Extend `Catalog.Query.player_page/2` to accept the filter map. Apply optional predicates to the existing joined relation: `league.id`, exact `team.id`, and `position.id`. Apply all predicates before keyset seek, order, and `page_size + 1` limit. Keep `lower(btrim(display_name)), player.id` ordering and association preloads. Do not route this API through `Query.players/1`, whose ID ordering and unbounded result contract differ.
4. Preserve JSON rendering and pagination metadata. An absent or inconsistent valid ID naturally produces zero SQL rows, without a separate existence query or relationship disclosure. No filter alters the detail route.

### Cursor compatibility

- Continue encoding unfiltered pages with the exact TASK-011 v1 payload, key derivation, AAD, encryption envelope, scope, and ordering anchor. Decode previously issued v1 tokens on requests with no filters only.
- Encode filtered pages as v2 with the same encrypted, authenticated envelope and a canonical map of present filter names to lowercase UUIDs. Fix the map's key set and representation so query-parameter order and UUID letter case yield the same effective filter set. Decode v2 only with an identical normalized set; reject missing, added, or changed filters as `invalid_cursor`. Reject wrong version/scope/shape/types and extraneous filter keys. Do not include page size, actor, provider data, or plaintext filter values in the token.
- Before editing `PlayerCursor`, freeze a literal v1 token produced by the unchanged TASK-011 encoder under the fixed test secret and anchor. Check the literal into a test fixture; the compatibility test must not regenerate it with the new encoder. Assert it decodes, continues an unfiltered page, rejects an added filter, and obeys the existing key lifetime/rotation semantics. The anchor need not correspond to a still-present row.
- Retain TASK-011 non-snapshot behavior across catalog mutation and uniform invalid-cursor errors. ADR [0008](../../docs/adr/0008-filter-bound-player-catalog-cursors.md) records the versioning decision.

### Performance and indexes

Start with the existing catalog order index and foreign-key indexes. Add a composite expression index only if measured query plans show a concrete bottleneck; document its migration and before/after evidence. A speculative index would increase writes and storage without demonstrating benefit.

For SC-006, create a deterministic, isolated fixture of five leagues × two seasons each × ten teams per season × 1,000 players per team = 100,000 players, split equally among the four configured positions. Publish the stable generation seed, IDs, and actual cardinalities. Benchmark league (20,000 matches), position (25,000), team (1,000), league+position (5,000), team+position (250), and league+team+position (250); measure both first and continuation pages at `page_size=100` for each case. Warm each case with 10 requests, then time 100 sequential in-process Phoenix requests through authentication and JSON rendering at concurrency one. Compute p95 as sorted sample 95 of 100; require each case's p95 ≤ 2,000 ms. Run on an otherwise idle local machine with at least four available CPU cores and 8 GiB RAM, local PostgreSQL using the pinned `compose.yaml` image, migrated isolated test DB, warmed connection pool, and no concurrent workload. Record CPU/RAM, OS, Elixir/OTP and PostgreSQL versions, database location, fixture counts, exact command, per-case p95, and query plans for slow cases. The in-process measurement excludes network latency and is not a production capacity claim. If the gate fails, report the failing cases and conditions; do not narrow the matrix or threshold silently.

The current tagged performance test has a five-minute ExUnit timeout. Replace it with a timeout that cannot abort this fixed 12-case protocol at its permitted latency (plus fixture setup), such as `:infinity`; otherwise the test can fail before it has measured the required cases. Keep this tagged test excluded from the routine suite and run it explicitly for the SC-006 gate.

## Critic Findings and Rejected Alternatives

1. **Latency reproducibility**: The fixed dataset, machine and database conditions, request matrix, sample count, and p95 calculation above make SC-006 inspectable. Rejected: reusing TASK-011's one-team diagnostic, which measures no filter selectivity and does not assert the threshold; treating this local result as a production SLA.
2. **Legacy cursor migration**: The literal pre-change v1 fixture proves backwards decoding and filter rejection. Rejected: generating the purported legacy token with the modified encoder, which could conceal a format break; replacing all cursors with v2, which would violate FR-009.
3. **Filter ID discovery**: The contract directs clients to use IDs found in existing player list representations. Tests use IDs obtained from real list responses. Rejected: new enumeration endpoints or UI, which exceed FR-016 and would require a separate product decision.
4. **Query strategy**: Predicate extension of the existing bounded query is sufficient. Rejected: post-page filtering, which shortens pages and omits matches; separate existence lookups, which add latency and disclose relationship existence; rewriting generic `list_players/1`, which has another order contract.

## Project Structure

### Documentation (this feature)

```text
specs/012-composable-player-catalog-filters/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/player-catalog-filters.md
└── handoffs/architecture.md
docs/adr/0008-filter-bound-player-catalog-cursors.md
```

### Source Code (repository root)

```text
lib/football_market/catalog.ex
lib/football_market/catalog/query.ex
lib/football_market/catalog/player_cursor.ex
lib/football_market_web/controllers/player_controller.ex
test/football_market/catalog/{player_cursor_test,player_pagination_test,query_test}.exs
test/football_market_web/controllers/{player_controller_test,player_catalog_auth_precedence_test,player_catalog_performance_test}.exs
test/fixtures/ (literal pre-change cursor fixture, location chosen during implementation)
```

**Structure Decision**: Keep transport validation in the controller, catalog selection in the existing context/query, and cursor cryptography in `PlayerCursor`. Reuse response rendering and existing database schema unless measured evidence warrants an index.

## Verification Strategy

- Cover each single filter, three pairs, and all three using all five leagues, multiple seasons, same-name teams, each position, valid unknown IDs, conflicting IDs, ordering ties, exact boundary and after-final empty pages. Compare complete cursor traversals to an independently derived expected player set.
- Exercise valid UUID case normalization, every invalid/structured/repeated filter, unknown parameters, parameter-order invariance, exact error bodies and priority, both credential methods, and unauthenticated short circuit before validation/catalog SQL.
- Test the v1 literal fixture, filtered v2 round trips and tampering, filter addition/removal/change, cursor replay, page-size changes, and no plaintext or new response fields. Probe provider/cache paths to ensure zero calls.
- Run focused ExUnit tests, `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, full `MIX_ENV=test mix test`, and the isolated SC-006 measurement from [quickstart.md](quickstart.md). Record actual results; do not claim a check that was not run.

## Complexity Tracking

No constitution violations require justification.
