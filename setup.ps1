[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Require-Command([string] $Name, [string] $InstallHint) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name is required. $InstallHint"
    }
}

Require-Command "git" "Install it with: winget install Git.Git"
Require-Command "uv" "Install it with: winget install astral-sh.uv"

if (-not (Get-Command specify -ErrorAction SilentlyContinue)) {
    & uv tool install specify-cli
    if ($LASTEXITCODE -ne 0) { throw "Could not install Specify CLI" }
}

if (-not (Get-Command bash -ErrorAction SilentlyContinue)) {
    throw "Git Bash is required by the checked-in Spec Kit skills. Install Git for Windows and enable bash.exe on PATH."
}

$HasCodex = [bool](Get-Command codex -ErrorAction SilentlyContinue)
$HasClaude = [bool](Get-Command claude -ErrorAction SilentlyContinue)
if (-not $HasCodex -and -not $HasClaude) {
    throw "Install and authenticate Codex CLI or Claude Code."
}

Push-Location $Root
try {
    & specify integration status
    if ($LASTEXITCODE -ne 0) { throw "Spec Kit integration validation failed" }
    & (Join-Path $Root "agentflow.ps1") start TASK-001 --dry-run
    if ($LASTEXITCODE -ne 0) { throw "Agentflow validation failed" }
    Write-Host "Ready. Run .\agentflow.ps1 or .\agentflow.ps1 backlog."
} finally {
    Pop-Location
}
