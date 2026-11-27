# Task-generation delta

33 tasks: US1 8, US2 9, US3 4; setup/foundation 5, developer cross-cutting 5, independent gates 2. Test authoring groups are parallel only across distinct files; runtime/profile execution stays ordered because it shares services/build state.

The first MVP is create/track with pure projections; it is not the complete deliverable. All three P1 stories and all developer checks must complete before T032 QA and T033 final review. Only those two IDs map to gate stages.

Implement preflight and actual HTTP assertion runners as explicit tasks before invoking the manifest. Final unit/integration profiles execute once each through the established mise entry points; parity checks do not run them again. Preserve existing E2E regression without claiming order UI coverage.

Watch the purchase extraction baseline, separate direct/conditional purchase identity and reciprocal commit-time guards. Quote/cancel races require committed-connection barriers; a shared Sandbox connection or a sequential quote test cannot satisfy them. Post-evaluation expired-state read assertions belong to T020 in US2, so US1 validation has no circular evaluator dependency.

TASK-060's contract check validates obligations, not delivery behavior. Retain that distinction through QA/review. No worker/UI implementation or new timing/fairness promise is assigned here. No extensions.yml is registered, so tasks hooks have no executable entries.
