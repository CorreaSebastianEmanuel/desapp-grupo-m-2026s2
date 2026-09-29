# ADR-0010: LiveView Browser Sessions Carry the Accounts Access Token

**Status**: Accepted

**Date**: 2026-09-29

**Scope**: LiveView frontend (application shell, authentication, catalog, and API-key screens)

## Context

The frontend is built only with Phoenix LiveView. Browser pages need a signed-in user, but Accounts already owns credential verification (`login/1`, dummy Argon2 work for unknown emails, one generic failure) and short-lived HS256 access tokens (ADR-0005). A LiveView cannot write cookies, and adding a persisted browser-session table would introduce a new migration and revocation model.

## Decision

- A minimal `UserSessionController` handles only `POST /users/log-in` and `DELETE /users/log-out`; every rendered page is a LiveView.
- Login delegates to `Accounts.login/1` and stores the issued access token in the session cookie, which is now signed **and encrypted**. The session ID is renewed on login and logout to prevent fixation.
- `FootballMarketWeb.UserAuth` revalidates the token through Accounts on every dead render, LiveView mount, `handle_params`, and `handle_event`. The token is captured by LiveView hooks, never assigned, so it cannot be rendered or pushed to the client.
- Logout broadcasts `disconnect` to the session's `live_socket_id`, closing open LiveViews.
- Catalog and account screens require authentication, matching the protected REST API. Development gets its own dev-only JWT configuration; production still requires runtime secrets.

## Consequences

- A browser session lasts exactly as long as its access token (15 minutes) and then asks the user to log in again. There is no refresh or server-side revocation before expiry.
- No migration, table, dependency, or cache is added; UI authentication and API authentication share one verification path.
- Login throttling and broader hardening remain in TASK-050.

## Rejected alternatives

- A persisted session-token table (`phx.gen.auth` style): adds persistence and a second revocation model outside current scope.
- Storing only the user ID in the cookie: no expiry, and it bypasses the timing-safe Accounts login path.
- Auto-login right after registration via `phx-trigger-action`: requires echoing the password back into the form; the user logs in explicitly instead.
