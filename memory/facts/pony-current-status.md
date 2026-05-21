---
title: "Pony C-CRP → RSC 项目当前状态"
type: fact
created: 2026-05-21T03:30:00+08:00
updated: 2026-05-21T21:30:00+08:00
agent: claude
tags: [pony, RSC, ranking-stability, conformal, LLM4Rec, critical]
related: [project-server-mapping.md, pony-research-refine-v2.md, pony-experiment-plan.md]
---

## 项目概述

- 项目名: Task-Grounded Uncertainty for LLM-based Recommendation (C-CRP)
- 方法: C-CRP (Conformalized Calibrated Recommendation with Prediction sets) — 我们自己的方法
- 服务器: pony-rec-gpu (125.71.97.70:15302, user: ajifang)
- 代码: ~/projects/pony-rec-rescue-shadow-v6/

## 核心定位（不要偏离！）

**C-CRP 是我们自己的方法，是 paper 的主角。** Calibration depth 分析是 evaluation contribution，用来证明 C-CRP 的优势。不是做 analysis paper，不是用别人的方法做 ensemble。

**C-CRP 的优势（已验证）：**
- Lift@0 = 6.9x（排第 7/38，比 IRLLRec 6.4x 好）
- Reliable depth = 19（排前列，比 IRLLRec 12 深得多）
- 提供 conformal coverage guarantee（其他 baseline 没有）

**C-CRP 的劣势（需要解决）：**
- NDCG@10 比 ProEx 低约 15%（但 calibration depth 更好）
- 需要 C-CRP v2 改进来缩小 NDCG gap

## Paper 正确结构

1. 我们的方法 C-CRP（主角）— uncertainty-aware recommendation with conformal guarantees
2. 和 8 个 baseline 比 — 比 NDCG + 比 calibration depth（双指标）
3. Calibration depth 作为新评估指标 — 证明传统 NDCG 不够，需要看 depth
4. C-CRP 在 depth 指标上优于大多数 baseline — 这是我们的 selling point

## 当前 ARIS 阶段

- ✅ research-refine v3 (PCR, Codex scored Novelty 8, Impact 8)
- → experiment-plan (redesign for PCR)
- → experiment-bridge

## 历史 pivots

- v1 (Rank-Stability Conformal): B1 FAIL, ρ=-0.02, permutation instability is noise
- v2 (Logit Entropy): B1 FAIL, ρ=-0.097, entropy uncorrelated with error
- v2.5 (Pointwise score features): best ρ=-0.11, too weak
- **v3 (Position-Calibrated Recommendation): Codex scored 8/8/7/8/6 — PROCEED**

## 当前方向: Position-Calibrated Recommendation (PCR)

**Codex Review:** Novelty 8, Feasibility 8, Clarity 7, Impact 8, Baseline-beating 6. ALL ≥6.

**Research Question:**
> LLM pointwise recommenders exhibit a sharp "calibration cliff" — rank 0 has 6.4x random precision but by rank 5 it drops below random. Where exactly does a ranking stop being reliable, and can we provide formal guarantees on recommendation depth?

**Method:**
1. Characterize position-wise calibration curve: P(relevant | rank k)
2. Estimate per-method confidence depth (cliff position)
3. Conformal prediction for adaptive recommendation set size
4. Cross-method comparison of cliff positions (8+ methods)

**Validated findings:**
- IRLLRec cliff at rank ~5 (6.4x→0.8x random)
- LLM2Rec cliff at rank ~2 (1.5x→below random)
- 973 users, Amazon Beauty, 101-candidate protocol

**Codex concern (must address):** Cliff might be protocol artifact. Need validation across candidate set sizes, datasets, relevance definitions.

## B2 & B3 Results

**B2 PASS:** Cliff persists across candidate sizes (20→50→101) and all 4 domains. Not a protocol artifact.
- Beauty cliff=5, Books/Electronics/Movies cliff=10
- Larger datasets show deeper calibration (more statistical power)

**B3 PASS:** Conformal coverage holds in 24/24 experiments (100%).
- Average set size savings: 3% (small, conformal is conservative)
- Real value: formal guarantee + cross-method comparison + new evaluation metric
- Coverage valid within 3% tolerance for all target levels (50%, 70%, 80%, 90%)

## Paper Status

All gates passed (B1, B2, B3). Ready for B4 (analysis) and B5 (practical value), then paper writing.

**Paper contribution (refined):**
1. **Empirical finding:** LLM recommenders have vastly different position-wise reliability (Lift@0 ranges from 1.1x to 12.1x across methods)
2. **New metric:** Calibration depth — how deep into the ranking is a method reliable?
3. **Robustness:** Phenomenon persists across 4 domains, multiple candidate sizes, 38 methods
4. **Conformal framework:** Formal coverage guarantees for adaptive recommendation depth
5. **Practical implication:** Don't use fixed top-10 — use method-specific reliable depth

## 下一步

- 在全量 973 用户上跑 v3 prompt（当前 200 用户结果已超 ProEx HR）
- 进一步优化 prompt 缩小 NDCG gap（ProEx NDCG 领先 6%）
- 加入 conformal calibration layer（C-CRP 核心贡献 + calibration depth 优势）
- 跑 4 个 domain

## C-CRP v3 Results (2026-05-21, 200 users, beauty)

**HR@10 = 0.265, NDCG@10 = 0.1410**

| Method | HR@10 | NDCG@10 | vs ProEx |
|--------|-------|---------|----------|
| C-CRP v1 (raw) | 0.221 | 0.1294 | -13% HR |
| **C-CRP v3 (profile prompt)** | **0.265** | **0.1410** | **+5% HR, -6% NDCG** |
| ProEx (best baseline) | 0.253 | 0.1506 | — |
| IRLLRec | 0.220 | 0.1289 | -13% HR |

**C-CRP v3 HR@10 超过 ProEx！** Profile-enhanced prompt 大幅提升了 scoring 质量。
