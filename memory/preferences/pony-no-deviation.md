---
title: "Pony 项目主线警告 — 不要偏离"
type: preference
created: 2026-05-21T23:30:00+08:00
updated: 2026-05-21T23:30:00+08:00
agent: claude
tags: [pony, warning, permanent, all-agents, critical]
related: [pony-current-status.md, research-hard-rules.md]
---

## 警告：Pony 项目不要偏离主线

**C-CRP 是我们自己的方法，是 paper 的主角。** 所有分析、实验、evaluation 都是为了证明 C-CRP 的价值。

**不允许的偏离：**
- 不要做纯 analysis paper（只分析别人的方法）
- 不要做 ensemble/selection（用别人的方法组合）
- 不要把 calibration depth 分析变成主要贡献（它是辅助贡献）
- 不要 toy 化（不要只做 evaluation 不做 method）

**正确的主线：**
- C-CRP 是方法贡献（conformal prediction for LLM recommendation）
- Calibration depth 是评估贡献（新指标，证明 C-CRP 优势）
- 和 8 个 baseline 正面比较（NDCG + calibration depth 双指标）
- C-CRP v2 改进缩小 NDCG gap

**如果 NDCG 打不过 baseline：**
- 不要放弃 — 换 framing："C-CRP trades slight NDCG for much deeper calibration + formal guarantees"
- 或者改进 C-CRP v2（calibration-aware reranking）来提升 NDCG
- 但绝不能放弃自己的方法去做别人方法的分析
