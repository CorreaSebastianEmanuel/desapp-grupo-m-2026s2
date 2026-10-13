# Tasks handoff — TASK-024

29 tasks cover five story increments. New source behavior follows config/formula assertions; later conformance assertions precede any corresponding correction. Existing engine behavior may already pass and requires no artificial red result or gratuitous edit. T003 protects boundaries before the scorer exists; its final pass follows T007.

Only T028 Independent QA and T029 Final review are gate-tagged and mapped in verification.json. T001–T027, including all final developer checks and profile executions, must complete before QA. Fourteen manifest checks cover all eighteen canonical FR/SC IDs; thirty numbered scenarios have a concrete assertion map. No AC identifiers or affected HTTP routes occur in this spec.

File-level parallel opportunities are explicit, but the scorer has one owner and global tracing/service checks run serially. New support code keeps independent vectors in memory with count/checksum evidence, respecting current feedback. Neither an additional historical CP1 report nor duplicate unchanged complete profiles are requested.

Architecture evidence: setup-plan/setup-tasks resolved active feature 060 and loaded required templates. workflow_artifact_probe.py plan --readiness and tasks --readiness passed. python3 /tmp/task024-architecture-audit.py passed scenario/identifier/command/task/gate/link/inventory checks and 49 independent design arithmetic vectors; git diff --check passed. These are design checks, not implementation evidence. Extension hook configuration is absent; before/after hooks for both skills have nothing to dispatch.

Implementation should use the common engine unchanged. If a concrete failing obligation needs an extra common production path, update the bounded plan/ADR first. No code implementation, QA success or publication is claimed by these planning artifacts.
