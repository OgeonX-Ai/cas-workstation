param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('setup', 'doctor', 'start', 'upgrade', 'uninstall')]
    [string]$Command
)

$ErrorActionPreference = 'Stop'
$ScriptRoot = $PSScriptRoot

switch ($Command) {
    'setup' {
        Write-Host "Running setup..."
        & (Join-Path $ScriptRoot "setup.ps1")
    }
    'doctor' {
        Write-Host "Running doctor..."
        & (Join-Path $ScriptRoot "doctor.ps1")
    }
    'start' {
        Write-Host "Running start..."
        & (Join-Path $ScriptRoot "start.ps1")
    }
    'upgrade' {
        Write-Host "Running upgrade..."
        & (Join-Path $ScriptRoot "upgrade.ps1")
    }
    'uninstall' {
        Write-Host "Running uninstall..."
        & (Join-Path $ScriptRoot "uninstall.ps1")
    }
}

