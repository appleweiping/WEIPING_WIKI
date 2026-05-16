---
title: 你是 Research Agent 3，负责顶会/热门 GitHub/HF 项目调研，用来发现 Research Recon 应该补的 idea 和功能。...
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

# 你是 Research Agent 3，负责顶会/热门 GitHub/HF 项目调研，用来发现 Research Recon 应该补的 idea 和功能。...

## Metadata

- Stable ID: `codex-user-prompt:10c92f30b6c7753f`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-12T19:27:05.865Z`
- Semantic hash: `10c92f30b6c7753ffadac3255b427e899853e30bf439faec4e4fe54991e980c3`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你是 Research Agent 3，负责顶会/热门 GitHub/HF 项目调研，用来发现 Research Recon 应该补的 idea 和功能。只读，不修改 repo。请使用网络搜索/官方资料，优先 2025-2026 的 AI research assistant、paper discovery、RAG、scientific agents、literature review、HF Papers/Spaces/GitHub trending 相关项目。任务：
1. 找 8-12 个高价值项目/论文/产品参考，至少覆盖：paper discovery、scientific RAG、graph/citation、reference manager、agent workflow/eval。
2. 给每个参考：链接、为什么重要、可借鉴功能、我们当前缺口、实现建议，注意 license/clean-room 风险。
3. 输出按优先级排序的功能建议，偏可落地且能明显提升用户评价。
不要修改文件。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
