# desapp-grupo-m-2026s2
UNQ-Desarrollo de Aplicacion- Alquimistas

## Agentic SDD

This repository includes a local Spec Kit workflow using an authenticated Codex CLI installation.

```bash
./setup
./agentflow                         # menu
./agentflow backlog
./agentflow create "Task title" --checkpoint CP1
./agentflow start TASK-001
./agentflow status TASK-001
./agentflow feedback TASK-001 "Use Phoenix 1.8" --stage architecture
./agentflow history TASK-001
./agentflow resume TASK-001
./agentflow verify TASK-001
./agentflow complete TASK-001       # after human review/merge
```

`start` runs seven fresh-agent stages: product specification, an independent product challenge, architecture synthesis, validated task planning, implementation, adversarial QA, and final review. Multiple perspectives are used at decision and verification boundaries; implementation keeps one owner to avoid conflicting edits. When both verification gates pass it commits the generated feature branch, pushes it, and creates a GitHub PR. A failed gate leaves the task blocked so feedback can rewind it to the affected stage. Merge remains human-controlled. Use `--no-pr` for a local-only run. Start from a clean, up-to-date `main` branch.

Agentflow prints every stage, a heartbeat every 20 seconds, and underlying CLI output in real time. It keeps stdin attached so permission or authentication prompts remain interactive. Runtime output is saved to `.agentflow/runs/TASK-NNN.live.log`; `status` reports the current stage and last activity. If interrupted with `Ctrl+C`, continue the preserved Spec Kit run with `./agentflow resume TASK-NNN`.

Agents exchange structured handoffs under the active feature's `handoffs/` directory. Human feedback is versioned in `backlog/feedback/TASK-NNN.md`; adding feedback rewinds the preserved workflow to the selected affected stage. `history` shows feedback, handoffs, and stage results. A task accepts at most three feedback cycles before it must be resolved or split, preventing unbounded autonomous loops.

QA executes applicable checks rather than only inspecting code. When a task exposes or changes HTTP endpoints, QA must start the application and exercise the affected endpoints with real HTTP requests (such as `curl`), including specified success and failure cases. An unavailable runtime is reported as a blocker, not skipped.

### Windows PowerShell

Install Python 3, Git for Windows (including Git Bash), `uv`, and Codex CLI. Then run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup.ps1
.\agentflow.ps1
.\agentflow.ps1 backlog
.\agentflow.ps1 start TASK-001
.\agentflow.ps1 complete TASK-001
```

Git Bash is required because the checked-in Spec Kit integration uses its portable shell scripts. The backlog, specs, workflow, and agent sessions are otherwise identical on macOS, Linux, and Windows.
