# Product Handoff: API Authentication Pipeline

## Decisions

- Use `Authorization: Bearer <token>` for JWTs and `X-API-Key: <key>` for API keys.
- Reject requests carrying both methods or repeated credential values; never choose a winner.
- Public routes ignore credentials and never create optional actor context in this task.
- Authentication establishes identity and credential provenance only; it grants no role, permission, or ownership authority.

## Unresolved Assumptions

- No material product assumption remains unresolved before planning.

## Guidance

- Centralize route classification and authentication so omissions fail closed and handlers receive only trusted actor context.
- Preserve the existing TASK-008 and TASK-009 validation contracts rather than decoding, querying, or verifying credentials again at the web boundary.
- Keep the generic 401 body identical across methods and failure causes. A Bearer challenge is protocol metadata, not permission to reveal the attempted method or cause.
- Treat all credential-bearing headers as sensitive in request logging, exception reporting, telemetry, and test failure output.
- Define a representative public route and a minimal protected test route or existing operation during planning; do not invent authorization or product behavior merely to demonstrate the pipeline.
