# Research: API Authentication Pipeline

## Route policy enforcement

- **Decision**: Use two explicit Phoenix router pipelines, `:api_public` and `:api_protected`, and audit every application-owned `/api` route through `Phoenix.Router.routes/1`. Require exactly one policy and an explicit allowlist entry for each public route.
- **Rationale**: This makes policy visible at the shared web boundary and turns omission into a failing test while excluding browser, framework, development-only, and unmatched routes from TASK-010.
- **Alternatives considered**: A single pipeline with per-controller opt-out hides public exceptions; path-only conventions cannot prove a pipeline ran; treating every endpoint in the Phoenix application as REST expands scope beyond the specification.

## Integration surface while no production API route exists

- **Decision**: Exercise the production Plug and policy pipelines with a test-only router/probe, and independently audit the production router. Add no production endpoint.
- **Rationale**: This proves downstream gating and actor propagation without creating unsupported product surface before TASK-011.
- **Alternatives considered**: A shipped “who am I” or probe endpoint would become an undocumented API; Plug parser unit tests alone would not prove the shared boundary and authoritative validators integrate.

## Header multiplicity and malformed transport

- **Decision**: Inspect every raw header value exposed by Plug. Reject repeated occurrences before validation, never split commas, and let strict Bearer parsing or canonical API-key identification reject a single coalesced/altered value. Guarantee generic `401` only after a request reaches the Plug boundary.
- **Rationale**: Credential strings are opaque and comma splitting could change meaning. Bandit may reject invalid HTTP bytes before application code can produce the application error contract.
- **Alternatives considered**: Splitting comma-delimited fields invents unsafe credential grammar; taking the first value violates fail-closed ambiguity; weakening the HTTP parser to convert transport failures into authentication failures enlarges the attack surface.

## Actor representation

- **Decision**: Add an Accounts-owned struct with only `account_id`, `authentication_method`, and `credential_id`, built from trusted validator outputs and assigned under `:authenticated_actor`.
- **Rationale**: An explicit value prevents raw credentials, claims, roles, and unrelated user data from drifting inward while supporting both methods uniformly.
- **Alternatives considered**: Passing validator maps directly couples application code to credential-specific shapes; loading a User schema adds persistence and disclosure; maps offer a weaker, typo-prone contract.

## Failure response and challenge

- **Decision**: Every application-level failure returns status `401`, body `{"error":{"code":"unauthenticated"}}`, and `WWW-Authenticate: Bearer realm="api"`.
- **Rationale**: One minimal stable body makes all failure classes observationally equivalent, while the Bearer challenge satisfies the protected resource convention without echoing details.
- **Alternatives considered**: Method-specific codes leak validation paths; multiple challenges imply unsupported API-key challenge semantics; using the generic Phoenix error renderer risks unrelated future formatting changes.

## Validation delegation and dependencies

- **Decision**: Call `Accounts.validate_access_token/1` and `Accounts.identify_api_key/1` directly; add no authentication library or direct Repo query.
- **Rationale**: TASK-008 and TASK-009 already own canonical verification, expiration, and revocation behavior. The pipeline only adapts HTTP credentials to their contracts.
- **Alternatives considered**: Guardian or another framework duplicates established Joken logic; decoding claims in the Plug trusts unverified input; querying `ApiKey` from the web layer violates context ownership.

## Privacy and observability

- **Decision**: Emit one low-cardinality telemetry event with duration, policy, generic outcome, and the selected method only when unambiguous. Inspect only authentication-generated artifacts for disclosure.
- **Rationale**: This supports latency evidence without exporting secrets or high-cardinality identity data and avoids incorrectly constraining downstream domain responses.
- **Alternatives considered**: Logging validation causes or IDs leaks sensitive existence/provenance; suppressing all signals prevents the required measurement; inspecting all business output exceeds TASK-010.

## Performance measurement

- **Decision**: Use an opt-in local test with running PostgreSQL, one active key, one JWT, 5 warm-ups, and 40 complete Plug decisions per method; require 38/40 under one second and report p95.
- **Rationale**: This makes SC-005 repeatable while including the database lookup for API keys and avoiding a noisy default CI gate.
- **Alternatives considered**: Parser-only timing omits the authoritative dependency; production caching is unjustified by a coarse one-second threshold; a single sample cannot establish a percentile.
