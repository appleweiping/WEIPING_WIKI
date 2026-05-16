---
title: 看看我们还差哪些模块，建议直接全部补齐。
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

# 看看我们还差哪些模块，建议直接全部补齐。

## Metadata

- Stable ID: `codex-user-prompt:de2594e500941789`
- Source kind: `codex-session-user`
- Category: `research-workflow`
- Timestamp: `2026-05-07T15:04:12.975Z`
- Semantic hash: `de2594e5009417892726691895056fb51ca78fe644d1cca29dd95007af7adbaf`
- Public handling: selected full-text prompt with secret filtering.

## Prompt Text

```text
看看我们还差哪些模块，建议直接全部补齐。
我们目前差的模块

Human Audit / Human Baseline
现在任务是生成式 topconf-1，规模够，但还缺人工 audit。顶会 reviewer 会问：这些 completion specs 是否人为确认？
我们需要：抽样 50-100 tasks，人工标注 gold criteria 是否充分，报告 agreement 或 adjudication。

非 oracle execution baseline
现在 spec_first 的 task success 偏乐观，因为 execution path 仍然 reference-style。
我们需要一个真实-ish executor：根据模型 spec/action policy 调工具，而不是直接 reference final state。否则 execution 结果不能强 claim。

统计模块
已有 raw JSONL，但 paper-ready 还缺：

bootstrap CI
paired model comparison
pass^k / consistency
domain/difficulty stratification
invalid DoneSpec taxonomy
任务去模板化与多样性审计
300 tasks 数量够，但 pattern 仍较规则。
需要加：

lexical diversity / near-duplicate detector
task family leakage report
hidden-test style split
task construction datasheet
错误案例库
顶会 paper 必须有高质量 failure cases。
我们需要自动抽取：

high CC-F1 but low near-miss detection
valid DoneSpec but self-violation
bad spec / good execution
policy/confirmation failures
Reproducibility package
还缺 Docker/devcontainer 或一键环境说明、model access date、cost/latency logging、API retry/rate-limit logs。
不是为了炫，是 reviewer 会看 artifact 是否可复现。

原创性边界再强化
我们的原创不是“又一个 agent benchmark”。要反复强调：
DoneBench 测的是 agent 能否在执行前构造 completion semantics，并用 near-miss verifier 和 self-violation 检查它是否真的知道 done 是什么。
除了以上的点补齐之外你还要想想还缺什么模块什么内容，怎么补，你可以自己找一些idea，但别缝合或者抄别人的。
能做到真的顶会级别项目，多找几篇顶会文章项目对比一下，别做toy，要有创新，别在trivial的点上纠结。后面我们再做实验，先补模块。结束后要明确的告诉我做了什么，贡献，内容，结论等。多agent工作
github分commit，然后最后push提交 https://github.com/appleweiping/donebench.git
```

## Reuse Notes

- EXTRACTED: This is a selected Codex prompt or automation prompt from the local Codex corpus.
- INFERRED: Future agents can reuse its structure, constraints, and acceptance criteria when creating similar Codex workflows.

## Related

- [[codex-prompt-corpus]]
- [[codex-prompt-taxonomy]]
