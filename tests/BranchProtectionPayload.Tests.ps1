Set-StrictMode -Version Latest

Describe 'apply-branch-protection payload contract' {
    BeforeAll {
        . (Join-Path $PSScriptRoot '..\scripts\apply-branch-protection.ps1') -Repos test -DryRun
        $script:existing = [pscustomobject]@{
            required_status_checks = [pscustomobject]@{ strict = $false; contexts = @('existing-check') }
            required_pull_request_reviews = [pscustomobject]@{ required_approving_review_count = 2; dismiss_stale_reviews = $true; require_code_owner_reviews = $false; require_last_push_approval = $true }
            restrictions = [pscustomobject]@{ users = @([pscustomobject]@{ login = 'octocat' }); teams = @([pscustomobject]@{ slug = 'security' }); apps = @([pscustomobject]@{ slug = 'ci-app' }) }
            required_conversation_resolution = [pscustomobject]@{ enabled = $true }
        }
    }

    It 'preserves stricter controls and normalizes restriction identities' {
        $payload = New-ProtectionPayload -Contexts @('automerge-eligibility') -RequireCodeOwnerReviews $true -ExistingProtection $script:existing
        $payload.required_status_checks.strict | Should -BeFalse
        $payload.required_status_checks.contexts | Should -Contain 'existing-check'
        $payload.required_pull_request_reviews.required_approving_review_count | Should -Be 2
        $payload.required_pull_request_reviews.require_last_push_approval | Should -BeTrue
        $payload.required_conversation_resolution | Should -BeTrue
        $payload.restrictions.users | Should -Be @('octocat')
        $payload.restrictions.teams | Should -Be @('security')
        $payload.restrictions.apps | Should -Be @('ci-app')
    }
}
