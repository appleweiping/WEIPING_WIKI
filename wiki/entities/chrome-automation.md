---
title: Chrome Automation Skill
type: entity
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - entity
  - agent-skills
  - browser-automation
  - chrome
source_pages:
  - 2026-05-17-anbeime-frontend-design-and-chrome-automation
---

# Chrome Automation Skill

## Role In The Wiki

`chrome-automation` is a project-local installed skill for controlling real Google Chrome through `agent-browser` and Chrome DevTools Protocol.

## Current Claims

- EXTRACTED: The upstream path is `https://github.com/anbeime/skill/tree/main/skills/chrome-automation/chrome-automation`.
- EXTRACTED: It was mirrored under `skill/chrome-automation/`.
- EXTRACTED: It was installed under `.codex/skills/chrome-automation/`.
- EXTRACTED: The installed skill was locally annotated with a D-drive runtime override because upstream examples assume `~/.claude/skills` and `$HOME\Documents\agent-browser`.
- EXTRACTED: The D-drive `agent-browser-win32-x64.exe` runtime passed a real CDP smoke test on 2026-05-17.

## Usage

Use it when the user needs visible real-browser automation:

```text
用 chrome-automation 打开这个网站并截图。
Use chrome-automation to fill this form in real Chrome.
控制我当前 Chrome 页面，帮我点这个按钮。
```

Local command pattern:

```powershell
$AB_HOME = "D:\Research\vipin's knowledgebase\.wiki-tmp\tools\agent-browser"
$AB_BIN = "$AB_HOME\bin\agent-browser-win32-x64.exe"
$PORT = 9223
$env:AGENT_BROWSER_HOME = $AB_HOME
& $AB_BIN open https://example.com --cdp $PORT --session codex-smoke
& $AB_BIN get title --cdp $PORT --session codex-smoke
& $AB_BIN get url --cdp $PORT --session codex-smoke
& $AB_BIN snapshot -i --cdp $PORT --session codex-smoke
& $AB_BIN screenshot body ".wiki-tmp\state.png" --cdp $PORT --session codex-smoke
```

Before use, ensure Chrome is running with `--remote-debugging-port=$PORT`.

## Verification Record

- EXTRACTED: Installed `agent-browser` under `.wiki-tmp/tools/agent-browser/`.
- EXTRACTED: Downloaded binary returned `agent-browser 0.27.0`.
- EXTRACTED: Chrome launched with `--remote-debugging-port=9223` and D-drive profile `.wiki-tmp/tools/chrome-automation-profile`.
- EXTRACTED: `agent-browser --cdp 9223 open https://example.com` succeeded.
- EXTRACTED: `get title` returned `Example Domain`.
- EXTRACTED: `get url` returned `https://example.com/`.
- EXTRACTED: `screenshot` wrote `.wiki-tmp/chrome-automation-example.png`.
- EXTRACTED: A retest found the Windows binary is most reliable when global flags are placed after the command, for example `open https://example.com --cdp 9224 --session codex-retest`.
- EXTRACTED: Saved screenshots work with `screenshot body <path>` or `screenshot --full <path>`; `screenshot <path>` can be parsed as a selector and fail.
- AMBIGUOUS: Native Rust rebuild failed because MSVC `link.exe` was missing; this does not block the downloaded Windows binary.

## Safety Boundary

- Do not enter credentials or publish/submit forms without explicit user confirmation.
- Prefer isolated D-drive Chrome profiles for testing.
- Use real-user sessions only when the user asks for that context.
- Show screenshots or summarize visible state after significant browser actions.

## Counterpoints And Gaps

- AMBIGUOUS: Upstream auto-install scripts still default to `$HOME\Documents`; future agents should use the D-drive override unless the user explicitly wants global installation.
- AMBIGUOUS: The upstream docs often show `--cdp <port>` before the command; on this local Windows runtime, use command-first examples in this page.
- INFERRED: If a future task requires native rebuild, installing Visual Studio Build Tools with MSVC linker may be necessary; this should not be committed to the repo.

## Related Pages

- [[2026-05-17-anbeime-frontend-design-and-chrome-automation]]
- [[agent-skill-installation-workflow]]
- [[agent-skill-repositories]]
