---
title: 你先连接一下这个仓库。https -//github.com/appleweiping/Medora.git
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

# 你先连接一下这个仓库。https://github.com/appleweiping/Medora.git

## Metadata

- Stable ID: `codex-user-prompt:9bfeb51892401a7f`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-14T20:16:31.880Z`
- Semantic hash: `9bfeb51892401a7f0ba53161419b45f01dc6596ca3e3866c80596e935dbc9267`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你先连接一下这个仓库。https://github.com/appleweiping/Medora.git

然后 Read the entire docs folder first.

Task:
Create the initial monorepo skeleton for this project.

Scope:
- Create package structure only.
- Create TypeScript configuration.
- Create README and package placeholders.
- Do not build UI yet.
- Do not connect any LLM yet.

Deliverables:
- apps/web
- packages/core
- packages/db
- packages/ai
- packages/shared
- root package setup
- basic README explaining how this repo maps to the docs

Validation:
- install works
- typecheck works
- repo structure matches docs/ARCHITECTURE.md
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
