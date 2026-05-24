---
title: "TRUCE-Rec 项目当前状态 — 服务器部署阶段"
type: fact
created: 2026-05-21T23:30:00+08:00
updated: 2026-05-21T23:30:00+08:00
agent: claude
tags: [TRUCE-Rec, uncertainty, LLM4Rec, generative-recommendation, research, critical]
related: [all-projects-status.md, project-server-mapping.md, research-hard-rules.md]
---

## 项目状态

| 维度 | 值 |
|------|-----|
| 阶段 | Gate R1 — 服务器部署 + 四域实验构建 |
| 方向 | Uncertainty-Aware Generative Recommendation (title grounding + confidence decomposition + exposure-aware calibration) |
| 服务器 | 未部署（部署命令已就绪） |
| 本地代码 | 完整（80+ tests, 60+ scripts, 全部 scaffold） |
| Novelty | 2026-05-21 文献确认安全 |
| Git | main branch, origin https://github.com/appleweiping/TRUCE-Rec.git |

## 与 Pony/TGL-Rec 的关系

- 共同点：同组论文，共享 8 个外部 baseline 和数据 setting（Amazon 四域 same-candidate）
- 不同点：方法/framework 完全不同
- Baseline 分数可复用（同 baseline + 同数据 = 同分数）
- 方法代码绝不混用
- 服务器独立部署

## 核心创新（2026-05-21 文献压力测试通过）

**Claim**: LLM generative recommendation 的 confidence 不只是 reliability signal，
而是 exposure-shaping variable。Confidence 被 popularity prior 污染后，通过
exposure feedback 放大 echo chamber。

**与竞品区别**:
- vs UGR (2602.11719): UGR 做 Semantic-ID 的 uncertainty-weighted reward；TRUCE 做 free-form title generation + catalog grounding + confidence-popularity disentanglement
- vs Echoes in the Loop (2602.07442): 纯诊断框架，没有方法；TRUCE 提供解决方案
- vs Uncertainty & Fairness (2602.02582): 只用 entropy 做 zero-shot fairness；TRUCE 做 full confidence decomposition

## 技术架构

1. Title-level generative recommendation + catalog grounding
2. Triangulated confidence elicitation (verbal, token-prob, margin, semantic consensus, counterfactual stability)
3. Popularity-confidence causal disentanglement
4. Exposure-counterfactual confidence target: C(u,i) ≈ P(user accepts | do(exposure))
5. Uncertainty-guided data triage (not naive pruning)
6. Ours adapter: Qwen3-8B + LoRA with promote/suppress/defer policy

## 下一步

1. 部署到服务器
2. 准备四域 same-candidate 数据
3. 跑 base Qwen3-8B observation
4. 跑 Ours + ablations
5. 对比 8 个共享 baseline

Related: [[pony-current-status]], [[tglrec-current-status]], [[all-projects-status]]
