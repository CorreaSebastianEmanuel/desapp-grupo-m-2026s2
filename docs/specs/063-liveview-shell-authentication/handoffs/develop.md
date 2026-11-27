# Development delta — TASK-046 CI correction

PR #39 exposed a Market scope test reading ignored local .specify/feature.json
with File.read!, absent in CI. It now uses one optional fail-closed reader for
missing/malformed/unexpected JSON; temporary-file regression preserves unknown
feature rejection without mutating the real pointer.

SonarCloud reported javascript:S9383 and zero imported coverage. Workspace
lifecycle now has an injected factory retaining the production browser export;
the internally caught detached retry is explicitly void. Node tests cover private
DOM concealment, socket disposal, deduplicated recovery, failed-connectivity
500ms safe-read retry, bfcache and workspace-only online/offline events. Native
Node LCOV is generated under ignored cover/workspace with 100% module
line/branch/function thresholds. Sonar imports that measured report. Its unchanged
native Quality Gate runs after pinned Node 24 coverage generation. Scanner/gate
credentials are step-local, outside JS tests. No threshold reduction or source
exclusion. Exact feature allowance adds only the CI contract test and Sonar
workflow (36 paths); baseline workflow/hash stay unchanged.

Plan and manifest include JS coverage and the exact CI entry point because that
concrete failure was missed by local tagged-profile validation. Both original
profiles remain required. Current passing historical QA/review are stale; both
gates are reopened. Refresh every manifest check, then independent QA/review on
this source before updating the existing PR.

Earlier B1 cookie-recovery correction and its HTTP/Chromium regressions remain.
Main 7f8d4ba/TASK-019 is integrated with both explicit scope allowances and ADR-0026.
Historical integration nondeterminism remains documented; do not infer a fix.
Use network-capable workspace permissions or appropriate escalation for Mix,
DB/Redis and Chromium; do not repeat denied commands unchanged. Limit is two
failed executions for identical inputs, not two total attempts. No source edits
in QA/review; no merge or publication before both current independent PASS gates.

Current development evidence: all ten manifest checks passed with unchanged
source/inputs after rebuilding assets. javascript 0.238s; feature 12.752s;
preflight 2.702s; format 0.809s; compile 0.692s; openapi 0.702s; unit 22.984s;
integration 193.076s; foundation 2.034s; exact ci runner 169.921s. Total 405.910s.
Canonical check-*.json receipts hold hashes/evidence. T027 complete; independent
T028/T029 remain pending. No remote green claim before push and observed CI.
