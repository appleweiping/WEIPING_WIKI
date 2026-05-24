---
title: "DeepSeek CLI terminal whale logo polish"
type: session
created: 2026-05-22T00:00:00+02:00
updated: 2026-05-22T00:00:00+02:00
agent: codex
tags: [deepseek-cli, terminal-ui, branding, whale-logo]
related: ["2026-05-22_deepseek-cli-safety-sessions-ci.md"]
---

## Summary

After user feedback that the terminal DeepSeek whale logo did not look like a real whale, the startup ASCII logo in `src/ui/terminal.ts` was replaced with a more recognizable side-profile blue whale: water spout, eye, body, tail/fluke, waves, and `>_` terminal cue.

## Git

- Repo: `D:/devtools/deepseek-cli`
- Commit: `f8dc1b8 polish terminal whale logo`
- Pushed: yes, `master -> master`

## Validation

- `node .\node_modules\typescript\bin\tsc --noEmit` passed
- `npm.cmd run build` passed
- Interactive startup smoke showed the new whale logo in terminal
- `git diff --check` passed

## Note

README Image 2 banner was not changed in this follow-up; only the terminal startup logo changed.
