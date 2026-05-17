---
title: Where Can Local CC Be Used
type: query
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - query
  - local-tools
  - claude-code
  - pixelcat
  - opencode
source_pages:
  - local-cc-sidecar-agent-workflow
  - 2026-05-17-opencode-cc-pixelcat-setup
---

# Where Can Local CC Be Used

## Short Answer

EXTRACTED: Vipin's local Claude Code entrypoint is `D:\cc\cc.cmd`; PixelCat provides the local proxy at `127.0.0.1:8990`; the PixelCat management panel must be open for the local `cc` family tools to work.

INFERRED: Terminal use is the most direct and controllable path, but it is not the only useful environment. Any local environment that can either execute `D:\cc\cc.cmd` or use the PixelCat-compatible local API endpoint can potentially be wired into the setup.

## Usable Environments

- Terminal / PowerShell / CMD: direct `cc` or `D:\cc\cc.cmd` usage, including non-interactive `-p` prompts for review/scanning.
- Codex Desktop: can call `D:\cc\cc.cmd` for read-only Opus/Sonnet partner reviews when the local workflow threshold is met.
- VSCode / Claude Code extension: recorded as installed; can use the local Claude Code setup when configured correctly.
- OpenCode: `D:\cc\opencode.cmd` is installed and smoke-tested, with PixelCat-compatible local API configuration recorded.
- PixelCat management panel: control plane for model routing, quota/status, and local proxy availability. Treat it as the local service/dashboard, not as the main Claude Code authoring surface.

## Web And Downloaded App Boundary

INFERRED: Claude web or a standalone Claude app can be used for normal Claude chat, but that is a separate environment from Vipin's local `cc` runtime. Those surfaces do not automatically inherit `D:\cc\cc.cmd`, local repository access, Codex's working directory, or the PixelCat proxy configuration.

INFERRED: A web UI can only use this local setup if it is explicitly designed/configured to call a local or OpenAI-compatible endpoint such as `http://127.0.0.1:8990`. A generic hosted webpage normally cannot just invoke the local `cc.cmd` command or read local repositories.

## Rule Of Thumb

Use this check:

- If the environment can run local commands, it can usually invoke `cc`.
- If the environment can be configured to call the PixelCat local API, it may use the same routed model backend.
- If the environment is a hosted web/app chat surface with no local command or local API access, treat it as separate from the local Claude Code setup.

## Related Pages

- [[local-cc-sidecar-agent-workflow]]
- [[2026-05-17-opencode-cc-pixelcat-setup]]
