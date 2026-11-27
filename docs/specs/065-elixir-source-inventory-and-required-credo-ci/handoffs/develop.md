# Development handoff — TASK-065

## Deltas and decisions

- Added `config/credo_inventory.json`, `scripts/credo_inventory.exs`, and `scripts/credo_ci.sh`. Git, the maintained inventory, and Credo effective inputs reconcile; default rules and the TASK-066 configuration remain unchanged. ADR-0030 explains the two lint passes.
- Existing Quality baseline now requires Credo and uploads complete JSON/log evidence for 14 days. README documents commands, scope, revision labels and limitations. Coverage and SonarCloud infrastructure remain unchanged.
- Wrapper cleanup now rejects traversal, unrelated temporary directories and symlink output paths before removing anything. Only a nonsymlink `tmp/credo-ci[-suffix]` directory is accepted.
- Added 19 cases, retaining all 890 existing cases and their profile assignments. Current inventory: 909 cases; maintained/effective source scope: 416 files with 25 exact historical exclusions.

## Execution evidence

- Initial isolated focused suite: 29 passed. Standard Credo/inventory evidence passed with Credo 1.7.19 and both statuses zero.
- Initial manifest regression stopped after two failures in the developer execution context; it was not bypassed. A service-capable unit diagnostic on the same code passed 456/456 cases.
- Two output-path preservation tests first failed against the unsafe cleanup and then passed after its correction. The seven wrapper contract cases now pass. The two new cases were registered before final verification.
- All seven final manifest IDs passed on the corrected source through the approved runner: preflight 5.88s, format 1.83s, compile 1.06s, inventory 19.93s, Credo 8.27s, regression 603.95s (458 unit and 449 integration cases), E2E 32.47s. T016 is complete; readiness must pass before QA.
- The first service-capable joint regression failed after 494.43s. Isolated integration then passed 449/449, followed by the bounded second joint attempt passing both profiles. The first failure's cause remains unconfirmed; disclose it to independent QA/review rather than claiming it was fixed or substituting isolated results for the required gate.

## Independent QA guidance

Run all seven manifest IDs with `--stage qa`, no receipt reuse. Use approved per-command access to the existing PostgreSQL/Redis/Docker/browser prerequisites; PostgreSQL currently publishes at 15432, Redis at 6379. Challenge actual-input equality, finding/invalid-source failures, exact exclusions, output preservation, status propagation, snapshot mutation and retained artifacts. All existing regression/E2E gates remain required. Keep unsupported native-Java equivalence and bug-absence claims excluded. Hosted artifact retrieval awaits the PR CI run.
