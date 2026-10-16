# Repository stage assignment

`.agentflow/models.json` owns schema-1 defaults. The shared resolver validates both approved models (`gpt-6-luna`, `gpt-6.1-sol`) with low/medium/high effort. This matrix is local policy, not a provider availability guarantee.

| Stage | Model | Effort |
| --- | --- | --- |
| product | gpt-6-luna | high |
| product_challenge | gpt-6-luna | high |
| architecture | gpt-6.1-sol | medium |
| develop | gpt-6-luna | high |
| qa | gpt-6.1-sol | low |
| review | gpt-6.1-sol | medium |

Inspect a new selection without writing state or launching a child:

```sh
./agentflow start TASK-NNN --dry-run
./agentflow start TASK-NNN --dry-run --stage-model develop=gpt-6.1-sol --stage-effort develop=medium
```

Each field resolves independently: stage CLI, run-wide CLI (`--model`, `--effort`), task `develop_model`/`develop_effort`, repository stage default. Duplicate flags, unknown stages, unsupported pairs and conflicting unmanaged launch settings fail visibly. Development overrides do not alter another stage. Choose an explicit Sol override when concurrency, transactions, idempotency or security warrants it; there is no classifier or fallback. No global user settings change.

Normal `./agentflow resume TASK-NNN --dry-run` inspects saved assignments. Repository edits cannot change a saved pair. Selection flags on resume require `--adopt-models`; adoption freezes a future generation and reopens the interrupted stage, preserving completed attempts. Example:

```sh
./agentflow resume TASK-NNN --adopt-models --stage-model develop=gpt-6.1-sol --stage-effort develop=medium --dry-run
```

For a legacy run lacking structured launch settings, absent fields are unknown. Supply each missing field explicitly with adoption, for example `--adopt-models --model gpt-6.1-sol --effort medium`. This chooses future launches and does not recover historical observations. Generation files and bindings remain ignored locally; never edit them manually. Active processes must be interrupted before adoption.

Frozen run `72789de8` may continue its original settings. This delivery does not claim that run exercised the new defaults. Configured and resolved values are distinct from provider-observed identity; unavailable observations remain null. Product challenge, separate development/QA/review sessions, required checks and both terminal PASS gates remain mandatory. Provider rejection or spawn failure produces one failed launch, with no hidden retry escalation.
