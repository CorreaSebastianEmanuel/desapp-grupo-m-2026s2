# Sanitized SonarCloud fixtures

These files model only the SonarCloud Web API fields consumed by the checkpoint
gate. They are hand-minimized from the documented response shapes; they are not
raw production captures. Recheck the shapes against the API documentation when
the endpoint version changes.

Never add authorization headers, cookies, account data, private URLs, or real
tokens. Redaction tests construct a synthetic canary at runtime; its complete
value must never appear in a fixture, tracked configuration, or gate output.
Fixture revisions and project keys are synthetic. HTTP-status fixtures contain
a status and a generic, non-sensitive body only.
