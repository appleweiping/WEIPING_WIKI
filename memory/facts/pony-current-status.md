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

- 项目名: Ranking Stability as Uncertainty for LLM-Based Recommendation
- 方法: RSC (Rank-Stability Conformal) — permutation instability as uncertainty signal
- 服务器: pony-rec-gpu (125.71.97.70:15302, user: ajifang)
- 代码: ~/projects/pony-rec-rescue-shadow-v6/experiments/rsc/
- Conda env: qwen_vllm

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

## 下一步

- 设计 experiment-plan 围绕 PCR
- 核心 blocks: cliff characterization (8 methods), cross-dataset, candidate-size sensitivity, conformal adaptive depth, practical value

## 下一步

- 设计 position-calibration 实验
- 用已有的 pointwise scores 计算 position-wise accuracy curve
- 看不同用户的 calibration curve 是否有差异（有差异 = 可以做 adaptive cutoff）
