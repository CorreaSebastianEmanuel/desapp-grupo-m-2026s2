# Implementation Plan: JWT Login and Validation

**Branch**: `009-jwt-login-and-validation` | **Date**: 2026-09-23 | **Spec**: `specs/009-jwt-login-and-validation/spec.md`

**Input**: Feature specification from `specs/009-jwt-login-and-validation/spec.md`

## Summary

Extend the existing `FootballMarket.Accounts` boundary with credential login and standalone JWT validation. Login reuses TASK-007 normalized lookup and Argon2 verification, performs a dummy Argon2 verification for unknown accounts, and returns one generic public failure. A small authentication component uses Joken/JOSE and one trusted HS256 runtime configuration to issue 15-minute tokens and validate their signature, fixed algorithm, issuer, audience, required claims, UUID identities, and exact time boundaries. Validation is cryptographic only: it does not query the account or add revocation, authorization, transport, or web routes.

## Technical Context

**Language/Version**: Elixir 1.20.3 on OTP 29  
**Primary Dependencies**: Phoenix 1.8.13 application; Ecto 3.13/Postgrex for account lookup; Argon2 Elixir 4.1.3 for real and dummy password verification; Joken 2.7 with JOSE for JWT signing and verification  
**Storage**: Existing PostgreSQL `users` and `password_credentials`; no new table or migration  
**Testing**: ExUnit, Ecto SQL Sandbox, deterministic injected UTC clock and UUID/JTI generator, log capture, property-style mutation fixtures, and a documented local benchmark  
**Target Platform**: Existing Linux/Phoenix server and local macOS/Linux development environments  
**Project Type**: Modular-monolith web service; this feature exposes an internal context contract and no HTTP route  
**Performance Goals**: Documented warm local benchmark p95 below one second for login and standalone validation; correctness tests remain environment-independent  
**Constraints**: 900-second lifetime; integer Unix-second NumericDate claims; zero clock skew; `exp <= now` is invalid; fixed HS256 only; runtime secret at least 32 bytes; generic safe errors; no secret/token logging; no database lookup during token validation  
**Scale/Scope**: One Accounts context extension, one authentication module/config boundary, one dependency, configuration, and focused unit/integration/security tests; no UI, controller, plug, or schema changes

## Constitution Check

*GATE: Passed before research and re-checked after design.*

- **Specification before implementation — PASS**: all design decisions trace to FR-001–FR-015; critic findings are resolved in `research.md`, and no clarification remains.
- **Domain integrity — PASS**: account identity and TASK-007 credential rules are reused; no market, audit, or monetary rules change.
- **Modular simplicity — PASS**: work remains inside the modular monolith and existing Accounts/domain/configuration boundaries; no service, cache, worker, route, or persistence model is added.
- **Evidence-based quality — PASS**: `quickstart.md` defines automated correctness, security, boundary, configuration, leak, and local benchmark evidence.
- **Independent verification — PASS**: the product challenge was synthesized, the product decision says no human check is required, and no `backlog/feedback/TASK-009.md` exists.
- **Safety and delivery — PASS**: secrets come from runtime configuration; committed test material is explicitly non-production; no push, merge, or destructive operation is planned.

Post-design re-check: **PASS**. The internal contract, data model, quickstart, and ADR preserve the same boundaries. There are no unjustified constitution violations.

## Design Decisions

### Authentication boundary

- Add login and token validation entry points to `FootballMarket.Accounts`; delegate JWT mechanics to `FootballMarket.Accounts.Authentication` so persistence, password verification, and token cryptography remain separately testable.
- Login accepts only a map containing binary `email` and `password`. Email lookup keeps TASK-007 trim/lowercase normalization; password bytes are passed unchanged to Argon2.
- Unknown users run `Argon2.no_user_verify/0`; known users run the stored-hash verification. All invalid shapes, unknown users, and wrong passwords return `{:error, :authentication_failed}`. Internal cause distinctions are not returned or logged.
- Successful login returns `{:ok, %{access_token: token}}`. The complete token occurs only in this explicit result field.

### Token issuance and validation

- Use Joken 2.7/JOSE with one explicitly constructed HS256 signer. Do not accept an algorithm, key, issuer, audience, time, subject, or JTI from caller input.
- Read issuer, audience, and a Base64-encoded key of at least 32 decoded bytes from application runtime configuration. Production startup fails on missing/invalid configuration; issuance and validation also fail closed with safe errors if configuration is unavailable. Tests use an unmistakably test-only key in `config/test.exs`.
- Use one injected UTC clock that returns Unix seconds. At issuance, `iat = now` and `exp = iat + 900`; `jti` is a newly generated UUID string and `sub` is the account UUID string. All six claims (`sub`, `jti`, `iat`, `exp`, `iss`, `aud`) are required.
- Apply zero skew. Validation rejects `iat > now`, `nbf > now` when `nbf` is present, and `exp <= now`; no leeway may extend expiration. Reject non-integer time claims, malformed UUID `sub`/`jti`, wrong/missing claims, and every method except HS256.
- After complete verification, return `{:ok, %{account_id: sub, token_id: jti}}`; otherwise return `{:error, :invalid_token}`. Never use decoded-but-unverified claims in a result.
- Do not query PostgreSQL during validation. Deletion or later account changes do not invalidate an already-issued token; it remains valid until `exp`. Revocation is deliberately absent.

### Verification boundaries

- Contract tests assert identical public result shape for every login failure and invalid-token class. Review additionally confirms the unknown-account path performs dummy hash work; exact constant-time behavior and brittle timing comparisons are rejected.
- Leak tests use sentinel email/password/key/token values and capture application-owned return values, raised/configuration errors, Logger output, inspected authentication structures, and emitted authentication telemetry metadata. They assert no password, key, or complete token outside the successful `access_token` field.
- SC-005 is a reproducible local benchmark, not a CI correctness gate: one seeded user, local PostgreSQL, test Argon2 cost, sequential calls, 10 warm-ups, 100 measured login attempts and 1,000 measured validations, monotonic timing, nearest-rank p95, and recorded environment/configuration.
- The 1,000-token uniqueness check uses the production UUID generator with a fixed clock. Other claim-boundary tests inject deterministic clocks and generators.

## Rejected Alternatives

- **Phoenix.Token or hand-built JOSE calls**: either lacks the explicit standard JWT claim contract or duplicates claim-policy plumbing already supplied by Joken.
- **RS256/key pairs or key rotation now**: add deployment and key-selection complexity not required by CP1; one HS256 key is the smallest compliant trusted configuration. Rotation can be introduced behind the same boundary later.
- **Positive clock skew**: unnecessary inside this monolith and weakens deterministic boundary semantics. Zero is permitted by FR-011 and preserves exact expiration.
- **Per-validation account lookup**: creates undeclared account-state/revocation semantics and database coupling contrary to standalone validation.
- **Hard timing-equality or CI performance assertions**: flaky and incapable of proving constant time. Public equivalence plus dummy Argon2 work is stable evidence.
- **Controllers, plugs, OpenAPI paths, throttling, refresh/revocation, or authorization**: explicitly belong to later integration/security work and violate FR-015 here.

## Project Structure

### Documentation (this feature)

```text
specs/009-jwt-login-and-validation/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── authentication.md
└── handoffs/
    └── architecture.md

docs/adr/
└── 0005-jwt-signing-and-validation-boundary.md
```

### Source Code (repository root)

```text
config/
├── runtime.exs                         # production JWT environment parsing
└── test.exs                            # explicitly test-only JWT configuration

lib/football_market/
├── accounts.ex                         # public login/validation orchestration
└── accounts/
    └── authentication.ex               # claims, signer, issue/verify policy

test/football_market/accounts/
├── authentication_test.exs             # deterministic claim and validation tests
├── authentication_security_test.exs    # generic errors, mutation, leaks, config
└── authentication_performance_test.exs # tagged/manual reproducible benchmark
```

**Structure Decision**: Extend the existing Accounts context rather than create a new application or web layer. Authentication owns only credential orchestration and token policy; Ecto remains behind Accounts, runtime configuration remains in `config/`, and TASK-010 will adapt this internal contract to HTTP.

## Complexity Tracking

No constitution violations require justification.
