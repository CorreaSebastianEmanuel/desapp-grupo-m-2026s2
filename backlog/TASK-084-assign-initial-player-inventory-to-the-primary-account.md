---
id: TASK-084
title: Assign initial player inventory to the primary account
type: task
checkpoint: CP2
priority: high
workflow: thinflow-v1
status: review
depends_on: none
active_run: none
---

## Outcome

The complete local player workflow works from five-league catalog sync and search, through player-scoped statistics scraping/import and quote calculation, to portfolio buy/sell and operator visibility. Newly created catalog players and previously unissued players accepted through a player-scoped import receive exactly one initial 100-token issuance assigned to the explicitly configured primary account. Missing or ambiguous configuration never silently chooses a user; league-wide imports never mass-issue inventory.
