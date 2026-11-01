# Practical frontend

## Outcome

Refresh the existing home, sign-in, portfolio, conditional orders and API documentation routes with a restrained, useful, responsive design. Add public browser registration through the existing Accounts boundary. Preserve authentication, trading rules and existing data contracts.

## Acceptance

- [ ] Given a visitor registers with valid details, when account creation succeeds, then they reach sign-in without receiving credits or API credentials; invalid or duplicate registrations receive a generic error.
- [ ] Given a developer activates repository tools with mise, when Node is resolved, then it selects v24.22.1 from `.tool-versions`; CI stays on the Node 24 release line.
- Home links work for sign-in, portfolio, orders and API documentation without fabricated market data.
- Sign-in preserves CSRF, return destination, field labels, autocomplete and error semantics.
- Registration at `/register` is linked from home and sign-in, accepts normalized email and confirmed password under the existing 12–128 character policy, never repopulates password fields, and redirects successful creation to sign-in with a notice. Invalid or duplicate details return a generic error without email enumeration.
- Registration preserves CSRF and origin checks, non-cacheable responses, and does not issue API credentials or tokens.
- Workspace preserves session hooks, private data boundary, identity, active navigation, logout, position values and conditional order lifecycle.
- Responsive layouts, visible keyboard focus and contained narrow-screen table scrolling keep workflows readable.
- Conditional orders explain non-reservation and UTC expiry. Player selection searches the local catalog, shows team and league, and submits only the selected catalog ID.
- Documentation keeps Swagger and credential controls functional with a return link.
- Controller tests cover entry links and registration success/rejection; LiveView tests prove explicit player selection and ID submission; existing session and portfolio regressions pass; desktop and narrow layouts are inspected in a local worktree server.

## Scope

Existing browser routes and public registration, including focused tests and responsive styling. Pin the repository-local Node toolchain to v24.22.1 to align local workflows with CI's Node 24 release line. Existing local TASK-032 changes are a separate baseline and remain separately attributable.

## Non-goals

Full catalog detail and ranking screens, new trading flows beyond the existing conditional order form, charts, translations, email verification, automatic login after registration, account recovery, and changes to financial calculations.

## Risk

High: browser authentication, registration, session handling and trading UI are in scope. Registration must reuse Accounts validation and credential storage; no credit issuance, financial behavior, or credential leakage may be introduced. Product decision dated 2026-10-28 allows public self-registration while returning new users to sign-in.
