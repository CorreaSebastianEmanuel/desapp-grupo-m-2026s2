# ADR 0030: Revision-bound Credo inventory evidence

- Status: Accepted
- Date: 2026-10-20
- Feature: TASK-065 / specs/065-elixir-source-inventory-and-required-credo-ci

## Context

The independent product challenge requires an observable effective-input oracle, per-path exclusion accountability and retained complete evidence. TASK-066 and ADR-0029 settle version, rules and maintained scope. No application architecture deviation is needed; this ADR records the durable tooling extension and explicit lint-pass tradeoff.

## Decision

Keep the literal standard CLI invocation. Follow it with the exact same arguments through Credo 1.7.19's documented Credo.run/1 pipeline and inspect Execution.get_source_files/1 and get_exit_status/1. Bind both executions to identical Git/content/configuration snapshots; fail closed on mutation, halted/incomplete oracle or mismatches. Two static lint passes avoid changing the reviewed analyzer configuration or introducing a plugin. They never execute test profiles.

Commit a complete maintained-path inventory and exact per-path exclusion records. Enumerate every tracked Elixir file, including archived standalone verification probes outside maintained roots. Unknown paths fail; category globs cannot silently exclude them, and maintained TASK-066 paths cannot be excluded.

Use the existing required Quality baseline job, independently of SonarCloud. Always upload complete revision-associated JSON/log evidence for 14 days, fail on absent artifact, and distinguish checked-out HEAD from triggering SHA and local dirty content. Keep all existing jobs and profiles. No new coverage collector, hosted settings change or external credential requirement.

## Alternatives and consequences

Issue-only logs and a duplicate wildcard inventory cannot prove effective inputs. An observer plugin saves a lint pass but changes configuration/loading and expands the integration surface. Exact-path exclusions require reviewed updates when historical evidence changes; this friction is intentional. Full retained files resolve truncation risk. Native Java equivalence and bug absence remain explicitly unproven. CI gate enforcement inherits the existing required Quality baseline status; branch protection remains human-owned.
