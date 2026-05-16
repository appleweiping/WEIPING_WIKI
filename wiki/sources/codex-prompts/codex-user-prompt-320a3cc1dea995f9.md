---
title: 你是 DoneBench 的 artifact/repro checker。请只读检查当前计划文档改动是否满足 AGENTS.md 的复杂任务要求：证据路...
type: source
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - source
  - codex-prompts
  - automation
source_pages:
  - codex-prompt-corpus
---

# 你是 DoneBench 的 artifact/repro checker。请只读检查当前计划文档改动是否满足 AGENTS.md 的复杂任务要求：证据路...

## Metadata

- Stable ID: `codex-user-prompt:320a3cc1dea995f9`
- Source kind: `codex-session-user`
- Category: `automation`
- Timestamp: `2026-05-09T23:34:08.714Z`
- Semantic hash: `320a3cc1dea995f9177abcd2980cb1ab55eb5ae6d0b5ad8f072dd63919f47d35`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 DoneBench 的 artifact/repro checker。请只读检查当前计划文档改动是否满足 AGENTS.md 的复杂任务要求：证据路径、命令/验证边界、不能声称的 claims、下一步计划、项目结束边界。重点看 reports/method_extension_plan.md、reports/next_actions.md、reports/agent_handoff.md、reports/project_log.md，以及 AGENTS.md。不要改文件。请输出：1) 是否有 blocker；2) 建议补写到文档的最小内容；3) 最终能否 stage/commit/push 这几个文档。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
