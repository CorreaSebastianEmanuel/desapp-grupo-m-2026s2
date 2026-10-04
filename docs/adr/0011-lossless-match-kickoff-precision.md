# ADR-0011: Lossless Microsecond Kickoff Inputs

**Status**: Accepted for TASK-020 implementation
**Date**: 2026-10-03

## Context

Truncation can change retained kickoff facts and inclusive interval membership. The approved product decision permits a conservative lossless precision boundary.

## Decision

Accept DateTime values or ISO-8601 strings containing an explicit UTC/offset instant, with zero through six fractional second digits. Reject greater textual precision before parsing, even trailing zero digits; reject naive dates/times, invalid offsets, special infinity values and malformed inputs. Apply the same boundary to interval bounds. Normalize to UTC, pad precision to six digits without changing the instant, and use Ecto :utc_datetime_usec over PostgreSQL timestamp(6) without time zone, always containing UTC. Preserve the instant, not the original textual offset.

The domain input validator must run before Ecto casts: generic casts can silently coerce values. Reject DateTime structures whose precision metadata exceeds six or whose microseconds/calendar/offsets cannot describe a valid ISO instant. Use ordinary DateTime conversion rather than interpreting local zone names.

## Consequences

Ordering and inclusive predicates compare stored UTC microseconds. Test equivalent offsets, exact equality and facts one microsecond either side of a bound. No rounding or inferred season-date window is permitted. Arbitrary precision would require a different storage/query representation; second-only truncation violates retention.

## Evidence

The pinned PostgreSQL 17 supports microsecond timestamp resolution and precision 0–6: [PostgreSQL timestamp documentation](https://www.postgresql.org/docs/17/datatype-datetime.html). The repository's installed Ecto PostgreSQL adapter maps :utc_datetime_usec to timestamp (deps/ecto_sql/lib/ecto/adapters/postgres/connection.ex); its Ecto type normalizes UTC and pads microseconds. No dependency migration is needed.
