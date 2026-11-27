# Architecture handoff — TASK-012

- The current `PlayerCursorTest` deliberately rejects every v2 payload. Adjust that negative test when introducing filtered v2 so it still rejects malformed, wrong-scope, and unexpected-version payloads; do not weaken the legacy v1 assertions.
- Freeze the pre-change cursor literal at the start of implementation, before editing the cursor module. The planner could not execute Mix because dependencies are absent in this checkout. The fixed secret in `config/test.exs` makes the fixture reproducible; capture its provenance in a test comment.
- The existing tagged performance test inserts all 100,000 players into one team and only asserts nonnegative timings. Replace or extend its fixture and assertions to meet the planned distribution and threshold. Its tagged isolation avoids slowing the routine suite.
- Watch Ecto query binding positions when adding optional predicates to the preloaded five-way join. Keep the selected normalized display name from PostgreSQL itself; deriving it in Elixir could move the cursor boundary under different collation behavior.
- A test of changed filters should assert no catalog query after cursor mismatch, not only the HTTP error. SQL logging of decoded cursor anchors is already suppressed on continuation reads; preserve that behavior with filtered continuations.
