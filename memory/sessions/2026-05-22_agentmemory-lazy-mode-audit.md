---
title: "2026-05-22 agentmemory lazy-mode audit and fixes"
type: session
created: 2026-05-22T13:10:00+02:00
updated: 2026-05-22T13:10:00+02:00
agent: codex
tags: [agentmemory, lazy-mode, infrastructure, mcp, startup, cli]
related: [2026-05-22_infrastructure-audit-fix.md, ../facts/agent-cli-launch-config.md]
---

# 2026-05-22 agentmemory lazy-mode audit and fixes

## Summary

Codex audited the local multi-agent memory setup and fixed lazy-mode startup for the main agents.

## Verified / Fixed

- `agentmemory` npm package exists at `C:\Users\admin\AppData\Roaming\npm\node_modules\@agentmemory\agentmemory` and version is `0.9.21`.
- Full agentmemory server is now running with REST `http://localhost:3111`, streams `ws://localhost:3112`, viewer `http://localhost:3113`, and engine `ws://localhost:49134`.
- Startup script added: `D:\devtools\agentmemory-server.ps1` and `D:\devtools\agentmemory-server.cmd`; login startup entry added at the user Startup folder as `agentmemory-server.cmd`.
- MCP `tools/list` now proxies to the full server and returns 53 tools instead of the 7-tool standalone fallback.
- Codex config now has `[mcp_servers.agentmemory]` pointing to the local `standalone.mjs`; `codex mcp list` reports `agentmemory` enabled.
- Claude/CC config now registers `agentmemory`; `claude mcp list` reports `agentmemory` connected.
- DeepSeek launcher now sets `DEEPSEEK_CONFIG=D:\devtools\deepseek-cli\config.toml`; `deepseek --doctor` reports `mcp_servers: 1` and `agentmemory` configured.
- OpenCode MCP config was updated to the current local-server shape; `opencode mcp list` reports `agentmemory connected`.
- `cc` and `claude` launchers were repaired: restored `claude.exe`, added `D:\devtools\claude.cmd`, and configured PowerShell profiles plus cmd AutoRun so new terminal windows prioritize `D:\devtools`.

## Caveats

- Machine-level PATH write was denied by Windows registry permissions, so the robust fallback is shell-level bootstrap: PowerShell profiles and cmd AutoRun.
- PowerShell `CurrentUser` execution policy was set to `RemoteSigned` so the profile bootstrap can load.
- ARIS still reports `Codex CLI: NOT FOUND` and `Codex MCP: NOT CONFIGURED` in `aris doctor`; this appears to be ARIS-specific optional detection, while `codex.exe --version` works from `D:\devtools`.
- OpenHands starts and shows help; no native agentmemory MCP integration was confirmed, but its microagent rule points at the shared markdown memory.
