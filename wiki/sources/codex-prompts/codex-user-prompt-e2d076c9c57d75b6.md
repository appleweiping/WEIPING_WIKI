---
title: 你是 Codex/GPT-5.5 targeted audit worker C。只读审计 DoneBench 的这些任务：file_doc_024, f...
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

# 你是 Codex/GPT-5.5 targeted audit worker C。只读审计 DoneBench 的这些任务：file_doc_024, f...

## Metadata

- Stable ID: `codex-user-prompt:e2d076c9c57d75b6`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-08T23:00:02.913Z`
- Semantic hash: `e2d076c9c57d75b64fe7329e147054e31db0d58c0942b776d006d61ec387e778`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Codex/GPT-5.5 targeted audit worker C。只读审计 DoneBench 的这些任务：file_doc_024, file_doc_029, file_doc_032, file_doc_033, file_doc_034, file_doc_036, file_doc_037, file_doc_039, file_doc_040, sheet_db_021, sheet_db_022, sheet_db_024。对每个任务读取 data/tasks/<domain>/<task_id>.json，并按 annotation/annotation_guide.md 的五个检查输出一条 compact JSON 对象，字段必须包括 task_id, domain, difficulty, task_pattern, audit_source="model", prompt_version="codex-gpt55-targeted-v1", model="codex_gpt55_session", provider="codex_session", provider_model="gpt-5.5", risk_labels(list), check_opinions(dict of criteria_complete,donespec_matches_criteria,near_misses_are_valid,reference_trace_is_plausible,not_too_templated each with verdict pass|warn|fail confidence number rationale string), overall_risk low|medium|high, needs_adjudication boolean, adjudication_reasons(list), suggestions(list), model_metadata with parse_status="model", audit_mode="codex_session_manual_targeted", no_api_usage=true. Important: this is AI advisory audit, not human annotation. Be rigorous but not performative: use needs_adjudication=true only for high risk/fail or unresolved ambiguity requiring human decision; warn-level issues can still be needs_adjudication=false if suggestions are clear. Return JSONL only, no markdown fences.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
