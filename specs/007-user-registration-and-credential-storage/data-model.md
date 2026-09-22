# Data Model: User Registration and Credential Storage

## User

| Field | Type | Rules |
|---|---|---|
| `id` | UUID | Primary key, generated once and stable. |
| `email` | text | Required; persist only the trimmed, lowercase email. PostgreSQL uniquely indexes `lower(btrim(email))`. |
| `inserted_at`, `updated_at` | UTC microsecond timestamps | Framework-managed audit timestamps. |

The public user representation contains only `id` and `email`; it has no password or credential fields.

## PasswordCredential

| Field | Type | Rules |
|---|---|---|
| `user_id` | UUID | Primary key and foreign key to `users`; one credential per user. |
| `password_hash` | text | Required Argon2id encoded hash only; never selected into public user results. |
| `inserted_at`, `updated_at` | UTC microsecond timestamps | Framework-managed audit timestamps. |

## Relationships and invariants

```text
User (1) ---- (1) PasswordCredential
```

- Registration validates both input values before persistence, then inserts both records in one transaction.
- An invalid email/password, duplicate normalized email, or failed credential insert rolls back all rows created by that attempt.
- Email identity is normalized before validation and comparison. Password text is evaluated exactly as supplied; whitespace counts as characters, but an all-whitespace value is invalid.
- The functional unique index is named so the context can turn a database race conflict into the same field-level email error as a normal duplicate.

## State transitions

`unsubmitted -> validated -> registered` is the only successful transition. Every error returns to `unsubmitted` with no persistent user or credential state. Login, credential change/reset, confirmation, and profile states are not modeled.
