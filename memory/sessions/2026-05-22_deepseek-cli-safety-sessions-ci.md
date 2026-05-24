---
title: "DeepSeek CLI safety sessions CI productization"
type: session
created: 2026-05-22T00:00:00+02:00
updated: 2026-05-22T00:00:00+02:00
agent: codex
tags: [deepseek-cli, cli, safety, sandbox, sessions, ci, image2, productization]
related: ["2026-05-21_deepseek-cli-alignment.md"]
---

## Summary

DeepSeek CLI in `D:/devtools/deepseek-cli` was productized with Codex/Claude-Code-style safety and session controls, verified, committed, and pushed to GitHub.

## Git

- Repo: `https://github.com/appleweiping/deepseek-cli.git`
- Branch: `master`
- Commit: `5b053e0 feat: add safety approvals and sessions`
- Pushed: yes, `master -> master`
- Local-only unstaged file intentionally left out: `config.toml` with user-specific MCP config.

## Implemented

- Shell approval/sandbox layer:
  - `DEEPSEEK_APPROVAL_MODE=on-request|never|auto`
  - dangerous shell commands blocked
  - risky shell commands queued for `/approvals`, `/approve <id>`, `/deny <id>`
- File patch preview layer:
  - `DEEPSEEK_WRITE_MODE=preview|direct`
  - `write_file` and `edit_file` create patch previews by default
  - `/patches`, `/apply <id>`, `/reject <id>`
  - patch apply checks file has not changed since preview
- Workspace sandbox:
  - `DEEPSEEK_SANDBOX_MODE=workspace-write|read-only|unrestricted`
  - default blocks file writes outside current workspace
- Sessions:
  - JSON transcripts under `~/.deepseek-cli/sessions/`
  - `--session`, `--resume`, `/session`, `/compact [n]`
- MCP diagnostics:
  - `--doctor` connects configured MCP servers and reports `mcp_diagnostics`
  - agentmemory configuration is diagnosable from doctor output
- CI/E2E:
  - `.github/workflows/ci.yml`
  - Node 22, typecheck, build, E2E smoke tests
- Branding:
  - README `assets/banner.png` replaced through local Image 2 hub with cartoon companions: DeepSeek whale, Codex robot, Claude-style assistant
  - terminal startup banner now includes blue pixel whale logo
- README updated with safety/session/sandbox/CI docs.

## Validation

- `node .\node_modules\typescript\bin\tsc --noEmit` passed
- `npm.cmd run build` passed
- `node scripts/e2e.mjs` passed with elevated execution because sandbox blocks `spawnSync` locally
- Startup smoke confirmed blue whale logo appears in terminal banner
- `git diff --check` passed

## Official Docs Checked

- DeepSeek API docs for thinking mode / request parameters and V4 Pro/Flash dual-mode behavior
- GitHub Actions official workflow syntax and official `actions/checkout` / `actions/setup-node` usage
