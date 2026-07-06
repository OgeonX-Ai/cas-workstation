$personaDir = "C:\\PersonalRepo\\engineering-os\\personas"
$requiredTags = @("<Identity>","</Identity>","<Tone>","</Tone>","<Cognitive_Protocol>","</Cognitive_Protocol>","<Behavioral_Guardrails>","</Behavioral_Guardrails>","<Few_Shot_Patterns>","</Few_Shot_Patterns>")
$allOk = $true
foreach ($file in Get-ChildItem $personaDir -Filter *.md) {
    $content = Get-Content $file.FullName -Raw
    foreach ($tag in $requiredTags) {
        if (-not $content.Contains($tag)) {
            Write-Host "Missing $tag in $($file.Name)" -ForegroundColor Red
            $allOk = $false
        }
    }
}
if ($allOk) { exit 0 } else { exit 1 }
