import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OS = ROOT / "engineering-os"


def load(relative: str):
    return json.loads((OS / relative).read_text(encoding="utf-8"))


def require_keys(value, keys, name):
    missing = sorted(set(keys) - set(value))
    if missing:
        raise AssertionError(f"{name} missing keys: {missing}")


routing = load("examples/routing-decision.json")
require_keys(routing, ["taskClass", "risk", "complexity", "parallelizable", "sdlcProfile", "roleAlias", "confidence", "escalationReason"], "routing")
assert routing["sdlcProfile"] in {"quick", "standard", "critical"}
assert routing["roleAlias"] in {"light", "standard", "strong", "adjudicator"}
assert 0 <= routing["confidence"] <= 1

override = load("examples/sdlc-override.json")
require_keys(override, ["reason", "owner", "skippedGate", "risk", "compensatingVerification"], "override")
assert override["compensatingVerification"]

packets = load("examples/task-packets.json")
for index, packet in enumerate(packets):
    require_keys(packet, ["goal", "instructionChain", "roleAlias", "mutation", "writeScope", "acceptanceCriteria", "verifier", "evidenceDestination", "timeoutMinutes", "maxDelegationDepth"], f"packet[{index}]")
    assert 0 <= packet["maxDelegationDepth"] <= 2
    if packet["mutation"]:
        assert packet["writeScope"] and packet.get("worktree")

telemetry = load("examples/telemetry-event.json")
require_keys(telemetry, ["tool", "agentRole", "modelAlias", "elapsedMs", "retries", "contextEstimate", "verifierResult", "rework", "routingConfidence"], "telemetry")

print("Engineering JSON examples validated: 4/4")
