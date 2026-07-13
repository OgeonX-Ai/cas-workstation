[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$Apply,
    [string]$TargetRoot
)

$root = Split-Path -Parent $PSScriptRoot
$adapterRoot = Join-Path $root 'engineering-os\adapters'
$backup = Join-Path $adapterRoot 'backups'
$manifest = Get-Content (Join-Path $adapterRoot 'backup-manifest.json') -Raw | ConvertFrom-Json
$activeProfile = 'C:\Users\KimHarjamäki'
$targets = @{
    'codex-home-AGENTS.md' = 'C:\codex-home\AGENTS.md'
    'codex-profile-AGENTS.md' = (Join-Path $activeProfile '.codex\AGENTS.md')
    'claude-CLAUDE.md' = (Join-Path $activeProfile '.claude\CLAUDE.md')
    'gemini-gemini.md' = (Join-Path $activeProfile '.gemini\gemini.md')
    'shared-GLOBAL_AGENTS.md' = (Join-Path $activeProfile '.config\ai-agents\GLOBAL_AGENTS.md')
}

if ($TargetRoot) {
    New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
    foreach ($name in @($targets.Keys)) { $targets[$name] = Join-Path $TargetRoot $name }
}

$snapshotRoot = Join-Path $env:TEMP ("engineering-os-pre-rollback-" + (Get-Date -Format 'yyyyMMddHHmmss'))
foreach ($entry in $targets.GetEnumerator()) {
    $source = Join-Path $backup $entry.Key
    if (-not (Test-Path -LiteralPath $source)) { throw "Missing backup: $source" }
    $actualHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
    $expectedHash = $manifest.files.PSObject.Properties[$entry.Key].Value
    if ($actualHash -ne $expectedHash) { throw "Backup provenance failure: $($entry.Key)" }
    $content = Get-Content -LiteralPath $source -Raw
    if ($content -match '(?i)infinite healing loop|zero-touch deployment|direct deployment to production') {
        throw "Unsafe legacy directive in restorable backup: $($entry.Key)"
    }

    if (-not $Apply) { Write-Output "Would restore verified $source -> $($entry.Value)"; continue }
    if ($PSCmdlet.ShouldProcess($entry.Value, "Atomic restore from $source")) {
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $entry.Value) | Out-Null
        if (Test-Path -LiteralPath $entry.Value) {
            New-Item -ItemType Directory -Force -Path $snapshotRoot | Out-Null
            Copy-Item -LiteralPath $entry.Value -Destination (Join-Path $snapshotRoot $entry.Key) -Force
        }
        $temp = "$($entry.Value).restore-$([guid]::NewGuid().ToString('N'))"
        Copy-Item -LiteralPath $source -Destination $temp -Force
        if ((Get-FileHash -LiteralPath $temp -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expectedHash) {
            Remove-Item -LiteralPath $temp -Force
            throw "Staged restore hash mismatch: $($entry.Key)"
        }
        Move-Item -LiteralPath $temp -Destination $entry.Value -Force
    }
}

if (-not $Apply) { Write-Output 'Dry run only. Pass -Apply to restore.' }
elseif (Test-Path $snapshotRoot) { Write-Output "Pre-rollback snapshot: $snapshotRoot" }
