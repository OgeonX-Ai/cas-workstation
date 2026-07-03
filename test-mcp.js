const { spawn } = require('child_process');

const server = spawn('gemini-prompt-refiner', [], { stdio: ['pipe', 'pipe', 'inherit'], shell: true });

let output = '';
server.stdout.on('data', (data) => {
    output += data.toString();
});

server.stdin.write(JSON.stringify({
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: {
        protocolVersion: "2024-11-05",
        capabilities: {},
        clientInfo: { name: "test-client", version: "1.0.0" }
    }
}) + '\n');

setTimeout(() => {
    server.stdin.write(JSON.stringify({
        jsonrpc: "2.0",
        id: 2,
        method: "tools/list",
        params: {}
    }) + '\n');
}, 1000);

setTimeout(() => {
    server.stdin.write(JSON.stringify({
        jsonrpc: "2.0",
        method: "notifications/initialized"
    }) + '\n');
}, 500);

setTimeout(() => {
    console.log(output);
    server.kill();
}, 2000);
