# Gemini Nano Integration

The `gemini-nano/` directory contains experimental bridges and API servers designed to interface with local Gemini Nano capabilities. 

## Purpose

As AI workloads move closer to the edge, running inference locally reduces latency and dependency on external cloud providers for routine coding or orchestration tasks. This integration aims to provide a unified API surface over the browser's or OS's local AI features.

## Architecture

1. **Chrome Bridge**: Interfaces directly with Chrome's experimental local AI features.
2. **Python API Server**: Wraps the local calls in a standard REST or MCP (Model Context Protocol) format so that the broader CAS ecosystem agents can interact with it seamlessly.
3. **Mediapipe Support**: Provides vision or media processing capabilities alongside the text models.

> **Note**: This feature is currently experimental and may require specific flags to be enabled in your browser or environment.
