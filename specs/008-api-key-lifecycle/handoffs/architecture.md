# Architecture handoff: API key lifecycle

- `Accounts.register_user/1` already converts database failures into a reconstructed safe result. Follow that pattern for key issuance, but avoid rescuing a broad failure after a successful insert because the caller must never receive a secret for an uncertain commit outcome.
- `User.public_projection/1` currently returns only ID and email. Keep API-key associations out of that projection and out of ordinary account retrieval; a schema preload would make later inspection more likely to expose credential metadata.
- Cast management IDs safely before Ecto queries. A malformed UUID should reach the documented non-disclosing result rather than raising `Ecto.Query.CastError` with query details.
- The existing repository telemetry metrics aggregate durations without tags. Inspect any new handler or exporter for parameter forwarding; the risk is at that integration boundary, beyond application-written log messages.
- Reuse `AccountsCase` and the SQL Sandbox for lifecycle tests. Assert route absence through `Phoenix.Router.routes/1`, so the check reflects registered routes rather than source-text comments.
