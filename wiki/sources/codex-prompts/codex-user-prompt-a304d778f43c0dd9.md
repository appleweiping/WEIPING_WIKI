---
title: 请作为顶会审稿人/实验设置审计员，快速检查当前仓库关于 external baseline fairness 的改动方向是否还有明显口径风险。重点看 RE...
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

# 请作为顶会审稿人/实验设置审计员，快速检查当前仓库关于 external baseline fairness 的改动方向是否还有明显口径风险。重点看 RE...

## Metadata

- Stable ID: `codex-user-prompt:a304d778f43c0dd9`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-08T09:16:35.422Z`
- Semantic hash: `a304d778f43c0dd9b2530f686ccf1f9d2e6b5c39f2da1c904d013041a7b7de42`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
请作为顶会审稿人/实验设置审计员，快速检查当前仓库关于 external baseline fairness 的改动方向是否还有明显口径风险。重点看 README、docs/baseline_protocol.md、OFFICIAL_EXTERNAL_BASELINE_UPGRADE_PLAN_2026-05-07.md、configs/official_external_baselines.yaml。不要改文件，输出最需要补的 5-8 个点，尤其是 Qwen3 base vs LoRA/full-finetune、baseline 默认超参、same-candidate score schema、Beauty supplementary、style vs official rows。
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
