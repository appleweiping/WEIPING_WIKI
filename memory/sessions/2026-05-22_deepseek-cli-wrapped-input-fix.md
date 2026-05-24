---
title: "DeepSeek CLI wrapped terminal input fix"
type: session
created: 2026-05-22T00:00:00+02:00
updated: 2026-05-22T00:00:00+02:00
agent: codex
tags: [deepseek-cli, terminal-ui, readline, input-editor, bugfix]
related: ["2026-05-22_deepseek-cli-terminal-whale-logo.md", "2026-05-22_deepseek-cli-safety-sessions-ci.md"]
---

## Summary

User reported DeepSeek CLI terminal input corruption with long Chinese prompts: wrapped lines duplicated `deepseek >`, Up/Down arrows added odd lines, and Backspace could corrupt redraw. Root cause was relying on Node's default `readline` prompt rendering for long wrapped CJK input and ANSI-colored prompt behavior.

## Fix

- Replaced TTY interactive input with a custom raw-mode line editor in `src/ui/terminal.ts`.
- Non-TTY/piped input still uses Node `readline` so scripts and E2E remain stable.
- New editor supports:
  - stable full repaint of wrapped input
  - Chinese/fullwidth character column measurement
  - Left/Right, Home/End, Backspace/Delete
  - Up/Down visual-row cursor movement inside wrapped input
  - history navigation only at top/bottom visual row
  - Ctrl+A/E/U/K, Ctrl+C, Ctrl+D
- Added `DEEPSEEK_LEGACY_READLINE=1` escape hatch for reverting to Node readline.
- README and `/help` document wrapped-line editing behavior.

## Git

- Commit: `612558c fix terminal wrapped input editing`
- Pushed: yes, `master -> master`
- Local-only unstaged file intentionally left out: `config.toml`.

## Validation

- `node .\\node_modules\\typescript\\bin\\tsc --noEmit` passed
- `npm.cmd run build` passed
- `node scripts/e2e.mjs` passed with elevated execution due local spawnSync sandbox behavior
- `git diff --check` passed
