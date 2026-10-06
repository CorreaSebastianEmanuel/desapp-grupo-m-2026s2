# Feature-specific resolutions

Settled choices: `docs/ARCHITECTURE.md`, `mix.exs`, ADR-0002 and ADR-0010–0012. Local inspection of `Catalog.supported_leagues/0`, `Catalog.Position`, `Statistics.Input` and `Statistics.Count` confirms semantic boundaries. Provider normalization will not call persistence contexts. No new dependency, vendor or stack survey is required.

## Eligibility before full validation

- **Decision**: Validate envelope and match eligibility discriminators; exclude demonstrably irrelevant matches; validate every retained record and reference closure. Ambiguous eligibility fails. See contracts/provider.md and F-P04–F-P07.
- **Rationale**: Satisfies interval/completion filtering without repairing eligible facts or hiding invalid historical/current relationships.
- **Alternatives considered**: Checking every irrelevant metric makes narrow requests fail on unrelated data; unvalidated filtering can conceal corruption.

## Identity-aware equivalence

- **Decision**: Test-only explicit correspondence, bijective references, unordered membership/edges. Validate provenance independently.
- **Rationale**: Result refs are local and names are not unique; SC-001 requires equivalent facts, not equal source IDs/order.
- **Alternatives considered**: Literal equality rejects replacement sources; name matching accepts merges/swapped edges; production reconciliation is downstream scope.

## Error and provenance safety

- **Decision**: Fixed explanations, known fields, safe local optional refs, typed failures, public-safe provenance IDs. Reject recognizable secret/transport content instead of reflecting or rewriting it.
- **Rationale**: FR-012 covers the entire returned term and raw-term logging would undermine safe messages.
- **Alternatives considered**: Arbitrary-message redaction misses leaks. An invented alphanumeric ID taxonomy violates opacity. Raw exception text is prohibited.

## One elapsed-time budget

- **Decision**: Monitored read worker plus a deadline-aware owner, terminal outcome/cancellation and controlled time/event mechanics. Retain a real blocked-worker smoke test.
- **Rationale**: Post-return measurement cannot bound blocking work; wall time is unsuitable for elapsed budgets; pages are not public successes.
- **Alternatives considered**: Fresh page budgets, retries and partial streams violate FR-003/FR-010/FR-011. Worker pools add infrastructure. Virtual tests alone cannot establish cancellation.

## Offline and preservation checks

- **Decision**: Plain Elixir ExUnit bootstrap for pure suites, separate from database isolation and existing Mix profiles. Stage new files before existing CP1 coverage snapshot checks; retain its inventory unchanged. Feature .gitignore excludes only generated local check receipts, and the develop handoff must be staged before QA coverage reruns.
- **Rationale**: `mix test` aliases database preparation. Profile discovery requires exactly one existing module-level profile tag. Coverage refuses untracked inputs; agentflow_check creates its receipt before launching each command. Receipts reference ignored workspace output and remain verified by content/hash/freshness regardless of Git tracking.
- **Alternatives considered**: Mix-only offline evidence conceals service dependencies; widening CP1 inventory or weakening its untracked-file guard changes reporting scope. Publishing receipts with unavailable local outputs does not create portable evidence.

## Feasibility risk

- **Decision**: TASK-017 assesses real operation/league/metric coverage; TASK-022 owns incomplete valuation inputs. No live research or scoring policy here.
- **Rationale**: Unknown counts/empty performances can conform without supplying usable CP2 valuation data.
- **Alternatives considered**: Selecting a vendor or scoring completeness here expands FR-014. Synthetic PASS cannot prove real access/capability.

All material unknowns resolved. Durable choices: ADR-0013. Implementation and independent QA must supply behavioral evidence.
