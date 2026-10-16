# Next authorized task comparison protocol

TASK-064 delivers this protocol and deterministic fixtures. It does not start another backlog task, run a paid experiment or claim percentage token or quality savings.

The historical comparison configuration is Sol Medium for every stage. Missing historical model identity, reasoning effort, token dimensions, file counts or retry causes are **unknown**; do not recover a baseline through broad historical log exploration. The comparison configuration uses the six stage defaults in [AGENTFLOW_MODELS.md](AGENTFLOW_MODELS.md). An explicit development Sol override is recorded separately with its per-field source. Frozen run 72789de8 retains its original assignment and is not evidence of the new defaults.

At the beginning of the next normally authorized task, record its task ID, source revision, checkpoint, scope and resolved assignment from the dry run. Use the task's ordinary authorization; do not invoke a second task merely to measure this workflow. Keep workflow changes and model changes as separate comparison factors. A single differently scoped task cannot isolate either factor.

Capture consumption using the existing allowlisted interface:

```sh
./agentflow metrics TASK-NNN
```

Record stage/attempt counts, configured/resolved/observed model and effort, reported input, cached input, output and reasoning tokens, dimension coverage and unknown counts. Cached input and reasoning output are subsets; never add them to parent totals. Report measured subtotals as partial whenever coverage is incomplete. Elapsed check time is not token usage.

Record a base revision before delivery. At the final candidate, measure added versioned/generated files without inspecting their contents:

```sh
git diff --name-only --diff-filter=A BASE_REVISION -- specs docs
python3 - <<'PY'
import pathlib, subprocess
names=set(subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard','-z','--','specs','docs']).decode().split('\0'))-{''}
files=[pathlib.Path(name) for name in names if pathlib.Path(name).is_file()]
print({'files':len(files),'bytes':sum(path.stat().st_size for path in files)})
PY
```

Take the same count/byte observation at baseline and final candidate; report generated additions separately from pre-existing files and modifications. Exclude ignored logs, receipts and dependency outputs. Record mandatory canonical completeness, applicability decisions, supporting-document counts, bounded summary size and independent report size. Do not equate fewer bytes with complete requirements.

Record retry counts and causes from local check summaries and structured attempt metrics, distinguishing environment, implementation and requirement repairs. Record every required check outcome, elapsed check time, readiness result, fresh independent QA/review verdicts and human acceptance outcome. Unknown causes remain unknown; do not scan unrelated sessions.

A comparison report names baseline availability, task scope differences, tool/service parity, assignment overrides, partial consumption coverage, repairs and quality outcomes. Missing comparable baseline data prevents a savings calculation. Preserve independent verification even when development reuses intact receipts. No benchmark, automatic switching or inferred savings is authorized by this protocol.
