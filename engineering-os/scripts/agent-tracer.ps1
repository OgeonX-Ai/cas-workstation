param (
    [Parameter(Mandatory=$true)]
    [string]$ActionType, # e.g., 'agent.reasoning', 'agent.tool_execution', 'llm.generation'
    
    [Parameter(Mandatory=$true)]
    [string]$Persona,
    
    [Parameter(Mandatory=$false)]
    [string]$TraceId = $([guid]::NewGuid().ToString()),
    
    [Parameter(Mandatory=$false)]
    [string]$SpanId = $([guid]::NewGuid().ToString().Substring(0,8)),
    
    [Parameter(Mandatory=$false)]
    [string]$ReasoningPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ToolCall = "",
    
    [Parameter(Mandatory=$false)]
    [int]$TokensPrompt = 0,
    
    [Parameter(Mandatory=$false)]
    [int]$TokensCompletion = 0
)

$traceFile = "C:\PersonalRepo\.planning\traces.jsonl"

# Create the directory if it doesn't exist
$traceDir = Split-Path $traceFile
if (-not (Test-Path $traceDir)) {
    New-Item -ItemType Directory -Force -Path $traceDir | Out-Null
}

$timestamp = (Get-Date).ToString("o")

$logEntry = [ordered]@{
    timestamp = $timestamp
    trace_id = $TraceId
    span_id = $SpanId
    action_type = $ActionType
    persona = $Persona
    metrics = @{
        tokens_prompt = $TokensPrompt
        tokens_completion = $TokensCompletion
        total_tokens = ($TokensPrompt + $TokensCompletion)
    }
}

if ($ReasoningPath -ne "") {
    $logEntry.reasoning_path = $ReasoningPath
}

if ($ToolCall -ne "") {
    $logEntry.tool_call = $ToolCall
}

$jsonLog = $logEntry | ConvertTo-Json -Depth 5 -Compress

Add-Content -Path $traceFile -Value $jsonLog
Write-Host "Trace emitted -> $traceFile"
