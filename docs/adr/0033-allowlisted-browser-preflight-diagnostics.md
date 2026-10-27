# ADR-0033: Allowlisted browser-preflight failure causes

**Status**: Accepted within TASK-029 feedback 2 authorization.
**Date**: 2026-10-23

## Context

TASK-029 development stopped after two integration browser-prerequisite failures before ExUnit. Human feedback records that exact-environment Chromium launch now succeeds and authorizes a narrowly scoped diagnostic fix, regression tests, and normal verification recovery. Current shared tooling discards launch cause and the safe evidence reader cannot expose it. Preserve ADR-0028 profile isolation and ADR-0031 coverage/receipt guarantees; no purchase rule changes.

## Decision

Extend the existing inline Node launch probe, Python supervisor and safe evidence consumer using contracts/profile-diagnostics.md's closed cause enum and anchored record grammar. Classify errors privately and expose only allowlisted categories. Unknown causes remain launch-failed. Preserve existing safe diagnostics, nonzero outcomes, cleanup, profile membership, receipt invalidation and retry limits. No raw Playwright output, command lines, paths, environment or secrets enter published diagnostics.

Add deterministic producer/forwarder/consumer refusal and compatibility tests to the existing native unit profile, and exact workflow scope allowances. Reuse existing integration/E2E real-launch preflight. The implementation owner must complete the relevant source fix, freeze inputs, execute the manifest through the existing helper and achieve development readiness before independent QA/review. Canonical planning edits alone are not recovery evidence.

## Alternatives and consequences

Raw exception reporting risks sensitive data exposure; dropping the browser prerequisite or clearing retry history hides the failure. A new runner, dependency upgrade, automatic browser installation or full-profile duplicate adds unrelated scope. Closed causes trade detail for safe actionable diagnosis; launch-failed explicitly preserves uncertainty. This is a human-authorized shared-tooling exception to the purchase-only implementation boundary, not a new application behavior or CP2 product requirement.
