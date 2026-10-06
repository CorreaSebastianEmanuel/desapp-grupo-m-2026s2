# ADR-0015: Source-anchored retry expiry at complete readiness

**Status**: Accepted for TASK-017 feedback 1
**Date**: 2026-10-06

## Context

Independent QA B1 and authoritative `backlog/feedback/TASK-017.md` show that a relative retry duration calculated by FootballData.Errors can overstate a wait or survive expiry while Runner finishes normalization. FR-011 requires a known future wait; FR-015 requires complete-boundary evidence. ADR-0013 owns the public contract and ADR-0014 owns source/status/transport decisions. Neither product scope nor vendor semantics changes. The former plan prohibited Runner edits, preventing the required correction.

## Decision

Allow the smallest private seam in Runner, without changing Error, Runtime, Adapter behaviour, request/result fields or another adapter's behavior. Private transport results capture complete-header receipt monotonic/UTC evidence before parsing/close. Errors derives an immutable monotonic not-before instant from the original receipt pair, never from parser entry. Missing/incoherent evidence means unknown wait.

Runner supplies a private record_retry_not_before callback in context. Record only integer expiry in worker-local storage under a fresh per-call reference, retaining the earliest if registered repeatedly, with cleanup on every outcome/exception and synchronous fixture execution. The FootballData callback still returns the existing failure map. After existing Error.failure and normalization, Runner captures that integer and carries it with the normalized outcome in an opaque internal wrapper through the unchanged runtime. Only at accepted readiness, strictly before deadline, unwrap and refine a valid rate_limited Error using div(max(expiry_us - ready_us, 0), 1000). Non-positive becomes nil. No extra UTC sample, public metadata, vendor-specific dispatch, wait, retry, process or persistent state.

Unregistered adapters retain byte-equivalent public outcomes, including their legacy fixed durations. Success, non-rate errors, malformed failures and exceptions do not inherit registered expiry. Deadline/caller-exit/cleanup semantics and huge positive timeout acceptance remain unchanged. Preserve the original normalization hook so independent QA pauses still exercise the full boundary.

Only Runner.run/4 and the private with_retry_window/1 and refine_retry_delay/3 helpers may differ from its protected AST. Replace Runner's byte guard with a constrained metadata-normalized AST-delta comparison and independent semantic checks; preserve all other byte guards. Statistics scope allowance adds only runner.ex. All 217 cases, fixed fingerprints, reusable assertions and shallow-checkout portability remain intact; do not edit original fixtures/helper/bootstrap or add historical Git prerequisites.

## Consequences and alternatives

Deterministic delta/date/reset tests cover parsing and later normalization independently, positive overstated waits, expiry and sub-ms precision at full readiness. Port and rerun the original controlled and real HTTPS QA assertions, preserving /tmp originals. Real TLS tests observe headers, final categories/delays and peer closure; owner executes all fresh manifest checks before independent QA/review.

Rejected: adapter-only subtraction (cannot see later normalization), removal of every delay (loses valid information), public expiry keys or relaxed Error allowlist (changes contract), Runtime changes (readiness already available), provider-specific Runner branch (breaks separation), blanket removal of byte guards (weakens protection).

This is an internal correction authorized by feedback, with no human product decision, new dependency, service, public endpoint or CP2 capability claim.
