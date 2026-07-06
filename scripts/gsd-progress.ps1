# gsd-progress shim script
# Executes the GSD progress workflow via gsd-sdk
$workflow = "$env:USERPROFILE\.gemini\antigravity\get-shit-done\workflows\progress.md"
# Run the workflow using the SDK (assumes gsd-sdk is on PATH)
& gsd-sdk run-workflow $workflow
