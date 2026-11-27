# Tasks: Authenticated Application Shell

**Input**: spec.md, plan.md, research.md, data-model.md, contracts/browser.md, quickstart.md and ADR-0026. TASK-046 only; actual branch 046-liveview-application-shell-and-authentication.
**Tests**: Required by FR-015 and repository rules. Write and observe relevant failing assertions before each behavioral implementation; then make them pass. Use isolated two-account fixtures and test-only clock/failure controls. Every ExUnit module declares exactly one :unit or :integration profile tag. All tasks are initially unchecked because this stage produces design only.
**Paths**: Relative to repository root. Generated migration timestamp wildcard identifies one new migration; implementation chooses its unique timestamp. [P] means independent files within the stated phase, not permission to bypass predecessors.

## Phase 1: Setup

- [X] T001 Verify pinned toolchain/services/browser prerequisites using `scripts/check_toolchain.sh`, `scripts/local_services.sh` and `tools/openapi/package-lock.json`; install existing locked dependencies/Chromium and build assets with `mix.exs` aliases without introducing a new toolchain.
- [X] T002 Create isolated shared-sandbox runtime fixtures, injectable microsecond clock, lifecycle action probes and backend-failure controls in `test/support/browser_session_case.ex`; use two Accounts users, test-only modules and ephemeral listener, never production control endpoints.

## Phase 2: Foundational (blocks every story)

- [X] T003 Write failing digest/status/schema/900-second/exclusive-boundary/account-deletion/anonymous-retirement/concurrent-login tests in `test/football_market/accounts/browser_sessions_test.exs` and pure return-validation tests in `test/football_market_web/browser_return_test.exs`; cover deadline minus one microsecond, exact deadline and after, tampered/replayed authority, missing user and DB outages.
- [X] T004 Add `lib/football_market/accounts/browser_session.ex` and `priv/repo/migrations/*_create_browser_sessions.exs` with the fields, FK, indexes and DB constraints in data-model.md; persist digests only, conceal secrets in Inspect and query logs.
- [X] T005 Add `lib/football_market/accounts/browser_sessions.ex` and Accounts entry points in `lib/football_market/accounts.ex` for anonymous creation, transactional row-locked retirement/new authority, trusted validation by cookie digest, internal bound-reference revalidation, fixed clock and idempotent revocation; publish only after commit, return safe invalid/expired/unavailable distinctions and make T003 pass.
- [X] T006 Add exact destination allowlist and trusted projection helpers in `lib/football_market_web/plugs/browser_auth.ex`; reject arbitrary account IDs and decode/URL tricks, make pure return tests pass and keep API pipelines separate.

## Phase 3: US1 — Sign in to my workspace (P1, first demonstration increment)

**Goal**: Existing credentials enter only their own authenticated workspace.
**Independent test**: Correct normalized email/exact password succeeds, generic invalid credentials clear password, direct private access fails, reload/valid-session sign-in retains identity/deadline.

- [X] T007 [P] [US1] Write failing credential, normalization, exact-password and browser-unavailable/API-compatibility tests in `test/football_market/accounts/browser_credentials_test.exs`; assert unknown/malformed/wrong credentials do not disclose account existence.
- [X] T008 [P] [US1] Write failing form, CSRF/Origin, cookie rotation, forged identity/API-credentials-only, direct-access and authenticated-stale-form tests in `test/football_market_web/controllers/session_controller_test.exs`; inspect decoded LiveView payloads for raw authority and assert 422/503/303 contracts.
- [X] T009 [US1] Factor reusable browser credential verification in `lib/football_market/accounts.ex` while retaining existing API login/validation return values and telemetry; reuse normalized-email lookup/Argon2 and make T007 pass without issuing a browser JWT.
- [X] T010 [US1] Implement sign-in form/controller in `lib/football_market_web/controllers/session_controller.ex`, `lib/football_market_web/controllers/session_html.ex` and `lib/football_market_web/controllers/session_html/new.html.heex`; validate current cookie before submitted credentials, ignore stale replacement credentials for authenticated users, rotate pre-login authority/CSRF only after commit and clear passwords on failure.
- [X] T011 [US1] Wire separate browser routes/guards in `lib/football_market_web/router.ex`, cookie/connect_info options in `lib/football_market_web/endpoint.ex`, deployment transport settings in `config/prod.exs`, secret filtering in `config/config.exs` and test clock configuration in `config/test.exs`; set encrypted signed HttpOnly/SameSite cookie and no-store, with Secure in deployment.
- [X] T012 [US1] Add protected mount and minimal Portfolio entry in `lib/football_market_web/live/browser_auth.ex` and `lib/football_market_web/live/workspace_live.ex`; disconnected render uses trusted HTTP projection, connected render independently validates server-side cookie connect_info, never serialized authority; run T008 and existing API/page regressions to green.

## Phase 4: US3 — End or recover my visit (P1)

**Goal**: Revocation, exclusive expiry and reconnection preserve account isolation.
**Independent test**: Controlled time plus two tabs/users proves exact authorization denial and separately <=2-second connected removal, committed logout/replay denial, truthful failed invalidation and no stale identity restoration.

- [X] T013 [P] [US3] Write failing LiveView tests in `test/football_market_web/live/browser_session_lifecycle_test.exs` for exact expiry on events/params/info/async, missed PubSub, subscribe/revoke race, missing users, validation outage, independent sessions/API credentials and no deadline renewal; use test-only probes rather than product mutations.
- [X] T014 [P] [US3] Write failing real-browser lifecycle scenarios in `tools/openapi/workspace_browser.mjs` and launcher `test/football_market_web/workspace_browser_test.exs` for two-tab logout/expiry, stale sign-in forms, account switching/history including bfcache, offline expiry/reconnect, persisted-state refresh and no queued event replay; use safe category-only output and real measured <=2-second removal, not just route assertions.
- [X] T015 [US3] Extend revocation/failure HTTP tests in `test/football_market_web/controllers/session_controller_test.exs` before adding POST sign-out in `lib/football_market_web/controllers/session_controller.ex`; commit before cookie deletion/success, retain HttpOnly retry authority on 503, conceal local state, make repeated sign-out safe and preserve other sessions/API credentials.
- [X] T016 [US3] Implement subscribe-then-revalidate, fixed-deadline timer, <=1-second status validation, guarded params/events/private results and state-clearing redirects in `lib/football_market_web/live/browser_auth.ex` and `lib/football_market_web/live/workspace_live.ex`; reject at exact deadline independently of display timer and make T013 pass.
- [X] T017 [US3] Implement lifecycle concealment, pagehide/pageshow validated reload, disconnect disablement and teardown-before-reload recovery in `assets/js/workspace_session.js` wired by `assets/js/app.js`; remove private DOM before history snapshot and never replay buffered events or store authority/private state in Web Storage; make T014 lifecycle cases pass.

## Phase 5: US2 — Navigate the CP2 workspace (P2)

**Goal**: Both direct-address destinations share an honest, clearly identified shell.
**Independent test**: Navigate either way in one selection, direct-load both areas, inspect single active item/account/heading and test exact allowlisted returns versus hostile variants.

- [X] T018 [P] [US2] Write failing route/shell/placeholder/safe-return tests in `test/football_market_web/live/workspace_navigation_test.exs`, including external/encoded/unknown/query/fragment returns and no invented finance data or transactional controls.
- [X] T019 [P] [US2] Add failing direct-access and one-selection navigation scenarios to `tools/openapi/workspace_browser.mjs`; assert correct account and heading on each destination and after safe/unsafe sign-in returns.
- [X] T020 [US2] Implement shared shell and honest availability components in `lib/football_market_web/components/workspace_components.ex`, destination selection in `lib/football_market_web/live/workspace_live.ex` and protected routes in `lib/football_market_web/router.ex`; provide account email, Portfolio default, Conditional orders, one active indication and POST Sign out; make T018/T019 pass without chart/order/trading behavior.

## Phase 6: US4 — Understand failures (P2)

**Goal**: Every failure has safe accessible recovery.
**Independent test**: Inject auth outage/disconnection/denial/missing destination; verify recoverable text, escaped content and keyboard-only 1280x800 flow with no horizontal scroll.

- [X] T021 [P] [US4] Write failing failure/secret-disclosure/escaping tests in `test/football_market_web/browser_feedback_test.exs` with captured logs/telemetry and decoded mount payloads; use test-only owned-resource denial probes to verify trusted actors, no cross-account data, safe 403/404/503 and recovery links without adding a product resource route.
- [X] T022 [P] [US4] Add failing outage/offline/recovery and keyboard/accessibility scenarios in `tools/openapi/workspace_browser.mjs`; assert field labels/error associations, live announcements, visible focus, action disablement, no horizontal scroll at 1280x800, password clearing and no secrets in DOM/URL/storage/network diagnostic output.
- [X] T023 [US4] Implement shared safe feedback/not-found/access-denied outcomes in `lib/football_market_web/components/workspace_components.ex`, `lib/football_market_web/controllers/error_html.ex`, `lib/football_market_web/controllers/session_html/new.html.heex`, `lib/football_market_web/live/workspace_live.ex` and `assets/css/app.css`; conceal on validation failure, escape text and supply accessible recovery/focus; make T021/T022 pass.

## Phase 7: Polish, developer acceptance and independent gates

- [X] T024 Write failing real-listener HTTP assertions then implement their test harness in `test/football_market_web/workspace_http_runtime_test.exs` using `test/support/browser_session_case.ex`; assert readiness before requests and every status/header/body/cookie contract in contracts/browser.md for GET/POST sign-in, POST sign-out, both areas, rejected GET sign-out, safe unknown routes, CSRF/Origin and outage paths. Verify `/` and `/docs` remain public and session cookies alone leave `/api/players` at 401 with existing JWT/API-key precedence unchanged.
- [X] T025 Integrate all new suites into existing discovery with one module profile tag per file in `test/football_market/accounts/browser_sessions_test.exs`, `test/football_market_web/workspace_http_runtime_test.exs` and `test/football_market_web/workspace_browser_test.exs`; ensure the browser launcher builds assets, performs real HTTP readiness assertions, runs all four stories and lifecycle controls, and fails for absent browser/services/assets rather than skipping. Preserve `test/support/test_profile_audit.ex` rules and existing coverage/CI safeguards; do not create a duplicate full-suite gate.
- [X] T026 Reconcile `specs/063-liveview-shell-authentication/verification.json` with final concrete tests and update `specs/063-liveview-shell-authentication/quickstart.md` for any routine implementation path changes; keep all FR/SC obligations and service/runtime assertions, review PRODUCT invariants and CP2 ownership, then freeze all source/design edits before final receipts.
- [X] T027 Execute every manifest check via `scripts/agentflow_check.py` (preflight, format, compile, openapi, unit, integration, foundation, feature, javascript, ci), record helper outcomes and elapsed time in `specs/063-liveview-shell-authentication/handoffs/develop.md` under 400 words, reconcile completed tasks against named files, and run `scripts/workflow_artifact_probe.py develop --readiness`. No historical CP1 report; the existing exact CI runner is repeated only to verify PR #39's demonstrated CI-only failure as documented in plan.md, without adding a second CI job.
- [X] T028 Independent QA [gate:qa] reruns `specs/063-liveview-shell-authentication/verification.json` independently without developer receipt reuse, challenges requirement mappings and all four critic findings, and writes `specs/063-liveview-shell-authentication/qa-report.md` plus `specs/063-liveview-shell-authentication/handoffs/qa.md` ending the report exactly with Verdict: PASS only if satisfied.
- [X] T029 Final review [gate:review] uses fresh independent QA evidence, reviews alignment/security/invariants/checkpoint boundaries and targeted uncovered risks, and writes `specs/063-liveview-shell-authentication/review-report.md` ending exactly with Verdict: PASS only if satisfied; no implementation changes or merge.

## Dependencies and execution order

Setup T001 -> T002 -> foundational T003 (red) -> T004 -> T005 -> T006 (green). Then US1 T007/T008 (red, independent files) -> T009 -> T010 -> T011 -> T012 (green). US3 follows US1, before P2 work: T013/T014 (red) -> T015 -> T016 -> T017 (green). US2 T018/T019 (red) -> T020 (green); US4 T021/T022 (red) -> T023 (green). T024 -> T025 -> T026 -> T027 require all stories; T028 depends on all T001–T027 complete and current passing receipts; T029 depends on independent QA PASS. Only T028/T029 may remain unchecked at development handoff and are the only task_stages entries.

US3 uses minimal Portfolio from US1; US2 enriches it with both navigation destinations. US4 tests shared failures independently using fixtures, while integrating prior flow. Story tests remain runnable individually against shared foundation. Browser-file edits across stories are sequential to avoid conflicts.

## Parallel examples

- US1: T007 credential test file and T008 controller test file can be authored together after foundation.
- US3: T013 server lifecycle tests and T014 browser tests can be authored together after US1.
- US2: T018 navigation test file and T019 browser additions can be authored together after US3.
- US4: T021 safe-feedback tests and T022 browser accessibility additions can be authored together after US2.

These are file-level opportunities; this workflow retains one implementation owner and does not launch research agents or another planning session.

## Implementation strategy

First validate US1 as the smallest demonstration increment, then finish P1 US3 lifecycle guarantees before P2 US2/US4. US1 alone is not an acceptable release because lifecycle/isolation remain required. Deliver the complete shell only after all developer checks and both independent PASS gates. Do not implement later charts, analytics, trading or conditional orders, change API authentication policy, publish or merge from this stage.
