---
title: Codex Automation Model Policy
type: concept
status: active
created: 2026-05-18
updated: 2026-05-18
tags:
  - automation
  - codex
  - agent-rules
source_pages:
  - AGENTS.md
---

# Codex Automation Model Policy

## Rule

Cron automations should run with:

- `model = "gpt-5.5"`
- `reasoning_effort = "high"`

EXTRACTED: The user explicitly rejected low- and medium-reasoning automation settings and asked future agents to treat high-intelligence automation as a hard rule.

INFERRED: This applies to scheduled cron automations where the automation schema exposes `model` and `reasoning_effort`. Heartbeat automations may not expose these fields; they should not be treated as noncompliant solely for lacking them.

## Operating Guidance

- When creating a new cron automation, set `model` to `gpt-5.5` and `reasoningEffort` to `high`.
- When updating an existing cron automation, preserve schedule, prompt, workspace, environment, and status unless the user asks to change them, but keep or restore `gpt-5.5/high`.
- Do not use `minimal`, `low`, or `medium` reasoning for recurring scheduled work.
- If an automation appears cheaper or lighter than usual, still prefer high reasoning unless the user explicitly gives a narrow one-off exception.

## 2026-05-18 Audit

EXTRACTED: On 2026-05-18, all local cron automations under `C:\Users\admin\.codex\automations` were audited. Seven cron automations were upgraded from `low` or `medium` reasoning to `high`, while cron automations already at `gpt-5.5/high` were left unchanged.

EXTRACTED: The final audit found zero noncompliant cron automations. One paused heartbeat automation had no model or reasoning fields and was considered not applicable to the cron-only model policy.

## Counterpoints And Gaps

- AMBIGUOUS: Heartbeat automations are controlled by the thread heartbeat mechanism and may not expose model or reasoning fields. This policy should not invent unsupported fields for heartbeats.
- INFERRED: High reasoning costs more latency and compute, but the user's stated preference is to preserve quality for recurring automation rather than optimize for cheap low- or medium-reasoning runs.

## Related

- [[durable-agent-rule-memory]]
- [[index]]
