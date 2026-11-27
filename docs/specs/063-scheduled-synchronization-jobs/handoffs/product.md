# Product handoff — TASK-019

No unresolved material product decision was identified during drafting. Independent product challenge has not yet run.

For the challenge, prioritize the distinction between an active run and a due occurrence: test whether the specification fully resolves incompatible-source work, coalesced occurrences that subsequently fail, and schedule disable/re-enable during downtime. Raise any ambiguity before architecture chooses persistence mechanics.

Architecture should justify how admission, occurrence tracking and completion recovery compose with the existing ingestion transaction. Inspect the TASK-018 contract before designing the worker; successful domain publication and durable worker completion are distinct failure boundaries. Avoid using queue uniqueness configuration as the sole argument for correctness.

Do not infer feature numbering from TASK IDs or branch names. The canonical directory is bound by `.specify/feature.json`; the branch is already supplied by this stage's environment.

The working tree contained a pre-existing modification to the TASK-019 backlog record on entry. It was left untouched.
