# Architecture rewind — Feedback 1

Feedback 1 supersedes the earlier no-feedback assumption. QA B1 and the unchanged root probe identify gaps in metadata parsing and legacy candidate classification; the spec and approved product boundaries remain unchanged. ADR-0014 and the shared contract now record both corrections.

Use one strict scalar-frontmatter parser for every critical consumer, including Agentflow meta/state/dependency decisions. Reject unsupported and duplicate forms before any backlog/pointer write or verifier/publication side effect. Keep canonical unknown scalar fields and body bytes. Do not write blocked status after invalid metadata.

Exclude safely validated different-task branch declarations from legacy counting. One/two foreign equal-number specs permit pre-product None and existing product creation; required lookup remains missing. Headerless legacy candidates still resolve uniquely or refuse ambiguity; malformed/unsafe/same-task claims and metadata conflicts still refuse.

The unchanged root probe exited 1 in architecture; evidence: /tmp/task054-architecture-root-probe.log. Preserve both original /tmp diagnostics and their hashes in research.md. The adversarial script asserts exploitation, so its post-fix failure is not acceptance; tracked inverse assertions must prove refusal and byte-identical backlog across every consumer.

Retain unaffected work. Reopen affected tests/implementation/checks, write regressions before corrections, and require actual start-path cases plus unchanged root-probe success. Regenerate all ten receipts and development readiness, then fresh independent QA/review. No implementation or publication occurred here. TASK-054 remains separate and must merge before PR #28.
