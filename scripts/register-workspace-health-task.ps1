<#
.SYNOPSIS
  Registers (idempotently) the daily workspace-health sweep as a Windows
  Scheduled Task (REQ-1.4.12 / Phase 34-02).
.DESCRIPTION
  Creates task 'CAS-WorkspaceHealth' running scripts\workspace-health.ps1
  daily at 08:00 under the current user. Running this script twice does not
  create a duplicate task - if the task exists it is updated in place.
.EXAMPLE
  powershell -NoProfile -File scripts\register-workspace-health-task.ps1
  powershell -NoProfile -File scripts\register-workspace-health-task.ps1 -At '18:30'
#>
[CmdletBinding()]
param(
    [string]$TaskName = 'CAS-WorkspaceHealth',
    [string]$Root = 'C:\PersonalRepo',
    [string]$At = '08:00'
)

$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $Root 'scripts\workspace-health.ps1'
if (-not (Test-Path -LiteralPath $scriptPath)) {
    Write-Error "Sweep script not found: $scriptPath"
    exit 1
}

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -WindowStyle Hidden -File `"$scriptPath`" -Root `"$Root`"" `
    -WorkingDirectory $Root
$trigger = New-ScheduledTaskTrigger -Daily -At $At
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existing) {
    Set-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings | Out-Null
    Write-Host "Updated existing scheduled task '$TaskName' (daily at $At)."
} else {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings `
        -Description 'CAS workspace-health drift sweep (Phase 34, REQ-1.4.12)' | Out-Null
    Write-Host "Registered scheduled task '$TaskName' (daily at $At)."
}
exit 0
