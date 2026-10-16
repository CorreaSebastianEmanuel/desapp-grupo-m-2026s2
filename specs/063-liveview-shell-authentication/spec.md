# Feature Specification: Authenticated Application Shell

**Feature Branch**: `046-liveview-application-shell-and-authentication`

**Created**: 2026-10-15

**Status**: Draft

**Input**: TASK-046 — LiveView application shell and authentication, CP2; depends on TASK-010.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sign in to my workspace (Priority: P1)

As an existing market user, I can sign in with my email and password and enter a workspace identified as my account.

**Why this priority**: Charts and conditional orders need trusted identity before displaying private information.

**Independent Test**: Sign in with an existing account, reload, and compare successful access with invalid credentials and direct unauthenticated access.

**Acceptance Scenarios**:

1. **Given** an existing account, **When** I submit the correct password and a supported case or surrounding-whitespace variation of its email, **Then** I enter that account's workspace; the password is verified exactly as entered.
2. **Given** an unknown email, incorrect password, or blank/malformed credentials, **When** I submit sign-in, **Then** I remain signed out, receive the same generic failure without confirmation of account existence, and the password is cleared.
3. **Given** no valid session, **When** I open a protected destination directly, **Then** I reach sign-in without receiving private content.
4. **Given** a valid session, **When** I reload or visit sign-in, **Then** I enter my workspace without another prompt and see my account email.

---

### User Story 2 - Navigate the CP2 workspace (Priority: P2)

As a signed-in user, I can move between Portfolio and Conditional orders and understand where I am.

**Why this priority**: A common shell provides entry points for subsequent CP2 features.

**Independent Test**: Visit both areas through navigation and direct addresses; verify identity, headings and the active destination.

**Acceptance Scenarios**:

1. **Given** successful sign-in without a requested destination, **When** the workspace opens, **Then** Portfolio is the landing area and navigation includes Portfolio, Conditional orders, account email and Sign out.
2. **Given** either area, **When** I select the other or visit its address directly, **Then** it has a meaningful heading, the same shell and one active navigation indication.
3. **Given** a feature not yet implemented, **When** I open its area, **Then** availability text explains its status without invented financial data or controls implying a working transaction.
4. **Given** I requested a known protected destination before sign-in, **When** I authenticate, **Then** I reach it; an external, malformed or unknown return destination instead leads to Portfolio.

---

### User Story 3 - End or recover my visit (Priority: P1)

As an account owner, I can sign out and recognize session termination or connection loss without exposing my data to another user.

**Why this priority**: Interactive pages need authentication throughout their lifetime.

**Independent Test**: Use controlled time, two browser tabs and two users to exercise sign-out, expiry, reconnect and account switching.

**Acceptance Scenarios**:

1. **Given** an authenticated visit, **When** I sign out, **Then** I reach sign-in, its session cannot authenticate again, and its connected workspace tabs lose access and private content.
2. **Given** an authenticated visit, **When** its fixed 15-minute lifetime ends, **Then** connected workspaces return to sign-in with a session-ended notice; further navigation, interaction or reconnection cannot read or change private data until a new sign-in.
3. **Given** a disconnected workspace, **When** I reconnect with a valid session, **Then** identity is checked again and the area reloads current persisted state; an ended or invalid session instead leads to sign-in.
4. **Given** account A signed out, **When** B signs in in the same browser and uses navigation or browser history, **Then** no private content or identity belonging to A is restored.

---

### User Story 4 - Understand failures (Priority: P2)

As a user, I receive understandable feedback and a safe recovery action when access or connectivity fails.

**Why this priority**: Shared feedback keeps later feature screens consistent.

**Independent Test**: Trigger unavailable authentication, connection loss, a missing destination and a denied resource; inspect messages and recovery controls.

**Acceptance Scenarios**:

1. **Given** unavailable authentication, **When** I attempt sign-in, **Then** no session is established and a temporary-unavailability message offers retry without internal details.
2. **Given** a connected workspace, **When** connectivity is lost, **Then** a visible notice appears and connection-dependent actions are unavailable; reconnection does not replay mutations automatically.
3. **Given** an unknown destination or denied resource, **When** I request it, **Then** a safe not-found or access-denied outcome offers workspace navigation (or sign-in if unauthenticated), without another user's data.
4. **Given** feedback appears, **When** I use a keyboard or assistive reader, **Then** I can find the message and recovery action, and field errors are associated with their fields.

### Edge Cases

- Missing, tampered, expired or otherwise invalid sessions fail closed on load, connection establishment, reconnection and protected interactions.
- Expiry is exclusive at the exact expiration instant; navigation does not extend it. Disconnected tabs cannot learn of remote termination immediately, but must clear private content before resuming protected access.
- Altering an account identifier in a destination, form or interactive message cannot change the actor or grant another account's resources.
- Repeated sign-out is safe. Ending this browser session does not end independent browser sessions or revoke separately issued API credentials.
- Unavailable authentication is distinguishable from invalid credentials, but reveals no account existence and grants no access.
- Untrusted identity and error text cannot execute content; return destinations cannot send the user outside the known workspace.
- Forged or cross-site state-changing submissions cannot sign users in, sign them out or perform protected actions.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Provide a public email/password sign-in form for existing accounts and a protected workspace. Reuse existing identity normalization and credential verification; verify passwords exactly as entered. Invalid submissions MUST yield the same generic failure, establish no session and clear the password.
- **FR-002**: Successful sign-in MUST replace pre-login session authority with new authenticated authority for exactly one existing account. Caller-supplied identity, navigation parameters or API credentials alone MUST NOT establish browser authentication.
- **FR-003**: Browser sessions MUST expire exactly 15 minutes after successful sign-in, without sliding renewal or automatic refresh. Validate session authority on initial access, connection establishment, reconnection and before protected interactions; connected workspaces MUST also end at expiry without waiting for a user action.
- **FR-004**: Sign-out MUST invalidate the current browser session, terminate its connected workspaces, clear private rendered state and return to sign-in. Replaying previous session authority or reconnecting MUST NOT restore access. Independent browser sessions and API credentials retain their existing lifecycle.
- **FR-005**: Every workspace destination MUST require authentication before returning private content. Missing, invalid or ended sessions MUST reach sign-in; expired visits MUST include a session-ended notice. Temporary validation failures MUST fail closed with safe retry guidance.
- **FR-006**: Only trusted session identity MUST establish the actor for private reads/actions. Caller-controlled account identifiers MUST NOT override it. Missing accounts MUST fail authentication, and another user's resource MUST be denied without disclosing its contents.
- **FR-007**: The common shell MUST show account email, Portfolio and Conditional orders navigation, the current destination, a main heading and Sign out. Portfolio MUST be the default destination. Preserve a requested known local protected destination through sign-in; all other return values MUST fall back to Portfolio.
- **FR-008**: Both destinations MUST support direct access and share authentication behavior. Unimplemented feature areas MUST show honest availability text without sample financial data or working-looking business actions. Charts, analytics, trading and order creation/cancellation/execution MUST remain separately owned features.
- **FR-009**: Passwords, raw session authority, complete access tokens, API-key secrets and signing material MUST NOT appear in page content, addresses, client-readable storage, errors, logs, telemetry or diagnostics. Session transport MUST prevent script access and cross-site submission abuse and require encrypted transport in deployment; local development MAY use local unencrypted transport.
- **FR-010**: State-changing browser submissions, including sign-in and sign-out, MUST reject forged/cross-site requests. Visiting a link alone MUST NOT establish authentication or sign out a user. Pre-login session authority MUST NOT become reusable authenticated authority.
- **FR-011**: Shared feedback MUST cover invalid credentials, ended sessions, temporary service failure, connection loss, access denial and missing destinations. Each outcome MUST offer sign-in, retry or safe navigation as appropriate, without stack traces, credentials or private resource details. Render untrusted content as text.
- **FR-012**: Connection loss MUST be visible and prevent connection-dependent actions. Reconnect MUST revalidate identity and reload current authoritative persisted state rather than trust stale private state or replay mutations. Account switching MUST clear the previous workspace state; browser history MUST NOT restore ended private content.
- **FR-013**: Sign-in, navigation, sign-out and recovery controls MUST support keyboard operation, accessible labels and visible focus. Feedback MUST be announced to assistive readers; field errors MUST identify their fields. At 1280 by 800 pixels, these controls MUST be usable without horizontal scrolling. Broader responsive polishing remains CP3.
- **FR-014**: Existing public pages and public/protected API policies MUST retain their behavior. Browser sessions MUST NOT silently authenticate API requests or change JWT/API-key precedence, issuance, expiration or revocation rules.
- **FR-015**: Automated acceptance coverage MUST exercise every story and edge case, using controlled time, two users and two tabs for lifecycle/isolation. Include forged submissions, tampered/replayed authority, safe returns, shared errors and API authentication regressions. Browser-level checks MUST exercise sign-in, navigation, sign-out and private-content removal.

### Key Entities

- **Account**: Existing durable user identity, normalized email and credential-verification capability; no new roles or permissions.
- **Browser Session**: Authority associated with one account, a fixed start/expiry and an ended status, shared by the browser's workspace tabs.
- **Workspace Destination**: Protected Portfolio or Conditional orders area with a heading and navigation state, independent of later feature content.
- **User Feedback**: Safe access, connection or navigation outcome and its available recovery action.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of valid credential acceptance cases enter the correct workspace; zero invalid or forged cases grant access or expose private content.
- **SC-002**: Every tested session stops authorizing access at exactly 15 minutes; 100% of sign-out replay/reconnection cases remain signed out. Connected tabs remove private content and return to sign-in within two seconds of expiry or confirmed sign-out under normal local conditions.
- **SC-003**: Each CP2 area is reachable in one navigation selection from the other; all direct-address and safe-return tests show the correct destination and account.
- **SC-004**: All account-switch, altered-account, reconnect and browser-history tests expose zero data from another user or an ended visit.
- **SC-005**: Every specified failure presents an understandable outcome and usable recovery action; inspection finds zero secrets or internal diagnostics in user-visible output and operational evidence.
- **SC-006**: The complete sign-in, two-area navigation and sign-out journey works using only a keyboard at the specified desktop viewport, with all controls, fields and feedback programmatically identifiable.

## Assumptions

- TASK-010 is complete and owns existing API policy. TASK-007/009 supply accounts and authentication. The conservative fixed browser lifetime follows the existing 15-minute authentication lifetime; browser sign-out adds no API-token revocation policy.
- Sources: `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, `docs/CHECKPOINTS.md`, `docs/CP2_ARCHITECTURE.md`, ADR-0017 and the constitution. TASK-057/058 own analytics/charts; TASK-059/060/061 own conditional-order semantics, evaluation and UI. This specification does not approve the proposed order rules in ADR-0017.
- Existing project capabilities provision accounts. Registration UI, password recovery, remember-me, refresh, SSO, MFA, throttling, role management and global sign-out are outside this task.
- The two-second connected-tab target assumes a functioning local application and connection. Disconnected tabs enforce termination on resuming communication; offline private operations are unsupported.
- Exact addresses, styling, session representation and component structure remain planning choices constrained by these behaviors and existing architecture. No new infrastructure is required.
