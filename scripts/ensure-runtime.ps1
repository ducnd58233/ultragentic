<#
.SYNOPSIS
  Makes sure the ultragentic runtime is installed, for an AI agent to call.

.DESCRIPTION
  The user never has to install the runtime by hand. When a delivery command finds
  it missing, the agent runs this script (see .ai-agents/references/runtime-bootstrap.md).
  The license is a condition of use, so the agent asks the user and only then
  reruns this with $env:UA_ACCEPT_LICENSE = '1'; this script never assumes consent.

  Exit codes: 0 installed and answering `version`; 3 not installed and the license
  has not been accepted (ask the user); 1 the install failed.
#>
$ErrorActionPreference = 'Stop'
$installDir = if ($env:UA_INSTALL_DIR) { $env:UA_INSTALL_DIR } else { Join-Path $env:USERPROFILE '.local\bin' }
$env:PATH = "$installDir;$env:PATH"

function Test-Runtime {
    $cmd = Get-Command ultragentic -ErrorAction SilentlyContinue
    if (-not $cmd) { return $null }
    try { & $cmd.Source version *> $null; if ($LASTEXITCODE -eq 0) { return $cmd.Source } } catch { }
    return $null
}

$found = Test-Runtime
if ($found) {
    Write-Host "ultragentic runtime ready: $((& $found version | Select-Object -First 1))"
    Write-Host "binary: $found"
    exit 0
}

if ($env:UA_ACCEPT_LICENSE -ne '1') {
    Write-Host 'LICENSE_REQUIRED'
    Write-Host 'The ultragentic runtime is not installed. It is a closed-source binary under'
    Write-Host 'RUNTIME-LICENSE.md: free to use, including commercially; no reverse engineering,'
    Write-Host "no redistribution. License text: $(Join-Path $PSScriptRoot '..\RUNTIME-LICENSE.md')"
    Write-Host 'Ask the user whether to install it. If they agree, run:'
    Write-Host "  `$env:UA_ACCEPT_LICENSE = '1'; powershell -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Write-Host 'If they decline, stop; the delivery commands cannot run without it.'
    exit 3
}

try {
    & (Join-Path $PSScriptRoot 'install-runtime.ps1')
} catch {
    Write-Error "ensure-runtime: the install failed: $($_.Exception.Message)"
    exit 1
}
$target = Join-Path $installDir 'ultragentic.exe'
try { & $target version *> $null } catch { }
if ($LASTEXITCODE -ne 0) { Write-Error "ensure-runtime: installed $target but it does not run."; exit 1 }
Write-Host "binary: $target"
Write-Host "If a later command says 'not recognized', call it by that path or open a new terminal."
exit 0
