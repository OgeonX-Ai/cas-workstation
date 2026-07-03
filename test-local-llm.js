const { spawn } = require('child_process');

const server = spawn('universal-refiner', [], { stdio: ['pipe', 'pipe', 'inherit'], shell: true });

let output = '';
server.stdout.on('data', (data) => {
    output += data.toString();
});

server.stdin.write(JSON.stringify({
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: { protocolVersion: "2024-11-05", capabilities: {}, clientInfo: { name: "test-client", version: "1.0.0" } }
}) + '\n');

setTimeout(() => {
    server.stdin.write(JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" }) + '\n');
}, 500);

setTimeout(() => {
    server.stdin.write(JSON.stringify({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/call",
        params: {
            name: "lint_prompt",
            arguments: {
                prompt: "Write a script that creates an S3 bucket.",
                semantic: true
            }
        }
    }) + '\n');
}, 1000);

setTimeout(() => {
    console.log("=== MCP SERVER RESPONSE AND LOGS ===");
    const lines = output.split('\n');
    const responseLine = lines.find(l => l.includes('"id":2'));
    if (responseLine) {
        console.log(JSON.stringify(JSON.parse(responseLine), null, 2));
    } else {
        console.log(output);
    }
    server.kill();
}, 45000); // Wait 45 seconds for local LLM to respond
