# Browser interface contract

All routes use the browser pipeline, escaped HTML and existing CSRF protection. REST/OpenAPI credential policy stays ADR-0006; these HTML routes do not enter the REST contract.

| Method and route | Authority | Outcome |
| --- | --- | --- |
| GET /sign-in | Public | 200 labelled email/password form and fresh CSRF; valid authenticated cookie redirects 303 to Portfolio/allowlisted destination without renewal. |
| POST /sign-in | CSRF + pre-login session | Valid existing credentials: commit new authority, rotate cookie/CSRF, 303 to exact safe return or Portfolio. Invalid: 422 same generic failure and empty password. Backend unavailable: 503 safe retry, no new authority. Valid authenticated cookie: ignore credentials, 303 current account's safe workspace. Retired anonymous authority fails closed. |
| POST /sign-out | CSRF + current browser authority | Commit idempotent revocation then 303 sign-in and clear cookie; connected tabs lose private state. Missing/ended authority safely redirects. Unavailable revocation: 503 concealed retry view, retained HttpOnly retry handle; never claim success. |
| GET /portfolio | Valid browser authority | 200 common shell, account email, Portfolio heading/active item, honest unavailable-content notice. Otherwise 303 sign-in with safe return; expiry includes ended notice. Validation unavailable: safe 503, no private content. |
| GET /conditional-orders | Valid browser authority | Same protection/shell with Conditional orders heading/active item and honest availability notice. |

GET /sign-out does not mutate or end a session (safe 404). GET /sign-in never establishes authenticated authority. Missing/invalid CSRF or rejected Origin on state-changing HTTP requests is 403 with safe HTML and no authority change. Preserve framework websocket origin/CSRF protections; forged socket connections fail. Unknown routes return safe 404 with validated safe navigation, never resource contents; denied test resources return 403 with safe recovery.

Request form fields: email, password, _csrf_token, return_to. No account_id is accepted. Exact safe returns: `/portfolio` and `/conditional-orders`; all other values fall back to Portfolio, including external/protocol-relative URLs, encoding tricks, backslashes, query/fragment suffixes and malformed values. Return state is validated at capture and use. Password is never echoed, even for validation errors.

Protected HTML and sign-in/error responses carrying identity/session state use Cache-Control: no-store. Cookie is signed/encrypted, HttpOnly, SameSite=Lax, path=/, Secure in deployment; max-age is bounded to the fixed deadline but database time is authority. Websocket connect_info receives the cookie server-side; raw handle must not enter signed LiveView mount payloads or client-readable storage. Session renewal does not reset an authenticated deadline.

Shared shell: account email as text; one main heading; semantic nav with one aria-current=page item; keyboard-operable ordinary POST sign-out form; visible focus. Feedback has an announced region, associated field errors and retry/sign-in/safe-navigation controls. Use expired, invalid, unavailable, disconnected, denied and missing message kinds, no stack traces. Viewport 1280x800 has no horizontal scrolling.

LiveView contract: validate on disconnected access, connected mount, reconnect, params/events and private result handling. Subscribe then revalidate; enforce expires_at exclusively, timer plus <=1-second status validation. Clear assigns/private DOM before full sign-in redirect. On disconnect conceal content/disable dependent controls; destroy stale connection and reload authoritative state before revealing content, without replay. pagehide/pageshow handling prevents bfcache restoring identity after logout or account switch. No raw authority, credentials or business mutations in client events. Test harness probes remain test-only.
