Set-StrictMode -Version Latest

function Get-CasModuleRoot {
    Split-Path -Parent $PSScriptRoot
}

function Get-CasManifestPath {
    Join-Path (Get-CasModuleRoot) "stack.manifest.json"
}

function Get-CasManifest {
    param(
        [string]$Path = (Get-CasManifestPath)
    )

    Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json
}

function Get-CasDefaultRootPath {
    param(
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $Manifest.defaults.rootPath
}

function Get-CasDefaultConfigPath {
    param(
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $Manifest.defaults.configPath
}

function Get-CasProfile {
    param(
        [string]$Name = "full",
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $profile = $Manifest.profiles.PSObject.Properties[$Name]
    if (-not $profile) {
        throw "Unknown profile '$Name'."
    }

    $profile.Value
}

function New-CasDirectoryLayout {
    param(
        [string]$RootPath,
        [string]$ConfigPath,
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $paths = @(
        $RootPath,
        (Join-Path $RootPath $Manifest.paths.reposRoot),
        $ConfigPath,
        (Join-Path $ConfigPath $Manifest.paths.logs),
        (Join-Path $ConfigPath $Manifest.paths.state),
        (Join-Path $ConfigPath $Manifest.paths.memory),
        (Join-Path $ConfigPath $Manifest.paths.mcp),
        (Join-Path $ConfigPath $Manifest.paths.config),
        (Join-Path (Join-Path $ConfigPath $Manifest.paths.mcp) "clients")
    )

    foreach ($path in $paths) {
        if (-not (Test-Path -LiteralPath $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
}

function Get-CasProfileToolDefinitions {
    param(
        [string]$Profile = "full",
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $toolIds = @((Get-CasProfile -Name $Profile -Manifest $Manifest).tools)
    foreach ($toolId in $toolIds) {
        $Manifest.tools | Where-Object { $_.id -eq $toolId }
    }
}

function Get-CasProfileRepos {
    param(
        [string]$Profile = "full",
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $repoIds = @((Get-CasProfile -Name $Profile -Manifest $Manifest).repos)
    foreach ($repoId in $repoIds) {
        $Manifest.repos | Where-Object { $_.id -eq $repoId }
    }
}

function Invoke-CasCommandCapture {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList = @()
    )

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        # PowerShell command shims such as npm.ps1 may read this automatic
        # variable before launching a native process. Strict mode requires it
        # to exist before the shim is invoked.
        $global:LASTEXITCODE = 0
        $output = & $FilePath @ArgumentList 2>$null
        [string]::Join([Environment]::NewLine, @($output))
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
}

function Get-CasVersionFromOutput {
    param(
        [string]$Output,
        [string]$Pattern
    )

    if (-not $Output) {
        return $null
    }

    $match = [regex]::Match($Output, $Pattern)
    if ($match.Success) {
        if ($match.Groups["version"].Success) {
            return $match.Groups["version"].Value.TrimStart("v")
        }
        return $match.Value.TrimStart("v")
    }

    return $null
}

function Compare-CasVersion {
    param(
        [string]$InstalledVersion,
        [string]$MinimumVersion
    )

    if (-not $InstalledVersion -or -not $MinimumVersion) {
        return 0
    }

    try {
        $installed = [version]$InstalledVersion
        $minimum = [version]$MinimumVersion
        return $installed.CompareTo($minimum)
    }
    catch {
        return 0
    }
}

function Get-CasToolStatus {
    param(
        [pscustomobject]$Tool
    )

    $command = Get-Command $Tool.command -ErrorAction SilentlyContinue
    if (-not $command) {
        return [pscustomobject]@{
            id = $Tool.id
            displayName = $Tool.displayName
            required = $true
            status = "missing"
            installedVersion = $null
            minimumVersion = $Tool.minimumVersion
            message = "Command '$($Tool.command)' was not found."
        }
    }

    $output = Invoke-CasCommandCapture -FilePath $command.Source -ArgumentList @($Tool.versionArgs)
    $installedVersion = Get-CasVersionFromOutput -Output $output -Pattern $Tool.versionPattern
    $compare = Compare-CasVersion -InstalledVersion $installedVersion -MinimumVersion $Tool.minimumVersion
    $status = if ($compare -lt 0) { "out-of-date" } else { "installed" }
    $message = if ($status -eq "installed") {
        "$($Tool.displayName) is installed."
    }
    else {
        "$($Tool.displayName) is below the required version $($Tool.minimumVersion)."
    }

    [pscustomobject]@{
        id = $Tool.id
        displayName = $Tool.displayName
        required = $true
        status = $status
        installedVersion = $installedVersion
        minimumVersion = $Tool.minimumVersion
        message = $message
    }
}

function Get-CasRepoStatus {
    param(
        [pscustomobject]$Repo,
        [string]$RootPath,
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $path = Join-Path (Join-Path $RootPath $Manifest.paths.reposRoot) $Repo.id
    [pscustomobject]@{
        id = $Repo.id
        status = if (Test-Path -LiteralPath $path) { "present" } else { "missing" }
        path = $path
    }
}

function Test-CasDockerDaemon {
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        return [pscustomobject]@{
            id = "docker-daemon"
            status = "missing"
            message = "Docker CLI is not installed."
        }
    }

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        $output = & $docker.Source info --format "{{.ServerVersion}}" 2>$null
        $nativeCommandSucceeded = $?
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($nativeCommandSucceeded) {
        return [pscustomobject]@{
            id = "docker-daemon"
            status = "ready"
            message = "Docker daemon is reachable."
        }
    }

    [pscustomobject]@{
        id = "docker-daemon"
        status = "degraded"
        message = "Docker CLI is installed but the daemon is not reachable."
    }
}

function Test-CasGhAuth {
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $gh) {
        return [pscustomobject]@{
            id = "gh-auth"
            status = "missing"
            message = "GitHub CLI is not installed."
        }
    }

    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & $gh.Source auth status 1>$null 2>$null
        $nativeCommandSucceeded = $?
    }
    finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($nativeCommandSucceeded) {
        return [pscustomobject]@{
            id = "gh-auth"
            status = "ready"
            message = "GitHub CLI is authenticated."
        }
    }

    [pscustomobject]@{
        id = "gh-auth"
        status = "degraded"
        message = "GitHub CLI is installed but not authenticated."
    }
}

function Get-CasServiceStatuses {
    param(
        [string]$Profile = "full",
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $statuses = @()
    $profileServices = @((Get-CasProfile -Name $Profile -Manifest $Manifest).services)
    foreach ($service in $profileServices) {
        switch ($service) {
            "docker-daemon" { $statuses += Test-CasDockerDaemon }
            "gh-auth" { $statuses += Test-CasGhAuth }
            default {
                $statuses += [pscustomobject]@{
                    id = $service
                    status = "degraded"
                    message = "Unknown service check."
                }
            }
        }
    }

    $statuses
}

function Get-CasMcpServerStatus {
    param(
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $args = @($Manifest.sharedMcpServer.args)
    if ($args.Count -ne 1 -or -not [IO.Path]::IsPathRooted([string]$args[0])) {
        return [pscustomobject]@{
            id = $Manifest.sharedMcpServer.name
            status = "invalid"
            path = if ($args.Count -gt 0) { [string]$args[0] } else { $null }
            message = "The shared MCP server must declare exactly one absolute script path."
        }
    }

    $scriptPath = [IO.Path]::GetFullPath([string]$args[0])
    $rootPath = [IO.Path]::GetFullPath([string]$Manifest.defaults.rootPath).TrimEnd('\') + '\'
    if (-not $scriptPath.StartsWith($rootPath, [StringComparison]::OrdinalIgnoreCase)) {
        return [pscustomobject]@{
            id = $Manifest.sharedMcpServer.name
            status = "invalid"
            path = $scriptPath
            message = "The shared MCP script path must remain under the CAS workspace root."
        }
    }

    $exists = Test-Path -LiteralPath $scriptPath -PathType Leaf
    [pscustomobject]@{
        id = $Manifest.sharedMcpServer.name
        status = if ($exists) { "ready" } else { "missing" }
        path = $scriptPath
        message = if ($exists) { "The shared MCP runtime is available." } else { "The shared MCP runtime script was not found." }
    }
}

function Get-CasOverallStatus {
    param(
        [object[]]$ToolStatuses,
        [object[]]$ServiceStatuses,
        [object[]]$RepoStatuses,
        [pscustomobject]$McpServerStatus
    )

    if ($ToolStatuses.status -contains "missing" -or $ToolStatuses.status -contains "out-of-date") {
        return "not-ready"
    }

    if ($ServiceStatuses.status -contains "missing" -or $ServiceStatuses.status -contains "degraded") {
        return "degraded"
    }

    if ($RepoStatuses.status -contains "missing") {
        return "degraded"
    }

    if ($McpServerStatus -and $McpServerStatus.status -ne "ready") {
        return "degraded"
    }

    "ready"
}

function Get-CasRecommendations {
    param(
        [object[]]$ToolStatuses,
        [object[]]$ServiceStatuses,
        [object[]]$RepoStatuses,
        [pscustomobject]$McpServerStatus
    )

    $messages = New-Object System.Collections.Generic.List[string]

    foreach ($tool in $ToolStatuses | Where-Object { $_.status -eq "missing" }) {
        $messages.Add("Install $($tool.displayName).")
    }

    foreach ($tool in $ToolStatuses | Where-Object { $_.status -eq "out-of-date" }) {
        $messages.Add("Upgrade $($tool.displayName) to at least $($tool.minimumVersion).")
    }

    foreach ($service in $ServiceStatuses | Where-Object { $_.status -ne "ready" }) {
        switch ($service.id) {
            "docker-daemon" { $messages.Add("Start Docker Desktop and confirm the daemon is reachable.") }
            "gh-auth" { $messages.Add("Authenticate GitHub CLI with 'gh auth login'.") }
            default { $messages.Add($service.message) }
        }
    }

    foreach ($repo in $RepoStatuses | Where-Object { $_.status -eq "missing" }) {
        $messages.Add("Clone or install the managed repo '$($repo.id)'.")
    }

    if ($McpServerStatus -and $McpServerStatus.status -ne "ready") {
        $messages.Add($McpServerStatus.message)
    }

    $messages.ToArray()
}

function Get-CasDoctorReport {
    param(
        [string]$Profile = "full",
        [string]$RootPath = (Get-CasDefaultRootPath),
        [string]$ConfigPath = (Get-CasDefaultConfigPath),
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $toolStatuses = @(Get-CasProfileToolDefinitions -Profile $Profile -Manifest $Manifest | ForEach-Object {
        Get-CasToolStatus -Tool $_
    })
    $serviceStatuses = @(Get-CasServiceStatuses -Profile $Profile -Manifest $Manifest)
    $repoStatuses = @(Get-CasProfileRepos -Profile $Profile -Manifest $Manifest | ForEach-Object {
        Get-CasRepoStatus -Repo $_ -RootPath $RootPath -Manifest $Manifest
    })
    $mcpServerStatus = Get-CasMcpServerStatus -Manifest $Manifest
    $overallStatus = Get-CasOverallStatus -ToolStatuses $toolStatuses -ServiceStatuses $serviceStatuses -RepoStatuses $repoStatuses -McpServerStatus $mcpServerStatus
    $recommendations = @(Get-CasRecommendations -ToolStatuses $toolStatuses -ServiceStatuses $serviceStatuses -RepoStatuses $repoStatuses -McpServerStatus $mcpServerStatus)

    [pscustomobject]@{
        bundleId = $Manifest.bundleId
        generatedAtUtc = [DateTime]::UtcNow.ToString("o")
        profile = $Profile
        rootPath = $RootPath
        configPath = $ConfigPath
        overallStatus = $overallStatus
        tools = $toolStatuses
        services = $serviceStatuses
        repos = $repoStatuses
        mcpServer = $mcpServerStatus
        recommendations = $recommendations
    }
}

function Write-CasDoctorReport {
    param(
        [pscustomobject]$Report,
        [string]$JsonPath
    )

    if ($JsonPath) {
        $directory = Split-Path -Parent $JsonPath
        if ($directory -and -not (Test-Path -LiteralPath $directory)) {
            New-Item -ItemType Directory -Path $directory -Force | Out-Null
        }

        $Report | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $JsonPath -Encoding UTF8
    }

    $Report
}

function Install-CasTool {
    param(
        [pscustomobject]$Tool
    )

    $status = Get-CasToolStatus -Tool $Tool
    if ($status.status -eq "installed") {
        Write-Host "[ok] $($Tool.displayName) already installed ($($status.installedVersion))."
        return
    }

    foreach ($installer in @($Tool.installers)) {
        switch ($installer.kind) {
            "scoop" {
                $scoop = Get-Command scoop -ErrorAction SilentlyContinue
                if ($scoop) {
                    Write-Host "[install] scoop install $($installer.id)"
                    & $scoop.Source install $installer.id
                    return
                }
            }
            "winget" {
                $winget = Get-Command winget -ErrorAction SilentlyContinue
                if ($winget) {
                    Write-Host "[install] winget install --exact --id $($installer.id)"
                    & $winget.Source install --exact --id $installer.id --accept-package-agreements --accept-source-agreements
                    return
                }
            }
            "npm" {
                $npm = Get-Command npm -ErrorAction SilentlyContinue
                if ($npm) {
                    Write-Host "[install] npm install -g $($installer.id)"
                    & $npm.Source install -g $installer.id
                    return
                }
            }
            "manual" {
                if ($installer.hint) {
                    Write-Warning $installer.hint
                    return
                }
            }
        }
    }

    throw "No supported installer was available for $($Tool.displayName)."
}

function Ensure-CasTool {
    param(
        [pscustomobject]$Tool
    )

    $status = Get-CasToolStatus -Tool $Tool
    if ($status.status -ne "installed") {
        Write-Host "[provision] Automatically provisioning $($Tool.displayName) on-the-fly..."
        Install-CasTool -Tool $Tool
        $postStatus = Get-CasToolStatus -Tool $Tool
        if ($postStatus.status -ne "installed") {
            Write-Warning "Auto-provisioning completed but $($Tool.displayName) is still not reporting as 'installed'."
        } else {
            Write-Host "[provision] Successfully provisioned $($Tool.displayName)."
        }
    } else {
        Write-Host "[ok] $($Tool.displayName) already installed ($($status.installedVersion))."
    }
}

function Sync-CasRepo {
    param(
        [pscustomobject]$Repo,
        [string]$RootPath,
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $git = Get-Command git -ErrorAction Stop
    $reposRoot = Join-Path $RootPath $Manifest.paths.reposRoot
    $repoPath = Join-Path $reposRoot $Repo.id

    if (-not (Test-Path -LiteralPath $repoPath)) {
        Write-Host "[clone] $($Repo.id)"
        & $git.Source clone $Repo.url $repoPath
        return
    }

    Write-Host "[update] $($Repo.id)"
    & $git.Source -C $repoPath fetch origin
    & $git.Source -C $repoPath checkout $Repo.defaultBranch
    & $git.Source -C $repoPath pull --ff-only origin $Repo.defaultBranch
}

function New-CasClientConfigs {
    param(
        [string]$ConfigPath,
        [string]$RootPath = (Get-CasDefaultRootPath),
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $clientRoot = Join-Path (Join-Path $ConfigPath $Manifest.paths.mcp) "clients"
    if (-not (Test-Path -LiteralPath $clientRoot)) {
        New-Item -ItemType Directory -Path $clientRoot -Force | Out-Null
    }

    $sharedServer = [ordered]@{
        mcpServers = @{
            ($Manifest.sharedMcpServer.name) = @{
                command = $Manifest.sharedMcpServer.command
                args = @($Manifest.sharedMcpServer.args)
                transport = $Manifest.sharedMcpServer.transport
            }
        }
    }

    foreach ($client in @($Manifest.clients)) {
        $target = Join-Path $clientRoot $client.fileName
        $sharedServer | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $target -Encoding UTF8
    }

    $runtimeConfig = [ordered]@{
        bundleId = $Manifest.bundleId
        generatedAtUtc = [DateTime]::UtcNow.ToString("o")
        mcpServer = $Manifest.sharedMcpServer
    }
    $runtimeTarget = Join-Path (Join-Path $ConfigPath $Manifest.paths.config) "stack.runtime.json"
    $runtimeConfig | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $runtimeTarget -Encoding UTF8
}

function Start-CasRuntime {
    param(
        [string]$Profile = "full",
        [string]$RootPath = (Get-CasDefaultRootPath),
        [pscustomobject]$Manifest = (Get-CasManifest)
    )

    $docker = Test-CasDockerDaemon
    if ($docker.status -ne "ready") {
        $dockerDesktop = Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"
        if (Test-Path -LiteralPath $dockerDesktop) {
            Write-Host "[start] Docker Desktop"
            Start-Process -FilePath $dockerDesktop -WindowStyle Hidden
        }
        else {
            Write-Warning "Docker Desktop is not installed or its executable was not found."
        }
    }

    foreach ($repo in Get-CasProfileRepos -Profile $Profile -Manifest $Manifest) {
        $repoPath = Join-Path (Join-Path $RootPath $Manifest.paths.reposRoot) $repo.id
        if (-not (Test-Path -LiteralPath $repoPath)) {
            Write-Warning "Repo '$($repo.id)' is missing at $repoPath."
        }
    }
}

Export-ModuleMember -Function *-Cas*
