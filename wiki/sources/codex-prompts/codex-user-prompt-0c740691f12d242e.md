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

- Stable ID: `codex-user-prompt:0c740691f12d242e`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T20:29:21.337Z`
- Semantic hash: `0c740691f12d242ed7791a62213200b8cc807495fb3f4b67da2c3dfad00f9f15`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Read the docs folder first.

Task:
Implement the core domain model and Prisma schema based on docs/DATA_MODEL.md and docs/STATE_MACHINES.md.

Scope:
- packages/core
- packages/db
- Prisma schema
- seed data

Deliverables:
- TypeScript domain types
- Prisma models
- state union types
- state transition helpers
- seed scenario for one glucose-management patient

Validation:
- migrations run
- typecheck passes
- seed creates PatientProfile, HealthDocument, TimelineEvent, Insight, AgentRun, SafetyReview, and SourceReference
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
