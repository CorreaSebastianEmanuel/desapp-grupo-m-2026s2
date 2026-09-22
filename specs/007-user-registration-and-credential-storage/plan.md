# Implementation Plan: User Registration and Credential Storage

**Branch**: `007-user-registration-and-credential-storage` | **Date**: 2026-09-22 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/007-user-registration-and-credential-storage/spec.md`

## Summary

Implement an internal `Accounts` domain context that registers a user from normalized email and an unchanged password, persists the user plus a one-to-one Argon2id credential atomically in PostgreSQL, and exposes credential verification for later authentication. PostgreSQL is authoritative for race-safe normalized-email uniqueness. This task deliberately adds no HTTP endpoint, router entry, LiveView, UI, session, token, API key, or login behavior.

## Technical Context

**Language/Version**: Elixir `~> 1.20.3`; OTP 29.0.6 baseline

**Primary Dependencies**: Phoenix 1.8, Ecto SQL 3.13, Postgrex, and new `argon2_elixir` 4.1.3

**Storage**: PostgreSQL via `FootballMarket.Repo`; Redis is not used

**Testing**: ExUnit, Ecto SQL Sandbox, existing `mix test` alias

**Target Platform**: Phoenix modular-monolith service on local/server BEAM runtime

**Project Type**: Web application with an internal domain contract only

**Performance Goals**: Valid local registration completes within the specified 30 seconds; password hashing intentionally dominates the operation

**Constraints**: Password is never normalized, logged, displayed, or persisted as plaintext/reversible data; all failures are atomic; no external UI/API surface; configuration follows [ADR-0003](../../docs/adr/0003-user-credential-protection-and-email-identity.md)

**Scale/Scope**: One Accounts context, two PostgreSQL tables, one migration, and focused unit/integration tests; no authentication workflow

## Constitution Check

### Pre-design gate: PASS

| Principle | Evidence / decision |
|---|---|
| Specification before implementation | The plan maps the normalized email, password policy, non-disclosure, verification, and atomicity rules directly to FR-001 through FR-014. |
| Domain integrity | Accounts holds registration/credential rules; neither web nor catalog code owns them. PostgreSQL constraints and a transaction protect identity and partial-state invariants. |
| Modular simplicity | Remains a single Phoenix/Ecto modular monolith; adds only the Argon2 library needed for secure password hashing. No new service or infrastructure. |
| Evidence-based quality | Focused ExUnit tests cover every stated behavior, database uniqueness/race handling, rollback, and public non-disclosure before the full suite. |
| Independent verification | Product challenge findings are resolved here; recorded human feedback confirms the canonical spec and completed product handoffs. No unapproved material decision remains. |

### Post-design gate: PASS

The data model, internal contract, quickstart, and ADR preserve the same boundaries. The durable security and identity choice is recorded in ADR-0003. No constitution violation or unresolved clarification remains.

## Design

### Domain and persistence boundary

1. Create `FootballMarket.Accounts` as the sole public domain entry point for this feature, with `User` and `PasswordCredential` persistence schemas under `lib/football_market/accounts/`.
2. `register_user/1` accepts email and password, normalizes only email, validates all requirements before hashing, creates an Argon2id hash, and uses `Ecto.Multi` to insert the user and credential together.
3. `verify_password/2` finds the internal credential by user ID and uses Argon2 verification. It returns only a boolean and neither returns nor logs credential data.
4. Return a public user projection (`id`, normalized `email`) from registration and ordinary lookup paths. Keep `PasswordCredential` private to Accounts persistence/verification code.

### Validation and durable invariants

- Trim and lowercase email before checking it. Require a non-empty local part and domain, prohibit whitespace, and require valid dot-separated domain labels. Do not perform DNS/delivery validation.
- Preserve password bytes/text exactly as submitted. Require 12–128 characters and reject all-whitespace values; do not trim it.
- Create `users` with UUID primary key, nonblank email constraint, and named unique functional index on `lower(btrim(email))`.
- Create `password_credentials` with `user_id` as both primary key and foreign key plus a non-null `password_hash`.
- Attach the named index as an Ecto unique constraint so both normal and concurrent duplicate attempts produce an `:email` error. Use `Ecto.Multi` so validation, collision, or credential failure leaves no partial write.

### Credential protection

- Add locked `argon2_elixir` 4.1.3. Use Argon2id with production values `t_cost: 2`, `m_cost: 65536`, `parallelism: 1`, 16-byte salt, and 32-byte hash; use documented low-cost test-only parameters without changing algorithm/format.
- Do not put a password field on User; pass the supplied password directly from the Accounts boundary to hashing/verification, avoiding changeset persistence and logging.
- Do not serialize, inspect, include in errors, audit messages, or return the hash/salt/credential. Registration errors contain only user-correctable field/duplicate messages.

### Tests

- Unit-test email normalizing/validation and the exact password rules, including both length boundaries and preservation of leading/trailing/internal spaces.
- Integration-test successful registration, public result shape, stored normalized email, exactly one credential, correct-password verification, and distinct-password rejection.
- Test blank/malformed email; blank, too-short, too-long, and all-whitespace password; no rows after every rejected attempt.
- Test exact, case-only, and surrounding-whitespace duplicates, then a concurrent attempt or direct database-conflict path to prove the functional index—not a pre-check—governs uniqueness.
- Force a second `Ecto.Multi` operation to fail and assert both tables remain unchanged. Assert returned user values/errors and normal inspect/serialization paths contain neither plaintext password nor hash.

## Project Structure

### Documentation (this feature)

```text
specs/007-user-registration-and-credential-storage/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── accounts-context.md
└── handoffs/
    └── architecture.md
```

### Source Code (repository root)

```text
lib/football_market/
├── accounts.ex
├── accounts/
│   ├── user.ex
│   └── password_credential.ex
└── repo.ex

priv/repo/migrations/
└── *_create_users_and_password_credentials.exs

config/
├── config.exs
└── test.exs

test/football_market/accounts/
├── accounts_test.exs
├── user_test.exs
└── password_credential_test.exs
```

**Structure Decision**: Extend the existing context/schema/migration/test layout. Accounts remains separate from web, catalog, infrastructure, and external adapters; only the internal domain contract is added for later authentication consumers.

## Complexity Tracking

No constitution violation requires a complexity exception. The added password-hashing dependency and functional index are the smallest controls that satisfy the security and race-safety requirements; ADR-0003 records them.
