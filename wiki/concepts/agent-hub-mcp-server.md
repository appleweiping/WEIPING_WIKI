---
title: Agent Hub MCP Server
type: concept
status: deprecated
created: 2026-05-18
updated: 2026-06-01
tags:
  - agent-workflow
  - collaboration
  - mcp
  - infrastructure
  - deprecated
source_pages:
  - AGENTS.md
  - CLAUDE.md
---

# Agent Hub MCP Server

> [!WARNING]
> Deprecated historical page. Agent Hub is retired; use [[agentmemory-first-agent-collaboration]] for active memory, signals, actions, checkpoints, and partner handoffs.

## Status

DEPRECATED: Agent Hub is no longer active infrastructure for Vipin's agent stack.

EXTRACTED: On 2026-06-01, the operating contract was updated to make `agentmemory` the active memory and collaboration layer. New work should not register, start, or depend on `D:\devtools\agent-hub\`, port `9800`, or `hub_*` tools.

Use [[agentmemory-first-agent-collaboration]] instead.

## Historical Role

Agent Hub was a custom MCP collaboration experiment at `D:\devtools\agent-hub\`. It attempted to provide:

- shared mailboxes and shared context
- task routing and spec dispatch
- pipeline orchestration
- retry cascades across Opus, Sonnet, DeepSeek, and Codex
- a daemon on port `9800`

INFERRED: The system overlapped too much with memory, queueing, routing, and orchestration concerns that are better handled by a maintained upstream substrate such as `agentmemory` plus explicit context packs.

## Current Replacement

Active collaboration now uses:

- `agentmemory` memory recall/search for active state
- agentmemory signals/actions/checkpoints for handoffs
- git state for file ownership and commit boundaries
- wiki pages for public-safe durable crystallization
- explicit partner context packs for Opus, Sonnet, OpenCode, and DeepSeek

## Migration Rule

- Do not add new `mcp_servers.agent_hub` config.
- Do not add startup tasks for the Agent Hub daemon.
- Do not send future agents to `hub_send_message`, `hub_route_task`, `hub_pipeline`, or `hub_quality_gate`.
- Preserve this page as historical context only.

## Counterpoints And Gaps

- AMBIGUOUS: Some old session notes and generated prompt pages may still mention Agent Hub as active; treat those as historical unless a newer operating document reactivates it.
- INFERRED: A small archived copy of Agent Hub can remain useful for audit and rollback context, but it should not be in active startup paths.
- UNVERIFIED: The full private `D:\devtools` git history still needs separate cleanup before that original repository could ever be made public.

## Related

- [[agentmemory-first-agent-collaboration]]
- [[implicit-skill-routing]]
- [[local-cc-sidecar-agent-workflow|local CC partner workflow]]
