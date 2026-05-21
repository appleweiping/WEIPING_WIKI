---
title: "编码偏好 — Opus 优于 Codex"
type: preference
created: 2026-05-18T00:00:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: claude
tags: [coding, model-preference, opus]
related: [research-hard-rules.md]
---

User finds Claude Opus significantly stronger than Codex/GPT-5.5 at coding tasks.

**Rule:** Prefer Opus (Claude Code or OpenCode) for implementation work. Use Codex for review/audit roles, not primary coding.

**Why:** Based on direct comparison experience — Opus produces higher quality code with fewer iterations.

**How to apply:** When assigning coding tasks in multi-agent workflows, route implementation to Opus-based agents. Codex handles cross-model review, experiment-audit, and coordination.
