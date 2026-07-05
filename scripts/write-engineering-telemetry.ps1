[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter(Mandatory)][string]$OutputPath
)

$event = Get-Content -LiteralPath $InputPath -Raw | ConvertFrom-Json
$required = @('tool', 'agentRole', 'modelAlias', 'elapsedMs', 'retries', 'contextEstimate', 'verifierResult', 'rework', 'routingConfidence')
foreach ($name in $required) { if (-not $event.PSObject.Properties[$name]) { throw "Telemetry missing $name" } }
$line = $event | ConvertTo-Json -Depth 6 -Compress
[System.IO.File]::AppendAllText($OutputPath, $line + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
Write-Output "Telemetry appended: $OutputPath"
