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

- ✅ research-refine (Codex scored Novelty 7/10)
- ✅ experiment-plan (6 blocks, 8 baselines, Codex scored Paper 7/10)
- 🔄 experiment-bridge (M0 passed, B1 full run in progress)

## M0 Sanity Check 结果 (2026-05-21)

- Spearman ρ = 0.91 (threshold: 0.2)
- Quartile error rates: 0.167 → 0.333 → 0.500 → 1.000 (perfectly monotonic)
- Decision: PROCEED

## 方法核心

1. Listwise LLM reranker (Qwen3-8B) reranks 20 candidates per user
2. Run K=10 passes with different input permutations
3. Per-user rank variance = uncertainty signal
4. Conditional conformal prediction per stability group
5. Output: adaptive prediction sets (stable users → small sets, unstable → large)

## 下一步

- 等 B1 full run 完成 (200 users × 10 passes, ~30-60 min)
- 确认 full ρ > 0.2 + monotonicity + controls
- 然后实现 B2 (conditional conformal pipeline)
