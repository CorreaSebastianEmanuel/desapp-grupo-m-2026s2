# Architecture handoff: TASK-013

## Decisions and guidance beyond the plan

- `Plug.Static` runs before the Phoenix router. In integration tests, request the endpoint itself to prove that `/openapi.json` has the expected JSON content type and is reachable without a credential; router-only tests cannot establish static publication. A missing static asset should fail the browser gate visibly.
- The existing API policy test scopes application-owned `/api` routes. Keep its protected-route assertion intact and derive contract route comparison from every router method at `/api/players` or beneath `/api/players/`; assert their `:api_protected` metadata. This catches an added catalog route without treating documentation or the home page as undocumented catalog operations.
- The current controller reads raw query pairs to preserve duplicate detection. A generic OpenAPI request validator must not be inserted into that path: automatic query coercion or validation could change the specified error order and 401 precedence.

## Risks to check during implementation

- Swagger UI may render the selected header in a generated cURL snippet or another request panel even when its primary mutated-request display is disabled. Inspect every visible request representation in Chromium. Keep the actual browser network assertion authoritative, then adjust the small wrapper if a credential appears on screen.
- The browser test will cross process boundaries into the test database. Use an isolated loopback server with SQL sandbox sharing or an equivalent isolated test database. On setup or assertion failure, close Chromium, stop the server, and remove any short-lived credential file without printing its contents.
- Recheck the pinned UI distribution license, asset hashes, and browser configuration when upgrading the bundle; an asset update can change authorization and command-display behavior without changing the OpenAPI JSON.
