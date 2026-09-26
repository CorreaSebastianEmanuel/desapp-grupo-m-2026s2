# Feature Specification: API Authentication Pipeline

**Feature Branch**: `010-api-authentication-pipeline`

**Created**: 2026-09-26

**Status**: Draft

**Input**: TASK-010: "Protect API routes consistently and expose authenticated actor context to the application."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Access with a JWT (Priority: P1)

As a signed-in market user, I can call a protected API route with my valid access token so that the application handles the request as my account.

**Why this priority**: JWT access is the primary user authentication path and proves that route protection can turn a validated credential into trusted actor context.

**Independent Test**: Obtain a JWT through TASK-009, present it in the standard authorization header to a representative protected route, and verify that the route receives the correct account identity and token identity while missing or invalid credentials receive no actor context.

**Acceptance Scenarios**:

1. **Given** a valid, unexpired JWT, **When** it is presented as a Bearer credential to a protected API route, **Then** the request proceeds with actor context containing the verified account identity, JWT method, and token identifier.
2. **Given** a protected API route, **When** no credential is presented, **Then** the request is rejected as unauthenticated before protected application behavior runs.
3. **Given** an invalid, expired, or malformed JWT, **When** it is presented to a protected API route, **Then** the request receives the same unauthenticated outcome and no actor context.

---

### User Story 2 - Access with an API Key (Priority: P2)

As an integration acting for a market account, I can call a protected API route with an active API key so that the application handles the request as that account and knows which key was used.

**Why this priority**: CP1 requires API-key support, and integrations need the same protected-route boundary and actor attribution as JWT users.

**Independent Test**: Issue an API key through TASK-008, present it in the standard API-key header to the same representative protected route, and verify correct account/key attribution plus rejection after revocation.

**Acceptance Scenarios**:

1. **Given** an active API key, **When** it is presented in the API-key header to a protected API route, **Then** the request proceeds with actor context containing the verified account identity, API-key method, and key identifier.
2. **Given** an unknown, malformed, or revoked API key, **When** it is presented to a protected API route, **Then** the request is rejected as unauthenticated and receives no actor context.
3. **Given** a key that has been revoked successfully, **When** it is used on the next protected request, **Then** it is rejected while another active key for the account remains usable.

---

### User Story 3 - Apply a Predictable Route Policy (Priority: P3)

As an API consumer and application developer, I need public and protected routes to apply one explicit authentication policy so that callers receive predictable behavior and application code never has to trust raw credentials.

**Why this priority**: A consistent boundary prevents accidental exposure of protected operations and avoids duplicating security-sensitive parsing in individual handlers.

**Independent Test**: Exercise representative public and protected routes with no credential, each supported credential, malformed headers, and both credential types together; verify the declared policy and that raw credentials never reach application operations.

**Acceptance Scenarios**:

1. **Given** a route explicitly designated public, **When** it is called without credentials, **Then** the request proceeds without actor context or an authentication challenge.
2. **Given** a route designated protected, **When** it is called with exactly one valid supported credential, **Then** authentication is performed once before protected application behavior and only verified actor context is passed inward.
3. **Given** a request containing both a Bearer credential and an API key, **When** it targets a protected route, **Then** it is rejected as unauthenticated without selecting one credential or exposing either credential's validity.

### Edge Cases

- Header names are matched without regard to letter case, while credential values remain exact and are not trimmed or normalized beyond separating the authentication scheme from its value.
- Blank values, repeated credential headers, multiple values for one credential header, unsupported authorization schemes, malformed Bearer syntax, and non-text input are rejected on protected routes without raising an externally visible internal error.
- A Bearer scheme is matched without regard to letter case and must contain exactly one non-empty token value; additional credential parts are malformed.
- Requests containing both supported credential types are ambiguous and fail closed even when one or both credentials are valid.
- Authentication success does not itself grant a role or permission. A protected route only receives the verified identity and credential provenance needed by later authorization rules.
- Authentication failures do not reveal whether an account, token, or API key exists, which validation check failed, or whether another credential in an ambiguous request was valid.
- Complete JWTs, API-key secrets, stored verification material, and unverified claims are absent from responses, logs, telemetry, errors, and actor context.
- Public routes ignore authentication headers and do not create actor context; routes must be deliberately placed in the public or protected policy rather than becoming public by omission.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Every API route MUST be explicitly assigned to either a public policy or a protected policy. A newly added API route without an explicit assignment MUST fail closed rather than become publicly reachable.
- **FR-002**: Protected API routes MUST accept exactly one of two credential forms: a JWT access token in the `Authorization: Bearer <token>` header or an API key in the `X-API-Key: <key>` header.
- **FR-003**: The pipeline MUST delegate JWT validation to the trusted capability supplied by TASK-009 and active API-key identification to the trusted capability supplied by TASK-008. It MUST NOT reimplement credential verification or trust unverified credential content.
- **FR-004**: A successfully authenticated request MUST receive one immutable actor context containing the stable account identity, the authentication method (`jwt` or `api_key`), and the corresponding verified token or key identifier.
- **FR-005**: Actor context MUST contain no password, complete credential, signing material, stored hash, unverified claim, role, or inferred permission.
- **FR-006**: Protected application behavior MUST run only after successful authentication and MUST receive actor context rather than a caller-supplied account identifier or raw credential as proof of identity.
- **FR-007**: Missing, blank, malformed, repeated, unsupported, invalid, expired, unknown, or revoked credentials MUST produce one generic unauthenticated response and MUST NOT execute the protected application behavior.
- **FR-008**: A request that supplies both supported credential forms, or multiple values for either form, MUST be rejected as unauthenticated without attempting to prefer one credential or revealing which credential is valid.
- **FR-009**: The unauthenticated response MUST use HTTP status 401 and one stable machine-readable error code. JWT failures, API-key failures, missing credentials, and ambiguous credentials MUST be indistinguishable in response status and body.
- **FR-010**: A 401 response MUST include a standards-compatible Bearer authentication challenge and MUST NOT echo credentials, account identifiers, key/token identifiers, validation causes, or internal errors.
- **FR-011**: Public API routes MUST remain callable without credentials, MUST NOT require actor context, and MUST ignore supplied authentication credentials rather than validate them or attach an actor.
- **FR-012**: Authentication processing MUST NOT log, emit in telemetry, return, or place in request-visible diagnostics any complete JWT, API-key secret, stored verification material, unverified claim, account identity, or token/key identifier. Operational signals MAY identify the route policy, selected authentication method after unambiguous selection, generic outcome, and duration.
- **FR-013**: Authentication MUST occur at one shared API boundary before controllers or application operations, and route handlers MUST NOT independently parse or validate supported credentials.
- **FR-014**: Automated tests MUST cover both successful methods, missing credentials, every malformed/repeated/ambiguous header class, invalid/expired JWTs, unknown/revoked API keys, generic 401 equivalence, public-route behavior, actor-context shape, protected-operation non-execution, and non-disclosure in responses, logs, telemetry, and inspection.
- **FR-015**: This feature MUST be limited to API request authentication and actor propagation. Credential issuance, login, registration, API-key lifecycle, authorization roles or permissions, ownership/business rules, refresh/logout/revocation policy for JWTs, rate limiting, browser sessions, LiveView authentication, and OpenAPI publication are outside scope.

### Key Entities

- **Authenticated Actor**: A trusted, request-scoped representation of the verified account, authentication method, and credential identifier. It conveys identity and provenance, not authorization.
- **Route Authentication Policy**: The explicit classification of an API route as public or protected and the consistent authentication behavior applied before route handling.
- **Presented Credential**: One transient JWT or API-key secret received in its designated header and used only to obtain a verified identity from the owning authentication capability.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In automated verification, 100% of protected-route requests with exactly one valid supported credential reach the protected operation with the correct account, method, and credential identifier; 0% of rejected requests reach it.
- **SC-002**: In automated verification, 100% of missing, malformed, repeated, ambiguous, invalid, expired, unknown, and revoked credential cases return the same 401 status and machine-readable error body with no actor context.
- **SC-003**: In automated verification, 100% of designated public-route requests proceed without credentials, and supplied credential headers produce no actor context or credential-validation dependency call.
- **SC-004**: Inspection of authentication responses, actor context, errors, logs, telemetry, and diagnostics finds zero complete JWTs, API-key secrets, stored verification material, unverified claims, or identity identifiers outside the protected in-process actor context allowed by this specification.
- **SC-005**: Under normal local operating conditions, at least 95% of authentication pipeline decisions for either supported method complete within one second.
- **SC-006**: A route-policy audit accounts for 100% of API routes as explicitly public or protected, with zero route handlers independently parsing or validating JWTs or API keys.
- **SC-007**: Review finds no authorization policy, new credential issuance or lifecycle behavior, browser/LiveView authentication, rate limiting, or OpenAPI publication introduced by this feature.

## Assumptions

- TASK-008 provides authoritative active-key identification returning an account identity and key identifier; TASK-009 provides authoritative JWT validation returning an account identity and token identifier.
- `Authorization: Bearer` and `X-API-Key` are the sole credential transports for this CP1 feature. Credentials in query parameters, cookies, request bodies, or alternate headers are unsupported.
- Requests with both credential types are rejected because choosing one could hide configuration mistakes and create inconsistent attribution.
- Public routes do not offer optional authentication in this task. A future feature may define optional actor enrichment if a concrete product need arises.
- Route authentication establishes identity only. Domain operations remain responsible for their own business rules, and later tasks may add explicit authorization requirements.
