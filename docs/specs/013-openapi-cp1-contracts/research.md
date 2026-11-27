# Research: TASK-013 OpenAPI publication

## Decision 1 — Contract source and publication

**Decision**: Maintain one OpenAPI 3.0.x JSON file at `priv/static/openapi.json`, serve it with Phoenix's existing static plug at `/openapi.json`, and point the public `/docs` page at that fixed same-origin URL.

**Rationale**: The router has exactly two CP1 catalog operations. A tracked static contract adds no runtime dependency or controller annotation, and the existing static plug can publish it. The contract is checked against router metadata and live JSON rather than trusted merely because it parses. OpenAPI 3.0 represents a nullable required continuation field with `nullable: true` and expresses either credential scheme as two separate security-requirement objects. See [OpenAPI authentication](https://swagger.io/docs/specification/v3_0/authentication/) and [OpenAPI data types](https://swagger.io/docs/specification/v3_0/data-models/data-types/).

**Alternatives considered**: `open_api_spex` can generate and serve a spec, but adds a runtime dependency and annotation/validation integration for only two unchanged routes. A contract assembled from a separate Markdown copy would permit drift; the Markdown contract here is a design checklist, while the JSON file will be the sole served source.

## Decision 2 — Interactive page and secret handling

**Decision**: Use a pinned official Swagger UI distribution copied locally with its license. Provide one masked credential input and mode selector. Clear it on mode switch; the request interceptor strips both credential headers and adds the chosen one only for same-origin protected catalog GETs. Disable native competing authorization controls, authorization persistence, remote validator, query-driven config, cookies on requests, and display of mutated request commands. Render a visible load error if the JSON or assets fail.

**Rationale**: Swagger UI supplies mature OpenAPI rendering and live execution, but its standard authorization state can hold both credentials. The UI configuration and interceptor support the required mediation; the browser test must establish the actual header set, since the OpenAPI security OR does not do so. Local assets avoid third-party script execution on a page where readers type credentials. See [Swagger UI installation](https://github.com/swagger-api/swagger-ui/blob/main/docs/usage/installation.md) and [configuration](https://github.com/swagger-api/swagger-ui/blob/main/docs/usage/configuration.md).

**Alternatives considered**: CDN assets add an external execution and availability dependency. Native Authorize alone can send mixed headers. A custom renderer would recreate schema, example, and execution features outside the smallest CP1 scope. Redoc alone does not meet live request execution.

## Decision 3 — Evidence beyond schema validity

**Decision**: Pin `@apidevtools/swagger-parser` and `playwright-core` in test-only `tools/openapi/package-lock.json`. Use the parser for a machine validity gate, ExUnit to compare the served contract with all catalog router entries and deterministic HTTP behavior, and Chromium for JWT/API-key switching and request-header inspection.

**Rationale**: A parser validates OpenAPI syntax/structure, while authentication priority, repeated query rejection, filter intersection, cursor binding, and exact 401 header require live requests. Existing `AccountsCase`, `CatalogCase`, `CatalogFilterCase`, and catalog-query probes support deterministic fixtures. [Swagger Parser](https://github.com/APIDevTools/swagger-parser) is a suitable pinned test-only validator; Chromium is installed locally. Keep this tooling outside the production application.

**Alternatives considered**: A renderer-only check misses schema defects and runtime drift. Comparing every Phoenix route against the document would falsely include the home and documentation routes. Adding HTTP credential-issuance endpoints merely to supply the browser test would violate the product scope.

## Resolved unknowns

There are no `NEEDS CLARIFICATION` items. No durable deviation from `docs/ARCHITECTURE.md` is required, so no ADR is warranted for this plan.
