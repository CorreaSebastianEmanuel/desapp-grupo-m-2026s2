# Agent execution providers

Agentflow dispatches every agent stage through one provider CLI. The provider
is a seam (`scripts/agentflow_providers.py`), not a string replacement: model
availability lives in external configuration, sessions stay bound to the
provider that created them, and Spec Kit's workflow, gates, prompts and
metrics remain identical across providers.

## Selecting a provider

```bash
./agentflow start TASK-NNN --provider codex      # default, unchanged behavior
./agentflow start TASK-NNN --provider opencode   # OpenCode CLI (opencode run)
./agentflow resume TASK-NNN                      # keeps the run's provider
./agentflow verify TASK-NNN --provider opencode  # auxiliary commands follow the selection
```

- The repository default lives in `.agentflow/config.toml` (`default_provider`).
  `auto` and absence both mean the value there; today it is `codex`.
- `--agent` remains accepted as a legacy alias of `--provider`; using both
  with different values is refused before anything is launched.
- `resume` always reuses the provider frozen in the run's assignment. Passing
  a different `--provider` is refused: switching requires
  `--adopt-models --provider opencode`, which opens a new assignment
  generation and a fresh session rather than replaying half a run through
  another CLI.

## Configuring models

`.agentflow/models.json` owns one model/effort pair per stage in the
repository's canonical (Codex) selection space. Provider-capable models live
in `.agentflow/providers.json`:

```json
{
  "schema_version": 1,
  "providers": {
    "codex":   {"models": ["gpt-6-luna", "gpt-6.1-sol"], "efforts": ["low", "medium", "high"]},
    "opencode": {"models": ["opencode-go/glm-5.3-flash"],
                 "stage_models": {"*": "opencode-go/glm-5.3-flash"},
                 "verify_model": "opencode-go/glm-5.3-flash"}
  }
}
```

- Codex keeps the legacy pair semantics (`--model`, `-c model_reasoning_effort`).
- OpenCode carries the model in a single `-m provider/model#variant` flag and
  has no reasoning-effort parameter; Agentflow never invents one for it.
- `stage_models` maps each repository stage model onto a provider model. An
  explicit CLI/task model override must already be provider-available; Agentflow
  refuses it rather than silently swapping the operator's choice.
- Verify the models your account actually serves with `opencode models`
  before editing the list.

## How dispatch works

1. `./agentflow start --provider <p>` passes `--input integration=<p>` to
   Spec Kit, which resolves the provider via its built-in integration and
   resolves the executable from the environment.
2. Agentflow interposes a forwarding shim for each provider without touching
   Spec Kit:
   - `SPECKIT_INTEGRATION_CODEX_EXECUTABLE` → `scripts/agentflow_codex.py`,
     with `SPECKIT_INTEGRATION_CODEX_EXTRA_ARGS=--approve-for-me`.
   - `SPECKIT_INTEGRATION_OPENCODE_EXECUTABLE` → `scripts/agentflow_opencode.py`,
     with `SPECKIT_INTEGRATION_OPENCODE_EXTRA_ARGS=--auto`.
   - `AGENTFLOW_CODEX_REAL` / `AGENTFLOW_OPENCODE_REAL` carry the real CLI path.
   Operator-set overrides of the shim executable always win.
3. Each shim validates the frozen per-stage assignment (`launch_args`),
   appends the provider-owned flags only, records structured usage under
   `.agentflow/runs/<TASK>.metrics.jsonl`, and keeps qa/review report
   provenance attestations. OpenCode's stream reports no token usage, so its
   usage is recorded as explicitly unknown; metrics completeness stays false
   until the provider exposes accounting.

## Verify the installation

```bash
which codex opencode                      # both provider CLIs installed
opencode auth list                        # authenticated (OpenCode Go plan)
opencode models                           # models actually available
python3 -m unittest discover -s test/scripts -p "agentflow_providers_test.py" -t .
```

OpenCode needs its Spec Kit commands installed once:
`specify integration install opencode --force` (codex remains the default
integration; `.specify/integration.json` records both).
