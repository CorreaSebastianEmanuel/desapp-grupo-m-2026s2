# Workflow records

No application schema or migration changes. All paths are repository-relative. JSON readers reject duplicate keys, unknown schema versions and invalid field types with actionable diagnostics.

## Applicability (plan-owned)

One fenced `json artifact-applicability` block contains schema_version 1 and exactly research, data_model, contracts, quickstart entries. Each has required:boolean and nonempty reason:string; applicable entries refer to research.md, data-model.md, contracts/ and quickstart.md respectively. Omission never waives a behavioral requirement. Future changes re-evaluate the corresponding owning stage. Canonical spec/plan/tasks/verification are required before develop, QA and review reports at their downstream gates.

## Verification obligation

Existing verification.json schema_version 1 is retained. Checks retain id, argv, env, runtime, expectation and reuse fields. Add optional retry_inputs selectors (see contract), applicability and environment descriptions plus ci_obligations: an array with unique identity, workflow path, step/job, disposition (local-equivalent, ci-required, not-applicable), reason and satisfying check IDs or required external evidence. Validate complete current obligation inventory, compare workflow digest, and reject unknown additions until re-planned. ci-required entries need actual revision-bound successful evidence, never a rationale alone. This feature uses local equivalents for affected obligations.

## Local receipt and retry journal (schema 2)

Receipt: workspace identity (random ignored ID), feature/task identity, stage, check ID and command digest, source before/after, canonical input digest, obligation digest, exit status, completion state, duration, output path/hash and environment assessment. Namespace: .agentflow/runs/checks/<workspace>/<feature>/<stage>/<check>/; filenames are internally generated, not caller-controlled paths. Preserve logs and inventories locally. Fail on traversal, escaping symlinks, missing output, wrong workspace/stage or mismatched digests.

State transitions: absent -> running (invalidate previous acceptance first) -> passed/failed/interrupted. Only passed with intact matching evidence is reusable, explicitly in development. QA/review receipts never satisfy development reuse. Runtime and reuse:false checks always execute.

Journal: check/stage/command/relevant-input scope, cumulative failed-attempt count since a valid repair/pass, elapsed time, last cause and evidence reference. Running found after interruption counts as failed once during recovery. Two failed attempts stop the scope across resume; later relevant repairs create a new scope without deleting the old one. Irrelevant edits may invalidate a receipt but cannot reset retry count. Applicability/command changes must document changed obligations; changing a label is insufficient.

## Final evidence summary (schema 1)

Task, feature, Git base revision, verified source digest, canonical-input and manifest digest, workflow identities, finalization time, checks keyed by unique ID (stage, status, duration, command identity, environment parity, coverage IDs, output digest and availability/reference), requirement coverage, QA/review verdict and report hashes, completeness and missing-evidence disclosures. One final row per check per required execution stage, no attempts/inventories/raw output/private session identifiers. Size grows only with required checks/requirements, not retries. Missing local evidence on another checkout means reviewable historical summary and non-ready workspace. Fail incomplete/mismatching finalization; never synthesize PASS. Source binding excludes only exact report outputs per ADR-0026.

## Feedback impact

Record discrepancy, impact category, requested stage, effective owning stage, rationale, preserved artifact references, affected evidence and required regressions in the existing feedback file. Product -> product; design or verification-plan -> architecture; implementation/test correction -> develop; QA-only evidence -> qa; review-only evidence -> review. Multiple impacts choose earliest. Legacy unclassified entries require explicit classification before dependent work, without deleting their text.

## Usage observation

Allowlisted schema-versioned event with task, stage, stable attempt/event identity, optional hashed session identity (local only), configured model/effort and source, observed model/effort and source, counter semantics/baseline, token dimensions from existing DIMENSIONS, completion and time. Unknown = null plus reason. Cached input and reasoning output remain subsets of input/output. Deduplicate exact event identities; conflicting duplicates are ambiguous and excluded from confirmed subtotals. Known cumulative baselines permit deltas; uncertain/resumed counters remain observations with unknown increments. Stage summaries expose measured subtotal, known/unknown counts by dimension and attempt completion coverage, never label a partial subtotal a complete total.

## Stage assignment generation (schema 1)

assignment_id, task_id, generation, created_at, repository_config_digest and six stage selections. Each selection stores configured candidate fields, resolved model/effort, per-field winning source and known/unknown reason. Attempt records reference assignment_id and stage, immutable resolved launch pair, launch outcome and separate observed values/sources. Parent generation and adoption reason connect future generations; completed/interrupted records remain unchanged.

Transitions: validated selection -> saved generation -> initial attempt launch with a pending binding -> run-bound generation -> completed/failed/interrupted. Only the original new-start invocation may use pending binding; resume requires a valid bound generation. Adoption on an existing run binds before its new attempt launches. Adoption creates a new generation and new attempt/session; it never mutates a launched attempt. Legacy unknown fields block launch until explicit values are supplied, without inventing history. Unbound, cross-run, malformed or unsupported generations fail safely. The separate binding index relates assignment_id to run_id; binding never mutates the frozen selection. Local assignment state is ignored; repository defaults and task overrides remain bound source inputs. See ADR-0027 and contract for exact precedence and CLI.
