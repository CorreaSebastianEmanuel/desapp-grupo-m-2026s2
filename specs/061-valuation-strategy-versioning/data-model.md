# Data model — TASK-025

Behavior: [spec.md](spec.md). Enforcement/trust: [ADR-0023](../../docs/adr/0023-immutable-valuation-configurations-and-selection.md). Original football entities and common Descriptor remain unchanged.

## Immutable configuration version

Table `valuation_configuration_versions`; schema `Configurations.Version`:

| Field | Storage | Rule |
|---|---|---|
| id | UUID primary key | generated per successful save; no caller identity/reuse/deduplication |
| strategy_id | nonempty text | supported pair required for creation/use; lookup may inspect formerly supported names |
| formula_version | nonempty text | distinct from configuration UUID |
| rules | JSONB, nonnull | complete schema-versioned typed config/references/requirements/mapping |
| created_at | UTC timestamp, microseconds | immutable; no updated_at |

Index `(created_at, id)` supports ascending stable lists. Each call saves a distinct version even when canonical rules are equal. Validate rules before inserting; complete row insertion is atomic. No player/season/week/facts, active flag, mutable label or quote fields.

Decoded version exposes `id`, `strategy_id`, `formula_version`, `config`, `references`, `requirements`, `position_mapping`, `created_at`. Full group settings and unused mapping entries remain present. Registry support is checked on save/activation/evaluation/replay, not read-only inspection. Read from immutable storage without joining current position labels. At creation, key-share lock/check every mapping position UUID through Catalog.Position; deletion after an unused mapping was saved does not change its retained bytes or impose new catalog lifetime restrictions.

## Typed exact rule codec, schema 1

Top-level string keys: `schema_version`, `config`, `references`, `requirements`, `position_mapping`. Unknown/missing keys or schema versions are rejected as storage integrity failures. Config is exactly weights, represented by ordered metric entries for balanced or ordered four-group metric entries for position-aware. References are ordered metric/numeric entries. Requirements are ordered scope/metric lists. Mapping is ordered UUID/group entries. Orders match existing Request/Evidence metric and scope ordering; mapping UUIDs canonicalize before duplicate detection. Whitelist every decoded structural enum; never call String.to_atom, dynamic module loading or binary term deserialization.

Numeric leaves:

| Public type | Stored tagged object | Reconstruction |
|---|---|---|
| integer | `{"type":"integer","value":"-12"}` | exact arbitrary-size Integer |
| Decimal | `{"type":"decimal","sign":"-1","coefficient":"125","exponent":"-2"}` | validated Decimal struct using integer components |

Only codec-generated numeric strings are decoded; public configuration rejects textual coercion. Coefficient is nonnegative, exponent signed, sign ±1; normalize trailing coefficient zeros and zero sign/exponent exactly as Evidence.normalize_config. Decimal 1 and integer 1 remain distinct; Decimal 1.0 and 1.00 canonicalize equally. No database numeric range/scale, float JSON leaves, ambient-context arithmetic or scientific string coercion. Extreme coefficients/exponents remain subject to ordinary resources rather than a newly invented rule ceiling. Compare `Evidence.canonical` before/after storage under varied Decimal contexts.

## Serialization anchor

Table `valuation_selection_locks`; schema `Configurations.SelectionLock`: integer primary key `id`, constrained to 1. Migration inserts exactly one row; protect UPDATE/DELETE/TRUNCATE. No active identity or mutable revision is stored here. Activation and history insertion lock this existing row even when history is empty. Unexpected missing anchor is storage failure, not no-active success.

## Selection change

Table `valuation_selection_changes`; schema `Configurations.SelectionChange`:

| Field | Storage | Rule |
|---|---|---|
| change_order | bigint primary key from owned sequence | assign in BEFORE INSERT after anchor lock; increasing order, gaps permitted |
| previous_version_id | nullable UUID FK | null only when no committed selection exists; must match actual latest target |
| new_version_id | nonnull UUID FK | existing version; must differ from previous |
| effective_at | UTC timestamp, microseconds | sampled inside serialized transaction, published by commit |

Both foreign keys restrict deletion/update of referenced identities. No cascades. Insertion guard requires READ COMMITTED (reject other isolation with a named guard), acquires the singleton lock, then checks latest committed predecessor and supplies order using a fresh command snapshot. Effective time is the database transaction timestamp, sampled by the insert guard; multiple changes within one transaction may share it. Keep the trigger volatile; reject disconnected/duplicate changes with named constraints. Read-only lookup/list snapshots may use a single statement or REPEATABLE READ; no history inserts occur in those transactions. UPDATE/DELETE/TRUNCATE guards reject changes, including no-op updates. Sequence order, not timestamps, is authoritative. A transaction rollback leaves no successful change; gaps are harmless. Ordinary database access cannot reset history. Database-owner bypass/DDL is outside application immutability guarantees.

Active identity = latest committed `new_version_id`, or nil for empty history. Get/list plus selection inspection use a consistent transaction snapshot, so callers see a complete state. History is ascending `change_order`; times may tie. Version save does not select. Matching target/current/expectation is success without insertion; stale expectation conflicts even for current target. Restoring a saved version appends a change, not a version. Expected identity permits A→B→A value matches and adds no revision policy.

## Managed calculation binding

`ManagedDescriptor`: `schema_version: 1`, `configuration_version_id`, `evidence` (existing Descriptor). `ManagedResult`: `configuration_version_id`, `strategy_id`, `formula_version`, `score`, `prepared`, `descriptor` (managed envelope). These are internal in-memory DTOs, not new database tables or public serialization formats. Existing formula Definition/Request/ScoreResult/Descriptor keep their layouts/signatures.

Evaluate: strict subject/week request → resolve saved version once → validate/reconstruct full original rules → existing evaluate → wrap existing descriptor. No fact read before configuration validation; no version re-resolution during scoring. Replay: validate envelope → load original UUID → compare full original rules/formula → inherited replay of original facts. No activation/read-current dependency and no writes. Missing originals/unsupported/mismatched evidence remain distinct no-score outcomes.

Durable descriptor retention and quote effective dates/integrity are TASK-026. Test restart transport is trusted test-generated temporary data only. Every quote must eventually persist the configuration UUID separately from formula identity/version and protect the complete evidence binding; this feature does not create quotes.
