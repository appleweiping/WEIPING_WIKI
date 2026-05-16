---
title: 同时本地/代码侧可以继续补 SRPD formal 配置模板，但模板必须 fail-fast：缺 train/valid teacher 就不跑，不允许偷...
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

# 同时本地/代码侧可以继续补 SRPD formal 配置模板，但模板必须 fail-fast：缺 train/valid teacher 就不跑，不允许偷...

## Metadata

- Stable ID: `codex-user-prompt:4636540f704376cd`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-08T19:56:00.745Z`
- Semantic hash: `4636540f704376cd013edf707bd173a31a0294d07191e97e5b629e78d7bdeb9b`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
同时本地/代码侧可以继续补 SRPD formal 配置模板，但模板必须 fail-fast：缺 train/valid teacher 就不跑，不允许偷用 test teacher。把 SRPD formal 配置做成“干净但不自欺”的版本：train/valid teacher required、test forbidden、use_sample_weights: true、leakage_audit 必过、输出默认 same_schema_internal_ablation。这样等外部 baseline 跑完或 GPU 空出来，就能直接上服务器跑，而不是之后再返工。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
