# QA handoff — TASK-026

Verdict: FAIL

Final review is blocked by the acceptance matrix and blockers in `../qa-report.md`. Do not treat passing unit checks or the developer handoff as proof of integration acceptance.

Reviewer guidance: distinguish an immutable calculation result from the mutable request projection. A request fence checked after quote confirmation does not fence confirmation itself. Challenge a stale worker whose lease expires during scoring, and a transient failure whose Oban job returns success while its durable request becomes retrying. Current tests focus on evaluation-delivery fences rather than calculation-worker fences.

No implementation was modified. Integration stopped after two unchanged Node-runtime prerequisite failures; runtime was not executed. Resume through development feedback, then fresh independent QA with the documented Node 24 environment and all required checks.
