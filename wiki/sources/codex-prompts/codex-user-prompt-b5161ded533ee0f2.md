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

- Stable ID: `codex-user-prompt:b5161ded533ee0f2`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T20:50:42.354Z`
- Semantic hash: `b5161ded533ee0f2b68df8969e54efe2ae22827b34090f781903e010f54e938c`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Read the docs folder first.

Task:
Implement the AI workflow layer.

Scope:
- packages/ai
- LLMProvider interface
- MockLLMProvider
- WorkflowRunner
- AgentRunService
- SourceReference service
- Zod schemas
- SafetyGuard interface

Non-goals:
- Do not connect real OpenAI yet.
- Do not build chat UI.
- Do not put model calls inside UI or API routes.

Validation:
A mock workflow run creates AgentRun, validates structured output, creates SourceReference, and stores safety status.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
