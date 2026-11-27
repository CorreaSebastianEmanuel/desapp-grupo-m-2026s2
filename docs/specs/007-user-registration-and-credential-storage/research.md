# Research: User Registration and Credential Storage

## Password verification

**Decision**: Add `argon2_elixir` 4.1.3 and use Argon2id with a random salt. Store only its encoded hash; verify a submitted password through the library's password-verification function.

**Rationale**: The library provides separate hash and verification operations, and Argon2id is the appropriate conservative variant for password storage. Production cost is fixed by [ADR-0003](../../docs/adr/0003-user-credential-protection-and-email-identity.md); test cost is deliberately lower only to keep automated tests practical. The password is never trimmed, normalized, logged, returned, or persisted outside the hash operation.

**Alternatives considered**:

- Bcrypt: established but less memory-hard than the selected Argon2id approach.
- A general digest or encryption: violates the requirement for non-recoverable, non-reusable credential material.
- Deferring the algorithm/cost: leaves the critic's security-boundary finding unresolved.

## Normalized email uniqueness and atomic writes

**Decision**: Normalize email in the Accounts domain and enforce `lower(btrim(email))` uniqueness in PostgreSQL. Insert the user and its credential in a single `Ecto.Multi` transaction; translate the named unique-index conflict into a correctable email error.

**Rationale**: A validation-time lookup alone cannot prevent concurrent inserts. The functional index independently preserves the observable normalization rule, while the transaction rolls back either row on validation, conflict, or persistence failure.

**Alternatives considered**:

- Application-only lookup before insert: race-prone.
- Case-insensitive database collation: platform/configuration-dependent and does not directly express trimming.
- Separate non-transactional inserts: can leave partial state.

## Email validation and public boundary

**Decision**: Use a conservative email validator after trimming: one non-empty local part, one non-empty domain, no whitespace, and valid dot-separated domain labels. Expose registration and verification only through the internal Accounts context; do not add a controller, router entry, LiveView, or OpenAPI operation.

**Rationale**: The specification requires syntactically identifiable addresses, not delivery verification or the full complexity of every RFC mailbox form. A small deterministic validator supplies field-specific feedback and is straightforward to test. A domain contract serves the later authentication feature without accidentally expanding this task into a user-facing flow.

**Alternatives considered**:

- Delivery/DNS validation: network-dependent and outside scope.
- A permissive nonblank `@` check: does not establish a valid local part and domain.
- An HTTP registration API/UI: explicitly deferred by FR-014.
