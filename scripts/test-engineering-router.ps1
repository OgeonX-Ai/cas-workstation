[CmdletBinding()]
param()

$root = Split-Path -Parent $PSScriptRoot
$fixtures = Get-Content (Join-Path $root 'engineering-os\router\fixtures.json') -Raw | ConvertFrom-Json
$classifier = Join-Path $PSScriptRoot 'classify-engineering-task.ps1'
$failures = @()

foreach ($fixture in $fixtures) {
    $actual = & $classifier -Task $fixture.input
    foreach ($name in @('taskClass', 'risk', 'sdlcProfile', 'roleAlias')) {
        if ($actual.$name -ne $fixture.expected.$name) {
            $failures += "$($fixture.input): $name expected $($fixture.expected.$name), got $($actual.$name)"
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Output "Router fixtures passed: $($fixtures.Count)/$($fixtures.Count)"
