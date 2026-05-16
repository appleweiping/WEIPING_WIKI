---
title: 你先做：接下来要做的是：
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

# 你先做：接下来要做的是：

## Metadata

- Stable ID: `codex-user-prompt:7c237abb8652745e`
- Source kind: `codex-session-user`
- Category: `automation`
- Timestamp: `2026-05-07T21:31:36.670Z`
- Semantic hash: `7c237abb8652745e60fadb9f0d5ba3807e40d7ddaa9ffd274e8a836b4aa79ccc`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
你先做：接下来要做的是：

逐个确认官方 repo / 官方算法细节

LLM2Rec
LLM-ESR
LLMEmb
RLMRec
IRLLRec
SETRec
每个 baseline 写一个 official adapter

输入：我们的 train/valid/test、same candidates、item text、history
输出：source_event_id,user_id,item_id,score
评估仍然走我们的统一 importer
统一 Qwen3-8B LoRA backbone

如果原方法用 LLM embedding，就替换成同一个 Qwen3-8B LoRA item/text encoder
如果原方法用 LLM 生成/推理，也统一走 Qwen3-8B LoRA
recommender 模块本身保留原算法结构
每个 baseline 写 provenance

official repo commit
哪些模块原样保留
哪些地方为了 same-candidate protocol 改了
backbone replacement 说明
不混用原论文 full-catalog 指标
这样做完才可以说：

官方算法级 baseline + 公平统一协议
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
