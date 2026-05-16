---
title: 多agent协作先做好这些，除非确实做不了，把 paper submission-ready 化
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

# 多agent协作先做好这些，除非确实做不了，把 paper submission-ready 化

## Metadata

- Stable ID: `codex-user-prompt:14c4c364bc502e0a`
- Source kind: `codex-session-user`
- Category: `coding-agent-workflow`
- Timestamp: `2026-05-09T08:14:26.194Z`
- Semantic hash: `14c4c364bc502e0a8455ea3b07a2e6d7030c25338ea7d7bfa47cf18ab57d430c`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
多agent协作先做好这些，除非确实做不了，把 paper submission-ready 化 
 
补 reports/model_access_cost_latency_retry.md 和正文里的 provider/model identifier、access date、decoding 参数、retry policy、trial count、cost/latency。
编译 LaTeX，检查表格是否爆页、caption 是否准确、所有结果是否都能追到 artifact。
这是最接近“能投”的下一步。
处理 GitHub 大文件风险

这次 trials.jsonl 是 50.08 MB，已经 push 成功，但 GitHub 提醒接近推荐上限。
下一步最好加一个 artifact 策略：raw trials 是否转 Git LFS、压缩存档、还是只保留 manifest + tables。否则后面再跑 cross-family 很容易把 repo 撑大。
跑真正的 cross-family slice

目前只配置好了，没 credentials，所以不能写结果。
一旦有 GPT/Claude/Gemini key，跑：
cross_family_slice
cross_family_token_matched_slice
这会回答 reviewer 最可能问的：“这是不是 DeepSeek family 特有现象？”
再做一轮顶会审稿式 paper audit

不是再审数据，而是审 claim：哪些句子太强、哪些 ablation 还不够、哪些 artifact 缺 citation/path。
目标是防止论文看起来像“做了很多工程但贡献边界不清”。

关于第三点，目前因为这三个国外的apikey比较贵，我们考虑qwen glm kimi 的key，你要做好修改
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
