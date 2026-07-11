param(
    [string]$Model = "gpt-4.1-mini",
    [switch]$SkipValidation,
    [switch]$UseExistingKey
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$profileRoot = "C:\Users\KimHarjamaki"
$env:USERPROFILE = $profileRoot
$env:HOME = $profileRoot
$env:AZURE_CONFIG_DIR = Join-Path $profileRoot ".azure"

function Read-SecretValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Prompt
    )

    $secure = Read-Host -Prompt $Prompt -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    }
    finally {
        if ($bstr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
}

function Mask-Secret {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return "<missing>"
    }

    if ($Value.Length -le 8) {
        return ("*" * $Value.Length)
    }

    return "{0}...{1}" -f $Value.Substring(0, 4), $Value.Substring($Value.Length - 4, 4)
}

function Set-UserEnvironmentVariable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    [System.Environment]::SetEnvironmentVariable($Name, $Value, "User")
    Set-Item -Path ("Env:{0}" -f $Name) -Value $Value
}

function Get-UserEnvironmentVariable {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $processValue = [System.Environment]::GetEnvironmentVariable($Name, "Process")
    if (-not [string]::IsNullOrWhiteSpace($processValue)) {
        return $processValue
    }

    $userValue = [System.Environment]::GetEnvironmentVariable($Name, "User")
    if (-not [string]::IsNullOrWhiteSpace($userValue)) {
        Set-Item -Path ("Env:{0}" -f $Name) -Value $userValue
        return $userValue
    }

    return $null
}

function Invoke-OpenAiValidation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,
        [Parameter(Mandatory = $true)]
        [string]$ModelName
    )

    $headers = @{
        Authorization = "Bearer $ApiKey"
        "Content-Type" = "application/json"
    }

    $body = @{
        model = $ModelName
        input = "Reply with OK."
        max_output_tokens = 16
    } | ConvertTo-Json -Depth 5

    return Invoke-RestMethod -Method Post -Uri "https://api.openai.com/v1/responses" -Headers $headers -Body $body
}

if ($UseExistingKey) {
    $apiKey = Get-UserEnvironmentVariable -Name "OPENAI_API_KEY"
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "OPENAI_API_KEY is not set in the current or user environment."
    }
    Write-Host "Using existing OPENAI_API_KEY from the Windows user environment."
}
else {
    $apiKey = Read-SecretValue -Prompt "Paste the new OpenAI API key"
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        throw "No API key was provided."
    }
}

if (-not $apiKey.StartsWith("sk-")) {
    throw "The value does not look like an OpenAI API key."
}

if (-not $UseExistingKey) {
    Set-UserEnvironmentVariable -Name "OPENAI_API_KEY" -Value $apiKey
    Write-Host "Stored OPENAI_API_KEY in the Windows user environment for $profileRoot."
}
else {
    Write-Host "OPENAI_API_KEY is present in the Windows user environment for $profileRoot."
}

Write-Host "Current process value: $(Mask-Secret -Value $env:OPENAI_API_KEY)"
Write-Host "Verified workspace consumers:"
Write-Host "- portfolio/autogen autogen_starter can read OPENAI_API_KEY from process environment."
Write-Host "- portfolio/autogen MAF starter does not use OPENAI_API_KEY today; it expects MAF_API_KEY or GEMINI_API_KEY."
Write-Host "- portfolio/cas-reference-product does not currently consume an OpenAI API key."

if ($SkipValidation) {
    Write-Host "Skipped API validation."
    return
}

try {
    $response = Invoke-OpenAiValidation -ApiKey $apiKey -ModelName $Model
    $responseId = $response.id
    Write-Host "OpenAI API validation succeeded with model '$Model'. Response id: $responseId"
}
catch {
    $httpResponse = $_.Exception.Response
    if ($httpResponse -and $httpResponse.StatusCode.value__ -eq 429) {
        Write-Warning "OpenAI API returned HTTP 429. The key is present, but the account/project is currently rate-limited or missing usable quota/billing for this model."
        Write-Warning "This is not a local secret-storage failure. Check OpenAI project limits, billing, and model access."
        exit 2
    }

    Write-Error ("OpenAI API validation failed: {0}" -f $_.Exception.Message)
    exit 1
}
