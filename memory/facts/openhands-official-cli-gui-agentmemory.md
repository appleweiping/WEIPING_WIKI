---
title: "OpenHands official CLI/GUI + agentmemory setup"
type: fact
created: 2026-05-22T21:25:00+02:00
updated: 2026-05-22T21:25:00+02:00
agent: codex
tags: [openhands, agentmemory, cli, gui, gpt-5.5, setup, verified]
---

# OpenHands official CLI/GUI + agentmemory setup

## What is installed

- Official OpenHands CLI package: `openhands==1.16.0` in `D:\devtools\openhands\cli-venv`.
- Existing OpenHands GUI/native package remains available separately in Python 3.12 site-packages; old custom terminal wrapper remains `D:\devtools\openhands-chat.cmd`.
- Docker GUI image available locally as `openhands:latest`.
- Shared OpenHands home is still junctioned: `C:\Users\admin\.openhands -> D:\devtools\openhands\home`.
- Official CLI has its own home: `D:\devtools\openhands\cli-home`, to avoid Docker-vs-Windows MCP URL conflicts.

## Launch commands

- Official terminal CLI/TUI: `D:\devtools\openhands.cmd` or `openhands` if `D:\devtools` is on PATH.
- Official CLI headless example: `D:\devtools\openhands.cmd --headless --json --always-approve -f D:\path\task.txt`.
- Official Docker GUI: `D:\devtools\openhands-gui.cmd`; then open `http://localhost:3000`.
- Official CLI web UI: `D:\devtools\openhands-web.cmd`.
- Legacy persistent custom terminal chat: `D:\devtools\openhands-chat.cmd`.

## Model configuration

- Default model: `openai/gpt-5.5` through `http://127.0.0.1:9100/v1` (key rotator).
- Claude model: `claude-opus-4-7` through `https://api.sbbbbbbbbb.xyz/v1` (available as llm_profile, switchable in GUI).
- CLI agent config: `D:\devtools\openhands\cli-home\agent_settings.json`.
- GUI settings: `D:\devtools\openhands\home\settings.json`.
- The 9100 key rotator is `D:\devtools\key-rotator.mjs` launched by `D:\devtools\key-rotator.cmd`.
- `prompt_cache_retention` must be null (not "24h") — gpt-5.5 rejects it even with `drop_params: true`.
- `stream` must be false — headless mode errors with "Streaming requires an on_token callback".
- 2026-05-22 verification: `/v1/models`, `/v1/responses` with `gpt-5.5`, and `/v1/chat/completions` with `gpt-5.5` all returned successfully after fixing rotator gzip/header forwarding.
- 2026-05-22 verification: `claude-opus-4-7` via `https://api.sbbbbbbbbb.xyz/v1/chat/completions` returned 200.

## agentmemory integration

- agentmemory service: `http://localhost:3111`.
- OpenHands HTTP MCP bridge: `D:\devtools\openhands-agentmemory-bridge.cmd` / `D:\devtools\openhands-agentmemory-bridge-start.cmd`.
- Bridge code: `C:\Users\admin\.openhands\agentmemory-bridge\agentmemory_openhands_bridge.py`.
- Bridge health: `http://localhost:3115/health`.
- CLI MCP config: `D:\devtools\openhands\cli-home\mcp.json` -> `http://localhost:3115/mcp`.
- GUI MCP config: `D:\devtools\openhands\home\mcp.json` -> `http://host.docker.internal:3115/mcp`.
- Docker container reachability to bridge verified with `curlimages/curl`.
- MCP bridge verified with FastMCP client: listed 53 tools and successfully called `memory_smart_search`.

## Important fixes made

- `D:\devtools\key-rotator.mjs`: strips inbound `accept-encoding` and outbound `content-encoding/content-length` to avoid PowerShell/.NET gzip decode failures while proxying upstream responses.
- `D:\devtools\openhands\cli-venv\Lib\site-packages\openhands_cli\stores\agent_store.py`: added `OPENHANDS_LOAD_PUBLIC_SKILLS` switch; default wrappers set it to `0` because Windows cannot checkout OpenHands/extensions files with `:` in filenames.
- `C:\Users\admin\.openhands\agentmemory-bridge\agentmemory_openhands_bridge.py`: passes `lifespan=http_app.lifespan` to Starlette so FastMCP streamable HTTP works instead of returning 500.
- All OpenHands JSON config files must be UTF-8 without BOM. Docker GUI threw `JSONDecodeError: Unexpected UTF-8 BOM` until `settings.json`, `agent_settings.json`, and `mcp.json` were rewritten without BOM.
- `agent_settings.json`: `prompt_cache_retention` set to null (was "24h", caused LLMBadRequestError with gpt-5.5).
- `agent_settings.json`: `stream` kept as false (headless mode lacks on_token callback).

## Verified on 2026-05-22

- `D:\devtools\openhands.cmd --version` -> `OpenHands CLI 1.16.0`.
- `D:\devtools\openhands.cmd mcp list` -> one enabled `agentmemory` HTTP MCP server at `http://localhost:3115/mcp`.
- Internal CLI load confirmed model `openai/gpt-5.5`, base URL `http://127.0.0.1:9100/v1`, and agent MCP key `agentmemory`.
- Bridge FastMCP client listed 53 memory tools and successfully called `memory_smart_search`.
- Docker GUI container `openhands-app` started from `openhands:latest`; `http://localhost:3000` returned 200; `/api/v1/settings` returned 200 and showed model `openai/gpt-5.5`.
- Official CLI headless run exited 0 and loaded all memory MCP tools into the tool list.
- **End-to-end verified**: headless CLI with gpt-5.5 successfully called `memory_smart_search("openhands")` and returned 5 memory results. First call had wrong param shape (wrapped in `data:`), agent self-corrected on retry.
- Claude profile (`claude-opus-4-7`) tested via direct API call — 200 OK.

## Known caveats

- WSL Ubuntu is currently broken with `ERROR_FILE_NOT_FOUND` mounting its ext4 VHDX; official Windows CLI docs prefer WSL, but this setup uses a native Windows venv because it is currently functional.
- Docker GUI starts slowly; wait 30-60 seconds before hitting `http://localhost:3000`.
- `D:\devtools\openhands-gui.cmd` may pull `docker.openhands.dev/openhands/openhands:latest`; for offline/local smoke testing use the already present `openhands:latest` image directly.
- Some third-party SDK warnings can appear on stderr in PowerShell even when exit code is 0; functional checks above passed.
