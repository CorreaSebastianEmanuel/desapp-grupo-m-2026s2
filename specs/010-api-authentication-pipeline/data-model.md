# Data Model: API Authentication Pipeline

This feature adds no persisted entity or migration. PostgreSQL models from TASK-008 and JWT claims validated by TASK-009 remain owned by those capabilities.

## Authenticated Actor

Request-scoped trusted value created only after credential verification.

| Field | Type | Rules |
|---|---|---|
| `account_id` | UUID string | Required; copied only from a successful Accounts validator result |
| `authentication_method` | `:jwt \| :api_key` | Required; derived from the single selected header type |
| `credential_id` | UUID string | Required; verified JWT `jti` or persisted API-key management ID |

The actor contains no raw credential, password, hash, signing material, claim set, role, permission, email, or loaded persistence schema. Elixir data is immutable; the struct uses enforced keys and is assigned once to the connection as `:authenticated_actor`.

## Route Authentication Policy

Structural classification represented by router pipeline membership rather than persistence.

| Value | Behavior |
|---|---|
| `public` | JSON API processing only; credentials ignored; no actor or authentication event |
| `protected` | Shared authentication Plug runs before the handler; success assigns an actor; failure halts |

For every application-owned route whose path is `/api` or starts `/api/`, exactly one policy is required. Intentional public routes additionally appear as `{HTTP verb, path}` entries in the route-audit allowlist.

## Presented Credential

Transient web-adapter input; never persisted or placed in actor context.

| Variant | Transport | Valid structural shape | Trusted operation |
|---|---|---|---|
| JWT | one `Authorization` field | case-insensitive `Bearer` scheme plus exactly one non-empty opaque token | `Accounts.validate_access_token/1` |
| API key | one `X-API-Key` field | one unchanged opaque value; canonical format enforced by owner | `Accounts.identify_api_key/1` |

### Decision states

```text
received
├── no supported header ------------------------------> rejected (401)
├── repeated header or both credential forms --------> rejected (401)
├── one malformed credential ------------------------> rejected (401)
└── one structurally valid credential -> delegated validation
    ├── trusted failure ------------------------------> rejected (401)
    └── trusted identity -> actor assigned -----------> authenticated
```

Rejection is terminal and the connection is halted. Authentication success grants identity only; authorization state is deliberately absent.
