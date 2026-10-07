# Develop — TASK-017 feedback 3

## Changes and decisions

Provider scope expectations now use the committed adapter inventory directly. Statistics chooses the same exact provider/adapter allowances from source-file presence. Neither guard reads ignored workflow metadata; original paths, Mix discovery, protected boundary bytes, Runner AST constraints and 217-case fingerprints remain enforced. Production code, configuration, dependency pins and Actions are unchanged.

`plan.md`, `tasks.md` and `verification.json` record T047 and the new `clean-checkout` check. `scripts/check_task017_clean_checkout.py` overlays git-listed working inputs into a separate shallow clone, asserts absent feature metadata and runs the complete CI script. Dependency/browser caches are reused; the build cache is isolated. Local workflow state stays intact.

## Command outcomes

The original shallow checkout reproduced both missing-metadata failures (`/tmp/task017-clean-red.log`). The corrected `clean-checkout` receipt records 400 passing CI tests, the discovery sentinel and four standard performance exclusions. All three retained QA/review probes passed unchanged (3/1/3 tests), including HTTPS expiry and fractional HTTP-date precision. Full `regression` passed all 404 tests.

Owner-check outcomes, output hashes and freshness are recorded in `handoffs/check-*.json`; coverage executes after this handoff is staged. No second evidence handoff is needed.

## Risks and exact QA guidance

This proves checkout portability with installed prerequisites, not a fresh dependency installation. Live quota/roster and CP2 limitations remain documented in `docs/FOOTBALL_DATA.md`.

Independently run all 21 manifest checks through `python3 scripts/agentflow_check.py CHECK_ID`, including `clean-checkout`, then develop readiness. Challenge exact scope/discovery/Runner protections without moving or deleting local `.specify` state. The clean check also reruns preserved original probes when available; tracked equivalents remain mandatory everywhere. Audit every completed task against named outputs. Obtain fresh QA and final-review PASS before Agentflow updates existing PR #28. This stage performs no publication.
