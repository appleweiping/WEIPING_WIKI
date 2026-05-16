---
title: You are the Implementation agent. Inspect current CCRP/Shadow and SRPD code/c...
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

# You are the Implementation agent. Inspect current CCRP/Shadow and SRPD code/c...

## Metadata

- Stable ID: `codex-user-prompt:30402d1703b51f98`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-08T19:14:05.008Z`
- Semantic hash: `30402d1703b51f98aec7139f90f0613442ff373f0e9c6e4c744ce779a83527fa`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
You are the Implementation agent. Inspect current CCRP/Shadow and SRPD code/configs/scripts. Find what exists, what is missing for a formal four-domain experiment track, and what code changes are needed so the user can run observation -> formal baseline-compatible CCRP/SRPD variants on server. Pay special attention to: confidence collapse mitigation for SRPD/confidence track, evidence-only CCRP, confidence+evidence combined variant, validation-only selection, same-candidate score schema/importer, provenance/status labels, and server command surface. Do not edit files. Return concrete file-level recommendations and likely patch points.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
