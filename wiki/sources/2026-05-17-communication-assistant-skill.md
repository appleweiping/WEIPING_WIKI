---
title: 2026-05-17 Communication Assistant Skill
type: source
status: active
created: 2026-05-17
updated: 2026-05-17
tags:
  - source
  - agent-skills
  - communication
  - whatsapp
  - wechat
  - qq
source_files:
  - "D:/Research/vipin's knowledgebase/skill/communication-assistant/SKILL.md"
  - "D:/Research/vipin's knowledgebase/.codex/skills/communication-assistant/SKILL.md"
source_pages:
  - https://github.com/op7418/Claude-to-IM-skill
  - https://github.com/fastclaw-ai/weclaw
  - https://github.com/huohuoer/wechat-cli
  - https://github.com/cluic/wxauto
  - https://github.com/NapNeko/NapCatQQ
  - https://github.com/tencent-connect/openclaw-qqbot
  - https://github.com/steipete/warelay
---

# 2026-05-17 Communication Assistant Skill

## Provenance

- Source: user request for a single lazy-mode communication skill covering WhatsApp, WeChat, QQ, and reuse of the email skill.
- GitHub scan identified multiple adapter-shaped projects rather than one perfect all-in-one skill.
- Chosen architecture: unified router skill with platform adapters and a shared outbox.

## External References

- EXTRACTED: `op7418/Claude-to-IM-skill` is a bridge skill for Telegram, Discord, Feishu/Lark, QQ, and WeChat.
- EXTRACTED: `fastclaw-ai/weclaw` is a WeChat AI bridge that uses QR login and supports message push.
- EXTRACTED: `huohuoer/wechat-cli` is a local WeChat data CLI for sessions/history/search/contacts.
- EXTRACTED: `cluic/wxauto` is a Windows WeChat UI automation library.
- EXTRACTED: `NapNeko/NapCatQQ` is a protocol-side QQ framework.
- EXTRACTED: `tencent-connect/openclaw-qqbot` is a QQ bot plugin for OpenClaw.
- EXTRACTED: `steipete/warelay` is a large personal AI assistant and gateway with WhatsApp support.

## Local Design

- EXTRACTED: Installed `communication-assistant` under `.codex/skills/communication-assistant/` and mirrored it under `skill/communication-assistant/`.
- EXTRACTED: Added a shared outbox CLI that creates, shows, marks, cancels, and lists local draft-like chat replies.
- EXTRACTED: Added references for adapter selection, outbox semantics, and safety rules.
- EXTRACTED: Reused `email-assistant` rather than recreating email logic.
- EXTRACTED: Default send posture is outbox/prefill-first; direct sends are explicit user decisions handled by platform adapters.
- EXTRACTED: Password discovery/storage is explicitly disallowed.

## Validation

- EXTRACTED: `pnpm install` completed in the skill directory using the local Node runtime.
- EXTRACTED: `node --check scripts/outbox.js` passed.
- EXTRACTED: `node scripts/outbox.js paths` returned ignored runtime directories under `.wiki-tmp/communication-assistant/`.
- EXTRACTED: Outbox smoke tests passed for create, show, mark to `prefilled`, cancel, and filtered list.
- AMBIGUOUS: Live platform adapters for WeChat / WhatsApp / QQ were not implemented in this first pass because the safest platform-specific path depends on the user's installed clients and preferred login mode.

## Limits

- This first version is a routing skill plus outbox, not a full gateway daemon.
- Live send paths remain platform-specific and should be added only after the best adapter for each platform is chosen and validated.

## Related

- [[communication-assistant-skill]]
- [[email-assistant-skill]]
- [[agent-skill-installation-workflow]]
