param(
    [switch]$InstallPython,
    [switch]$CreatePostgres,
    [switch]$ProvisionVM
)

if ($InstallPython) {
    Write-Host "Installing Python packages..."
    python -m pip install --upgrade pip
    if (Test-Path "requirements.txt") {
        pip install -r requirements.txt
    } else {
        Write-Host "requirements.txt not found - skipping Python package installation."
    }
}

if ($CreatePostgres) {
    Write-Host "Ensuring PostgreSQL is running..."
    # Attempt to start PostgreSQL via Docker; if Docker is unavailable or image pull fails, fall back to manual install message
    try {
        if (-not (docker ps --filter "name=pilot-postgres" --format "{{.Names}}")) {
            docker run -d --name pilot-postgres -e POSTGRES_PASSWORD=pilotpw -p 5432:5432 postgres:15-alpine
            Start-Sleep -Seconds 5
        }
    } catch {
        Write-Host "Docker PostgreSQL launch failed - please ensure PostgreSQL is installed locally or use a compatible Docker image."
    }
}

if ($ProvisionVM) {
    Write-Host "Provisioning optional second test VM..."
    # Placeholder: user should replace with their own provisioning logic
    Write-Host "Please ensure a second Windows machine is reachable via \\servername\\share."
}

Write-Host "Pilot setup completed."
