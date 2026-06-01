---
title: Agentmemory-First Agent Collaboration
type: concept
status: active
created: 2026-06-01
updated: 2026-06-01
tags:
  - agent-workflow
  - collaboration
  - memory
  - mcp
source_pages:
  - AGENTS.md
  - README.md
  - CLAUDE.md
---

# Agentmemory-First Agent Collaboration

## Rule

EXTRACTED: `agentmemory` is the active memory and collaboration layer for Vipin's local agents. The old Agent Hub mechanism is deprecated and historical.

Agents use agentmemory for active recall, memory saves, cross-agent signals, actions, and checkpoints. The public wiki remains the durable crystallization layer for stable, public-safe knowledge.

## Division Of Labor

| Layer | Purpose |
| --- | --- |
| `agentmemory` | Active operational memory, lessons, signals, actions, checkpoints, and cross-agent coordination. |
| `wiki/` | Public durable knowledge: concepts, sources, analyses, queries, workflows, and logs. |
| markdown `memory/` | Historical/superseded audit material unless explicitly targeted. |
| Git | File ownership, diff review, commit history, and public backup. |

## Operating Pattern

1. Search or recall agentmemory when past context can affect the task.
2. Classify the task and invoke relevant skills by intent.
3. Use agentmemory signals/actions for partner handoffs or multi-agent task state.
4. Verify partner output against live files before editing or committing.
5. Save important decisions or lessons to agentmemory.
6. Crystallize stable public-safe knowledge into `wiki/` when it should survive outside the operational memory layer.

## Devtools Implementation Boundary

As of 2026-06-01, `D:\devtools` keeps `agentmemory` as the active local runtime and treats `mem0ai/mem0` as an architecture reference rather than a bundled fork.

- Local runtime target: `@agentmemory/agentmemory` `0.9.24`, `iii.exe` `0.11.2`, service on `http://localhost:3111`, viewer on `http://localhost:3113`.
- Required service flags: `AGENTMEMORY_TOOLS=all` and `AGENTMEMORY_SLOTS=true`.
- Health checks should verify `/agentmemory/mcp/tools`; a very small tool count means the client has fallen back to standalone MCP instead of the full server-backed surface.
- Mem0 concepts absorbed into the local workflow: additive fact capture, explicit project/entity/agent context, agent-generated facts, hybrid retrieval, and temporal current-state notes.
- OpenMemory, old Agent Hub mailboxes, tracked DB/log files, and old C-drive npm agentmemory paths are not active interfaces.

## Safety Boundaries

- Do not store secrets, API keys, credentials, private chats, sensitive personal data, or raw private documents in agentmemory.
- Do not use old Agent Hub queues or daemon state for new work.
- Do not let stale markdown memory override the current user request, live repo facts, or newer operating docs.
- For research projects, preserve project-local evidence gates and never mutate experiments unless explicitly asked.

## Counterpoints And Gaps

- AMBIGUOUS: Some agentmemory tools may differ by client or server version; run diagnostics before relying on advanced slots/actions in critical workflows. Slots require the service to start with `AGENTMEMORY_SLOTS=true`.
- INFERRED: Markdown memory remains useful as historical evidence, but it should not be an always-on instruction source.
- UNVERIFIED: Cross-agent mesh synchronization beyond the local workstation is not part of the current active contract.

## Related

- [[agent-hub-mcp-server]]
- [[implicit-skill-routing]]
- [[agent-collaboration-tone-and-model-roles]]
- [[durable-agent-rule-memory]]
