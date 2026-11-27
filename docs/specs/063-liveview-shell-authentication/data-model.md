# Browser session model

Existing Account and PasswordCredential remain owned by Accounts and unchanged in meaning (ADR-0003). No roles, balance, inventory or financial entities are introduced.

## BrowserSession — browser_sessions

- id: generated UUID primary key, nonsecret internal reference.
- user_id: nullable users foreign key; required only for authenticated sessions. Deleted accounts must never validate; use restrictive FK and explicit joined lookup.
- token_digest: unique non-null 32-byte SHA-256 of random 32-byte opaque handle; raw handle is never stored or inspected.
- state: anonymous | authenticated | revoked; constrained in PostgreSQL.
- started_at: UTC microsecond timestamp; authenticated sign-in instant, immutable after insert.
- expires_at: UTC microsecond timestamp; authenticated = started_at + 900 seconds, enforced in DB and context. Anonymous form sessions also have a bounded 900-second lifetime, without authenticated authority.
- revoked_at: nullable UTC microsecond timestamp, consistent with revoked state.
- inserted_at/updated_at: standard UTC microsecond timestamps.

Indexes: unique token_digest; user_id; expires_at. Constraints require authenticated rows to reference an account and have the fixed lifetime; anonymous rows have no user. Transition anonymous -> revoked and insert authenticated row occurs under row lock in one transaction. If a second submission uses the retired anonymous handle it receives no session. Fresh authenticated handles are never derived from pre-login handles.

Authenticated -> revoked is idempotent, committed before success. Expiry is derived from now >= expires_at, not dependent on a worker updating a row. No sliding updates, renewals or automatic refresh. A valid authenticated submission to sign-in keeps the same account/session/deadline and ignores replacement credentials. Unavailable writes yield no new authority and no successful sign-out acknowledgement. No cleanup worker is required; future retention cleanup must preserve active correctness.

## Internal projections

Browser actor: account_id, normalized email and session_id, produced only by Accounts after digest/status/deadline/account validation. Session reference alone does not authenticate an HTTP request/socket. Validation returns ok | invalid | expired | unavailable; credential verification returns ok account | invalid_credentials | unavailable. No hashes/passwords/handles appear in projections, errors or telemetry. PubSub topic uses nonsecret session UUID and termination messages contain no credential or private resource data.

WorkspaceDestination: exact allowlist `/portfolio`, `/conditional-orders`; unknown/external/encoded/query/fragment variants fall back to `/portfolio`. Feedback is a fixed safe kind plus recovery action, never raw exception text. Access-denied resource probes are test-only and derive identity from trusted actor.
