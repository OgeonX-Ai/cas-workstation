Set-StrictMode -Version Latest

Describe 'apply-branch-protection protection preservation contract' {
    BeforeAll {
        $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
        $script:ProtectionScript = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'scripts\apply-branch-protection.ps1')
        $script:Policy = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'docs\merge-flow-policy.md')
        $script:Runbook = Get-Content -Raw -LiteralPath (Join-Path $repoRoot 'docs\merge-train-runbook.md')
    }

    It 'preserves existing branch-protection controls in the PUT payload' {
        foreach ($field in @(
                'required_conversation_resolution',
                'require_last_push_approval',
                'block_creations',
                'required_signatures',
                'lock_branch',
                'allow_fork_syncing')) {
            $script:ProtectionScript | Should -Match ([regex]::Escape($field))
        }

        $script:ProtectionScript | Should -Match 'Get-CurrentProtection'
        $script:ProtectionScript | Should -Match 'existingContexts'
    }

    It 'documents the root-specific branch-protection options' {
        $script:Policy | Should -Match ([regex]::Escape('-SkipEligibilityCheck -RequireCodeOwnerReviews'))
    }

    It 'resolves the default branch before break-glass operations' {
        $script:Runbook | Should -Match ([regex]::Escape('$branch = gh api "repos/$repo" --jq .default_branch'))
        $script:Runbook | Should -Match ([regex]::Escape('branches/$branch/protection/enforce_admins'))
    }
}
