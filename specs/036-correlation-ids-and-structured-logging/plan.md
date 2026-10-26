# Implementation boundary — TASK-036

Use the standard Logger formatter callback plus Jason, existing Phoenix/Plug events and Oban telemetry. Pure context/formatting helpers live under observability; HTTP handling stays in the web adapter; durable lineage lookup is a separate persistence adapter. Telemetry callbacks perform no database queries. Register owned handlers before Oban/Endpoint startup and detach on normal application stop; repeated attachment is idempotent.

Persist a nullable, at most 200-byte valid UTF-8 correlation ID on synchronization runs, outside input/identity material. Existing run UUIDs are fallback roots. Copy the root into Oban metadata at each existing enqueue boundary, with batched intent/calculation lineage lookups during scans. Preserve arbitrary existing job metadata and all argument/uniqueness policies. Keep the internal field out of run inspection response maps. Do not alter worker result semantics.

HTTP uses the existing header policy, process metadata and endpoint telemetry before static serving. Only template routes are included. Endpoint error-render events provide a deduplicated fallback terminal event. Context is reset for each request; scoped worker/provider context restores caller metadata. Formatter installation occurs after compilation in runtime config, preserves environment log levels, disables colors and retains standard message/report truncation.

Allowed changes: observability modules/tests; web request logger and Endpoint; Application/runtime logging configuration; synchronization run/store/recovery/dispatcher; quote membership/recovery enqueue annotations; provider runtime context copying; nullable migration and isolated-store migration setup; E2E runtime/fixture/scenario support; exact workflow scope allowance and tests; maintained source/test inventories; README and this feature/backlog metadata. No workflow runner, financial/auth policy, dependency or unrelated task changes.

Existing E2E queue and whole-config boundary assertions must recognize only the exact approved consumer queues and logging metadata. Retain the historical configuration hash by normalizing that complete metadata literal; reject missing/extra fields and retain all other negative configuration probes.

```json artifact-applicability
{"schema_version":1,"research":{"required":true,"reason":"Pinned Logger, Plug and Oban source decisions are recorded."},"data_model":{"required":false,"reason":"The single nullable logging field and compatibility policy are specified here."},"contracts":{"required":false,"reason":"The JSON event and existing header contract are specified in spec.md and README."},"quickstart":{"required":false,"reason":"README documents runtime use and correlation queries."}}
```
