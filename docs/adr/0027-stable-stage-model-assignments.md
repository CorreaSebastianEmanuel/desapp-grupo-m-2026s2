# ADR-0027: Repository stage assignment and stable attempt identity

- Status: Accepted for TASK-064 architecture, 2026-10-16
- Authority: Feedback 1; spec FR-017–022; refreshed critic findings 2 and 4.

## Decision

Use repository-owned `.agentflow/models.json` and a pure shared resolver in `scripts/agentflow_models.py`. Keep the existing launcher and independent stage sessions. Resolve each field using stage CLI, run-wide CLI, task development override, repository stage default, in that order. Defaults and exact schema/CLI live in the feature contract; no global configuration or autonomous classifier is introduced.

Freeze resolved settings and per-field sources into immutable local assignment generations. Normal resume preserves saved settings; missing legacy values remain unknown and require explicit selection when needed to launch. Explicit adoption creates a new generation and a separately identified future attempt/session, preserving interrupted attempts and completed history. A repository edit between resolution and launch cannot silently change the frozen assignment. Frozen active run 72789de8 retains its approved compatibility exception; no new-assignment execution is claimed for it.

The wrapper applies one validated model/effort pair to one child invocation. Unknown stages, conflicting unmanaged settings, malformed config and unsupported pairs fail visibly; child launch/provider rejection propagates failure without fallback or escalation. Provider availability is assessed only by the actual authorized launch, never a paid probe. Configured, resolved and observed identities remain distinct; unknown observations stay unknown.

## Evidence and alternatives

Test the actual subprocess boundary using a deterministic executable that captures invocation arrays and rejects selections. Cover start and resume stage outcomes, error events with exit zero, all precedence cases, partial legacy records, adoption and frozen compatibility. Resolver-only string assertions cannot prove failure propagation. Independent checks and PASS gates remain required.

Changing global defaults cannot express repository policy; mutating interrupted sessions obscures attempt identity; recursive routing and hidden retry escalation exceed authorization. JSON plus the existing wrapper needs no new service or dependency. Source binding includes repository model configuration; local assignment records remain ignored. ADR-0026 continues to govern evidence, retry identity and report finalization.
