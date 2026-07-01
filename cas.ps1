[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("setup", "doctor", "start", "upgrade", "uninstall")]
    [string]$Command,

    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$CommandArguments
)

$ErrorActionPreference = "Stop"
$entryPoints = @{
    setup = "setup.ps1"
    doctor = "doctor.ps1"
    start = "start.ps1"
    upgrade = "upgrade.ps1"
    uninstall = "uninstall.ps1"
}

$scriptPath = Join-Path $PSScriptRoot $entryPoints[$Command]
if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
    throw "CAS command '$Command' is unavailable because '$scriptPath' was not found."
}

& $scriptPath @CommandArguments
if (-not $?) {
    exit 1
}

exit 0
