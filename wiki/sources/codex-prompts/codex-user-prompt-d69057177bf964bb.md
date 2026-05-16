---
title: 请作为 reviewer agent 对 D -\Research\Agent-AI4EDA\analog-agent 当前未提交 diff 做只读代码审查...
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

# 请作为 reviewer agent 对 D:\Research\Agent-AI4EDA\analog-agent 当前未提交 diff 做只读代码审查...

## Metadata

- Stable ID: `codex-user-prompt:d69057177bf964bb`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-11T17:44:34.936Z`
- Semantic hash: `d69057177bf964bbfcb652ce2b1150ca87f11bef1e5b9650f38a27c9dfb4a16a`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
请作为 reviewer agent 对 D:\Research\Agent-AI4EDA\analog-agent 当前未提交 diff 做只读代码审查。重点检查：1) harness/归档规则是否有会破坏现有脚本或 CI 的地方；2) LLM provider adapter 是否有明显安全/配置/测试缺口；3) 新增 latent_state/world model diagnostics 是否重复或引入接口风险；4) baseline strength tier 叙述是否避免夸大。请按严重程度列 findings，附文件/行号，不要修改文件。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
