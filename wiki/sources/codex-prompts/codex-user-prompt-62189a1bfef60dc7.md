---
title: You are auditing DoneBench task quality for one domain. Workspace - D -\Researc...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - research-workflow
source_pages:
  - codex-prompt-corpus
---

# You are auditing DoneBench task quality for one domain. Workspace: D:\Researc...

## Metadata

- Stable ID: `codex-user-prompt:62189a1bfef60dc7`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-08T23:22:51.081Z`
- Semantic hash: `62189a1bfef60dc7078ff1ce9d8a4d94e85d09875ecbe991e09d75e97327b352`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
You are auditing DoneBench task quality for one domain. Workspace: D:\Research\DoneBench. You are not alone in the codebase: other workers are auditing other domains and writing disjoint files, so do not revert or modify their work.

Context: A GPT-5.2 full-domain audit was attempted but the model route returned 503; this run uses the current available strong model path and must NOT be described as GPT-5.2. This is model-assisted audit, not human annotation.

Your ownership: calendar domain only. Read annotation/human_audit_queue.jsonl, annotation/annotation_guide.md, reports/audit_full_domain_model_assisted/README.md, prior relevant audit evidence in reports/audit_deepseek_gpt55_merged/, and data/tasks/calendar/calendar_021.json through calendar_040.json.

Write exactly one output file: reports/audit_full_domain_model_assisted/calendar_ai_audit_opinions.jsonl. It must contain 20 JSONL records, one per calendar_021..calendar_040 task, using the schema in the README. Use prompt_version "full-domain-model-assisted-v1", model "model_assisted_full_domain_audit", provider "model_assisted_audit", provider_model "current-available-strong-model". Do not edit annotation/human_audit_queue.jsonl or human fields.

Audit checks: criteria_complete, donespec_matches_criteria, near_misses_are_valid, reference_trace_is_plausible, not_too_templated. Verdicts pass/warn/fail with concise rationales and confidence. overall_risk low/medium/high. Set needs_adjudication true for high risk or material unresolved semantic gaps. Be rigorous; do not try to make the gate pass. Independently verify prior high-risk claims from task JSON.

When done, final-answer with the path written, count of records, high-risk task_ids, adjudication task_ids, and notable domain pattern.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
