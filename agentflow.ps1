[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $AgentflowArgs
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3 (Join-Path $Root "agentflow") @AgentflowArgs
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    & python (Join-Path $Root "agentflow") @AgentflowArgs
} else {
    throw "Python 3 is required. Install it with: winget install Python.Python.3.13"
}

exit $LASTEXITCODE

