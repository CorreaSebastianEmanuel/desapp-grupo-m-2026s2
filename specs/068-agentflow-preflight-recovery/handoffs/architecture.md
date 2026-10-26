# Architecture delta — TASK-070

Current Feedback 1 supersedes the previous baseline fallback, cap 16 and serial-only policy; see amended ADR-0032. The unchanged spec supports these verification/governance refinements without reopening product decisions.

The baseline is now fast wrapper-contract/CI-parity assertions with zero native-suite fallback. Iterate with focused tests, freeze inputs, run the complete manifest once; freshness after real repairs can require new execution. QA runs its own complete manifest for this workflow change. Known saved baseline steps adapt in memory on resume; snapshots stay intact and unknown commands refuse.

At most two registered static/contract checks overlap. Exact argv allowlisting and explicit disjoint effects are mandatory. Mix/E2E, behavioral subprocess suites, services and browser work remain serial. Measure static fixtures and actual invocation counts rather than rerunning full profiles for benchmarking.

Change repository feedback policy to three durable repair cycles; allow the third repair and refuse a fourth across resumes, preserving feedback/history and recommending an explicit human-approved split. Keep the separate two-failure full-stage and per-check budgets.

Deliver a documented Vibecode procedure with brief spec, preflight, focused tests, CI, proportionate independent PASS gates and human merge; exclude finance, security, integrity, migrations, external contracts, uncertain impact and all workflow changes. No executable lane selector is planned; TASK-070 uses full flow.

Earlier critic findings remain resolved by final-context probing, typed prerequisite inventories, durable non-PASS partial QA with interruption recovery, and separate retry/evidence identities. ADR-0014 resolves numbering: preserve specs/068 and TASK-070's exact branch identity.

Planned executable checks are not current evidence. No affected HTTP endpoints; runtime_required=false. Service readiness remains mandatory for retained profiles. Do not add CP1 coverage, clean-candidate suites or duplicate baseline profiles.
