# Validation guide — TASK-024

This guide is for implementation and independent QA after the planned test files exist. Architecture does not run missing implementation tests or claim feature readiness. Full interfaces/entities are in contracts/position-aware-scorer.md and data-model.md.

## Prerequisites

Use repo root, pinned Elixir 1.20.3/OTP 29.0.6, installed existing deps, PostgreSQL test service and Redis. Current feedback records local PostgreSQL at 127.0.0.1:15432 and Redis at 127.0.0.1:6379; retain configured environment from the approved local setup without writing credentials to commands/artifacts. Guarded test preparation refuses production targets. For the integration profile use Node 24 and installed tools/openapi dependencies plus Playwright Chromium; the profile preflights an actual headless browser launch.

```bash
python3 scripts/agentflow_check.py toolchain --reuse
python3 scripts/agentflow_check.py services --reuse
```

Expected: pinned tools, successful guarded migrations, PostgreSQL migration probe and Redis PONG. Unavailable/authentication/migration failure exits nonzero, not a skipped check. If service startup is needed use the existing local-service workflow; no destructive reset. Mix socket-lock sandbox restrictions need authorized expanded execution, never disabling the lock/check.

## Test-first development

Use tasks.md and contracts/acceptance-map.md. Add the assigned assertions first; a missing PositionAware module should produce the genuine red result, then implement the actual scorer. Inherited behavior can already pass. After two unchanged failures diagnose and correct real inputs before another run; do not reset evidence or invent changes.

Examples of targeted commands after tests exist:

```bash
python3 scripts/agentflow_check.py position-config --reuse
python3 scripts/agentflow_check.py position-formula --reuse
python3 scripts/agentflow_check.py position-arithmetic --reuse
python3 scripts/agentflow_check.py position-replay --reuse
python3 scripts/agentflow_check.py position-selection --reuse
```

Assert all 36 group/metric pairs, fixture scores, approved 2/4 split effect, no dilution, group-specific required unknowns and zero weights, malformed/duplicate inputs, UTC half-open selection, original replay and exact cross-group ties/cancellation. Run the independent integer-rational generator in memory: persist source/count/checksum summary rather than expanded vectors. Vary Decimal context and at least 20 deterministic input permutations. Every successful fixture should support evaluate, authenticated score and replay; negative cases yield a distinct error and no score. Effect tests disable providers, capture actual reads and reject writes/events; a controlled isolated ownership error must remain visible.

## Final developer verification

Finish source/design edits before final checks. Run each check ID in verification.json with the helper, in manifest order:

```bash
python3 scripts/agentflow_check.py toolchain --reuse
python3 scripts/agentflow_check.py format --reuse
python3 scripts/agentflow_check.py compile --reuse
python3 scripts/agentflow_check.py services --reuse
python3 scripts/agentflow_check.py position-config --reuse
python3 scripts/agentflow_check.py position-formula --reuse
python3 scripts/agentflow_check.py position-outcomes --reuse
python3 scripts/agentflow_check.py position-arithmetic --reuse
python3 scripts/agentflow_check.py position-replay --reuse
python3 scripts/agentflow_check.py position-selection --reuse
python3 scripts/agentflow_check.py architecture --reuse
python3 scripts/agentflow_check.py valuation-regression --reuse
python3 scripts/agentflow_check.py unit-profile --reuse
python3 scripts/agentflow_check.py integration-profile --reuse
```

Expected: every exit code zero, audited complete profile receipts, no skipped tests. Eligibility for explicit development --reuse follows docs/AGENT_VERIFICATION.md; services reuse=false. Run each complete profile once after final changes; no historical CP1 coverage report unless a concrete affected obligation requires it. Coverage/CI remain preserved.

Record command receipt references and concise totals in handoffs/develop.md, mark all developer tasks complete, then validate:

```bash
python3 scripts/workflow_artifact_probe.py develop --readiness
```

Only mapped Independent QA/Final review tasks may remain unchecked. QA runs each check independently with --stage qa and no --reuse, challenges the acceptance map and records fresh evidence with terminal Verdict: PASS. Review checks fresh QA evidence and targeted uncovered risks; its terminal Verdict: PASS is also required. There is no affected HTTP endpoint, so no new server/HTTP assertion check is required; integration retains the existing browser coverage.
