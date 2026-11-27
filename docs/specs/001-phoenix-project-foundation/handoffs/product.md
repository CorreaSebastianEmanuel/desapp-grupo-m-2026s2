# Product Handoff: Phoenix Project Foundation

## Decisions

- Define the foundation around three independently verifiable contributor outcomes: successful compilation, a regression-detecting automated test baseline, and reproducible local startup.
- Require clean-checkout reproducibility and explicit prepare, compile, test, start, reachability-check, and stop instructions.
- Treat a reachable default page as sufficient runtime evidence for this task. Product-specific routes and screens are deferred.
- Keep database and cache provisioning out of scope because TASK-002 owns the PostgreSQL and Redis environment; keep continuous integration out of scope because TASK-003 owns that baseline.
- Introduce no domain entities or business behavior. Architecture boundaries are preserved as constraints for later work rather than populated prematurely.

## Assumptions

- The architecture-mandated modular Phoenix application is accepted as a fixed project constraint.
- The supported local environment and prerequisite versions will be chosen during planning and documented for contributors.
- The initial test may exercise the generated application surface, but it must be meaningful, discovered by the standard suite, and capable of demonstrating a failing exit status.
- No credentials or external provider access are necessary to establish this foundation.

## Open Questions

- No product-level clarification blocks planning.
- The architect should decide the narrowest supported runtime/tool versions and whether the generated project should defer repository-backed startup until TASK-002, while still satisfying the clean-start acceptance scenario.
- The architect should make the boundary between TASK-001 and TASK-002 explicit if generated defaults introduce a database startup dependency.

## Evidence

- `backlog/TASK-001-phoenix-project-foundation.md` defines the compiling application, minimal test baseline, and documented startup outcome.
- `docs/ARCHITECTURE.md` mandates one modular Elixir/Phoenix application and separation among presentation, domain, persistence, workers, cache, and external adapters.
- `docs/CHECKPOINTS.md` makes a working repository and unit tests foundational CP1 obligations; later CP1 tasks own CI, authentication, OpenAPI, and the player catalog.
- `docs/PRODUCT.md` defines sensitive domain invariants that this foundation must not accidentally implement or weaken.
- `.specify/memory/constitution.md` requires specification before implementation, modular simplicity, automated tests for behavior, and evidence-based checks.
- The specification quality checklist records a complete first-pass validation with no clarification markers.

## Guidance for the Critic

- Challenge whether every requirement can be demonstrated from a genuinely clean checkout rather than a prepared maintainer machine.
- Test whether “meaningful test” and “reachable default page” are specific enough to prevent a vacuous baseline.
- Look for hidden dependencies on PostgreSQL or Redis that would blur ownership with TASK-002.
- Flag any business behavior, deployment concerns, or CI requirements that expand this task beyond its foundation outcome.

## Guidance for the Architect

- Choose the smallest generated foundation consistent with the architecture baseline and CP1 trajectory.
- Map each acceptance scenario to an executable verification command and documentation section.
- Resolve generated database assumptions explicitly: either make foundation startup independent of TASK-002 or document the smallest justified coordination point without absorbing TASK-002.
- Keep framework configuration and module boundaries ready for later contexts without scaffolding speculative domain modules.
- Carry clean-checkout reproducibility, failure visibility, and regression-detection evidence into the plan and test strategy.

