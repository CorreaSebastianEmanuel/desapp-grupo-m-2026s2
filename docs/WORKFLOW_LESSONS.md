# Workflow lessons (cross-task)

This file is the persistent cross-task distillation of the per-task feedback in
`backlog/feedback/`. It exists so that every new task starts knowing the
patterns that already caused rework, instead of rediscovering them. Inspired by
the harnessing-level recursion of Google's
[Harness²](https://github.com/google-research/harness2): keep what transfers
across tasks, one entry at a time.

Per-task feedback files stay untouched and canonical. This file adds only what
repeats or generalizes; it never replaces a feedback file.

## Format

```
<date> — <pattern> — <actionable rule> — <tasks where it occurred>
```

One line per lesson. Entries are appended, never rewritten, and the file stays
small: prune merged duplicates or completed checkpoint concerns only when the
list passes the checkpoint hygiene review.

## Lessons

- 2026-10-06 — Parsers of backlog metadata (ids, status, dependency pointers)
  failed with concealed whitespace, non-ASCII Unicode (`U+00A0`) separators and
  trailing newline/EOF edge cases — probe refusal and malformed/ambiguous-input
  cases explicitly in the first attempt, with an assertion-based refusal oracle
  scripted and rerun unchanged after the fix, instead of discovering them via
  adversarial QA rounds — TASK-054
- 2026-10-18 — Legacy skill mirrors (`.claude/skills/`) drifted behind
  `.agents/skills/` and exposed an outdated feedback contract (`--stage` only,
  no `--impact`) — after migrating an agent integration, remove the superseded
  mirror in the same change or point it at the canonical copy — cleanup PR
- 2026-10-18 — Quality tooling depends on local services and hosted credentials — validate live prerequisites before final checks; report unavailable access separately from unsupported capabilities — TASK-065
- 2026-10-18 — Child-agent socket restrictions masked real compiler diagnostics — distinguish sandbox permission failures from service failures and verify child execution access before resuming — TASK-065
- 2026-10-18 — A new required linter exposes accumulated repository findings — assess the full finding set early and budget behavior-preserving remediation before the final verification run — TASK-065
- 2026-10-18 — Repository-wide lint adoption grew into domain refactors — isolate existing-code remediation as an explicit prerequisite and keep integration gates unchanged — TASK-065, TASK-066
- 2026-10-19 — Local prepared databases masked CI cold-start failure — run test.prepare before profile discovery in every CI job and verify once against an initially empty database — TASK-066
