# ADR 0028: Independent test inventory and a required E2E profile

- Status: Accepted
- Date: 2026-10-16
- Feature: TASK-063

## Context

CP2 requires actual end-to-end execution separate from unit/integration. TASK-014's module-tag audit and sentinel/summary checks cannot detect removal from both discovery and expected scope, nor prove each case ran. Existing integration includes HTTP/browser regressions and must keep its coverage. Current feedback restricts new journeys to the implemented authentication shell and durable catalog synchronization; charts/orders remain later work.

## Decision

Extend the two-profile developer interface with `mix test.e2e`. Preserve existing unit/integration assignments and CP1 report scope, provenance and threshold zero. Commit an independently reviewed per-case profile inventory; compare it with separate discovery and native execution events. Include repository-owned ExUnit, Python, Node/custom validator and shell cases. Explicit update is separate from read-only validation. Each selected profile executes its complete assigned population and fails on skips, omission, duplication, signal or missing prerequisite.

Run new journeys using actual Chromium, Endpoint HTTP/WebSockets, isolated PostgreSQL schema and real Oban consumers with fixture-only provider configuration. Trusted synchronization admission/inspection stay local interfaces; no public control API. Use 30-second readiness/terminal waits and a 180-second outer E2E deadline. Retain safe count/category/opaque-ID summaries only.

Add a mandatory E2E CI job on the existing PR/main events. Preserve baseline and Sonar quality categories. Refactor legacy all-Mix CI orchestration to execute unit/integration once each, with non-ExUnit components assigned once and category evidence validated from their receipts. Keep Sonar's existing JS coverage execution. Do not add the historical combined CP1 report as another local CP2 gate.

Integration also inventories existing Docker lifecycle scripts. Execute them against uniquely owned project/volumes/ports through a test-only CLI wrapper/materialized config; preserve original service assertions and production scripts. Docker absence and legacy SKIP output fail the profile. Do not change only the project name while retaining explicitly shared volume names. Native orchestration/helper ownership avoids duplicate execution of nested shell suites.

## Consequences and alternatives

This deliberately extends the TASK-014 command/evidence interface, requiring narrow updates to its contract tests and exact CI oracles. It introduces test-only inventory/runner code, no new product service or persistence model. Developers must review inventory updates when adding/removing/renaming tests. Runtime failures cannot be hidden by optional browser/worker execution.

Reject regenerated expected inventory, module-only counts and whole-process success as per-case evidence. Reject reclassifying existing integration cases, optional E2E, manual queue drain as asynchronous E2E, duplicate full-profile runs, raw browser artifacts, and product changes to satisfy test infrastructure. Reuse ADR-0006, ADR-0009, ADR-0025 and the revocable-browser-session ADR-0026 for settled product decisions.
