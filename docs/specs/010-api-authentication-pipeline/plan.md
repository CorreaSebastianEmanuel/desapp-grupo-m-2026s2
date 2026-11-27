# Implementation Plan: API Authentication Pipeline

**Branch**: `010-api-authentication-pipeline` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/010-api-authentication-pipeline/spec.md`; product challenge and decision handoffs; no current `backlog/feedback/TASK-010.md` exists.

## Summary

Add one Phoenix Plug at the REST boundary that classifies the raw `Authorization` and `X-API-Key` header occurrences, accepts exactly one well-formed supported credential, delegates verification to `FootballMarket.Accounts`, and assigns a minimal authenticated actor before protected code runs. Define explicit public and protected API pipelines and enforce their use with a route-table audit. Validate the boundary through a test-only router/probe because no production REST operation exists yet. [ADR-0006](../../docs/adr/0006-api-authentication-route-policy.md) records the durable route-policy and actor-boundary decisions.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3`; OTP 29 baseline

**Primary Dependencies**: Existing Phoenix 1.8, Plug (through Phoenix), Joken 2.7, Ecto SQL 3.13, and Postgrex; no new dependency

**Storage**: PostgreSQL remains authoritative for API-key status; JWT validation remains stateless; this feature adds no schema, migration, cache, or persisted session

**Testing**: ExUnit, `Phoenix.ConnTest`, a test-only Phoenix router/protected probe, Ecto SQL Sandbox, log/telemetry capture, route-table audit, and an opt-in local timing test

**Target Platform**: Existing Phoenix modular monolith on the BEAM

**Project Type**: Web application; REST authentication adapter over existing Accounts capabilities

**Performance Goals**: After 5 warm-up calls per method, at least 38 of 40 JWT decisions and 38 of 40 API-key decisions complete within one second on the local test stack with PostgreSQL running and one active test key

**Constraints**: Generic `401` response and Bearer challenge; fail closed on missing, ambiguous, repeated, malformed, or rejected credentials; no secret, unverified claim, or identity metadata outside the successful in-process actor; no authorization or credential lifecycle behavior

**Scale/Scope**: One actor value, one shared authentication Plug, two explicit API policy pipelines, one test-only probe/router, focused tests, and no production endpoint

## Constitution Check

*GATE: Must pass before Phase 0 research; rechecked after Phase 1 design.*

### Pre-design gate: PASS

| Principle | Evidence / decision |
|---|---|
| Specification before implementation | FR-001 through FR-015 define the boundary. The product decision authorizes conservative resolution of the critic's transport, route-universe, privacy, and timing findings. |
| Domain integrity | The Plug trusts only `Accounts.validate_access_token/1` and `Accounts.identify_api_key/1`; it neither decodes claims nor queries credential tables. Actor context carries identity and provenance, not permissions. |
| Modular simplicity | Reuse the Phoenix router, Plug, Accounts context, Repo, and telemetry stack. Add no framework, storage, cache, service, or production demonstration route. |
| Evidence-based quality | Integration tests cover the real validators, revocation/expiry, downstream non-execution, exact response equivalence, route policy, disclosure, and an explicit opt-in timing sample. |
| Independent verification | Product challenge and synthesis are complete, the product decision requires no human check, and no TASK-010 feedback record exists. Later QA and final review remain independent. |

### Post-design gate: PASS

The [research](research.md), [data model](data-model.md), [HTTP contract](contracts/api-authentication.md), [quickstart](quickstart.md), and [ADR-0006](../../docs/adr/0006-api-authentication-route-policy.md) preserve the modular monolith and resolve every planning clarification. No constitution exception remains.

## Design

### Shared authentication boundary

1. Add `%FootballMarket.Accounts.AuthenticatedActor{account_id, authentication_method, credential_id}` with enforced keys and only those fields. Construct it solely from successful results returned by the existing Accounts context. Never accept an actor, account ID, method, or credential ID from request parameters or unverified token data.
2. Add `FootballMarketWeb.Plugs.AuthenticateAPI`. It reads **all** raw values returned by `Plug.Conn.get_req_header/2` for both supported headers before calling a validator. Zero values is missing; more than one occurrence of either header or one occurrence of both types is ambiguous and fails immediately. A single intermediary-coalesced value remains one opaque value: strict Bearer parsing or the existing canonical API-key validator rejects any alteration; commas are never split into credentials.
3. Bearer parsing is case-insensitive only for the scheme and accepts exactly `Bearer` followed by one non-empty token separated by HTTP whitespace, with no additional credential parts. The token bytes are otherwise unchanged. An API-key value is passed unchanged to `Accounts.identify_api_key/1`; blank, whitespace-padded, comma-coalesced, and noncanonical values fail there. Header names remain case-insensitive through Plug.
4. Delegate JWT validation to `Accounts.validate_access_token/1` and API-key identification to `Accounts.identify_api_key/1`. On success, set `conn.assigns.authenticated_actor` and continue exactly once. On every application-reachable failure, halt with status `401`, JSON `{"error":{"code":"unauthenticated"}}`, and `WWW-Authenticate: Bearer realm="api"`. The failure path never assigns an actor or invokes downstream code.
5. Invalid HTTP bytes or header encodings rejected by Bandit/Phoenix before a `Plug.Conn` exists are transport failures outside this feature and may receive the server's `400`; do not weaken or replace the HTTP parser to manufacture a `401`. “Non-text” tests cover non-binary values supplied directly to the Plug and all malformed wire values that the server admits.

### Explicit route policy and propagation

1. Keep browser/LiveView routes separate. Define named `:api_public` and `:api_protected` pipelines, both with JSON acceptance; only `:api_protected` invokes `AuthenticateAPI`. Application-owned REST routes are routes registered in `FootballMarketWeb.Router` whose path is `/api` or begins `/api/`.
2. Every application-owned REST scope must pass through exactly one named policy pipeline. Public scopes deliberately use `:api_public`; protected scopes deliberately use `:api_protected`. The protected pipeline is the normal/default placement for new REST operations. Maintain a small explicit allowlist in the route-audit test for intentional public route `{verb, path}` pairs; an unclassified, multiply classified, or unlisted-public `/api` route fails the audit.
3. Public routes do not invoke the authentication Plug. Therefore they ignore either credential header, attach no actor, and make no validator call. The authentication Plug does not expose an optional-authentication mode.
4. Protected controllers/application adapters may read only the verified actor assign and pass that actor into application operations. They must not parse headers or treat request account identifiers as identity proof. Domain contexts continue to own authorization and business rules.
5. Since TASK-010 has no production REST operation to protect and TASK-011 owns catalog endpoints, add no production probe. Exercise the production Plug and both policy pipelines through a router/probe defined only under `test/support`; inspect the production router table independently.

### Observability and non-disclosure

1. Emit one pipeline telemetry event, `[:football_market, :api, :authentication]`, with monotonic duration measurement and metadata limited to `route_policy: :protected`, generic `outcome`, and `authentication_method` only after an unambiguous method is selected. Use a neutral value for missing/ambiguous credentials. Never attach headers, credential fragments, validation reasons, account IDs, token IDs, key IDs, claims, hashes, or inspected actor values.
2. Do not log credentials, actor context, validation results, or validator exceptions. The Plug maps all validator failures and safe exceptions to the same response without inspecting or rendering credential material. Existing Accounts query logging remains suppressed for API-key lookup.
3. Scope privacy evidence to artifacts generated by authentication: the `401` response, Plug/actor inspection, captured Logger output, emitted authentication telemetry, and raised/returned errors. Downstream business responses are outside this feature and may legitimately contain domain identifiers.

### Verification plan

- Through the test router, prove a real TASK-009 JWT and real TASK-008 API key create the exact actor and reach the protected probe once. Prove an expired JWT and a key rejected immediately after committed revocation produce the exact generic response and never run the probe.
- Table-drive missing, blank, unsupported scheme, malformed Bearer parts, invalid token, unknown key, repeated header lines, a single coalesced/altered header value, both credential forms, direct non-binary Plug input, and validator-safe failures. Assert byte-for-byte-equivalent status/body/challenge and absent actor for every failure.
- Prove public probe behavior separately: no credentials succeeds; valid, invalid, repeated, and ambiguous authentication headers are ignored; no actor is attached and no authentication telemetry or validator call occurs.
- Audit `Phoenix.Router.routes/1` for all production routes at `/api` or `/api/*`: exactly one policy pipeline, every public route in the intentional allowlist, and no controller/handler module containing independent supported-header parsing. Keep the latter as a focused architecture/source-boundary test over application web handlers, not generated/dependency code.
- Capture response bodies/headers, `inspect(actor)`, logs, telemetry metadata, and failure values with sentinel credentials and IDs to prove authentication-owned artifacts disclose none of the forbidden material. The successful actor is the sole permitted in-process identity artifact.
- Put the timing regression in an excluded-by-default `:performance` test. With local PostgreSQL prepared, create one account and active key, issue one valid JWT, warm each path 5 times, then measure 40 complete protected-pipeline decisions per method using `System.monotonic_time`; require at least 38/40 below one second for each method and report counts/p95. Do not add caching or make this noisy local measurement a default CI gate.

## Project Structure

### Documentation (this feature)

```text
specs/010-api-authentication-pipeline/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── api-authentication.md
└── handoffs/
    └── architecture.md
docs/adr/
└── 0006-api-authentication-route-policy.md
```

### Source Code (repository root)

```text
lib/football_market/accounts/
└── authenticated_actor.ex
lib/football_market_web/
├── router.ex
└── plugs/
    └── authenticate_api.ex

test/support/
└── api_authentication_probe.ex
test/football_market_web/
├── api_authentication_test.exs
├── api_authentication_security_test.exs
├── api_authentication_performance_test.exs
└── router_authentication_policy_test.exs
test/test_helper.exs
```

**Structure Decision**: Keep authentication parsing and HTTP responses in the web adapter, verified identity in a minimal Accounts-owned value, and credential verification in the existing Accounts context. The test-only probe provides end-to-end boundary evidence until a real API operation is introduced by its owning task.

## Complexity Tracking

No constitution violation requires an exception. Rejected larger alternatives—an authentication framework, direct persistence access, optional authentication, a production probe endpoint, and caching for the latency target—add scope or weaken ownership without improving this contract; their tradeoffs are recorded in [research.md](research.md) and [ADR-0006](../../docs/adr/0006-api-authentication-route-policy.md).
