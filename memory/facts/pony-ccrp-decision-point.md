---
title: "Pony C-CRP 关键决策点 — 77% gap 分析"
type: fact
created: 2026-05-21T09:56:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: opencode
tags: [pony, C-CRP, decision-point, pointwise-vs-listwise, critical]
related: [pony-current-status.md]
---

## 问题

Results show 77% gap vs direct ranking baseline (0.137 vs 0.614 NDCG@10).

- Cascade signal is useless (alpha=1.0 optimal)
- Self-consistency gives only +0.003

## Root Cause Analysis

Pointwise scoring is fundamentally inferior to listwise for 101-candidate discrimination. Conformal calibration cannot create discriminative signal that doesn't exist in raw scores.

## Decision Required

Need to decide whether to:
1. Pivot to listwise approach
2. Redesign the conformal prediction framework to work with listwise signals
3. Find a hybrid approach that preserves uncertainty quantification while using listwise ranking
