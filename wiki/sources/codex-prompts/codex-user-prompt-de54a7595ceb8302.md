---
title: 最关键不是继续跑 API，而是去模板化任务生成，让 300 tasks 的内容多样性也真正对齐顶会。当前模块骨架已经像了，内容审计也诚实暴露了风险。现在还...
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

# 最关键不是继续跑 API，而是去模板化任务生成，让 300 tasks 的内容多样性也真正对齐顶会。当前模块骨架已经像了，内容审计也诚实暴露了风险。现在还...

## Metadata

- Stable ID: `codex-user-prompt:de54a7595ceb8302`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-07T14:41:14.978Z`
- Semantic hash: `de54a7595ceb83029d1e8683f63d93f9e05b540b045a29edfda8623d1f51c20e`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
最关键不是继续跑 API，而是去模板化任务生成，让 300 tasks 的内容多样性也真正对齐顶会。当前模块骨架已经像了，内容审计也诚实暴露了风险。现在还剩的最大短板不在“模块”，而在“内容质量”：quality_audit 已经发现 near-duplicate 很多。下一步应该做去模板化任务生成/任务扩写，加一个 ai-audit 模块：用 DeepSeek/GPT 对 annotation/human_audit_queue.jsonl 先出审计意见，然后你只看 disagree/high-risk 的部分。
这些事之前你提的建议，全部做好。

然后再充当一次reviewer多看些相关的顶会论文，发现我们的不足和需要的创新点，以免做的单薄和toy或者缝合没有创新点。

建议之后一直多agent协同办公，一次prompt能够尽量多的产出和贡献项目
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
