---
title: "DeepSeek CLI terminal alignment"
type: session
created: 2026-05-21T17:00:00+01:00
updated: 2026-05-21T17:00:00+01:00
agent: codex
tags: [deepseek-cli, cli, terminal-ui, agent-tools, infrastructure]
related: [../facts/agent-cli-launch-config.md, ../preferences/d-drive-rule.md]
---

# DeepSeek CLI terminal alignment

## Summary

Codex reviewed and updated `D:\devtools\deepseek-cli`, the local/open-source DeepSeek-powered terminal agent, to move it closer to a Claude Code / Codex-style CLI experience without touching unrelated projects.

## Findings

- The project was already more than a toy wrapper: it had TypeScript source, a `deepseek` launcher, OpenAI-compatible DeepSeek API calls, a tool-calling agent loop, file/search/shell tools, and MCP client support.
- The terminal experience was still rough: the banner/prompt contained mojibake, status visibility was minimal, and tool execution progress was printed as a plain debug line.
- The local shared markdown memory for the multi-agent system is `D:\research\Vipin's Knowledgebase\memory\`.
- The MCP-style `agentmemory` database used by Codex memory tools is separate from the Knowledgebase markdown memory. DeepSeek's current local role prompt points at the Knowledgebase memory.

## Changes

- Replaced the terminal banner/prompt with a clean branded startup panel showing model, cwd, tool count, and MCP server count.
- Added interactive slash commands: `/help`, `/status`, `/clear`, and `/exit`.
- Added `--doctor` to print setup status without a live model call.
- Added visible `thinking...` and per-tool start/done/failure progress lines.
- Routed Windows shell tool execution through PowerShell instead of assuming `bash`.
- Updated `README.md` with the new terminal behavior and the local Knowledgebase memory path.

## Validation

- `npm run build` succeeded.
- `node dist/index.js --doctor` succeeded and reported the configured DeepSeek key, model, cwd, and built-in tools.
- `D:\devtools\deepseek.cmd` opens an interactive one-line `deepseek ›` prompt and exits cleanly on `/exit`.

## Notes

- `D:\devtools\deepseek-cli\config.toml` already had local uncommitted changes before this Codex update; Codex did not revert them.
- The current doctor output reports `mcp_servers: 0` because the current local config uses the Knowledgebase markdown memory prompt rather than an active MCP server block.
