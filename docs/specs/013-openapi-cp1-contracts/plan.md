# Implementation Plan: OpenAPI 3 Foundation and CP1 Contracts

**Branch**: `013-openapi-3-foundation-and-cp1-contracts` | **Date**: 2026-09-28 | **Spec**: [spec.md](spec.md)

**Input**: TASK-013 spec, product challenge and decision, architecture baseline, constitution, and current TASK-013 feedback (none recorded).

## Summary

Publish a single, hand-authored OpenAPI 3.0 JSON contract for the two existing protected player routes and a public Swagger UI page that loads it from the same origin. Serve a pinned local UI bundle. Give readers one ephemeral credential selector; the request interceptor sends exactly the chosen header to a catalog route. Preserve the existing router, authentication, catalog, and persistence behavior. Validate the document with an OpenAPI parser, compare it with live CP1 routes and responses, and execute both credential paths in a browser.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3`, Phoenix 1.8; browser JavaScript; Node 24 available locally for validation tooling

**Primary Dependencies**: Existing Phoenix, Plug, Jason and ExUnit; pinned, locally served `swagger-ui-dist` browser assets; pinned `@apidevtools/swagger-parser` and `playwright-core` as test tools only

**Storage**: No new persistence. One tracked JSON contract and tracked static UI assets; reader credentials live only in page memory.

**Testing**: ExUnit with existing Accounts/Catalog fixture helpers and ConnTest; Swagger Parser; Chromium request inspection through Playwright Core

**Target Platform**: Existing Linux-compatible Phoenix HTTP server and modern browser; same-origin documentation and API calls

**Project Type**: Modular monolith web API with public developer documentation

**Performance Goals**: No new catalog latency target; documentation loads with locally served assets without depending on an external CDN or validator service

**Constraints**: Exactly two documented HTTP operations; docs public while catalog remains protected; one credential per interactive request; no real credentials in tracked artifacts, URLs, storage, screenshots, or failure output; no changes to runtime result or authentication rules

**Scale/Scope**: One OpenAPI 3.0 document, one interactive page, two catalog operations, five list query parameters, two alternative security schemes, existing success and failure contracts

## Constitution Check

### Pre-design gate

- **Specification before implementation — PASS**: TASK-013 has a testable spec, independent challenge, and product decision; no unresolved human check or TASK-013 feedback exists.
- **Domain integrity — PASS**: Publication is read-only and does not touch token, quote, trading, audit, or catalog persistence rules.
- **Modular simplicity — PASS**: A static contract and local UI assets use the existing Phoenix web/static boundary; no domain context, database, cache, worker, or external adapter is added.
- **Evidence-based quality — PASS**: The design includes spec validation, contract/live comparisons, both authentication methods, error priority, and browser request-header evidence.
- **Independent verification — PASS**: Separate implementation, QA, and final review gates remain required; no new product decision is implied by the chosen addresses or UI control.

### Post-design gate

**PASS**. [research.md](research.md) resolves publication, credential selection, validation, and asset choices. The [contract](contracts/cp1-openapi.md) fixes schema and semantic coverage, and [quickstart.md](quickstart.md) defines executable checks. No constitutional exception or durable deviation from the architecture baseline is needed; therefore no ADR is added.

## Design

### Publication and ownership

1. Keep the OpenAPI 3.0.x JSON file at `priv/static/openapi.json` as the single served contract. Add that static path to `FootballMarketWeb.static_paths/0`; `GET /openapi.json` is public and returns JSON. Do not generate it from controller annotations or expose internal Accounts functions as routes.
2. Add `GET /docs` through the existing browser pipeline. Its small Phoenix HTML view loads only the fixed same-origin `/openapi.json` and pinned local Swagger UI JS/CSS from `priv/static/api-docs/`. Add a link to `/docs` and `/openapi.json` in README developer instructions. A failed spec/asset load must show a visible error in the page, not an empty success-looking page.
3. Keep `GET /api/players` and `GET /api/players/:player_id` unchanged in `:api_protected`. The public documentation paths are outside `/api`, so ADR-0006's API route-policy allowlist stays unchanged. Use a relative OpenAPI `servers` URL (`/`) to target the page's origin and avoid embedding a deployment hostname.
4. Vendor only the necessary files from one pinned official Swagger UI distribution, with its license and recorded version/hash. Keep them in a tracked static directory outside ignored `priv/static/assets/`. Disable remote CDN, remote validation, URL-based UI configuration, cookies on requests, and persistent authorization.

### Exclusive, ephemeral interactive authorization

- Put a single credential-mode control beside the rendered UI: Bearer JWT or API key, plus one masked input. Switching modes clears the value. Do not preload a credential or write it to local/session storage, URL, cookie, server state, or request logs. Suppress the native Swagger UI authorization inputs so there is one clear control.
- In Swagger UI's request interceptor, first remove both credential headers case-insensitively. For a same-origin `GET` to the two catalog route shapes only, add exactly the selected header if a value was entered: `Authorization: Bearer <token>` or `X-API-Key: <key>`. Do not attach credentials to `/openapi.json`, static assets, or an off-origin request. Leaving the input empty sends neither and exercises the existing 401.
- Disable display of interceptor-mutated requests so Swagger UI's generated command does not print a reader's credential. Prevent sensitive values from entering page error text or automated test output. Browser checks inspect real outbound headers without recording secret values.

### Contract structure and fidelity

- Declare only `GET /api/players` and `GET /api/players/{player_id}`. Each operation uses `security: [{BearerAuth: []}, {ApiKeyAuth: []}]`, with HTTP Bearer and `X-API-Key` schemes. An array of two one-scheme requirements expresses OR; one object containing both would incorrectly express AND. Describe exact single-credential policy, header/scheme case behavior, credential-value exactness, rejection cases, and authentication-before-validation.
- Define reusable `Player`, nested hierarchy, `Pagination`, `PlayerPage`, `PlayerDetail`, and `Error` schemas. Mark every required field, prohibit extra object properties, use UUID string formats, non-empty leaf strings, integer years, and OpenAPI 3.0 `nullable: true` on required `next_cursor` with non-empty string when present. Describe the page-size-dependent `data` bound and `returned_count`/`has_more` relationships in prose because the schema cannot express them.
- Document the five list parameters, the detail path UUID, statuses 200/400/401/404 as applicable, JSON media types, `WWW-Authenticate` on 401, all five named 400 examples, and representative list, empty-page, detail, 401 and 404 examples. Put filter intersection, order, unknown-key handling, validation priority, cursor/filter binding, allowed page-size changes, and non-snapshot behavior in affected descriptions.
- Use one OAS validator to prove document validity, then separate tests to prove fidelity: compare documented method/path pairs with the router's two CP1 catalog routes only; inspect exact schemes, parameter set, response statuses, code enum/examples, requiredness and nullability; validate example and live response structures; and assert deterministic live 200, 400, 401, and 404 observations, including authentication precedence and 401 challenge. A parser pass alone does not prove behavioral rules.

## Critic Findings and Rejected Alternatives

1. **Two authorizations can produce mixed headers**: the explicit mode and interceptor enforce one outbound header, with browser evidence for JWT → API key → JWT. Rejected: relying on OpenAPI OR or Swagger UI's native Authorize dialog alone, because neither guarantees single-header requests after both credentials have been entered.
2. **Schema validity does not prove fidelity**: parser validation is paired with scoped router comparison and live requests for all five list error codes, precedence, cursor binding, exact fields, and the Bearer challenge. Rejected: a validator-only or page-render-only gate.
3. **A public page can handle secrets**: assets are local, credentials are ephemeral and same-origin-only, and tests inspect URLs, storage, visible commands, examples, and emitted headers. Rejected: CDN assets or persistent authorization; a custom OpenAPI renderer would duplicate mature rendering behavior and increase UI scope.
4. **Discovery and credentials need repeatable evidence**: README publishes both addresses; existing Accounts/Catalog test setup issues short-lived test credentials for acceptance. Rejected: adding registration, login, or API-key issuance HTTP operations, which do not exist and violate FR-003/FR-016.
5. **Contract source**: one static JSON file is sufficient for two stable operations, with strict drift tests. Rejected: code-first annotations and a new runtime OpenAPI dependency, which would couple documentation publication to controller validation and risk changing established 400/401 behavior.

## Project Structure

### Documentation (this feature)

```text
specs/013-openapi-cp1-contracts/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/cp1-openapi.md
└── handoffs/architecture.md
```

### Source code (implementation boundary)

```text
priv/static/openapi.json
priv/static/api-docs/                  # pinned Swagger UI assets and license
lib/football_market_web.ex            # static allowlist
lib/football_market_web/router.ex     # public /docs route only
lib/football_market_web/controllers/  # documentation HTML view/template
priv/static/api-docs/docs.js            # small credential selector/interceptor
README.md                              # published addresses and walkthrough
test/football_market_web/openapi_contract_test.exs
test/football_market_web/openapi_browser_test.exs
tools/openapi/{package.json,package-lock.json,validate.mjs,browser.mjs}
```

**Structure Decision**: Documentation stays at the web/static edge. Existing controller, auth plug, Catalog context, query, and database files are outside the implementation boundary except for read-only test comparison.

## Verification Strategy

### Delivery order across stories

The interactive page in US1 consumes `/openapi.json`, so US1 creates the single
served contract with both operations, all response statuses, and the required
examples before the page is implemented. US2 strengthens and verifies the
failure and credential semantics in that same contract. US3 validates the
already published file as OpenAPI 3 and adds strict route, schema, and example
drift checks. This preserves the spec's P1 → P2 → P3 story order while making
each story's acceptance check executable at its checkpoint; US3 does not
introduce a second contract or publication path.

- Run the pinned OpenAPI 3 parser against the served JSON, then assert documented paths/methods equal the two protected CP1 catalog routes. Verify schemes are alternatives, list/detail parameters and response codes are complete, example values match schemas, and exact response fields are required with no extras.
- With deterministic fixtures, compare live success/empty/detail bodies to the schemas and examples. Exercise all five list errors, authenticated multi-error priority, malformed/absent player 404, filtered cursor mismatch, both valid credential types, missing/invalid/repeated/mixed credential 401, authentication before invalid parameters, exact 401 challenge, and zero catalog reads on rejection where existing probes support it.
- In Chromium, start at the README's `/docs` address and time the discovery of both operations, security choices, five list parameters, and responses against SC-001's three-minute limit. Confirm `/openapi.json` loads, then execute a protected request with JWT, API key, and JWT again. Capture request header names and status without printing values; assert exactly the selected header each time and no credential in URLs, browser storage, page configuration, generated command, or browser-visible error. Verify unauthenticated execution gets 401 and a broken spec URL produces a visible load failure.
- Run focused ExUnit, `mix format --check-formatted`, `MIX_ENV=test mix compile --warnings-as-errors`, full `MIX_ENV=test mix test`, the pinned OAS validator, and the browser check. Record actual results; no check is claimed before execution.

## Complexity Tracking

No constitution violation requires justification.
