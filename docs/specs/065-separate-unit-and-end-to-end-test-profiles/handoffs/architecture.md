# Architecture delta — TASK-063

The feature directory number differs from the delivery branch; keep the existing active pointer and exact Git branch, rather than renaming either. No unresolved human decision remains.

Implementation should first audit custom runner case observability: existing shell/custom-validator suites may need explicit stable case events. An exit-zero child alone cannot establish FR-003. Native adapter design is the largest execution risk; use small controlled fixture populations to prove negative cases before inventorying the full repository.

Existing strict scope/byte oracles may reject the declared CI/runner changes. Update only their affected expectations, retaining their security and category assertions. A scope failure is not permission to relax product boundaries. Do not copy TASK-046 test probe routes into production or use its sandbox/manual-worker runtime as the new E2E path.

The integration service-script component requires real Docker/Compose. Review target isolation especially carefully: a unique project name alone does not isolate explicitly named volumes. Existing default-port conflict tests must use the invocation's allocated ports.

The manifest names planned tooling as implementation deliverables; structural planning validation does not claim those commands exist or pass yet. QA must independently verify the completeness mechanism, not just trust matching counts.
