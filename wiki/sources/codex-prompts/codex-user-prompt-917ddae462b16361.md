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

- Stable ID: `codex-user-prompt:917ddae462b16361`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T21:28:59.351Z`
- Semantic hash: `917ddae462b16361cf96428ea0c8fc709a9aea03f52a7c5af84ef67976db1028`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
Read the docs folder first.

Task:
Implement OpenAIProvider behind the existing LLMProvider interface.

Rules:
- No direct OpenAI calls from UI.
- No direct OpenAI calls from API routes.
- All calls go through WorkflowRunner and LLMProvider.
- Use structured output matching existing Zod schemas.
- Persist provider, model, prompt version, input hash, output, safety status, and errors in AgentRun.
- Keep MockLLMProvider available for local development.

Validation:
Existing mock workflow tests still pass.
A real provider can be enabled through env vars without changing workflow code.
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
