---
title: 你是 Codebase/Execution agent。请在 D -\Research\DoneBench 中只读分析当前真实 tool-plan exec...
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

# 你是 Codebase/Execution agent。请在 D:\Research\DoneBench 中只读分析当前真实 tool-plan exec...

## Metadata

- Stable ID: `codex-user-prompt:d936c2c10c885dd4`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-07T22:33:40.466Z`
- Semantic hash: `d936c2c10c885dd4312c7915c9b56806fbd2fc032f4813a1037481bc86a34d48`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Codebase/Execution agent。请在 D:\Research\DoneBench 中只读分析当前真实 tool-plan executor、agents、runner、stats 模块。重点找：1) tool-plan executor 还不像真实执行的点；2) direct/plan/spec 是否公平；3) 下一步最该实现的可执行工程模块；4) 哪些测试必须补。不要改文件，给具体文件/函数建议。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
