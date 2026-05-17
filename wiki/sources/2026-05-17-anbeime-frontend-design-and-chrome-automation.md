---
title: 2026-05-17 Anbeime Frontend Design And Chrome Automation Skills
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - frontend
  - browser-automation
source_files:
  - "D:/Research/vipin's knowledgebase/skill/frontend-design/SKILL.md"
  - "D:/Research/vipin's knowledgebase/skill/chrome-automation/SKILL.md"
source_pages:
  - https://github.com/anbeime/skill/tree/main/skills/frontend-design/frontend-design
  - https://github.com/anbeime/skill/tree/main/skills/chrome-automation/chrome-automation
---

# 2026-05-17 Anbeime Frontend Design And Chrome Automation Skills

## Provenance

- Source: user request to record and install `frontend-design` and `chrome-automation` from `anbeime/skill`.
- Upstream repository: `https://github.com/anbeime/skill.git`.
- Upstream HEAD at inspection: `049efd5f29fb47c9165871caac4e61b4c67cb2c9`.
- Retrieval mode: sparse clone of only the two requested paths.
- Local source mirrors: `skill/frontend-design/` and `skill/chrome-automation/`.
- Installed skills: `.codex/skills/frontend-design/` and `.codex/skills/chrome-automation/`.

## Frontend Design

- EXTRACTED: `frontend-design` is a guidance skill for creating distinctive, production-grade frontend interfaces.
- EXTRACTED: It should be used when the user asks to build web components, pages, applications, or interfaces.
- EXTRACTED: The skill emphasizes choosing a bold aesthetic direction before coding: purpose, tone, constraints, and differentiation.
- EXTRACTED: It warns against generic AI aesthetics such as overused fonts, purple gradients, predictable layouts, and cookie-cutter component patterns.
- EXTRACTED: Its design axes include typography, color/theme, motion, spatial composition, backgrounds, texture, depth, and contextual visual details.
- INFERRED: It complements [[html-ppt-agent-workflow]]: `frontend-design` is broad interface design guidance, while `frontend-slides` is presentation-specific.

## Frontend Design Usage

Use it for prompts such as:

```text
用 frontend-design 帮我做一个有设计感的登录页。
Build a distinctive dashboard UI for this SaaS workflow.
给这个 HTML 页面重新做一个更有记忆点的视觉设计。
```

Expected workflow:

1. Determine product purpose, audience, technical constraints, and desired tone.
2. Commit to a clear visual direction rather than a neutral default.
3. Implement working frontend code.
4. Verify the UI with screenshots/browser checks when a runnable frontend exists.

## Chrome Automation

- EXTRACTED: `chrome-automation` controls a real Google Chrome instance through `agent-browser` and Chrome DevTools Protocol.
- EXTRACTED: It is intended for tasks where the user needs visible browser automation, control of an existing Chrome-like session, live screenshots, and precise element interaction.
- EXTRACTED: The upstream skill requires installation/dependency checks before use and explicitly says not to fall back to built-in browser tooling as a substitute.
- EXTRACTED: Its command model uses `agent-browser` with operations such as `open`, `snapshot -i`, `click`, `fill`, `press`, `get url`, `get title`, and `screenshot`, connected to Chrome with `--cdp <port>`.
- EXTRACTED: The upstream Windows scripts default to `$HOME\Documents\agent-browser` and `~/.claude/skills`, but this local installation uses D-drive paths.

## Chrome Automation Local Verification

- EXTRACTED: Chrome exists locally at `C:/Program Files/Google/Chrome/Application/chrome.exe`.
- EXTRACTED: `agent-browser` was cloned to `.wiki-tmp/tools/agent-browser/`.
- EXTRACTED: `bun install` downloaded `agent-browser-win32-x64.exe`, and the binary returned `agent-browser 0.27.0`.
- EXTRACTED: A project-local Rust toolchain was installed under `.wiki-tmp/tools/rust/` for build attempts.
- EXTRACTED: Native build failed because MSVC `link.exe` was missing; the downloaded upstream Windows binary still worked.
- EXTRACTED: A real CDP smoke test passed on port `9223`: Chrome launched with a D-drive profile, `agent-browser` opened `https://example.com`, returned title `Example Domain`, returned URL `https://example.com/`, and wrote a screenshot under `.wiki-tmp/chrome-automation-example.png`.
- EXTRACTED: A follow-up retest on port `9224` confirmed command-first invocation is reliable on this local Windows runtime: `open https://example.com --cdp 9224 --session codex-retest`, `get title --cdp 9224 --session codex-retest`, `get url --cdp 9224 --session codex-retest`, and `snapshot -i --cdp 9224 --session codex-retest`.
- EXTRACTED: The same retest showed `screenshot body <path> --cdp 9224 --session codex-retest`, `screenshot @e1 <path> --cdp 9224 --session codex-retest`, and `screenshot --full <path> --cdp 9224 --session codex-retest` write image files. A single path argument after `screenshot` can be interpreted as a selector and fail.
- INFERRED: The skill is operational for real Chrome automation using the downloaded Windows binary even without a local native rebuild.

## Chrome Automation Usage

Local D-drive command pattern:

```powershell
$AB_HOME = "D:\Research\vipin's knowledgebase\.wiki-tmp\tools\agent-browser"
$AB_BIN = "$AB_HOME\bin\agent-browser-win32-x64.exe"
$CHROME_PROFILE = "D:\Research\vipin's knowledgebase\.wiki-tmp\tools\chrome-automation-profile"
$PORT = 9223
$env:AGENT_BROWSER_HOME = $AB_HOME

Start-Process -FilePath "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  -ArgumentList @("--remote-debugging-port=$PORT", "--user-data-dir=$CHROME_PROFILE", "about:blank")

& $AB_BIN open https://example.com --cdp $PORT --session codex-smoke
& $AB_BIN snapshot -i --cdp $PORT --session codex-smoke
& $AB_BIN get title --cdp $PORT --session codex-smoke
& $AB_BIN get url --cdp $PORT --session codex-smoke
& $AB_BIN screenshot body ".wiki-tmp\state.png" --cdp $PORT --session codex-smoke
```

Common commands:

| Command | Purpose |
| --- | --- |
| `open <url>` | Navigate to a URL. |
| `snapshot -i` | List interactive elements with refs. |
| `click @e1` | Click an element by ref. |
| `fill @e1 "text"` | Fill an input. |
| `press Enter` | Send a key press. |
| `get title` / `get url` | Read current page metadata. |
| `screenshot body <path>` | Capture visible browser state to a file. |

## Installation And Testing Standard

- EXTRACTED: The user explicitly instructed that skill installation must not be toyified by skipping required downloads or dependency setup.
- EXTRACTED: For executable skills, future agents should re-run relevant dependency and smoke tests instead of treating the skill as a passive archive.
- INFERRED: A successful skill install in this wiki should include a source mirror, `.codex/skills` installation, runtime dependency check, practical smoke test, wiki documentation, catalog/lint validation, and scoped commit/push.

## Related

- [[frontend-design]]
- [[chrome-automation]]
- [[agent-skill-installation-workflow]]
- [[anbeime-skill]]
- [[agent-skill-repositories]]
