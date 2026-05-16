---
title: Read the docs folder first.
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

# Read the docs folder first.

## Metadata

- Stable ID: `codex-user-prompt:df18e1ea73b73f60`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T20:59:38.469Z`
- Semantic hash: `df18e1ea73b73f604686c0e3c2954a0a347c2a1e08e3ecad14eb3f3d223ef216`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Read the docs folder first.

Task:
Implement the initial workflows:
- DocumentUnderstandingWorkflow
- GlucoseReviewWorkflow
- DoctorSummaryWorkflow
- SafetyReviewWorkflow

Scope:
- packages/ai
- packages/core
- packages/db

Rules:
- All outputs must be structured JSON.
- All outputs must be validated by Zod.
- All outputs must be persisted.
- SafetyReview must run before showing insights or summaries.
- No diagnosis, prescription, medication-change, or insulin-dosing advice.

Validation:
End-to-end mock run:
HealthDocument → DocumentUnderstanding → GlucoseReview → SafetyReview → Insight → DoctorSummary.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
