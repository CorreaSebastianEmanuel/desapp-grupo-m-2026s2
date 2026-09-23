# Data Model: API Key Lifecycle

## Existing User

`users.id` is the existing UUID account identity from TASK-007. One user may own zero or more API keys. Ordinary user projections remain `{id, email}` and contain no key data.

## API Key

| Field | Type | Rules |
|---|---|---|
| `id` | UUID | Primary key; opaque, stable management reference generated independently of the secret. |
| `user_id` | UUID | Required foreign key to `users.id`; never changes. |
| `secret_hash` | 32-byte binary (`bytea`) | Required SHA-256 digest of the complete issued secret; unique across every key row, including revoked rows; private to persistence and matching. |
| `inserted_at` | UTC microsecond timestamp | Required creation time. |
| `revoked_at` | Nullable UTC microsecond timestamp | Null means active; non-null means revoked permanently. |

The table stores no raw secret, reversible ciphertext, key prefix, or second credential copy. The issuance result alone includes the raw secret. The schema's inspection hides `secret_hash`; ordinary context results are explicit projections, never the schema struct.

## Relationships and invariants

```text
User (1) ---- (0..n) API Key
```

- A successful insert has an existing owner and a unique digest. A rejected insert leaves no row and returns no secret.
- The unique digest index remains effective after revocation, preventing a duplicate usable secret from being stored later.
- `api_keys_secret_hash_32_bytes` checks digest length in PostgreSQL, and `api_keys_secret_hash_index` is unique across all rows.
- A key ID is not a secret and does not identify an actor. Identification uses the complete canonical secret and active state.
- Revocation is scoped by both `id` and `user_id`. Other keys and other owners' keys are unchanged.

## State transitions

```text
absent --successful issuance--> active --owner revocation--> revoked
active --issuance/revocation failure--> active
revoked --repeated owner revocation--> revoked
```

There is no revoked-to-active transition, expiration state, automatic rotation, or physical deletion in this task. For an in-flight identification, the database read determines whether it observes the state before or after a committed revocation.
