# ThinFlow verification

ThinFlow uses a repository-owned mapping instead of a generated
`verification.json` per feature. `.agentflow/thinflow.json` defines finite path
rules, maximum-severity risk tiers, argument-array commands, bounded timeouts,
and prerequisites expressed by the command itself.

`python3 scripts/thinflow.py check TASK-NNN`:

1. diffs the candidate from the configured base plus working-tree inputs;
2. refuses empty or unmapped change sets;
3. chooses the highest tier and unions checks from matching rules at that tier;
4. executes each check without an implicit shell;
5. records bounded local logs, hashes, elapsed time, and material digest;
6. refuses a third failed attempt for an unchanged digest.

`python3 scripts/thinflow.py evaluate TASK-NNN` revalidates selection, source
freshness, complete passing checks, and the exact terminal evaluator verdict.
Failed, missing, stale, skipped, empty, interrupted, or inconclusive evidence
never counts as passing. Evaluator output is downstream evidence and is excluded
from the candidate digest; current feedback, spec, policy, code, tests, and CI
definitions remain material.

The hosted `ThinFlow required` job reports only after Quality baseline,
End-to-end profile, and SonarCloud finish, and passes only when all three report
success. Repository protection must require this stable name for the latest PR
head.

## Agentflow 2.3 compatibility

Saved 2.3 runs keep their captured `verification.json`, schema-2 receipts,
ordered development/QA stages, and two terminal reports. The legacy definition
lives at `.specify/workflows/desapp-delivery/workflow.yml`. Do not relax or
convert those artifacts while resuming historical work.
