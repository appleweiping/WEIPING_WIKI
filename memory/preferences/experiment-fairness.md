---
title: "实验公平性规则 — 指标和数据必须对齐"
type: preference
created: 2026-05-22T01:30:00+08:00
updated: 2026-05-22T01:30:00+08:00
agent: claude
tags: [fairness, experiment, baseline, permanent, all-agents, critical]
related: [research-hard-rules.md, pony-no-deviation.md]
---

## 规则

和外部 baseline 对比时，**指标和数据必须完全对齐**，否则不公平。

具体：
- **指标对齐：** baseline 报了哪些指标（HR@5/10/20, NDCG@5/10/20, MRR, coverage），我们也必须全部报，不能只挑对自己有利的
- **数据对齐：** 同样的 test set、同样的 candidate pool、同样的 user 数量、同样的 split
- **候选集对齐：** 101 candidates same-candidate protocol，不能用不同的候选集
- **用户数对齐：** baseline 用 10000 users，我们也用 10000 users，不能用 500 或 200 然后声称公平
- **不能事后挑选：** 不能跑完发现某个 k 不好就不报

## Why

科研诚信的底线。Reviewer 会检查这些。如果发现不对齐，直接 reject。

## How to apply

写实验脚本时，先看 baseline 的 `ranking_metrics.csv` 报了哪些列，确保我们的输出完全覆盖。跑之前检查 user count 和 candidate count 是否匹配。
