---
title: "DeepSeek CLI input prompt and command palette upgrade"
type: session
created: 2026-05-22T00:00:00+02:00
updated: 2026-05-22T00:00:00+02:00
agent: codex
tags: [deepseek-cli, terminal-ui, slash-commands, permissions, input-editor, completion-audit]
related: ["2026-05-22_deepseek-cli-wrapped-input-fix.md", "2026-05-22_deepseek-cli-runtime-controls.md"]
---

# DeepSeek CLI input prompt and command palette upgrade

## Summary

Codex upgraded `D:\devtools\deepseek-cli` interactive input after user feedback that the green `deepseek >` prompt looked informal and that typing slash/backslash did not show actionable choices.

## Changes

- Replaced the old green `deepseek >` input prompt with a distinct blue double-rule marker (`\u2501\u2501 `, rendered as two long horizontal rules).
- Added a raw-mode command palette triggered by `/` or `\` at whitespace-delimited token boundaries, including mid-sentence positions such as `please /permissions`.
- Added filtering, Up/Down navigation, Tab/Enter accept, Escape dismiss, and nested option choices for model, thinking, permission model, approval mode, sandbox mode, write mode, and pending IDs.
- Connected menu selections to real runtime behavior rather than placeholders:
  - `/model`, `/thinking`
  - `/permissions`, `/permission-model <safe|read-only|trusted|locked>`
  - `/approval <on-request|auto|never>`
  - `/sandbox <workspace-write|read-only|unrestricted>`
  - `/write-mode <preview|direct>`
- Added runtime setters in safety modules so interactive permission changes affect shell approval, file write, and sandbox behavior immediately.
- Added text selection support in the custom editor:
  - Shift+Left/Right/Home/End selection
  - SGR mouse drag selection in modern terminals
  - Backspace/Delete removes the selected range in one operation.
- Added `--self-test-editor` hidden verification hook and E2E assertions for slash palette acceptance and one-shot selected-text deletion.
- Updated README terminal and safety sections.

## Validation

- `npm.cmd run typecheck` passed.
- `npm.cmd run build` passed.
- `node dist/index.js --self-test-editor` returned `{ "ok": true, "slash": true, "selection_delete": true }`.
- `node scripts/e2e.mjs` passed and now covers permission model changes, model/thinking changes, backslash command alias, embedded slash command execution, and editor self-test.
- `git diff --check` passed.

## Notes

- `D:\devtools\deepseek-cli\config.toml` had pre-existing local uncommitted agentmemory MCP changes before this task; Codex did not treat it as part of this UI/command-palette patch.
