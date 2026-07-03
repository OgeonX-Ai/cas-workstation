import os

base = "C:/PersonalRepo/portfolio/gsd-orchestrator/src/GsdOrchestrator.Tests"

# ── McpException tests ──────────────────────────────────────────────────────
mcp_exception_tests = r"""using GsdOrchestrator.Mcp;
using Xunit;

namespace GsdOrchestrator.Tests;

public class McpExceptionTests
{
    [Fact]
    public void Constructor_DefaultFlags_AreAllFalse()
    {
        var ex = new McpException("some error");
        Assert.False(ex.IsTransient);
        Assert.False(ex.IsSecondaryRateLimit);
        Assert.Null(ex.ErrorCode);
        Assert.Equal("some error", ex.Message);
    }

    [Fact]
    public void Constructor_IsTransientTrue_SetsFlag()
    {
        var ex = new McpException("transient", isTransient: true);
        Assert.True(ex.IsTransient);
        Assert.False(ex.IsSecondaryRateLimit);
    }

    [Fact]
    public void Constructor_IsSecondaryRateLimitTrue_SetsBothFlags()
    {
        var ex = new McpException("rate limit", isTransient: true, isSecondaryRateLimit: true);
        Assert.True(ex.IsTransient);
        Assert.True(ex.IsSecondaryRateLimit);
    }

    [Fact]
    public void Constructor_WithErrorCode_StoresErrorCode()
    {
        var ex = new McpException("error", errorCode: 429);
        Assert.Equal(429, ex.ErrorCode);
    }

    [Fact]
    public void FromToolError_SecondaryRateLimitText_SetsSecondaryFlag()
    {
        var ex = McpException.FromToolError("You have exceeded the secondary rate limit");
        Assert.True(ex.IsSecondaryRateLimit);
        Assert.True(ex.IsTransient);
    }

    [Fact]
    public void FromToolError_PrimaryRateLimitExceeded_SetsTransientNotSecondary()
    {
        var ex = McpException.FromToolError("API rate limit exceeded for this endpoint");
        Assert.True(ex.IsTransient);
        Assert.False(ex.IsSecondaryRateLimit);
    }

    [Fact]
    public void FromToolError_RateLimitExceededText_SetsTransientFlag()
    {
        var ex = McpException.FromToolError("rate limit exceeded, please slow down");
        Assert.True(ex.IsTransient);
        Assert.False(ex.IsSecondaryRateLimit);
    }

    [Fact]
    public void FromToolError_GenericError_NotTransient()
    {
        var ex = McpException.FromToolError("not found");
        Assert.False(ex.IsTransient);
        Assert.False(ex.IsSecondaryRateLimit);
    }

    [Fact]
    public void FromToolError_EmptyString_NotTransient()
    {
        var ex = McpException.FromToolError("");
        Assert.False(ex.IsTransient);
        Assert.False(ex.IsSecondaryRateLimit);
    }
}
"""

os.makedirs(f"{base}/Mcp", exist_ok=True)
with open(f"{base}/McpExceptionTests.cs", "w") as f:
    f.write(mcp_exception_tests)
print("Created McpExceptionTests.cs")
