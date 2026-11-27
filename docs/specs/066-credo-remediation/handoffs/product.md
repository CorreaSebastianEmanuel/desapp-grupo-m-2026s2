# Product handoff — TASK-066

## Decisions

- No additional product decision is needed. This is a behavior-preserving engineering prerequisite whose boundaries and acceptance conditions are fully captured in `spec.md`.

## Execution guidance

- Before reuse, verify `tmp/task066-split/TASK-066-draft.patch` against `tmp/task066-split/manifest.json`, its recorded base, and the approved spec/plan. Review the full patch, with particular attention to financial/authentication paths, E2E subset assertions, and native-profile safeguards.
- The task is already running in this isolated checkout through Agentflow; do not start a nested run. Do not apply the draft before this task’s approved plan.
- Reinspect actual PostgreSQL and Redis service mappings before assigning a fresh task-owned partition. Socket permission errors inherited from the sandbox do not establish that services are unavailable; request approved execution access if required checks cannot reach them.
- Shared Credo prerequisites remain in TASK-065’s integration draft. Coordinate artifact ownership so this task delivers them once and TASK-065 does not duplicate them.
- Keep TASK-065 instrumentation, Sonar probes, coverage collectors, report adapters, and credentials outside this task.
