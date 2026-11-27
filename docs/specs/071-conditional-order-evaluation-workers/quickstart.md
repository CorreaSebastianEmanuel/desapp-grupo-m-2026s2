# TASK-060 validation guide

Use repository-local PostgreSQL and Redis configuration, locked dependencies and the pinned mise toolchain. Domain scheduling uses PostgreSQL only; Redis remains required by the application's existing service preflight. Use controlled local fixtures, no provider access or production accounts.

Before native tests, run `python3 scripts/agentflow_check.py toolchain --reuse` and `python3 scripts/agentflow_check.py preflight --reuse`. Native checks retain the existing test preparation aliases. The runtime HTTP probe itself repeats service and bounded listener readiness, failing nonzero if unavailable. Browser checks require the existing pinned Node/Chromium setup and launcher-resolved sandbox metadata; do not repeat a known restricted browser launch (TASK-059 feedback 3).

After implementing tasks.md and finishing all canonical edits, run `python3 scripts/agentflow_stage_checks.py --stage develop --reuse`. Reuse is explicit development-only; runtime checks always execute. Focused checks precede one execution each of unit, integration and E2E. `ci-parity` validates wrapper parity without executing native profiles. Do not add test.cp1_coverage as an extra CP2 gate.

The executable `test/runtime/order_evaluation_http.exs` owns an isolated schema and real Endpoint/Bandit listener. Create an authenticated order over HTTP, confirm a fixture quote through the existing domain fixture, run the actual new Oban worker, then assert owned GET/list shows the exact executed purchase. Repeat wake/recovery and prove one purchase/two ledger entries, fixed supply, exact credits. Also assert price-pending, rejection and due-expiry; lost PubSub and reconnect return the same persisted result. Existing HTTP auth, JSON headers, Location and pure-read assertions remain. Stop/clean only probe-owned processes/schema with existing RuntimeProbe ownership safeguards.

For inspection/demo, use fixture workers with manual Oban execution: create above-limit pending, confirm a qualifying fixture quote, process wake/pass, read executed; repeat and compare unchanged purchase ID. Suppress one delivery, restart the isolated worker/application process, run recovery and read persisted completion; due expiry works without a quote. Assertions and setup live in the tests, not copy-pasted service bodies here. TASK-061/062 supply visual/demo presentation.

Implementation records every developer check before QA. QA executes all manifest checks independently without --reuse and writes qa-report.md. Final review checks mapping quality and writes review-report.md; both must end exactly `Verdict: PASS`. Development creates no downstream PASS report. The fixtures use an isolated Oban prefix through the existing configured instance seam; production continues to use the application instance. Automatic startup wakes are disabled only in manual test configuration; the restart acceptance enables startup against its owned schema and exercises the real application callback.

## Feedback 1: output packaging and fingerprint assertions

The prior run's reports and handoffs contain historical results. Archive retention and SHA-256 identities live in `handoffs/check-qa-supplement.json`; originals remain under ignored `tmp/task060-feedback-1/qa-evidence/`. To replay, extract the bundle's patch content to `/tmp/task060-runtime-probe.patch` and follow its `replay` commands. Never recreate the original source-directory layout. Fresh QA replaces results in excluded outputs, retaining historical provenance if needed; no application file is edited for supplementary replay.

After all canonical edits and developer checks/readiness, capture the pre-QA baseline from the repository root (do not recapture it after a mismatch):

```sh
python3 - <<'PYTHON'
from pathlib import Path
import json
from scripts.agentflow_verification import source_fingerprint, input_fingerprint
root = Path.cwd()
feature = root / 'specs/071-conditional-order-evaluation-workers'
assert not (feature / 'qa-evidence').exists()
baseline = root / 'tmp/task060-feedback-1/pre-qa-fingerprints.json'
baseline.parent.mkdir(parents=True, exist_ok=True)
baseline.write_text(json.dumps({'source': source_fingerprint(root), 'inputs': input_fingerprint(feature)}) + '\n')
PYTHON
```

QA independently executes the full manifest without reuse, finalizes its excluded reports/handoff/supplement, then runs:

```sh
python3 - <<'PYTHON'
from pathlib import Path
import json
from scripts.agentflow_verification import source_fingerprint, input_fingerprint
root = Path.cwd()
feature = root / 'specs/071-conditional-order-evaluation-workers'
before = json.loads((root / 'tmp/task060-feedback-1/pre-qa-fingerprints.json').read_text())
after = {'source': source_fingerprint(root), 'inputs': input_fingerprint(feature)}
assert not (feature / 'qa-evidence').exists(), 'QA recreated an input directory'
assert before == after, 'QA changed checked inputs; normal re-verification required'
out = feature / 'handoffs/check-qa-packaging.json'
out.write_text(json.dumps({'schema_version': 1, 'stage': 'qa', 'before': before, 'after': after, 'unchanged': True}, indent=2) + '\n')
assert after == {'source': source_fingerprint(root), 'inputs': input_fingerprint(feature)}
print('QA_OUTPUT_FINGERPRINTS_UNCHANGED')
PYTHON
```

A mismatch blocks acceptance; preserve evidence, diagnose actual input changes and follow normal developer/independent re-verification. Do not replace baseline hashes or relabel old receipts. Final review checks this result against fresh QA evidence. The architecture session only validates the packaging contract, not fresh application behavior or downstream PASS provenance.
