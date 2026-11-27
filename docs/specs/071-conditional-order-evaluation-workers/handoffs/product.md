# Product handoff

- **Decision**: Treat TASK-059 as the behavioral authority for order status, expiry, cancellation races, eligibility, rejection, and atomic purchase. TASK-060 owns orchestration and recovery; TASK-061 owns user-facing order presentation.
- **Assumption**: Recovery is eventual with no time-to-execution promise. A bounded immediate retry exhaustion leaves an order recoverable rather than converting infrastructure failure into a business rejection.
- **Guidance**: Preserve the CP2 architecture split: PostgreSQL is the durable source for work and order state; notifications only prompt connected views to reload after commit. Follow ADR-0017's bounded concurrency and reproducible creation-time/order-identity evaluation sequence without promising global priority.
- No unresolved product decision blocks planning. Any proposed change to the TASK-059 lifecycle or purchase outcomes requires revisiting that canonical spec before implementation.
