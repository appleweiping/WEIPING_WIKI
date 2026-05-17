---
title: OpenCode, Claude Code, and PixelCat Local Setup Session
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - local-tools
  - coding-agent
  - opencode
  - claude-code
  - pixelcat
source_files: []
source_pages:
  - local-cc-sidecar-agent-workflow
---

# OpenCode, Claude Code, and PixelCat Local Setup Session

## Provenance

Origin: chat session plus local smoke tests on 2026-05-17.

The user wanted OpenCode and Claude Code installed on the D drive, integrated with PixelCat, and made usable from VSCode without treating the setup as a toy collection. A user-provided tutorial page and local chat/video material guided the setup, but private chat/video contents are not copied into this public wiki.

Tutorial references:

- `https://ai.moono.vip/opencode-tutorial.html?v=2`
- `https://ai.moono.vip/claude-install-tutorial.html`

## Extracted Setup Facts

- EXTRACTED: OpenCode was installed under `D:\cc\npm-global`.
- EXTRACTED: Claude Code / `cc` was installed under `D:\cc\npm-global`.
- EXTRACTED: Convenience entrypoints were created at `D:\cc\opencode.cmd` and `D:\cc\cc.cmd`.
- EXTRACTED: `D:\cc\setup-env.ps1` was created to set the local PATH/runtime environment.
- EXTRACTED: User PATH was updated to include `D:\cc`, `D:\cc\node`, `D:\cc\npm-global`, and `D:\cc\npm-global\node_modules\.bin`.
- EXTRACTED: PixelCat local proxy was confirmed running via `D:\cc\pixelcat-app.exe` and listening on `127.0.0.1:8990`.
- EXTRACTED: OpenCode was configured to use the PixelCat-compatible local API endpoint and a default Claude Sonnet model.
- EXTRACTED: VSCode had the PixelCat OpenCode extension and Claude Code extension installed.

## Smoke Tests

- EXTRACTED: `D:\cc\opencode.cmd --version` returned `1.15.3`.
- EXTRACTED: `D:\cc\cc.cmd --version` returned `2.1.143 (Claude Code)`.
- EXTRACTED: `D:\cc\opencode.cmd run "Reply only OK" --model aiapi3/claude-sonnet-4-6` returned `OK`.
- EXTRACTED: `D:\cc\cc.cmd -p "Reply only OK" --model claude-sonnet-4-6 --output-format text` returned `OK`.
- EXTRACTED: `D:\cc\cc.cmd -p "Reply only OK" --model claude-opus-4-7 --output-format text` returned `OK`.
- EXTRACTED: `D:\cc\cc.cmd` successfully ran a read-only `claude-opus-4-7` diff-review sidecar prompt for the wiki update and reported `NO BLOCKERS`.

## Operational Meaning

INFERRED: The installation is usable as a local coding-agent runtime, not just a manually opened terminal tool. Future Codex sessions can call `D:\cc\cc.cmd` directly for sidecar planning, review, debugging, and verification when the task merits multi-agent collaboration.

See [[local-cc-sidecar-agent-workflow]] for the reusable workflow.

## Safety Notes

- Do not publish local auth tokens or provider secrets in wiki pages.
- Do not copy private chat/video contents into public wiki pages.
- Keep runtime packages, caches, and downloaded toolchains out of Git unless they are deliberate source files.
- If the PixelCat panel/proxy is not running, `cc` and OpenCode may fail even when the entrypoints exist.
- The hardcoded D-drive path and local proxy port are operational notes, not portable configuration; update the workflow if the local runtime moves.
