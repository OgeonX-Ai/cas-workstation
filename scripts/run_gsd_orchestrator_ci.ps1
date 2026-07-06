Set-StrictMode -Version Latest
# Change to orchestrator directory
Push-Location "portfolio\gsd-orchestrator"
# Restore and build
dotnet restore src/GsdOrchestrator/GsdOrchestrator.csproj
if ($LASTEXITCODE) { Write-Error "Restore failed"; exit 1 }
dotnet build src/GsdOrchestrator/GsdOrchestrator.csproj --configuration Release
if ($LASTEXITCODE) { Write-Error "Build failed"; exit 1 }
# Restore and build tests
dotnet restore src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj
if ($LASTEXITCODE) { Write-Error "Test restore failed"; exit 1 }
dotnet build src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj --configuration Release
if ($LASTEXITCODE) { Write-Error "Test build failed"; exit 1 }
# Run tests with coverage
dotnet test src/GsdOrchestrator.Tests/GsdOrchestrator.Tests.csproj --configuration Release --logger trx --collect:"XPlat Code Coverage" --results-directory ./TestResults
if ($LASTEXITCODE) { Write-Error "Tests failed"; exit 1 }
# Find coverage file
$covFile = Get-ChildItem -Path ./TestResults -Filter coverage.cobertura.xml -Recurse | Select-Object -First 1
if (-not $covFile) { Write-Error "Coverage file not found"; exit 1 }
[xml]$xml = Get-Content $covFile.FullName
$rate = [double]$xml.coverage.'line-rate'
if ($rate -lt 1.0) {
    $msg = @{event='ci_failure'; coverage_percent=($rate*100); required=100} | ConvertTo-Json -Compress
    Write-Output $msg
    exit 1
} else {
    Write-Output "Coverage $($rate*100)% OK"
}
Pop-Location
