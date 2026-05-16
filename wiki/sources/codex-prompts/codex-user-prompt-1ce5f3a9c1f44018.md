---
title: Read the docs folder first, especially -
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

# Read the docs folder first, especially:

## Metadata

- Stable ID: `codex-user-prompt:1ce5f3a9c1f44018`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T23:44:36.499Z`
- Semantic hash: `1ce5f3a9c1f4401831e6eca998dab77af666bb0e46b73fdae4e754f2c61e8a16`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Read the docs folder first, especially:
- docs/PROJECT_BRIEF.md
- docs/ARCHITECTURE.md
- docs/MVP_SCOPE.md
- docs/DATA_MODEL.md
- docs/MEDICAL_SAFETY.md
- docs/STATE_MACHINES.md
- docs/AGENTS.md

Follow the product direction and constraints in the docs.

Important:
- Do not build a toy chat app.
- Do not build a traditional glucose dashboard.
- Do not let UI call the LLM directly.
- Do not generate diagnosis, prescription, medication-change, or insulin-dosing advice.
- All AI outputs must be structured, persisted, source-grounded, and safety-reviewed.
- The health record and timeline are the center of the product.

Task:
[这里写这次要做什么]

Scope:
[这里写只允许改哪些模块/文件]

Deliverables:
[这里写最后要交付什么]

Validation:
[这里写怎么验证完成]


你把这段话做成md文件，放到根目录下 取名为PROMPT_TEMPLATE
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
