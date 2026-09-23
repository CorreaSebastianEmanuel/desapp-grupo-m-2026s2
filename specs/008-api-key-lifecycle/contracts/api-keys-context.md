# Internal Accounts API Key Contract

This is an application/domain interface for trusted code. It is not an HTTP, LiveView, or OpenAPI contract. The account ID passed to issuance or revocation must come from a trusted caller; a future authenticated web adapter must derive it from authenticated context.

## Issue

`Accounts.issue_api_key(user_id)`

| Result | Meaning |
|---|---|
| `{:ok, %{id: key_id, secret: secret}}` | One active key was durably inserted for the existing user. The raw secret appears in this result once. |
| `{:error, :issuance_failed}` | No key was issued; no secret or verification material is returned. Applies to missing/deleted owner, digest conflict, or insertion failure. |

`secret` is a canonical 43-character unpadded Base64URL string encoding 32 independently random bytes. `key_id` is a UUID management reference and is not part of the secret.
The implementation returns this result only after `Repo.insert/2` succeeds; a confirmed foreign-key, uniqueness, or trigger rejection returns the safe error.

## Identify

`Accounts.identify_api_key(presented_secret)`

| Result | Meaning |
|---|---|
| `{:ok, %{account_id: user_id, key_id: key_id}}` | The complete presented secret matched one active key. |
| `{:error, :invalid_key}` | Malformed, non-text, empty, altered, unknown, or revoked secret. No account is identified and no record-existence detail is revealed. |

No result contains the presented secret, stored digest, credential schema, or email. A key ID by itself returns `{:error, :invalid_key}`.

## Revoke

`Accounts.revoke_api_key(user_id, key_id)`

| Result | Meaning |
|---|---|
| `:ok` | This user owns the key; it is now revoked or was already revoked. |
| `{:error, :not_found}` | The ID is unknown, malformed, or belongs to another user; no key changes. |

After the update commits, every later database identification read rejects the former secret. An already running identification can observe the preceding active state if its read occurred before that commit. No timing-equivalence promise is part of any failure result.
Both owner and key identifiers are cast before querying; malformed identifiers follow the same failure result.
