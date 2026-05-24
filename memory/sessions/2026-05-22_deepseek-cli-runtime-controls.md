---
title: "DeepSeek CLI runtime controls hardening"
type: session
created: 2026-05-22T00:00:00+02:00
updated: 2026-05-22T00:00:00+02:00
agent: codex
tags: [deepseek-cli, cli, runtime-controls, thinking-mode, github, infrastructure]
related: [2026-05-21_deepseek-cli-alignment.md, ../facts/agent-cli-launch-config.md]
---

# DeepSeek CLI runtime controls hardening

## Summary

Codex deepened the `D:\devtools\deepseek-cli` review against official DeepSeek API docs and productized model/thinking controls, then committed and pushed to GitHub.

## Official-doc findings

- DeepSeek V4 supports Pro and Flash model variants.
- Thinking is controlled request-by-request through the `thinking` parameter.
- Both Pro and Flash can be used with thinking enabled or disabled.
- Thinking defaults to enabled in official V4 behavior; temperature is ignored/not useful in thinking mode.
- For tool-call turns in thinking mode, assistant `reasoning_content` must be preserved in message history for follow-up requests.

## Changes pushed

Commit: `e48c26a feat: harden DeepSeek runtime controls`

- Added model presets and aliases: `pro`, `flash`, `chat`, `reasoner`, `pro-thinking`, `pro-non-thinking`, `flash-thinking`, `flash-non-thinking`.
- Added CLI controls: `--model`, `--thinking`, `--reasoning-effort`, `--models`, `--json --doctor`, `--version`, `--cwd`, `--task`, `--flag=value`, and positional task input.
- Added interactive controls: `/models`, `/model <name>`, `/thinking <mode>`, with runtime status display.
- Added autonomous runtime switching tool: `configure_deepseek_runtime` so the agent can switch Pro/Flash/thinking when useful.
- Hardened DeepSeek API requests for V4 thinking mode, including `reasoning_content` preservation for tool call loops.
- Added stable JSON output/error policy for scriptable agent use.
- Fixed config lookup order and added `DEEPSEEK_CONFIG` support.
- Improved grep fallback when `rg` is unavailable.
- Fixed TypeScript strict issues in shell tool.

## Validation

- `node .\node_modules\typescript\bin\tsc --noEmit` passed.
- `npm run build` passed.
- `node dist/index.js --version` returned `0.1.0`.
- `node dist/index.js --json --doctor` returned stable JSON.
- `node dist/index.js --json --model flash --thinking off -t "Reply with exactly OK"` returned stable JSON with `output: "OK"`.
- Interactive smoke verified `/models`, `/model pro-non-thinking`, `/thinking max`, `/status`, `/exit`.
- GitHub push succeeded: `master` advanced `7db33b4..e48c26a`.

## Notes

- Local `config.toml` still has pre-existing unstaged local MCP changes and was intentionally not included in the commit.
- DeepSeek CLI can already operate on files and code like Codex/Claude Code through built-in tools: shell execution, file read/write/edit, glob, grep, and MCP tools; quality depends on model/runtime selection.
