# Development handoff: API authentication pipeline

## Changes

- Added the enforced three-field `FootballMarket.Accounts.AuthenticatedActor`.
- Added one shared `AuthenticateAPI` Plug: exact header-occurrence classification, strict Bearer parsing, opaque API-key delegation, generic halted `401`, safe validator failure convergence, actor assignment, and one low-cardinality telemetry event.
- Replaced the generic API pipeline with explicit public/protected policies; no production probe route was added.
- Added a test-only router/probe and functional, privacy, route-policy, real expiry/revocation, and opt-in performance coverage.
- Recorded the FR/SC/CP1 audit in `checklists/requirements.md`; contract and quickstart match the implementation.

## Decisions

- Validator exceptions are rescued only at the trust-boundary call, preserving the selected method while hiding causes.
- Public routes never invoke authentication. Repeated, dual, non-binary, and malformed credentials fail before validation.
- Telemetry metadata is exactly `route_policy`, `outcome`, and `authentication_method`; identity and credential data remain absent.

## Commands

- Focused functional/security/policy suite: 15 passed.
- `mix format --check-formatted`: passed.
- `MIX_ENV=test mix compile --warnings-as-errors`: passed.
- Complete default suite: 128 passed, 3 opt-in exclusions.
- Performance suite: JWT 40/40 below 1s (p95 84µs); API key 40/40 (p95 1.759ms).

## Residual risks

- T004, T008, T013, and T018 remain unchecked: their required pre-implementation failing runs were not observed, so no historical red-phase evidence is claimed. Current behavior and all final suites pass.
- Production currently has no `/api` route; the route audit becomes active as TASK-011 adds one.

## QA guidance

Run the commands in `quickstart.md`. Inspect exact `401` body/challenge equivalence, actor shape, telemetry metadata, real JWT expiry, immediate key revocation with second-key continuity, public-header ignoring, route classification, and absence of secrets/IDs from logs and telemetry.
