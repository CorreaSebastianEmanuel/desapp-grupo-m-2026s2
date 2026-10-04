# Feedback — TASK-020

## Feedback 1

- Time: 2026-10-04T00:53:15+00:00
- Author: ezequielgonzalez
- Restart from: develop

Independent QA blocker B1, not a new product requirement: specs/054-player-match-statistics/qa-report.md and qa-evidence/adversarial_test.exs reproduce duplicate season-scoped identities with surrounding U+00A0 whitespace. Align database normalization and scoped lookups with the Unicode whitespace requirement in FR-002 and String.trim; cover Unicode blank identities and duplicate/scoped lookup cases, preserving accepted facts and append-only protections. Resolve this implementation defect without narrowing the specification. Follow the existing plan boundary; rerun current checks and obtain fresh independent QA and final review PASS before publication.

## Feedback 2

- Time: 2026-10-04T01:51:44+00:00
- Author: ezequielgonzalez
- Restart from: architecture

Independent QA round 2: B1 Unicode normalization is verified PASS. B2: malformed identity containing NUL raises Postgrex.Error SQLSTATE 22021 in record_match/get_match/record_batch; add field-safe original-input rejection and ordinary behavioral regressions per FR-009/010 using qa-evidence/current/malformed_identity_test.exs. B3: required full regression repeatedly fails unchanged CatalogConcurrencyTest (constraints_test.exs:189) because Task.async_stream tasks use a Sandbox owner that exits. Diagnose causality and repair connection ownership without weakening assertions, omitting tests or hiding errors. Architecture must explicitly document a bounded test-harness plan extension for existing catalog concurrency tests/support if necessary, preserving independent concurrent connections and all product boundaries. No new product scope, no destructive database resets; retain B1 Unicode/migration protections. Then implement, rerun all current checks and obtain fresh independent QA and final review PASS before publication.

## Feedback 3

- Time: 2026-10-04T02:27:07+00:00
- Author: ezequielgonzalez
- Restart from: develop

The user explicitly approved the previously rejected cleanup through the command approval UI. Root executed /private/tmp/task020_fixture_cleanup.exs successfully: it verified football_market_testcatalog_concurrency, locked and checked the exact diagnostic league/season/team IDs, aborted on any references, backed up the three rows to /private/tmp/task020_fixture_backup.json, then deleted only those rows. No history, players, other fixtures, database resets or production data were touched. The blocker in handoffs/develop.md is now removed. Preserve the completed B1/B2/B3 repairs, rerun all 18 current manifest checks sequentially on stable sources, reconcile tasks and obtain fresh independent QA and final review PASS before publication.

