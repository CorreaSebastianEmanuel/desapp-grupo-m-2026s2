# Feedback — TASK-082

## Feedback 1

- Time: 2026-11-02T03:10:58+00:00
- Author: ezequielgonzalez
- Restart from: develop
- Impact: implementation
- Required regressions: cited discrepancy plus required manifest checks
- Checks: UNIT-PROFILE

Grouped repair for evaluation blockers B1–B3. B1: move Football-Data.org request pacing out of per-worker process state into a durable shared credential-scoped mechanism so consecutive jobs/retries and concurrent supported runs never exceed 10 requests in any rolling 60-second window; preserve provider reset intervals beyond attempt deadlines and prove adjacent-run/retry/cross-reset cases. B2: preserve provider error tuples and retry metadata from later team-resource fetches through translation, so retryable 429/503/timeouts reach Synchronization.Policy and retry durably; add assertions for classification, attempts, and unchanged accepted catalog on transient failure. B3: add registered source-specific tests through runtime config, Synchronization admission, Oban worker, atomic publish/replay/update and inspection. Cover missing/invalid secret and prove credentials absent from persisted inputs/jobs/inspection; incomplete/transient failure preserves prior accepted snapshot; reconciliation conflicts, omitted-player retention, and unchanged nonempty financial/statistics/unrelated-league state. Fix the advisory budget-clamp issue if the same adapter path is touched. Keep one grouped repair; no new public endpoint or scope expansion. Use the pinned mise Elixir 1.20.3/OTP 29 toolchain for checks.

