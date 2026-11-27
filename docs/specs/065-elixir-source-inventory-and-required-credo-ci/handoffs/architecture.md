# Architecture delta — TASK-065

Resolved all three critic findings: actual Credo execution sources with fail-closed completeness, exact per-path archival exclusions, and complete revision-associated artifacts retained 14 days. ADR-0030 records these decisions and the bounded tradeoff of a literal standard CLI pass followed by a programmatic observation pass with identical snapshots. No analyzer configuration/rules or application changes.

Feature directory and declared branch match TASK-065; backlog TASK-067 remains deferred. Archived broad TASK-065 feedback is not current acceptance evidence. Preserve TASK-066's cold-database preparation before profile discovery.

Implementation should stage new source before explicit inventory refresh, classify every outside-boundary tracked Elixir file and reject maintained-root exclusions. Historical standalone specs probes need individual reasons, never a broad specs exemption. Avoid treating issue output or a separately globbed set as the effective-input oracle.

Keep existing Quality baseline job and SonarCloud separation; add mandatory wrapper and always-upload step without changing hosted settings. Finite workflow scope/baseline fixture updates must preserve negative tests. Full schema/commands/test matrix are in data-model.md and contracts/quality-evidence.md.

verification.json owns seven owner-executed checks. No HTTP interface is affected; existing integration/E2E runtime assertions remain required. Do not add CP1 coverage execution locally. Owner completes all implementation/check tasks before independent QA; QA reruns all IDs without reuse. No implementation or publication was performed at architecture stage.
