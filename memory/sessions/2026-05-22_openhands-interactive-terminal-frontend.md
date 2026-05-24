---
title: OpenHands Interactive Terminal Frontend
date: 2026-05-22
tags: [openhands, cli, interactive, agentmemory, local-tools, windows]
status: completed-local
---

# OpenHands Interactive Terminal Frontend

## What changed

Implemented a local persistent interactive terminal frontend for the installed OpenHands engine on this machine.

Files:
- `D:\devtools\openhands-chat.py`: real interactive terminal frontend.
- `D:\devtools\openhands-router.py`: routes `openhands` invocations.
- `D:\devtools\openhands.cmd`: default launcher now routes no-arg/chat invocations to interactive mode and `-t`/`-f` tasks to official headless mode.
- `D:\devtools\openhands-chat.cmd`: direct chat launcher.
- `D:\devtools\openhands.cmd.bak-20260522-chat`: backup of previous launcher.

## Behavior

- `openhands` with no arguments starts interactive terminal chat and shows an OpenHands ASCII logo.
- `openhands chat ...` or `openhands --chat ...` starts interactive chat explicitly.
- `openhands -t "..."` and `openhands -f task.txt` are preserved as official OpenHands headless task mode via `python -m openhands.core.main`.
- `openhands-chat` starts chat directly.
- Chat mode reuses installed OpenHands `run_controller`, `create_runtime`, event stream, controller, runtime, tools, and MCP stack. It is not a per-message shell loop around `openhands -t`.
- Chat mode subscribes to the OpenHands event stream and prints agent messages, commands, file events, MCP calls/results, command output, errors, and terminal states.
- Chat mode patches `AgentState.FINISHED` into `AWAITING_USER_INPUT` for normal turns so a session can continue after the agent completes one turn. `/exit` or `/quit` ends the session.
- Chat mode sets `workspace_base`, `workspace_mount_path`, and `workspace_mount_path_in_sandbox` from `-d` or current directory.
- On Windows home directory launches, if `.openhands\microagents` is a junction outside the selected workspace, chat mode skips only that repository microagents load to avoid OpenHands path traversal failure. Agentmemory MCP remains active.

## Validation evidence

- Syntax check passed: `python -m py_compile D:\devtools\openhands-chat.py D:\devtools\openhands-router.py`.
- Default no-arg launcher shows logo and exits on `/exit` using `D:\devtools\openhands-logo-exit-out.txt`.
- Chat smoke test from `C:\Users\admin` showed `CHAT_READY` and loaded 53 agentmemory MCP tools. Evidence:
  - `D:\devtools\openhands-smoke3-out.txt`
  - `D:\devtools\openhands-smoke3-err.txt`
- Direct Python chat multiturn test used one OpenHands controller/session and showed both `FIRST_READY` and `SECOND_READY`. Evidence:
  - `D:\devtools\openhands-multiturn-direct-out.txt`
  - `D:\devtools\openhands-multiturn-direct-err.txt`
- Official one-shot route with `openhands -t "..."` still works and reached `AgentState.FINISHED`. Evidence:
  - `D:\devtools\openhands-official-route3-err.txt`
- Memory/MCP validation: tests logged `Loaded 53 MCP tools` and `Setting 53 MCP tools for agent CodeActAgent`.

## Usage

Interactive:

```powershell
openhands
```

Explicit chat:

```powershell
openhands chat -d D:\research
openhands-chat -d D:\research
```

Official one-shot task mode remains:

```powershell
openhands -t "Reply exactly READY, then finish. Do not modify files." -d C:\Users\admin -i 6
```

Chat commands:
- `/exit` or `/quit`: leave the OpenHands session.
- `<<<` then end with `>>>`: multiline input.

## Upstream note

No commit/push was made to `D:\research\openhands`. That repository is currently clean and tracks `OpenHands/OpenHands` main, but the local installed command uses legacy `openhands-ai 1.6.0` V0 APIs (`openhands.core.main.run_controller`). The current repo is V1/app_server/SDK-oriented and does not contain the same legacy CLI source path. Pushing this local V0 adapter into upstream main would not be a clean upstream contribution without redesigning it around the V1 SDK/app_server entrypoints.

Recommended if contributing upstream later: create a separate branch and implement a V1 SDK-native terminal frontend in the repo, with tests, instead of upstreaming the local machine adapter.
