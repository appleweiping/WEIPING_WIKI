---
title: Codex Automation Model Policy
type: concept
status: active
created: 2026-05-18
updated: 2026-06-04
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
- `reasoning_effort = "xhigh"` when supported; otherwise use the strongest accepted reasoning level and record the fallback

EXTRACTED: The user explicitly rejected low- and medium-reasoning automation settings and asked future agents to treat high-intelligence automation as a hard rule. On 2026-06-04, this rule was tightened for Codex cron automations to prefer `xhigh` reasoning where the automation schema supports it.

INFERRED: This applies to scheduled cron automations where the automation schema exposes `model` and `reasoning_effort`. Heartbeat automations may not expose these fields; they should not be treated as noncompliant solely for lacking them.

## Operating Guidance

- When creating a new cron automation, set `model` to `gpt-5.5` and `reasoningEffort` / `reasoning_effort` to `xhigh` when supported.
- When updating an existing cron automation, preserve schedule, prompt, workspace, environment, and status unless the user asks to change them, but keep or restore `gpt-5.5/xhigh` where supported.
- Do not use `minimal`, `low`, or `medium` reasoning for recurring scheduled work.
- If a runtime rejects `xhigh`, keep `gpt-5.5`, use the strongest accepted reasoning level, and record the downgrade in the relevant automation note or wiki log.
- If an automation appears cheaper or lighter than usual, still prefer xhigh/high reasoning unless the user explicitly gives a narrow one-off exception.

## 2026-05-18 Audit

EXTRACTED: On 2026-05-18, all local cron automations under `C:\Users\admin\.codex\automations` were audited. Seven cron automations were upgraded from `low` or `medium` reasoning to `high`, while cron automations already at `gpt-5.5/high` were left unchanged.

EXTRACTED: The final audit found zero noncompliant cron automations. One paused heartbeat automation had no model or reasoning fields and was considered not applicable to the cron-only model policy.

## 2026-06-04 WEIPING_WIKI Update

EXTRACTED: The active `maintain-vipinknowledge` cron automation under the D-drive Codex home was updated to keep the historical ID while using the current `WEIPING_WIKI` identity in the name/prompt and `reasoning_effort = "xhigh"`.

INFERRED: Older audit entries that say `high` describe the state at that time. They do not override the current preference for `xhigh` where supported.

## Counterpoints And Gaps

- AMBIGUOUS: Heartbeat automations are controlled by the thread heartbeat mechanism and may not expose model or reasoning fields. This policy should not invent unsupported fields for heartbeats.
- INFERRED: High reasoning costs more latency and compute, but the user's stated preference is to preserve quality for recurring automation rather than optimize for cheap low- or medium-reasoning runs.

## Related

- [[durable-agent-rule-memory]]
- [[index]]
