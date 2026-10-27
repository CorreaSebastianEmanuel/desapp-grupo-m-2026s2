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
- 2026-10-20 — A quality task combined independently deliverable analysis, coverage and external-service work while operational updates consumed feedback cycles — separate deliverables before implementation and keep routine progress in status/handoffs — TASK-065, TASK-066
- 2026-10-20 — Lint inventories include tests and support while application coverage measures runtime code — define the metric denominator explicitly and reconcile excluded categories before implementation — TASK-065, TASK-067
- 2026-10-20 — Manual recovery left Agentflow blocked while implementation advanced — route implementation recovery through classified feedback and resume, preserving explicit handoff deltas and independent gates — TASK-067
- 2026-10-20 — Line-level coverage can hide a missing executed clause counter — compare complete native counter identities against fresh instrumentation, even for clauses sharing a source line — TASK-067
- 2026-10-20 — JSON booleans compare equal to integer zero in Python — validate exact numeric types before comparing, recomputing or rendering counts — TASK-067
- 2026-10-20 — Receipt adapters can contain nested coercible component counts — validate every linked receipt component as an exact nonnegative integer before equality or evidence use — TASK-067
- 2026-10-20 — Partial receipt validation left audit counts and schema versions coercible — validate the complete numeric contract at the coverage boundary, derive audit counts from runner file membership, and test coherent linked evidence with real native controls — TASK-067
- 2026-10-21 — Producer and consumer validation drifted while incomplete positive fixtures passed — reconstruct shared evidence identities from owner oracles and bracket coherent mutation matrices with genuine nonempty native controls — TASK-067
- 2026-10-21 — Human feedback changes verification fingerprints and invalidates older receipts — finish canonical edits before the authorized round, regenerate development evidence, and stop at a concrete blocker without launching another full cycle — TASK-067
- 2026-10-21 — A formatter failure location may refer to a dependency stack frame — preserve the case identity and distinguish observed failure from an unproven assertion or performance cause before changing code — TASK-067
- 2026-10-26 — Planning declared separate profiles while the updated baseline required the CI wrapper — validate the actual CI parity contract during planning, before costly profiles, and repair manifest mappings through classified feedback — TASK-033
- 2026-10-26 — A workflow-only forced toolchain flag leaked into disposable launcher fixtures — restore contextual toolchain detection for profile subprocesses and prove both real pinned workspaces and unpinned fixtures retain their intended prerequisites — TASK-033
- 2026-10-26 — A new API exposed catalog-only contract assumptions and branch-specific merged-configuration guards — run affected contract, query and real HTTP controls before full profiles, extending exact expectations without weakening inherited checks — TASK-033

- 2026-10-23 — Trading specs can rely on spendable balances without defining how credits enter the account — decide explicitly whether provisioning is an existing input or separate product scope before implementation — TASK-029
- 2026-10-23 — Browser prerequisites can fail before tests while profile output exposes only a coarse category — reproduce the pinned runtime and report an allowlisted launch cause before retries; keep raw browser output private — TASK-029
- 2026-10-23 — A quote-first sequential test does not prove a concurrent quote-first order — add separate-connection barriers for both serial orders and assert which committed quote the purchase observes — TASK-029
- 2026-10-24 — Nested Mix tests can inherit an isolated profile partition and diverge from focused runs — resolve the active executable and explicitly control child Mix environment, with a partition-leak regression — TASK-029
- 2026-10-24 — Agentflow's parent CLI policy can differ from the sandbox inherited by its launched stage — resolve and record the effective mode at launch, bind it to browser-check identity, and rerun only under the verified mode — TASK-029
- 2026-10-24 — macOS path aliases and nested diagnostic counters can make valid outputs look unsafe or mask test failures — normalize only the declared boundary and avoid shadowing enclosing execution state in reporters — TASK-029
- 2026-10-24 — Opaque profile discrepancy markers hid repeatable failing test cases and assertion locations — expose only registered case identity, closed outcome, bounded source line and lifecycle counts while keeping assertion text and stack output private — TASK-029
- 2026-10-26 — Older calculation intents may lack newer snapshot records — preserve a player-and-season-scoped fallback when reporting asynchronous valuation status — TASK-056
- 2026-10-26 — Row-lock waits can consume transaction-time leases before authority is acquired — use the current database clock after locking and fence configuration binding as well as confirmation — TASK-026
- 2026-10-26 — Restoring absent application configuration as an explicit nil contaminates later tests — preserve absence with fetch_env/delete_env during fixture cleanup — TASK-027
- 2026-10-26 — Manual deliveries leave dependency and ownership records behind — reconcile canonical retrospective artifacts through fresh independent acceptance and normal completion without inventing workflow runs — TASK-027, TASK-056
- 2026-10-26 — New Elixir files can pass lint while coverage or helper inventories reject delivery — reconcile source roles, helper classifications and exact compatibility guards before full profiles — TASK-036
- 2026-10-27 — A green whole-suite result can miss required scenarios — confirm each acceptance scenario has an explicit delivered assertion before full verification — TASK-033
- 2026-10-27 — Repeated agent stages, prescriptive artifacts, and text-bound receipts made routine delivery consume days and invalidate itself — default to one builder, deterministic diff-based checks, one evaluator, and exact-head CI — TASK-026, TASK-029, TASK-067, TASK-071
- 2026-10-27 — Workflow/bootstrap and harness failures consumed product retry budgets — keep operational evidence local, classify harness failures separately, and allow only one grouped repair before a human decision or task split — TASK-071
- 2026-10-27 — Time-based lifecycle specs left query side effects ambiguous — define transition ownership, read projections and execution deadlines separately before planning — TASK-059
- 2026-10-27 — Generated feature numbers were mistaken for backlog task IDs — resolve task identity from the active task and exact branch declaration before selecting feedback or raising scope questions — TASK-054, TASK-059
- 2026-10-27 — Browser presence checks missed launch restrictions — prove a bounded headless launch in the effective child context before declaring browser-test readiness — TASK-029, TASK-059
- 2026-10-27 — Three-digit maintenance-branch names collided with task-branch detection and broke scope resolution in CI quality baseline — name non-task maintenance branches without a leading `NNN-` task prefix — TASK-030, TASK-055
