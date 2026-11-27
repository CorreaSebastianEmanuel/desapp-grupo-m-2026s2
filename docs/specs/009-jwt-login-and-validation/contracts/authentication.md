# Internal Authentication Contract

This contract is the domain-facing interface consumed by TASK-010. It is not an HTTP/OpenAPI contract and creates no route.

## Log in

`FootballMarket.Accounts.login(attrs)`

- Input: a map with binary `email` and binary `password` values.
- Success: `{:ok, %{access_token: token}}`, where `token` is one complete signed JWT.
- Failure: `{:error, :authentication_failed}` for invalid shape, blank/malformed values, unknown email, wrong password, or inability to issue safely.
- Email is normalized using TASK-007 rules. Password is verified byte-for-byte as supplied.
- The contract never returns an account-existence distinction, password, hash, signing material, internal cause, or partial token.

## Validate token

`FootballMarket.Accounts.validate_access_token(token)`

- Input: one binary compact JWT.
- Success: `{:ok, %{account_id: account_uuid, token_id: jti_uuid}}` only after all signature and claim checks pass.
- Failure: `{:error, :invalid_token}` for every non-binary, malformed, altered, incomplete, wrong-method, wrong-key, wrong-issuer, wrong-audience, premature, future-issued, or expired token and for invalid trusted configuration.
- Failure never returns decoded claims or an actor identity.
- Validation is standalone and performs no account lookup; an issued token remains cryptographically valid until its exact expiration boundary.

## Adapter obligations

A later web adapter must map each error atom to one stable public status/body, avoid logging request credentials or complete tokens, and never accept caller-selected signing configuration. Those transport choices are outside this feature.
