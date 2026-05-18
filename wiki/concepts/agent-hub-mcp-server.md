---
title: Agent Hub MCP Server
type: concept
status: active
created: 2026-05-18
updated: 2026-05-18
tags:
  - agent-workflow
  - collaboration
  - mcp
  - infrastructure
source_pages:
  - AGENTS.md
  - CLAUDE.md
---

# Agent Hub MCP Server

## What It Is

A shared MCP collaboration server at `D:\devtools\agent-hub\` that enables real-time multi-agent coordination between Opus, Codex (GPT-5.5), Sonnet, Haiku, and DeepSeek Pro.

Two layers:
- `agent-hub.mjs` — MCP server (stdio, each agent spawns its own instance, shares disk state)
- `daemon.mjs` — HTTP daemon on port 9800 (auto-dispatch, retry cascade, pipeline engine, warm context)

## Architecture

```
Codex ──spawn──→ agent-hub.mjs (identity=codex)  ──┐
                                                    ├── D:\devtools\agent-hub\state\ (shared)
Claude Code ──spawn──→ agent-hub.mjs (identity=claude) ──┘
                                                    ↕
                                          daemon.mjs (port 9800)
                                          - polls mailboxes every 2s
                                          - auto-dispatches urgent messages
                                          - auto-retries: Opus → Sonnet → DeepSeek
                                          - warm context every 5 min
```

## 20 MCP Tools

Messaging: `hub_send_message`, `hub_read_messages`, `hub_mark_read`, `hub_notify`
State: `hub_set_context`, `hub_get_context`, `hub_list_context`, `hub_agent_status`
Collaboration: `hub_create_thread`, `hub_thread_history`, `hub_dispatch_spec`
Routing: `hub_route_task`
Pipeline: `hub_pipeline`, `hub_pipeline_status`
Metrics: `hub_metrics`
Direct invocation: `hub_invoke_sonnet`, `hub_invoke_haiku`, `hub_invoke_gpt55`
Quality: `hub_quality_gate`
External: `deepseek_chat`

## Key Behaviors

- **Auto-retry cascade**: Opus fails → Sonnet → DeepSeek
- **Warm context**: daemon scans project state every 5 min, writes branch/dirty/commits/active_files
- **Quality gate**: Haiku lint (2s) → Sonnet review (10s) → PASS/FAIL
- **Pipeline with gates**: sequential steps with human confirmation at critical points
- **Spec-driven dispatch**: one spec, multiple agents, simultaneous execution

## Configuration

- Codex: `C:\Users\admin\.codex\config.toml` → `[mcp_servers.agent_hub]`
- Claude Code: `C:\Users\admin\.claude\mcp.json`
- Startup: `shell:startup\agent-hub-daemon.cmd` + `shell:startup\pixelcat.cmd`

## Environment Variables

- `AGENT_HUB_IDENTITY` — agent name (codex/claude)
- `AGENT_HUB_STATE_DIR` — shared state directory
- `DEEPSEEK_API_KEY`, `DEEPSEEK_BASE_URL`, `DEEPSEEK_MODEL`
- `GPT55_API_KEY` (or `OPENAI_API_KEY`), `GPT55_BASE_URL`, `GPT55_MODEL`

## Related

- [[local-cc-sidecar-agent-workflow]]
- [[model-collaboration-context-and-reference-intake]]
- [[2026-05-18-multi-agent-collaboration-architecture-review]]
