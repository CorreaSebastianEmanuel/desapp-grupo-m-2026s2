# Verification before independent QA

The architecture session creates `verification.json` alongside `plan.md` and
`tasks.md`. This executable acceptance map is required only by workflow 2.3.0 or
newer. Legacy snapshots keep their original requirements.

```json
{
  "schema_version": 1,
  "runtime_required": false,
  "checks": [
    {
      "id": "unit",
      "argv": ["mix", "test", "test/example_test.exs"],
      "env": {"MIX_ENV": "test"}
    }
  ],
  "coverage": {"FR-001": ["unit"], "SC-001": ["unit"]},
  "task_stages": {"T010": "qa", "T011": "review"}
}
```

Use actual commands, paths and requirement IDs from the active feature. Every
FR/AC/SC identifier in `spec.md` must map to one or more existing check IDs. Include
all applicable formatting, compilation, tests and checkpoint checks. Checks execute
as argument arrays without implicit shell expansion. Use an explicit shell only
when the real check requires it; keep secrets out of arguments, manifests and
evidence. Environment overrides may not repurpose HOME or CODEX_HOME.

For CP2, do not add the historical CP1 coverage report merely because it exists:
it repeats both test profiles. Preserve coverage infrastructure and CI; include
the report locally only for a concrete affected obligation or explicit request.
Record user-authorized changes to required checks in current feedback and align
the spec, plan, tasks and manifest rather than bypassing a failed gate silently.

For affected HTTP endpoints, include an executable runtime check with
`"runtime": true` and an `"expectation"` describing status/header/body assertions.
The gate independently detects method/route declarations (case-insensitive) and
route mappings in OpenAPI JSON, YAML/YML and RAML contracts, including root routes
and referenced path items. YAML detection is conservative: a route-shaped mapping
requires runtime evidence even when its operations are defined elsewhere. Invalid
JSON contracts fail validation.
Spec and contract declarations such as `GET /api/players` independently trigger
this obligation. A bare request without assertions is insufficient. Include service
readiness in the executable check itself; unavailable services must cause failure.
QA still starts the runtime and exercises endpoints independently.

Only downstream tasks with titles beginning `Independent QA` or `Final review`
may stay unchecked, explicitly tagged `[gate:qa]`/`[gate:review]` and mapped in
`task_stages`. Implementation and applicable developer checks must complete.
Preserve the standard task syntax and use unique IDs.

After implementation, run each check:

```bash
python3 scripts/agentflow_check.py unit
```

Finish source/design edits before running final checks. Within development, use
`python3 scripts/agentflow_check.py unit --reuse` to avoid repeating an unchanged
passing check. Reuse validates the same fingerprints and output hash as readiness;
missing, stale, failed or corrupted evidence triggers execution. Reuse is never
implicit and cannot reuse QA evidence. Runtime assertion checks always execute;
set `"reuse": false` for other checks requiring fresh service/environment state. QA executes commands independently or uses
`python3 scripts/agentflow_check.py unit --stage qa` without `--reuse`; review may
use `--stage review` for targeted checks.

After two failed executions in a stage with unchanged command/source/design inputs,
the helper refuses a third execution. Stop and diagnose; do not rerun commands
directly or change irrelevant inputs to evade the limit. Corrective input changes
start a new attempt scope; independent stages have separate counters. The summary
includes elapsed check time, failure count and evidence. Do not infer token usage
from test runtime; use Agentflow metrics for recorded model usage.

The helper captures complete output under ignored `.agentflow/runs/checks/` and
prints only the check ID, exit code, freshness status and evidence path. Inspect
bounded failure excerpts when needed. It invalidates the previous receipt before
starting, so failure or interruption cannot reuse an older passing result. Canonical
receipts live at `handoffs/check-CHECK_ID.json`; full outputs remain local.

Readiness validates source fingerprints before and after execution, the current
spec/plan/tasks/manifest, command identity, exit status and output hashes. Source
fingerprints include git-listed tracked and untracked files and deletion markers;
run outputs, feature reports, backlog state and disposable `tmp/` are excluded.
Task text is bound while checkbox completion is normalized: recording a passing
task after its check does not invalidate receipts. Current checklist state is
validated separately. Any other source or canonical input change requires rerunning
affected manifest checks; readiness conservatively requires all receipts to match
the current source set.

The planning and task gates validate the manifest before implementation. The
development gate uses `--readiness` to stop missing, failed, stale or uncovered
evidence before launching QA. This is structural and reproducible preparation,
not proof that the chosen tests fully cover the behavior: independent QA must
challenge mappings and verify every acceptance criterion. QA and final review
still require their own terminal PASS verdicts.

Receipts are local to a workspace: another checkout has to run its checks, since
full output files are intentionally not published. Do not manufacture receipts,
replace checks with trivial successes or weaken the manifest to bypass a blocker.
