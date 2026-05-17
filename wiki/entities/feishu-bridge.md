---
title: Feishu Bridge
type: entity
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - entity
  - agent-skills
  - feishu
  - lark
  - local-tooling
source_pages:
  - 2026-05-17-larksuite-cli-feishu-bridge
---

# Feishu Bridge

## Role In The Wiki

`feishu-bridge` is the project-local routing skill for connecting Feishu/Lark materials to Codex.

It is not a separate upstream Feishu skill from `anbeime/skill`. It is a local wrapper that combines the official [[lark-cli]] API workflow with [[chrome-automation]] for logged-in web pages and form-filling.

## Current Claims

- EXTRACTED: `feishu-bridge` is installed under `.codex/skills/feishu-bridge/` and mirrored under `skill/feishu-bridge/`.
- EXTRACTED: It routes Feishu/Lark documents, Wiki nodes, Drive files, Base records, Sheets, and messages to official `lark-cli` skills when API access is possible.
- EXTRACTED: It routes arbitrary Feishu web links and form-fill workflows to the already verified [[chrome-automation]] runtime.
- INFERRED: This is the right default for the user's pain point, because the main problem is model access to Feishu materials, not running a Feishu chat bot.

## Usage

Use this skill for prompts such as:

```text
读一下这个飞书文档并总结。
把这个飞书知识库节点整理成 Markdown。
帮我读取这个多维表格前 20 条记录。
打开这个飞书链接，帮我填一下表单。
Search my Lark Drive for the project plan and export it.
```

Routing rule:

1. Use `lark-cli` and the relevant `lark-*` skill first for structured read/write.
2. Use `chrome-automation` when the task depends on a live browser session, login-only web UI, or interactive form fields.
3. Record blocked API work as blocked by Feishu/Lark authorization instead of pretending it succeeded.

## Local Paths

- Skill: `D:/Research/vipin's knowledgebase/.codex/skills/feishu-bridge/`
- Mirror: `D:/Research/vipin's knowledgebase/skill/feishu-bridge/`
- Runtime: `D:/Research/vipin's knowledgebase/.wiki-tmp/tools/lark-cli/v1.0.32/bin/lark-cli.exe`

## Verification Record

- EXTRACTED: `feishu-bridge` passed the local `skill-creator` `quick_validate.py` check after normalizing UTF-8 without BOM.
- EXTRACTED: Browser-fill fallback was smoke-tested with `agent-browser 0.27.0` on a local HTML form: it opened the test page, found the textbox and button, filled `Beauty-Love Feishu test`, read the value back, and saved a screenshot.
- AMBIGUOUS: Real Feishu page fill was not attempted because no user-approved Feishu test form link was provided in this turn.
- AMBIGUOUS: API read/write tests are blocked until `lark-cli config init --new` and `lark-cli auth login --recommend` are completed by the user.

## Safety Boundary

- Do not write/delete/share/send in Feishu without clear user intent.
- Use dry-run or read-only commands first when available.
- Do not record private Feishu document contents in the public wiki unless the user explicitly approves.

## Related Pages

- [[lark-cli]]
- [[chrome-automation]]
- [[agent-skill-installation-workflow]]
- [[agent-skill-repositories]]