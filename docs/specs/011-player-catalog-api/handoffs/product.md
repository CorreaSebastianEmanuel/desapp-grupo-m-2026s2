# Product Handoff: Player Catalog List and Detail API

## Decisions

- Human feedback supersedes the earlier unbounded-list decision: pagination is mandatory in TASK-011.
- Use a conservative default page size of 25 and inclusive maximum of 100. Reject invalid sizes instead of coercing or silently truncating them.
- Continuation is an opaque cursor anchored to the documented case-insensitive display-name/stable-identity order. It supports deterministic keyset-style traversal without exposing cursor contents.
- Pagination metadata makes continuation explicit: applied size, returned count, `has_more`, and nullable `next_cursor` must agree.
- Cursor stability is guaranteed for unchanged ordering data, not as a cross-request historical snapshot during catalog mutations.
- Authentication precedes parameter validation and lookup, preserving TASK-010 non-disclosure behavior.

## Unresolved Assumptions

- No material product decision remains unresolved before planning.

## Guidance

- Planning should preserve the exact cursor behavior while treating its encoding and integrity mechanism as an internal, reversible choice.
- Include boundary evidence at sizes 1, 25, and 100; rejection at 0 and 101; exact-final-page behavior; replay stability; duplicate/case-variant names; and insertions on either side of a cursor anchor.
- Make provider adapters fail on invocation in tests to prove the reads are exclusively local.
