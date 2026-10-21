# ADR 0031: Application-only native coverage evidence

- Status: Accepted
- Date: 2026-10-20
- Feature: TASK-067

## Context

TASK-067 human feedback excludes tests/support from both numerator and denominator. The product critic identified absent shared content identity, implicit scope classification and stale successful-report ambiguity. Existing CP1 coverage has its own denominator (ADR-0009); TASK-065 lint accounting (ADR-0030) is broader than application coverage. Normal integration scheduling has regular and independently committed-file invocations; historical CP1 mode bypasses that split. Existing profile receipts prove case completion but not source content.

## Decision

Maintain a separate reviewed exact-path coverage role inventory reconciled to every canonical TASK-065 entry and Git. Include maintained application implementation under lib; explicitly exclude every other path with a role/reason. Bind compiled modules to actual source metadata. Do not derive coverage eligibility from a directory glob or modify the lint/CP1 denominator.

Attach opt-in native exports to the existing normal unit/integration ExUnit invocations without changing selected cases, database partitions, profile scheduling, cleanup or receipt schemas. Seal separate sidecars after genuine profile completion. Bind each export and expected partition to one run, full working-source content snapshot, compiled-module population and profile receipt nonce/hash. Analyse partitions separately; Boolean-union executable identities by source path and line. Native errors, absent partitions, conflicting populations and source mutations fail closed. Genuine zero-executable files remain visible with N/A rather than fabricated coverage.

Use immutable successful run directories and an atomic current-attempt status. Beginning a run invalidates current success; a failed/crashed run cannot select historical success. Preserve old runs with original snapshot labels. Publish report, HTML and measured documentation only after native, arithmetic and snapshot validation. Keep output outside CP1, JavaScript and existing profile receipt roots.

## Consequences and alternatives

This is a durable tooling extension, not a production architecture deviation. There is no new package, service, percentage threshold, Sonar import or application behavior. One audited profile pair supplies both acceptance and measured coverage; historical CP1 remains available and is not another default CP2 local gate. CI and existing independent E2E remain required.

Reusing historical CP1 mode loses normal partitions; rerunning profiles doubles cost; replacing audited receipt schemas changes ownership. A broad lib glob hides classification drift. Mutable report replacement or falling back to last success obscures current failure. Extra exact-path review and sidecar validation are deliberate integrity costs. Native parent coverage cannot measure independent nested BEAM processes or E2E; document that limitation rather than redesigning runners.
