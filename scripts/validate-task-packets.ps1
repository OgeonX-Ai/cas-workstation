[CmdletBinding()]
param([Parameter(Mandatory)][string]$Path)

$parsed = Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
$packets = @()
foreach ($item in $parsed) { $packets += $item }
$writers = @($packets | Where-Object mutation)
foreach ($packet in $packets) {
    if ($packet.maxDelegationDepth -lt 0 -or $packet.maxDelegationDepth -gt 2) { throw "Invalid delegation depth: $($packet.goal)" }
    if ($packet.mutation -and (-not $packet.worktree -or @($packet.writeScope).Count -eq 0)) { throw "Writer lacks worktree or write scope: $($packet.goal)" }
}
for ($i = 0; $i -lt $writers.Count; $i++) {
    for ($j = $i + 1; $j -lt $writers.Count; $j++) {
        if ($writers[$i].worktree -eq $writers[$j].worktree) {
            $overlap = @($writers[$i].writeScope | Where-Object { $writers[$j].writeScope -contains $_ })
            if ($overlap.Count) { throw "Writer collision in $($writers[$i].worktree): $($overlap -join ', ')" }
        }
    }
}
Write-Output "Task packets valid: $($packets.Count); writers: $($writers.Count); collisions: 0"
