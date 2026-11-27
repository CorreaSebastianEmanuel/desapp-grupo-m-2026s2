# Data Model: JWT Login and Validation

No migration or new persisted entity is required. The feature reads the TASK-007 account/credential model and introduces transient authentication values.

## Existing User Account

- `id`: UUID; stable token subject.
- `email`: normalized trimmed lowercase identity; unique in PostgreSQL.
- `password_credential`: one-to-one protected Argon2 hash, accessed only through Accounts verification.

Rules: login normalizes only email. The submitted password is passed exactly as received. Neither the password nor hash enters returned projections, tokens, errors, logs, or telemetry.

## JWT Access Token (transient compact string)

| Claim/header | Type | Rule |
|---|---|---|
| `alg` | header string | exactly `HS256`; `none` and every other method rejected |
| `typ` | header string | JWT library standard header; never trusted for algorithm selection |
| `sub` | UUID string | authenticated existing user ID at issuance; required and format-validated |
| `jti` | UUID string | new unpredictable value for every successful login; required |
| `iat` | integer | injected clock's Unix second at issuance; required; cannot be future |
| `exp` | integer | exactly `iat + 900`; required; invalid when `exp <= now` |
| `iss` | string | exact trusted configured issuer; required |
| `aud` | string | exact trusted configured audience; required |
| `nbf` | integer | not issued by this feature; if present on an otherwise valid token, cannot exceed `now` |

The compact token is never persisted. Its claims are untrusted until signature, algorithm, configuration-bound values, required fields, formats, and time rules all pass.

## Login Result (transient)

- Success: `%{access_token: binary}` inside `{:ok, result}`.
- Failure: `{:error, :authentication_failed}` with no account/token data.

Transition: valid normalized account lookup + exact password verification + valid signing configuration → one newly signed token. Every other path → generic failure and no token.

## Token Validation Result (transient)

- Success: `%{account_id: uuid, token_id: uuid}` inside `{:ok, result}`.
- Failure: `{:error, :invalid_token}` with no decoded claim data.

Transition: untrusted token → full cryptographic and claim verification → verified identity result. Failure of any check is terminal and generic. Validation does not load or mutate a User Account.
