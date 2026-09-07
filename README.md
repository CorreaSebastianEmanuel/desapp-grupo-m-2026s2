# desapp-grupo-m-2026s2
UNQ-Desarrollo de Aplicacion- Alquimistas

## Agentic SDD

This repository includes a local Spec Kit workflow using an authenticated Codex CLI or Claude Code installation.

```bash
./setup
./agentflow                         # menu
./agentflow backlog
./agentflow create "Task title" --checkpoint CP1
./agentflow start TASK-001
./agentflow status TASK-001
./agentflow resume TASK-001
./agentflow verify TASK-001
./agentflow complete TASK-001       # after human review/merge
```

`start` runs specification, architecture, tasks, implementation, convergence, QA, and final review. When both verification gates pass it commits the generated feature branch, pushes it, and creates a GitHub PR. Merge remains human-controlled. Use `--no-pr` for a local-only run. Start from a clean, up-to-date `main` branch.

Agentflow prints every stage, a heartbeat every 20 seconds, and underlying CLI output in real time. It keeps stdin attached so permission or authentication prompts remain interactive. Runtime output is saved to `.agentflow/runs/TASK-NNN.live.log`; `status` reports the current stage and last activity. If interrupted with `Ctrl+C`, continue the preserved Spec Kit run with `./agentflow resume TASK-NNN`.

### Windows PowerShell

Install Python 3, Git for Windows (including Git Bash), `uv`, and Codex CLI or Claude Code. Then run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup.ps1
.\agentflow.ps1
.\agentflow.ps1 backlog
.\agentflow.ps1 start TASK-001
.\agentflow.ps1 complete TASK-001
```

Git Bash is required because the checked-in Spec Kit integration uses its portable shell scripts. The backlog, specs, workflow, and agent sessions are otherwise identical on macOS, Linux, and Windows.
