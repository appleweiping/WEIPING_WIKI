---
title: You are implementation-planner worker for TGL-Rec Phase 10. You are not alone...
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

# You are implementation-planner worker for TGL-Rec Phase 10. You are not alone...

## Metadata

- Stable ID: `codex-user-prompt:79dc7b01e932c221`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-09T00:50:52.492Z`
- Semantic hash: `79dc7b01e932c221275a7d6c559d2d3ff6c497cd0e07e22d547ebd82710ac9d7`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
You are implementation-planner worker for TGL-Rec Phase 10. You are not alone in the codebase; do not revert others' edits. Ownership: inspect docs, configs, scripts, and src/llm4rec modules only; do not edit yet. Read docs/codex_project_memory.md, docs/phase10_master_plan.md, docs/server_runbook.md, docs/week8_large_same_candidate_protocol.md, docs/reference_method_adaptation_map.md, scripts/plan_four_domain_runs.py, scripts/import_week8_same_candidate.py, scripts/run_lora_rerank_eval.py, src/llm4rec/baselines/reference_methods.py, and method-related modules. Task: propose concrete implementation/docs/server-command changes that would make the user's desired workflow executable: observation protocol on beauty full + books/electronics/movies 10k, base Qwen3-8B observation plus at least four senior baseline observation checks, then formal baseline comparison with official algorithms. Identify missing scripts/configs/tests and suggest exact files to change. Do not edit files; return a patch plan with priorities.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
