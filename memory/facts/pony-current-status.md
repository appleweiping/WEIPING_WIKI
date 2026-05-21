---
title: "Pony C-CRP 项目当前状态"
type: fact
created: 2026-05-21T03:30:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: claude
tags: [pony, C-CRP, uncertainty, LLM4Rec, beauty, baselines, critical]
related: [project-server-mapping.md, pony-ccrp-decision-point.md]
---

## 项目概述

- 项目名: Task-Grounded Uncertainty for LLM-based Recommendation
- 方法: C-CRP (Conformalized Calibrated Recommendation with Prediction sets)
- 服务器: pony-rec-gpu (125.71.97.70:15302, user: ajifang)
- 代码: ~/projects/pony-rec-rescue-shadow-v6/

## C-CRP Beauty Domain 状态

- raw pointwise inference 完成 (Qwen3-8B, beauty domain)
- 4 official baselines 完成: ProEx, SETRec, ELMRec, IRLLRec
- C-CRP formal pipeline 完成 (build_conformal_sets → evaluate)
- 对比结果: C-CRP 在 NDCG@10 上比 ProEx 低约 15%

## C-CRP v2 改进计划 (已确认执行)

根本原因: missing calibration-aware reranking + weak set construction

改进方向:
1. Phase 1: vLLM backend (已完成验证)
2. Phase 2: Calibration-aware reranking
3. Phase 3: Adaptive conformal sets
4. Phase 4: Full evaluation

## 下一步

- 继续 C-CRP v2 改进实现
- 目标: 超越 ProEx SOTA
