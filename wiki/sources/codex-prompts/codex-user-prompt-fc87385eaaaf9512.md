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

- Stable ID: `codex-user-prompt:fc87385eaaaf9512`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-08T23:20:01.643Z`
- Semantic hash: `fc87385eaaaf951286ef927646b076aaa2a6a9dd845f0976e07d4238729f4036`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
You are auditing DoneBench task quality for one domain. Workspace: D:\Research\DoneBench. You are not alone in the codebase: other workers are auditing other domains and writing disjoint files, so do not revert or modify their work.

Current project context: DoneBench is a Specification Grounding benchmark. A full DeepSeek tool-plan execution run already completed; current blockers are audit/task-quality blockers, not execution reruns. Prior GPT-5.5 targeted model audit found high-risk tasks, but this GPT-5.2 pass should independently review all tasks in your domain. This is model-assisted audit, not human annotation.

Your ownership: sheet_db domain only. Read annotation/human_audit_queue.jsonl, annotation/annotation_guide.md, reports/audit_gpt52_full_domain/README.md, prior relevant audit evidence in reports/audit_deepseek_gpt55_merged/, and data/tasks/sheet_db/sheet_db_021.json through sheet_db_040.json.

Write exactly one output file: reports/audit_gpt52_full_domain/sheet_db_ai_audit_opinions.jsonl. It must contain 20 JSONL records, one per sheet_db_021..sheet_db_040 task, using the schema in the README. Use prompt_version "gpt52-full-domain-v1", model "gpt_5_2_model_audit", provider "model_assisted_audit", provider_model "gpt-5.2". Do not edit annotation/human_audit_queue.jsonl or any human annotation fields.

Audit checks: criteria_complete, donespec_matches_criteria, near_misses_are_valid, reference_trace_is_plausible, not_too_templated. Verdicts pass/warn/fail with concise rationales and confidence. overall_risk low/medium/high. Set needs_adjudication true for high risk or material unresolved semantic gaps. Be rigorous; do not try to make the gate pass. If the prior targeted audit marked a task high risk, independently verify whether that risk is real from the task JSON.

When done, final-answer with the path written, count of records, high-risk task_ids, adjudication task_ids, and any notable domain pattern.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
