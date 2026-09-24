# Feature Specification: JWT Login and Validation

**Feature Branch**: `009-jwt-login-and-validation`

**Created**: 2026-09-23

**Status**: Draft

**Input**: TASK-009: "Authenticate users and issue validated, expiring JWT access tokens."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log In with Account Credentials (Priority: P1)

As a registered market user, I can submit my email address and password and receive an access token so that later protected operations can recognize my account.

**Why this priority**: Credential-based login and token issuance are the minimum behavior that makes registered accounts usable for authenticated API access.

**Independent Test**: Register an account through TASK-007, log in with a case or surrounding-whitespace variant of its email and the exact password, and verify that one access token is returned for that account without exposing credentials.

**Acceptance Scenarios**:

1. **Given** an existing account and its correct password, **When** the user submits its email and password, **Then** authentication succeeds and one access token identifying that account is returned.
2. **Given** an existing account, **When** the user submits a case-only or surrounding-whitespace variation of its email and the correct password, **Then** authentication succeeds for the same account.
3. **Given** an unknown email or an incorrect password, **When** login is attempted, **Then** authentication fails with the same generic outcome and no token is issued.

---

### User Story 2 - Validate an Access Token (Priority: P2)

As a later request-authentication capability, I can validate a presented access token and obtain the account identity it represents so that authenticated requests can be attributed safely.

**Why this priority**: A token has no authentication value unless its origin, integrity, intended use, required claims, and validity period are checked before its identity is trusted.

**Independent Test**: Issue a token through a successful login, validate it during its lifetime, and verify that validation returns the correct account identity and token identifier without returning credentials or signing material.

**Acceptance Scenarios**:

1. **Given** an access token issued by this system that is within its validity period and unchanged, **When** it is validated for this application, **Then** validation succeeds and returns the represented account identity and token identifier.
2. **Given** a token whose content or signature has been altered, **When** it is validated, **Then** validation fails without identifying an account.
3. **Given** a structurally valid token issued for a different issuer or audience, or using an unaccepted signing method, **When** it is validated, **Then** validation fails without identifying an account.

---

### User Story 3 - Enforce Token Expiration (Priority: P3)

As an account owner, I need an issued access token to stop authenticating after a short, predictable lifetime so that exposure of the token does not grant indefinite access.

**Why this priority**: Expiration bounds credential risk and is explicitly required for CP1, while relying on the same issuance and validation behavior as the first two stories.

**Independent Test**: Issue a token using a controlled clock, validate it immediately, advance to its expiration boundary, and verify that it is rejected from that point onward.

**Acceptance Scenarios**:

1. **Given** a newly issued token, **When** it is inspected, **Then** its expiration is 15 minutes after its issuance time.
2. **Given** a token before its expiration instant, **When** it is validated, **Then** it may authenticate its represented account.
3. **Given** a token at or after its expiration instant, **When** it is validated, **Then** validation fails without identifying an account.

### Edge Cases

- Blank, malformed, non-text, or incomplete email, password, or token input fails without raising an externally visible internal error or issuing a token.
- Email input follows TASK-007 identity normalization, while the submitted password is verified exactly as supplied and is never trimmed or normalized.
- Unknown-email and incorrect-password attempts have the same externally observable result and do not reveal whether an account exists.
- A token is rejected if it is malformed, unsigned, signed with an unaccepted method or key, altered, expired, not yet valid, intended for another issuer or audience, or missing an account identity, unique token identifier, issuance time, or expiration time.
- The expiration boundary is exclusive: a token whose expiration time equals the validation time is expired.
- Future issuance times and optional not-before times beyond a small configured clock-skew allowance are rejected; the same allowance applies consistently at time boundaries.
- Repeated successful logins issue distinct token identifiers even when performed by the same account within the same time unit.
- Login and validation results, errors, logs, and telemetry never expose passwords, complete access tokens, or signing material.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST authenticate an existing user account from its normalized email identity and a password verified through the credential-verification capability supplied by TASK-007.
- **FR-002**: Login MUST normalize email input consistently with registration and MUST verify the password exactly as submitted without trimming, normalizing, recording, or returning it.
- **FR-003**: A successful login MUST issue exactly one signed JWT access token representing the authenticated account. A failed login MUST issue no token.
- **FR-004**: Unknown-email, incorrect-password, blank, malformed, and otherwise invalid login submissions MUST produce the same generic authentication-failure outcome and MUST NOT disclose whether an account exists.
- **FR-005**: Every issued access token MUST contain the stable account identity as its subject, a unique token identifier, an issuance time, an expiration time, and the configured issuer and audience.
- **FR-006**: Every issued access token MUST expire 15 minutes after issuance. The validity duration MUST be measured from the recorded issuance instant and MUST NOT be extended by validation or use.
- **FR-007**: Each successful login MUST produce a new unpredictable token identifier; two successful logins MUST NOT issue tokens with the same identifier.
- **FR-008**: Validation MUST verify token structure, cryptographic integrity, accepted signing method, trusted signing key, issuer, audience, required claims, and time validity before returning an identity.
- **FR-009**: Validation MUST return only the stable account identity and token identifier when every check succeeds. It MUST NOT treat unverified token content as an authenticated identity.
- **FR-010**: Validation MUST reject malformed, incomplete, unsigned, altered, expired, prematurely valid, wrongly issued, wrongly targeted, or incorrectly signed tokens with one generic invalid-token outcome and without identifying an account.
- **FR-011**: A token MUST be considered expired at or after its expiration instant. Time validation MAY use one consistently applied configured clock-skew allowance of no more than 60 seconds for issuance and not-before checks, but MUST NOT extend the expiration instant.
- **FR-012**: Passwords, complete access tokens, and signing material MUST NOT appear in authentication or validation errors, ordinary results other than the successful login token field, logs, telemetry, audit output, or inspected account representations.
- **FR-013**: Signing material MUST come from trusted runtime configuration and MUST NOT be embedded in source code, fixtures committed as production configuration, token claims, or user input. Missing or invalid signing configuration MUST prevent issuance and successful validation without exposing the material.
- **FR-014**: Automated tests MUST cover successful normalized-email login, exact-password handling, generic failure and non-enumeration behavior, token uniqueness and required claims, valid-token identity, every stated invalid-token class, exact expiration boundaries, controlled time behavior, configuration failure, and non-disclosure boundaries.
- **FR-015**: This feature MUST be limited to credential login, JWT access-token issuance, and standalone token validation. Route protection, credential transport conventions, authorization, roles or permissions, refresh tokens, logout, token revocation or denylisting, password recovery, login throttling or lockout, API-key authentication, and user-interface flows are outside scope.

### Key Entities

- **User Account**: The durable market-user identity and password-verification boundary supplied by TASK-007; its stable identity becomes the access token subject.
- **JWT Access Token**: A signed, short-lived credential carrying the subject account, unique token identifier, issuance and expiration times, issuer, and audience. Its claims are trusted only after complete validation.
- **Token Validation Result**: A safe result containing the verified account identity and token identifier, or a generic invalid-token outcome with no actor identity.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In automated verification, 100% of valid registered-user credential submissions, including supported email-normalization variants, return one token for the correct account; 0% of invalid submissions return a token.
- **SC-002**: In automated verification, 100% of unchanged, correctly issued tokens validate to the correct account during their lifetime, while 0% of tested malformed, altered, incorrectly signed, wrongly issued, wrongly targeted, incomplete, premature, or expired tokens identify an account.
- **SC-003**: Every tested token is valid before its expiration instant and invalid at and after that instant, with a recorded lifetime of exactly 15 minutes.
- **SC-004**: Across at least 1,000 successful login issuances in automated verification, every token identifier is unique.
- **SC-005**: Under normal local operating conditions, at least 95% of login and token-validation attempts complete within one second each.
- **SC-006**: Inspection of authentication results, failures, logs, telemetry, and account representations finds zero passwords, signing secrets, or complete tokens outside the successful login token field.
- **SC-007**: Review finds no route-protection, authorization, refresh-token, revocation, logout, lockout, API-key-authentication, or user-interface behavior introduced by this feature.

## Assumptions

- TASK-007 supplies durable accounts, normalized email lookup, and password verification. This feature does not alter registration or credential-storage policy.
- A 15-minute access-token lifetime is the conservative CP1 default. Refresh and revocation are intentionally deferred, so users obtain another token by authenticating again after expiration.
- Issuer, audience, accepted signing method, trusted signing key, and any clock-skew allowance are deployment configuration selected during planning; all are fixed by trusted configuration rather than caller-controlled input.
- Token validation establishes authentication identity only. TASK-010 decides how a caller presents a token, which routes require authentication, and how verified actor context reaches the application.
- Account status, roles, and permissions are not currently defined by the product or TASK-007 and therefore are not encoded as login eligibility or token authority in this feature.
