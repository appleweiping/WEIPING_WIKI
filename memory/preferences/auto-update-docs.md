---
title: "自动更新文档规则"
type: preference
created: 2026-05-18T00:00:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: claude
tags: [documentation, auto-update, permanent]
related: []
---

Always update ALL documentation files when changing infrastructure. User never wants to have to remind agents about this.

**Rule:** When modifying infrastructure (configs, scripts, directory structure, agent setup), automatically update all related documentation (AGENTS.md, CLAUDE.md, README.md, OPENCODE.md, etc.) in the same commit.

**Why:** User has been burned by stale docs multiple times. Documentation drift causes confusion across the multi-agent team.

**How to apply:** After any infrastructure change, scan for all docs that reference the changed component and update them. Do not ask — just do it.
