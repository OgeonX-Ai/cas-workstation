
import os, sys

base = "C:/PersonalRepo/portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests"

validating_cs = """using System.Text.Json.Nodes;
using GsdOrchestrator.Mcp;
using GsdOrchestrator.Workflows.Models;
using GsdOrchestrator.Workflows.States;
using Microsoft.Extensions.Logging.Abstractions;
using NSubstitute;
using NSubstitute.ExceptionExtensions;
using Polly.Registry;
using Xunit;

namespace GsdOrchestrator.Tests.States;

public class ValidatingStateTests
{
    private static McpToolDispatcher BuildDispatcher(IMcpClient mcpClient)
    {
        var registry = new ResiliencePipelineRegistry<string>();
        registry.TryAddBuilder("mcp-tools", (b, _) => { });
        return new McpToolDispatcher(mcpClient, registry, NullLogger<McpToolDispatcher>.Instance);
    }

    private static IMcpClient BuildMcpClientAhead()
    {
        var mcp = Substitute.For<IMcpClient>();
        mcp.CallToolAsync(
            Arg.Is<string>("compare_commits"),
            Arg.Any<JsonObject>(),
            Arg.Any<CancellationToken>())
           .Returns(Task.FromResult(new McpToolResult("{{\\\"status\\\":\\\"ahead\\\",\\\"files\\\":[] }}", false)));
        return mcp;
    }

    private static ValidatingState BuildSut(IMcpClient mcpClient) =>
        new(BuildDispatcher(mcpClient), NullLogger<ValidatingState>.Instance);

    private static GsdWorkflowContext BuildContext(
        IReadOnlyList<FileEdit>? edits = null,
        bool requiresTests = false,
        TestGenerationContext? testGeneration = null) =>
        new()
        {
            Issue = new IssueContext(42, "Fix Foo", "body", [], "testowner", "testrepo", "main"),
            Branch = new BranchContext("fix/issue-42", "abc123"),
            Plan = new AnalysisPlan("fix/issue-42", [new PlannedFile("src/Foo.cs", "fix")], "Fix foo", requiresTests),
            Edits = new EditContext(edits ?? [new FileEdit("src/Foo.cs", "oldsha", "newsha", "fix: foo")]),
            TestGeneration = testGeneration,
            CurrentState = WorkflowState.Validating
        };
}
"""

with open(f"{base}/States/ValidatingStateTests.cs", "w") as f:
    f.write(validating_cs)
print("Written")
