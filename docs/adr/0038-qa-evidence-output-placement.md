# ADR-0038: Supplemental QA evidence stays in excluded outputs

**Status**: Accepted under TASK-060 feedback 1, 2026-10-27.

## Context

The prior independent QA added portable evidence under the feature's qa-evidence/ directory after passing development verification. That directory is a source input, so publication correctly refused stale evidence. Feedback preserves ADR-0036/0037 and all application behavior; only packaging changes.

## Decision

Use the existing excluded handoffs/check-qa-supplement.json namespace for bounded portable replay instructions, patch, allowlisted responses, result and ordered command references. Keep original evidence byte-for-byte under ignored tmp/task060-feedback-1/qa-evidence/ and retain content/hash/provenance in the bundle. Update report links without claiming any fresh execution. Future QA writes only excluded outputs; no qa-evidence/ directory is recreated.

Finish canonical changes before developer checks. Regenerate required development evidence, run independent fresh QA and final review, and compare source/input fingerprints before and after finalizing QA outputs. Record comparison in excluded handoffs/check-qa-packaging.json. Real source changes require ordinary re-verification. Do not change receipt tooling, exclusions, retry budgets, sandbox selection or application code.

## Consequences and alternatives

Portable evidence remains reviewable without changing the checked inputs; ignored local archives are not portable receipts. Historical PASS reports cannot authorize the resumed run. Reject expanding exclusions (unnecessary tooling scope), deleting historical evidence, relabeling receipts and repeating full profiles merely for packaging. Current docs/AGENT_VERIFICATION.md remains the verification authority.
