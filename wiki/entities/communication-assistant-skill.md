---
title: Communication Assistant Skill
type: entity
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - entity
  - agent-skills
  - communication
  - whatsapp
  - wechat
  - qq
source_pages:
  - 2026-05-17-communication-assistant-skill
---

# Communication Assistant Skill

## Role In The Wiki

`communication-assistant` is a project-local routing skill for lazy-mode communication across chat and email platforms. It is the umbrella layer above platform-specific skills and adapters.

## Current Claims

- EXTRACTED: The skill is installed under `.codex/skills/communication-assistant/`.
- EXTRACTED: The source mirror is under `skill/communication-assistant/`.
- EXTRACTED: It is designed as a mixed-adapter router, not a single heavy monolith.
- EXTRACTED: It reuses `email-assistant` for Gmail / Google Workspace rather than duplicating email logic.
- EXTRACTED: It uses a shared local outbox in `.wiki-tmp/communication-assistant/outbox/`.
- EXTRACTED: The default send policy is prefill/outbox-first, not auto-send.
- EXTRACTED: The credential policy is QR/login-state first; no password storage.

## Platform Guidance

- WhatsApp: QR-session or WhatsApp Web adapter first; keep browser focus changes explicit.
- WeChat: prefer `wechat-cli` for read/search when possible, and `wxauto` for Windows client prefill fallback.
- QQ: prefer official QQ Bot / OpenClaw style adapters; treat protocol-side clients like NapCat as advanced options.
- Feishu/Lark: reuse `lark-im` and `feishu-bridge`.
- Email: reuse `email-assistant`.

## Local Runtime

Default runtime directories:

```powershell
D:\Research\vipin's knowledgebase\.wiki-tmp\communication-assistant\config
D:\Research\vipin's knowledgebase\.wiki-tmp\communication-assistant\sessions
D:\Research\vipin's knowledgebase\.wiki-tmp\communication-assistant\outbox
D:\Research\vipin's knowledgebase\.wiki-tmp\communication-assistant\logs
```

The helper CLI supports:

- `paths`
- `create`
- `list`
- `show`
- `mark`
- `cancel`

## Usage

Use this skill for prompts such as:

```text
帮我看微信未读消息，中文讲重点。
帮我回 WhatsApp 这条，先别发。
查一下 QQ 有没有课程/签证/账单相关消息。
把刚才那条回复填到微信聊天框，不要发送。
我确认，发送 outbox 里这条。
```

## Safety Boundary

- Do not store or recover passwords.
- Do not expose raw private chats or contacts in public wiki, logs, or commits.
- Do not send without explicit approval for the exact target and text.
- If a platform blocks safe access, keep the adapter pending instead of pretending support exists.

## Verification Record

- EXTRACTED: `quick_validate.py` has not yet been run on this skill.
- EXTRACTED: `node --check scripts/outbox.js` passed.
- EXTRACTED: `pnpm install` completed in the skill directory.
- EXTRACTED: `node scripts/outbox.js paths` returned the ignored `.wiki-tmp/communication-assistant` runtime paths.
- EXTRACTED: Outbox smoke tests passed for create, show, mark to `prefilled`, cancel, and filtered list.

## Related Pages

- [[2026-05-17-communication-assistant-skill]]
- [[email-assistant-skill]]
- [[chrome-automation]]
- [[feishu-bridge]]
