---
id: TASK-030
title: Atomic idempotent token sale
type: task
checkpoint: CP2
priority: critical
workflow: thinflow-v1
status: done
depends_on: TASK-029
active_run: none
---

## Outcome

Sell owned tokens at the current quote while preserving holdings, balance, supply, and ledger.

## Human decision (2026-10-27, ezequielgonzalez)

A sale mirrors the TASK-029 purchase contract: the designated initial
recipient (market stand) buys the seller's tokens at the one authoritative
current quote, pays the seller from its own credited balance, all-or-nothing,
rejected unchanged when the market lacks the exact credits the sale requires.
No user-to-user resale listings, no fees, and no synthetic crediting.


