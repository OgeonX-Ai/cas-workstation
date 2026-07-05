# Delegation and Collision Contract

The parent owns goal state, decomposition, model-role selection, synthesis,
verification, integration, and completion. Delegation is bounded by task packet,
depth, time, and write scope.

Each task packet contains: goal, non-goals, context files, instruction chain,
role alias, allowed tools, owned paths/worktree, acceptance criteria, verifier,
evidence destination, timeout, and escalation rule.

Read-only agents may run in parallel. Writers must use separate Git worktrees or
mutually exclusive owned paths. The integration owner checks base ancestry,
working tree status, tests, and conflicts before fan-in. A child cannot delegate
unless the packet explicitly grants one additional level and the tool supports
it. Gemini and Claude subagents are recursion-protected; Antigravity child model
behavior remains unsupported; Codex follows the current runtime fan-out cap.

On capacity exhaustion, authentication failure, unsupported capability, or
timeout, return a compact failure packet and let the parent execute or reroute.
