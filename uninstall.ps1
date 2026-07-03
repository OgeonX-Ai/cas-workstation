[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = "High")]
param(
    [string]$RootPath,
    [string]$ConfigPath
)

$ErrorActionPreference = "Stop"
$env:USERPROFILE = "C:\Users\KimHarjamäki"
$env:HOME = "C:\Users\KimHarjamäki"
$env:AZURE_CONFIG_DIR = "C:\Users\KimHarjamäki\.azure"

Import-Module (Join-Path $PSScriptRoot "scripts\Cas.Workstation.psm1") -Force

$manifest = Get-CasManifest
if (-not $RootPath) { $RootPath = Get-CasDefaultRootPath -Manifest $manifest }
if (-not $ConfigPath) { $ConfigPath = Get-CasDefaultConfigPath -Manifest $manifest }

foreach ($target in @($RootPath, $ConfigPath)) {
    if (Test-Path -LiteralPath $target) {
        if ($PSCmdlet.ShouldProcess($target, "Remove CAS Workstation managed directory")) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
    }
}

Write-Host "CAS Workstation uninstall completed."

