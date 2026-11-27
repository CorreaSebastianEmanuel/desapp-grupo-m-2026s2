# Accounts Context Contract

This is an internal domain contract for later authentication work. It is not an HTTP, LiveView, router, or OpenAPI contract.

## Register a user

`Accounts.register_user(%{email: email, password: password})`

| Outcome | Meaning |
|---|---|
| `{:ok, user}` | Creates one user and one credential atomically. `user` exposes stable `id` and normalized `email` only. |
| `{:error, changeset}` | Creates neither record. Errors are attached to `:email` or `:password`; an email collision is reported on `:email`. |

- `email` must be a binary. Surrounding whitespace is trimmed and identity is lowercased before validation.
- `password` must be a binary of 12 through 128 characters and not all whitespace. It is otherwise unchanged.
- No outcome contains the submitted password, hash, salt, or credential struct.
- Error changesets are reconstructed from the normalized email and field messages only; submitted password values and credential persistence data are not retained as changeset parameters.

## Verify a password

`Accounts.verify_password(user_id, submitted_password) :: boolean`

Returns `true` only when the supplied password verifies against the stored credential for that user; returns `false` for a distinct password or a missing credential. It accepts the password unchanged and exposes no credential material. It does not issue a session, token, API key, authorization decision, or user-facing response.
