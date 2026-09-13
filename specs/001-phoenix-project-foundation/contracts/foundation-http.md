# Foundation HTTP Contract

## Development default page

- **Method**: `GET`
- **URL**: `http://127.0.0.1:4000/`
- **Authentication**: none
- **External services**: none; PostgreSQL and Redis may both be unavailable
- **Ready response**: HTTP `200`
- **Stable response marker**: response body contains `Football Player Market`
- **Readiness bound**: the validation probe retries only until 30 seconds after server launch, then exits nonzero

Any redirect away from loopback, 4xx/5xx response, missing marker, connection failure after the readiness bound, or response dependent on PostgreSQL/Redis violates this foundation contract.

This is a contributor-facing smoke contract, not the product REST/OpenAPI foundation. TASK-013 owns OpenAPI and later API contracts; TASK-038 owns formal health endpoints.

## Shutdown contract

The documented foreground stop action must end the server process within 10 seconds. After exit, the same HTTP probe must fail to connect, and a fresh start must satisfy the ready response again. A child process retaining port 4000 violates the contract.
