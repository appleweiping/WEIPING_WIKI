---
title: "ProteinShift experiment-plan 完成"
type: fact
created: 2026-05-20T00:00:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: codex
tags: [ProteinShift, experiment-plan, DTCR, ACI, decision-gap, milestones]
related: [research-hard-rules.md]
---

## 状态

项目路径: D:\research\ProteinShift
状态: experiment-plan 完成 (经 GPT-5.5 审核并修订)，下一步 /experiment-bridge (实现代码)

## 实验计划要点

- 7 个 Block: B1 DG现象, B2 排除surrogate退化, B3 方法对比(含ACI/FACI), B4 机制分解, B5 surrogate鲁棒性, B6 下游优化性能, B7 现实模拟
- Baselines: Standard CP, ACI (Gibbs&Candes 2021), FACI, Coverage-WCP, DTCR, DTCR-fixed(λ=1)
- 关键设计决策: 每个UQ方法跑独立trajectory (UCB用interval width → 不同选择 → 不同优化路径)

## Milestones

M0(sanity) → M1(DG>0.3?) → M2(full panel) → M2b(seed expansion) → M3(method comparison) → M4(downstream+mechanism) → M5(robustness) → M6(extended)

## Decision Gates

- M1 DG<0.1 → STOP
- M3 DTCR不显著 → fall back to analysis paper

## 计算

~120 GPU-hours on 1× RTX 4090

## GPT-5.5 审核分数

Evidence 7, Rigor 7, Gates 8, Feasibility 6, Paper 7

## 输出文件

- refine-logs/EXPERIMENT_PLAN.md (已修订)
- refine-logs/EXPERIMENT_TRACKER.md (已修订)
