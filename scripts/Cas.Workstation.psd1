@{
    RootModule = 'Cas.Workstation.psm1'
    ModuleVersion = '1.0.0'
    GUID = '1A2B3C4D-5E6F-7A8B-9C0D-1E2F3A4B5C6D'
    Author = 'Coding-Autopilot-System'
    CompanyName = 'OgeonX-Ai'
    Copyright = '(c) 2026 Coding-Autopilot-System. All rights reserved.'
    Description = 'CAS Workstation bootstrap module for AI-native coding'
    PowerShellVersion = '7.0'
    FunctionsToExport = @(
        'Get-CasManifestPath',
        'Get-CasManifest',
        'Get-CasDefaultRootPath',
        'Get-CasDefaultConfigPath',
        'Get-CasProfile',
        'New-CasDirectoryLayout',
        'Get-CasProfileToolDefinitions',
        'Get-CasProfileRepos',
        'Invoke-CasCommandCapture'
    )
    VariablesToExport = '*'
    AliasesToExport = '*'
    CmdletsToExport = '*'
}
