# Architecture handoff: API authentication pipeline

- `Plug.Conn.get_req_header/2` returns all field occurrences. Count them before parsing; never use a helper that silently selects the first value. Treat a single comma-containing/coalesced value as opaque and invalid through the method-specific parser/validator.
- Keep the Bearer parser deliberately small. Scheme matching is case-insensitive, but pass token bytes unchanged to `Accounts.validate_access_token/1`; do not call `Joken.peek_claims/1` or decode claims in the web layer.
- The API-key branch must call `Accounts.identify_api_key/1`, whose database query already uses `log: false`. Do not alias the private `ApiKey` schema or `Repo` from the Plug.
- Send the generic JSON body directly from the Plug so unrelated changes to `ErrorJSON` cannot drift the security contract. Set the Bearer challenge on every application-level authentication failure, including API-key failures, to keep responses equivalent.
- Put the probe router/controller in `test/support` only. Its protected action should signal invocation independently of its response so tests can prove rejected requests never cross the boundary.
- Route auditing should use `Phoenix.Router.routes/1`, filter only `/api` and `/api/*`, verify exactly one named policy pipeline, and compare public `{verb, path}` pairs with an explicit allowlist. Avoid source-comment matching for route classification.
- Telemetry assertions should attach a temporary handler and inspect the complete metadata map for sentinel IDs/credentials. Detach it in `on_exit`; capture Logger output separately.
- Risk: future refactoring may bypass the named pipelines while preserving similar plugs. The route-table audit is the durable guard; update the ADR and audit together if policy representation changes.
