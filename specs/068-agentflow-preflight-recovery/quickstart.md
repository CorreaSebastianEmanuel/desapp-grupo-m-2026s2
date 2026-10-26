# TASK-070 validation guide

This guide targets implementation and independent QA. New test/script paths below are planned outputs, not already implemented checks. Run from repository root on the TASK-070 branch; feature directory is `specs/068-agentflow-preflight-recovery` by ADR-0014. Do not start another live Agentflow task to exercise these tests.

## Prerequisites

Use the existing setup, `.tool-versions`, locked Mix/OpenAPI dependencies and documented local PostgreSQL/Redis services. Start services deliberately with the normal local setup before acceptance; preflight itself never starts them. Provider CLI fixtures need no live credentials. Actual launch preflight uses the configured provider/override executable and final child PATH; never paste credentials or dumps into evidence.

Architecture structural validation (available before implementation):

```sh
python3 scripts/agentflow_artifacts.py specs/068-agentflow-preflight-recovery
python3 scripts/workflow_artifact_probe.py plan --readiness
python3 scripts/workflow_artifact_probe.py tasks --readiness
```

## Test-first scenarios

1. US1: write `test/scripts/agentflow_preflight_test.py`, then run `python3 -m unittest discover -s test/scripts -p agentflow_preflight_test.py`. Child-only PATH, wrong versions/settings, valid/invalid overrides, start/resume and per-provider-stage hooks, changed context, unknown/timeouts and unavailable service fixtures must gate actual fake Popen. Compare protected source/artifact/state bytes and service mutation counters before/after; no writes. Valid fixtures launch with exactly the probed env/cwd. Canary secrets must never reach any public diagnostic.
2. US2: write/run the analogous `agentflow_stage_checks_test.py`. Mixed success/failure continues an isolated later check; transitive/state-conflicting/unspecified independence blocks. Unknown IDs/cycles reject. SIGINT/SIGTERM after one completion preserve every inventory row and end non-PASS. Kill a fixture subprocess abruptly and recover its journal once; never reuse prior completions as current QA acceptance. Cover provider failure before batch invocation and redaction across console/JSON/Markdown.
3. US3: write/run `agentflow_recovery_test.py`. Two failed full attempts with multiple failing commands count twice, not per command; third refuses across resume. Nested finalization is idempotent. Unrelated docs/formatting, session IDs and reports do not reset; relevant producer/test/declared feedback correction does. Malformed journals refuse. Test each feedback category, mixed earliest owner, pending/conflicting/unknown check scopes, upstream byte preservation, three-cycle cap including durable pre-existing cycles, fourth refusal and no silent resets and product challenge ordering.
4. US4: write/run `agentflow_dedup_test.py`. Instrument native runner invocation counts: one development profile pair, zero native baseline invocations for all receipt states; parity fails closed on contract mismatch, one fresh QA pair, CI command unchanged. Stale/corrupt/failed/interrupted/foreign/source/profile membership drift never satisfies readiness. Resume adapts only recognized baseline steps in memory and unknown commands refuse. Test sequential/concurrent static fixtures for correct continuation, interruption, measured peak workers <=2 and zero overlap with Mix/E2E. Test Vibecode procedure examples and exclusions without enabling a shortcut for this task. HTTP obligation fixtures require service-ready status/header/body assertions and never accept bare requests.

Tests use temporary fixture repositories/processes and read-only fake-service probes; no changes to saved live workflow state. See contracts and data-model for exact semantics.

## Final development checks and independent QA

During iteration execute focused tests and cheap checks, without a full manifest after every edit. After stabilization freeze source/design/feedback and execute every `verification.json` check using `python3 scripts/agentflow_check.py CHECK_ID --reuse`; use ordered batch mode once implemented. The service-preflight check fails if readiness is unavailable; fix documented setup instead of skipping. Database/assets preparation is explicit and separate from read-only preflight. `ci_profiles` executes both existing profiles once. Do not add CP1 coverage, clean-tests, another unfiltered mix test or separate full profiles. Run `python3 scripts/workflow_artifact_probe.py develop --readiness` after all implementation/check tasks are complete.

QA executes each required check afresh with `--stage qa`, or the QA batch, and performs adversarial semantic assessment before PASS. Review uses that fresh evidence and only targeted uncovered checks. Report cause, elapsed time and contained evidence paths after two unchanged failures; no direct-command bypass. Source/canonical changes invalidate conservative full-source evidence even if targeted repair checks previously passed.

Expected artifacts: implementation `verification-audit.md` with invocation ledger and gate comparison, one `handoffs/develop.md`, independent `qa-report.md`/`handoffs/qa.md`, then `review-report.md`/`handoffs/review.md`. No publication is part of this guide.

Run `python3 scripts/agentflow_stage_checks.py --ci-parity` after readiness: expect wrapper-contract assertions and zero real profile invocations, including missing/stale evidence cases (readiness itself must refuse those). Capture static worker=1/2 fixture timings and invocation counts in `verification-audit.md`; do not benchmark by repeating full profiles. The Vibecode procedure remains inapplicable to this workflow task.
