human_check_required: false

The specification determines the product boundary: conditional complete catalogs, conservative refusal of unsupported or invalid evidence, explicit unsupported performance, read-only operation, safe credentials, and deterministic offline acceptance. TASK-017 has no current human feedback file (`backlog/feedback/TASK-017.md` is absent).

The challenge identifies source-evidence, quota, transport and checkpoint risks. Documentation and the existing provider contract give architecture a conservative resolution: establish documented scope/affiliation evidence, preserve refusal when evidence is insufficient, select and document a bounded retrieval strategy, and test security and cleanup through the actual transport boundary. Endpoint selection, fixture construction and request scheduling within the fixed deadline are internal, reversible choices.

No evidence requires choosing new product behavior, purchasing access, relaxing identity rules, or adding performance ingestion. Those alternatives are outside the authorized scope. The architect should document feasibility and refusal cases before implementation; synthetic fixture success must not be presented as guaranteed live coverage or completion of CP2 valuation ingestion.
