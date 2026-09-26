# ADR-0006: API Authentication Route Policy

**Status**: Accepted

**Date**: 2026-09-26

## Context

The application has authoritative JWT validation and API-key identification but no shared REST authentication boundary or production API routes yet. TASK-010 requires every application-owned REST route to be explicitly public or protected, propagates trusted identity without authorization data, and must not create demonstration product surface. Duplicate/coalesced headers and server-rejected malformed transport also require a precise boundary.

## Decision

- Represent REST policy with two named Phoenix pipelines: `:api_public` and `:api_protected`. Audit every production router path at `/api` or `/api/*` for exactly one policy, and explicitly allowlist intentional public routes.
- Authenticate protected requests in one web Plug. Count raw header occurrences, reject ambiguity before validation, never split comma-coalesced credentials, and delegate verification only to `FootballMarket.Accounts`.
- Propagate successful identity as an Accounts-owned `AuthenticatedActor` containing only account ID, authentication method, and verified token/key ID.
- Validate integration through a test-only router/probe until a separately owned task introduces a real endpoint. Add no production probe.
- Guarantee the generic `401` contract only for requests that reach Plug. Preserve the server's transport parser behavior for invalid HTTP rejected earlier.

## Consequences

New application REST routes must declare a policy and public exposure requires an auditable allowlist change. Controllers receive trusted actor context but remain responsible for calling domain/application code; authorization stays outside the Plug. The architecture adds no dependency, persistence, cache, or production endpoint. Transport-level `400` responses can differ from application authentication failures by design.

## Rejected alternatives

- A third-party authentication framework duplicates the existing validators and expands scope.
- Per-controller authentication or direct Repo/Joken access breaks the shared boundary and ownership rules.
- Optional authentication on public routes contradicts the specified ignore behavior.
- A shipped demonstration endpoint creates accidental product surface before TASK-011.
- Splitting coalesced header values invents credential grammar and can conceal ambiguity.
- Caching API-key identity to satisfy the latency criterion weakens immediate revocation and is unsupported by evidence.
