# Product handoff — TASK-025

No blocking clarification was found in the canonical inputs. Independent product challenge is still required; this stage does not assert task completion or implementation approval.

Challenge guidance: examine whether the complete reusable mapping boundary fits downstream recalculation when previously unseen historical positions arrive, and whether expected-current activation adequately handles concurrent changes. Evaluate these against the canonical scenarios before proposing additional policies.

Architecture guidance: the existing engine separates formula configuration from request references/mapping, and its evidence encoding distinguishes integer and decimal weight representations. Review `specs/058-valuation-contract-normalization/contracts/valuation-context.md` and `lib/football_market/valuation/evidence.ex` before choosing a durable round-trip representation. Recover trusted formula definitions through an explicit supported inventory; persisted configuration must never deserialize executable module names.

Verification guidance: use controlled concurrent activation and calculation interleavings rather than timing-based assertions. Independent arithmetic generators/probes should retain compact summaries/checksums and generate bulk cases in memory, following TASK-024 feedback.

Delivery caution: the working tree already contained a runner-owned TASK-025 backlog change. It was preserved. `.specify/feature.json` now resolves this feature; no runner histories were inspected. Hooks were absent.
