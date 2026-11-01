# Practical frontend

User request: review localhost:4000 and improve existing routes in a worktree with a restrained, useful design.

Product decision (2026-10-28): allow public self-registration from the browser. Registration uses the existing Accounts validation and persistence boundary; successful registration returns the user to sign-in. Do not add email verification, automatic login, balances, credit issuance or account recovery in this task.

- Home offers working links to sign-in, portfolio, orders and API documentation. No fabricated prices, charts, players or metrics.
- Sign-in preserves CSRF, return destination, field labels, autocomplete and error semantics.
- Public registration is available at `/register`, linked from the home page and sign-in page. It accepts a normalized email and password with confirmation, applies the existing 12–128 character password policy, and never repopulates password fields. A successful account creation redirects to sign-in with a confirmation notice; invalid or duplicate details produce a generic form error without disclosing whether an email is already registered.
- Registration remains inside the existing browser protections: CSRF and origin checks, non-cacheable responses, and no API credentials or tokens are issued to the browser.
- Workspace preserves session hooks, private data boundary, identity, active navigation, logout, position values and conditional order lifecycle.
- A shared light palette, dark green navigation, compact typography, responsive layouts and visible keyboard focus make the existing workflows readable. Tables scroll within their container on narrow screens.
- Conditional orders explain non-reservation and UTC expiry alongside the form. Player selection searches the local catalog by name, shows team and league, and writes only the selected catalog ID into the order terms.
- Documentation keeps Swagger and credential controls functional with a return link.

Scope excludes full catalog detail and ranking screens, new trading flows beyond the existing conditional order form, charts, translations, email verification, automatic login after registration, account recovery and changes to financial calculations. Existing local TASK-032 changes are copied as the working baseline and remain separately attributable.

Acceptance: controller tests verify real entry links, registration success and rejection without credential disclosure; order LiveView proves name search, explicit result selection and ID submission; existing session and portfolio regressions pass; inspect desktop and narrow layouts in a local worktree server.
