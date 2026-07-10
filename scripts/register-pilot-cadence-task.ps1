<#
.SYNOPSIS
  Registers (idempotently) the weekly pilot-cadence evidence run as a Windows
  Scheduled Task (REQ-1.5.4 / Phase 40-02).
.DESCRIPTION
  Creates task 'CAS-PilotCadence' running scripts\run-pilot-cadence.ps1
  weekly on $DayOfWeek at $At under the current user. Running this script
  twice does not create a duplicate task - if the task exists it is updated
  in place. Mirrors scripts\register-workspace-health-task.ps1's idempotent
  pattern, only changing the trigger cadence and target script.
.EXAMPLE
  powershell -NoProfile -File scripts\register-pilot-cadence-task.ps1
  powershell -NoProfile -File scripts\register-pilot-cadence-task.ps1 -At '10:00'
#>
[CmdletBinding()]
param(
    [string]$TaskName = 'CAS-PilotCadence',
    [string]$Root = 'C:\PersonalRepo',
    [string]$DayOfWeek = 'Sunday',
    [string]$At = '09:00'
)

$ErrorActionPreference = 'Stop'

$scriptPath = Join-Path $Root 'scripts\run-pilot-cadence.ps1'

$action = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -WindowStyle Hidden -File `"$scriptPath`" -Root `"$Root`"" `
    -WorkingDirectory $Root
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DayOfWeek -At $At
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

$existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existing) {
    Set-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings | Out-Null
    Write-Host "Updated existing scheduled task '$TaskName' (weekly $DayOfWeek at $At)."
} else {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Settings $settings `
        -Description 'CAS pilot-cadence weekly evidence run (Phase 40, REQ-1.5.4) -- pilot scenarios + fault-injection suites, evidence via PR, regressions auto-file issues.' | Out-Null
    Write-Host "Registered scheduled task '$TaskName' (weekly $DayOfWeek at $At)."
}
exit 0
