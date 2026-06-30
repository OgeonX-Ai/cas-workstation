[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $repoRoot "stack.manifest.json"
$modulePath = Join-Path $repoRoot "scripts\Cas.Workstation.psm1"
$failures = New-Object System.Collections.Generic.List[string]

function Assert-CasEqual {
    param([string]$Name, $Actual, $Expected)

    if ($Actual -ne $Expected) {
        $failures.Add("$Name expected '$Expected' but was '$Actual'.")
    }
}

function Assert-CasTrue {
    param([string]$Name, [bool]$Condition)

    if (-not $Condition) {
        $failures.Add("$Name was false.")
    }
}

$testRoot = Join-Path $env:TEMP ("cas-contract-" + [guid]::NewGuid().ToString("N"))
$testConfig = Join-Path $testRoot "config"

try {
    New-Item -ItemType Directory -Path $testRoot -Force | Out-Null
    Import-Module $modulePath -Force
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json

    Assert-CasEqual "defaults.rootPath" $manifest.defaults.rootPath "C:\PersonalRepo"
    Assert-CasEqual "defaults.configPath" $manifest.defaults.configPath "C:\Users\KimHarjamaki\.cas"
    Assert-CasEqual "paths.reposRoot" $manifest.paths.reposRoot "portfolio"

    $requiredRepos = @(
        "Promptimprover",
        "autogen",
        "gsd-orchestrator",
        "cas-contracts",
        "cas-evals",
        "cas-reference-product",
        "cas-platform"
    )
    $fullRepos = @($manifest.profiles.full.repos)
    $catalogRepos = @($manifest.repos | ForEach-Object { $_.id })
    foreach ($repoId in $requiredRepos) {
        Assert-CasTrue "full profile contains $repoId" ($fullRepos -contains $repoId)
        Assert-CasTrue "repo catalog contains $repoId" ($catalogRepos -contains $repoId)
    }

    $mcpArgs = @($manifest.sharedMcpServer.args)
    Assert-CasEqual "sharedMcpServer argument count" $mcpArgs.Count 1
    if ($mcpArgs.Count -eq 1) {
        Assert-CasEqual "sharedMcpServer script" $mcpArgs[0] "C:\PersonalRepo\portfolio\Promptimprover\universal-refiner\dist\src\index.js"
    }

    $mcpStatusCommand = Get-Command Get-CasMcpServerStatus -ErrorAction SilentlyContinue
    Assert-CasTrue "doctor exposes MCP health function" ($null -ne $mcpStatusCommand)
    if ($null -ne $mcpStatusCommand) {
        $missingManifest = $manifest | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $missingManifest.defaults.rootPath = $testRoot
        $missingManifest.sharedMcpServer.args = @((Join-Path $testRoot "missing-runtime.js"))
        $mcpStatus = Get-CasMcpServerStatus -Manifest $missingManifest
        Assert-CasEqual "missing MCP runtime status" $mcpStatus.status "missing"
    }

}
finally {
    Remove-Item -LiteralPath $testRoot -Recurse -Force -ErrorAction SilentlyContinue
}

if ($failures.Count -gt 0) {
    Write-Error ("CAS workstation contract failed:`n - " + ($failures -join "`n - "))
    exit 1
}

Write-Host "CAS workstation contract passed."
exit 0
