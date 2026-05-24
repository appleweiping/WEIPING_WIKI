---
title: "2026-05-22 ARIS and OpenHands readiness check"
type: session
created: 2026-05-22T13:32:00+02:00
updated: 2026-05-22T13:32:00+02:00
agent: codex
tags: [aris, openhands, agentmemory, api, cli, readiness]
related: [2026-05-22_agentmemory-lazy-mode-audit.md, ../facts/agent-cli-launch-config.md]
---

# 2026-05-22 ARIS and OpenHands readiness check

## ARIS

- `aris doctor` reports executor API auth OK and reviewer APIs OK.
- `aris --output-format text "Reply exactly ARIS_READY and nothing else."` succeeded and returned `ARIS_READY`.
- Direct usage: run `aris` for REPL, or `aris "task text"` / `aris --output-format text "task text"` for one-shot CLI mode.

## OpenHands

- Launcher `D:\devtools\openhands.cmd` now automatically loads `D:\research\openhands\config.toml`.
- Config uses CLI runtime, PixelCat at `http://127.0.0.1:8990`, and `agentmemory` MCP through `D:\devtools\node\node.exe`.
- Fixed OpenHands TOML encoding to UTF-8 no BOM; prior BOM caused TOML parse failure and fallback to Docker runtime.
- Fixed PixelCat base URL by removing the extra `/v1`; prior value produced `http://127.0.0.1:8990/v1/v1/messages` 404.
- Rewrote `C:\Users\admin\.openhands\microagents\research-workflow.md` as ASCII to avoid Windows GBK decode errors.
- Smoke test `openhands -t "Reply exactly OPENHANDS_READY, then finish. Do not modify any files." -d C:\Users\admin -i 5` succeeded; session event recorded `OPENHANDS_READY` and final state `finished`.
- OpenHands loaded 53 agentmemory MCP tools.

## Usage Notes

- Use `openhands -t "task" -d "project_path" -i 20` for headless CLI tasks.
- OpenHands CLI runtime has no sandbox and can edit files directly under `D:\Research`; use it only for trusted tasks.
- Avoid `--no-auto-continue` unless intentionally driving it interactively; it can wait for input in headless tests.
