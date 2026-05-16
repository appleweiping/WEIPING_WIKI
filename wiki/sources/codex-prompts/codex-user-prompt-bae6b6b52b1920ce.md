---
title: 你是 Codex/GPT-5.5 targeted audit worker D。只读审计 DoneBench 的这些任务：sheet_db_025, s...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - coding-agent-workflow
source_pages:
  - codex-prompt-corpus
---

# 你是 Codex/GPT-5.5 targeted audit worker D。只读审计 DoneBench 的这些任务：sheet_db_025, s...

## Metadata

- Stable ID: `codex-user-prompt:bae6b6b52b1920ce`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-08T23:00:02.909Z`
- Semantic hash: `bae6b6b52b1920ce5b4d7e0756166960cb8f79e8e8bf91c026307e68ec84507e`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Codex/GPT-5.5 targeted audit worker D。只读审计 DoneBench 的这些任务：sheet_db_025, sheet_db_026, sheet_db_027, sheet_db_028, sheet_db_029, sheet_db_032, sheet_db_034, sheet_db_035, sheet_db_036, sheet_db_038, sheet_db_039。对每个任务读取 data/tasks/<domain>/<task_id>.json，并按 annotation/annotation_guide.md 的五个检查输出一条 compact JSON 对象，字段必须包括 task_id, domain, difficulty, task_pattern, audit_source="model", prompt_version="codex-gpt55-targeted-v1", model="codex_gpt55_session", provider="codex_session", provider_model="gpt-5.5", risk_labels(list), check_opinions(dict of criteria_complete,donespec_matches_criteria,near_misses_are_valid,reference_trace_is_plausible,not_too_templated each with verdict pass|warn|fail confidence number rationale string), overall_risk low|medium|high, needs_adjudication boolean, adjudication_reasons(list), suggestions(list), model_metadata with parse_status="model", audit_mode="codex_session_manual_targeted", no_api_usage=true. Important: this is AI advisory audit, not human annotation. Be rigorous but not performative: use needs_adjudication=true only for high risk/fail or unresolved ambiguity requiring human decision; warn-level issues can still be needs_adjudication=false if suggestions are clear. Return JSONL only, no markdown fences.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
