---
title: 2026-05-17 Larksuite CLI Feishu Bridge
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - feishu
  - lark
  - cli
source_files:
  - "D:/Research/vipin's knowledgebase/skill/lark-cli/SOURCE-TRACE.txt"
  - "D:/Research/vipin's knowledgebase/.codex/skills/feishu-bridge/SKILL.md"
source_pages:
  - https://github.com/larksuite/cli
---

# 2026-05-17 Larksuite CLI Feishu Bridge

## Provenance

- Source: user-approved implementation plan for Feishu/Lark material access skills.
- Official upstream: `https://github.com/larksuite/cli`.
- Installed release: `v1.0.32`.
- Inspected commit: `14a3213038eaf563fb2c1234fe20c92981cc8ed9`.
- Runtime install location: `.wiki-tmp/tools/lark-cli/v1.0.32/bin/lark-cli.exe`.
- Source mirror: `skill/lark-cli/`.
- Local routing skill: `.codex/skills/feishu-bridge/` and `skill/feishu-bridge/`.

## What Was Installed

- EXTRACTED: Downloaded official `lark-cli-1.0.32-windows-amd64.zip` to the D-drive project-local tool cache.
- EXTRACTED: Verified SHA256 against the official release checksum.
- EXTRACTED: Mirrored official `larksuite/cli` README, license, source trace, and skill tree under `skill/lark-cli/`.
- EXTRACTED: Installed selected official skills under both `.codex/skills/` and `skill/`: `lark-shared`, `lark-doc`, `lark-wiki`, `lark-drive`, `lark-base`, `lark-im`, `lark-sheets`, `lark-markdown`, `lark-slides`, `lark-calendar`, `lark-contact`, `lark-openapi-explorer`, and `lark-skill-maker`.
- EXTRACTED: Created `feishu-bridge` as a local router skill that chooses official API access first and falls back to [[chrome-automation]] for web-only Feishu pages and form filling.

## Why This Approach

- INFERRED: `anbeime/skill` did not provide a single clean Feishu material-ingestion skill that matched the user's core pain point.
- INFERRED: Feishu bot/assistant-style skills are less relevant for “model reads my Feishu materials” than an official CLI plus browser automation bridge.
- INFERRED: `qiaomu-anything-to-notebooklm` remains a second-phase option for Feishu/web/PDF/WeChat-to-NotebookLM analysis, but it is not required for the first usable Feishu bridge.

## Smoke Tests

Passed:

- EXTRACTED: `lark-cli --version` returned `lark-cli version 1.0.32`.
- EXTRACTED: `lark-cli --help` listed major domains including docs, drive, wiki, base, im, sheets, slides, calendar, mail, tasks, and more.
- EXTRACTED: `lark-cli docs --api-version v2 --help` listed `+create`, `+fetch`, `+update`, media, search, and whiteboard commands.
- EXTRACTED: `lark-cli wiki --help`, `drive --help`, `base --help`, and `im --help` all returned command lists.
- EXTRACTED: `lark-cli doctor` passed `cli_version` and `cli_update`, and reported `1.0.32 (up to date)`.
- EXTRACTED: Installed `feishu-bridge`, `lark-doc`, `lark-base`, `lark-wiki`, `lark-drive`, and `lark-im` passed `skill-creator` quick validation after local compatibility normalization.
- EXTRACTED: Browser fallback smoke test used `agent-browser 0.27.0` on a local HTML form, identified a textbox/button, filled a value, read it back, and saved a screenshot.

Blocked until user authorization or test resources:

- AMBIGUOUS: `lark-cli auth status` reported `not configured` and suggested `lark-cli config init --new`.
- AMBIGUOUS: Real Feishu document fetch/export, Wiki node read, Base record read/write, and docs create/update tests require the user to complete Feishu/Lark OAuth setup and provide or approve test resources.
- AMBIGUOUS: Real Feishu form filling should use a user-approved test form or explicit live-form instruction.

## Concrete Usage Pattern

Read docs:

```powershell
$LARK_CLI = "D:\Research\vipin's knowledgebase\.wiki-tmp\tools\lark-cli\v1.0.32\bin\lark-cli.exe"
& $LARK_CLI docs +fetch --api-version v2 --doc "<doc URL or token>"
```

Search Drive:

```powershell
& $LARK_CLI drive +search --help
```

Read Wiki:

```powershell
& $LARK_CLI wiki +space-list --help
& $LARK_CLI wiki +node-list --help
```

Read Base:

```powershell
& $LARK_CLI base +table-list --help
& $LARK_CLI base +record-list --help
```

Browser-fill fallback:

```powershell
$AB_BIN = "D:\Research\vipin's knowledgebase\.wiki-tmp\tools\agent-browser\bin\agent-browser-win32-x64.exe"
& $AB_BIN open "<feishu URL>" --cdp 9225 --session feishu-fill
& $AB_BIN snapshot -i --cdp 9225 --session feishu-fill
& $AB_BIN fill @e3 "value" --cdp 9225 --session feishu-fill
```

## Related

- [[feishu-bridge]]
- [[lark-cli]]
- [[chrome-automation]]
- [[agent-skill-installation-workflow]]
- [[agent-skill-repositories]]