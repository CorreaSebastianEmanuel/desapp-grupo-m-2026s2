# Feature-specific research

No unsettled technology selection. Reuse docs/ARCHITECTURE.md, ADR-0013/0016/0017/0018/0019 and current TASK-018/055/021 feedback. No TASK-019 feedback file exists as of this session.

## Durable acceptance correlation

- Decision: add the narrow optional delivery receipt/fence in ADR-0025.
- Rationale: local `Ingestion` only allows provider/runtime/mappings/new_players; `Publisher` already atomically publishes observations, but cannot prove which attempt committed after a lost reply. Its private outcome constructor can generate the safe receipt inside that same transaction, including replay.
- Alternatives considered: another retrieval at attempt three exceeds budget; catalog-content matching cannot prove attribution; wrapping retrieval in an outer database transaction changes existing publication boundaries.

## Queue accounting and restart

- Decision: introduce Oban `~> 2.24.2`, transactional insertion and max_attempts=1 per delivery; persist domain attempts/waits separately. Dedicated execution guards and a boot/periodic reconciler prove owner loss before recovering.
- Rationale: official [Worker documentation](https://oban.hexdocs.pm/Oban.Worker.html) describes queue retries and transaction insertion; they do not provide TASK-019's domain history. The [Lifeline documentation](https://oban.hexdocs.pm/Oban.Lifeline.html) warns that time-only rescue may duplicate live execution. Do not use it as proof of owner death. Version-specific APIs and dependency compatibility must compile in implementation before acceptance.
- Alternatives considered: naive rescue-age inference and default automatic backoff cannot enforce the specified boundaries. No paid plugin or additional service is justified.

## Occurrence identity

- Decision: use durable latest-due reconciliation with explicit generations, not catalog jobs inserted directly from cron.
- Rationale: [Oban.Cron](https://oban.hexdocs.pm/Oban.Cron.html) provides expression parsing; occurrence bookkeeping and catch-up are feature obligations. Persist busy supersession as ADR-0025 describes.
- Alternatives considered: replaying every missed occurrence causes backlog storms; a boot import violates disabled/unconfigured scope requirements.

## Existing regression integration

- Decision: preserve config/config.exs unchanged; place dedicated config in config/synchronization.exs loaded through runtime.exs/test.exs. Add exact active-feature allowances to existing provider/statistics/market scope tests, including negative probes.
- Rationale: local inspection found issuance's SHA-256 configuration boundary and Git working-tree inventories; blindly adding runtime files makes legitimate regression fail. TASK-028 feedback prohibits HEAD-dependent replacements. Profile audit requires one unit/integration module tag per new test module.
- Alternatives considered: broad prefix allowances, disabled scope assertions and replacing the configuration hash weaken existing checks.

All feature-specific unknowns resolved to reviewable design. Implementation must record a concrete incompatibility before changing this boundary; no live source research is needed or authorized by fixture success.
