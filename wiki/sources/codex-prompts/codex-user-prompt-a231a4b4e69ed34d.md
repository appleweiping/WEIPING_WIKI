---
title: Implementation planner for TGL-Rec method upgrade. You are not alone in the c...
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

# Implementation planner for TGL-Rec method upgrade. You are not alone in the c...

## Metadata

- Stable ID: `codex-user-prompt:a231a4b4e69ed34d`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-09T10:58:55.572Z`
- Semantic hash: `a231a4b4e69ed34ddde997c501950645be4220babe489647c3fff450e5d012ea`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Implementation planner for TGL-Rec method upgrade. You are not alone in the codebase; do not revert others' edits. Ownership: inspect method/evidence/ranker/config/tests only; do not edit. Read docs/codex_project_memory.md, docs/method_card_time_graph_evidence.md, configs/methods/time_graph_evidence.yaml, src/llm4rec/evidence/*, src/llm4rec/methods/time_graph_evidence.py, src/llm4rec/rankers/time_graph_evidence_ranker.py, tests related to evidence/method. Task: propose concrete low-risk code/config/doc changes to make our method deeper and more original without pretending results exist. Include new abstractions if needed, planned tests, and server-readiness implications. Return a patch plan.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
