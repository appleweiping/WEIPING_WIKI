---
title: 做完这些，派六个agent，其中两个充当真实用户reviewer（不单单只是看一下界面那么简单，要实际使用（所有环节），多环境模拟，多api调用模拟，co...
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

# 做完这些，派六个agent，其中两个充当真实用户reviewer（不单单只是看一下界面那么简单，要实际使用（所有环节），多环境模拟，多api调用模拟，co...

## Metadata

- Stable ID: `codex-user-prompt:7c848f951a38aca7`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-12T19:25:00.939Z`
- Semantic hash: `7c848f951a38aca7ffc0300fbaa7c5cdd89d5cad253af8133d9929a4df674995`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
做完这些，派六个agent，其中两个充当真实用户reviewer（不单单只是看一下界面那么简单，要实际使用（所有环节），多环境模拟，多api调用模拟，codex模拟）找出项目的核心问题，缺漏的功能（跟其他项目相比），以及挑刺，其中两个去搜寻顶会或者热门的hf github相关的项目，用于寻找idea和功能，能够让我们目前的项目和产品功能更多，综合更多。然后接着让一个agent来实作，把这些问题解决（顶级项目级别实现，非toy），一个agent来做测试和检验，确保实作没有问题。 结束时，我希望用户能对我们的项目评价很高，使用起来很好，不管是通过什么方式什么环境使用该项目
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
