---
title: "PonyRec 方案决策: v3 主表 + v4 验证 + 放弃 temperature"
type: decision
created: 2026-05-24T15:20:00+08:00
agent: claude
tags: [pony, decision, method, c-crp]
related: [pony-ccrp-four-domain-status.md]
---

## 决策 1: 主表用 C-CRP v3, 不用 formal C-CRP

**选了什么:** v3 (pointwise relevance probability scoring, 按概率降序排列)
**没选什么:** formal C-CRP (uncertainty decomposition + risk-adjusted ranking)
**为什么:** formal 在 beauty 上 NDCG@10=0.131, v3=0.136。uncertainty penalty 过于保守, 把排对的 item 往下压了。

## 决策 2: 放弃 temperature scaling / threshold smoothing

**选了什么:** 不做 post-hoc calibration
**没选什么:** domain-adaptive temperature (score^(1/T)) 或 confidence threshold + smoothing
**为什么:** 分析 rank 分布发现 movies 问题是 discriminative power 不足 (positive item median rank=35/101), 不是 score distribution shape 问题。Post-hoc 只能重新分配已有差距, 不能创造新的区分力。

## 决策 3: 尝试 v4 enhanced prompt (改 scoring 本身)

**选了什么:** 提取 category 信息 + 更长 description + 更多 history
**为什么:** Movies titles 平均只有 15 chars (vs books 49 chars), 信息量不足。candidate_texts 里有完整的 "Categories: Drama > ..." 信息, 当前 prompt 没有显式利用。
**验证策略:** 先只跑 movies, 有效 (NDCG@10 > 0.15) 再四域全跑。
**风险:** 如果 v4 对 movies 有效但对 books/electronics 变差, 需要决定用 v3 还是 v4。不能混用。

## 关键约束

- 主表所有域必须用同一个方法/prompt (不能 per-domain 选不同方法)
- 所有指标必须对齐: HR@5, NDCG@5, HR@10, NDCG@10, HR@20, NDCG@20, MRR
- 不允许 toy 化: 全量 users (973/10000), 全量 candidates (101)
