---
title: "项目-服务器映射 (Pony, TGL-Rec, TRUCE-Rec)"
type: fact
created: 2026-05-20T00:00:00+08:00
updated: 2026-05-21T10:00:00+08:00
agent: claude
tags: [pony, TGL-Rec, TRUCE-Rec, server, mapping, critical]
related: [pony-current-status.md, proteinshift-status.md]
---

## 正确映射

| 本地项目 | 服务器路径 | 项目本质 |
|---------|-----------|---------|
| Pony/Uncertainty | ~/projects/pony-rec-rescue-shadow-v6/ | Task-Grounded Uncertainty for LLM-based Recommendation (主力项目) |
| D:\research\TGL-Rec | 未部署到服务器 | Temporal Graph + LLM Rec (独立项目) |
| D:\research\TRUCE-Rec | ~/projects/TRUCE-Rec (待部署) | Uncertainty-Aware Generative Recommendation (独立项目) |

## 三个项目的关系

- 三个项目都是推荐系统论文，共享 8 个外部 baseline 和数据 setting
- 8 个共享 baseline: LLM2Rec, LLM-ESR, LLMEmb, RLMRec, IRLLRec, ELMRec, ProEx, ProMax
- 数据 setting: Amazon 四域 (Beauty/Books/Electronics/Movies), same-candidate, Qwen3-8B + LoRA
- Baseline 分数可复用（同 baseline + 同数据 = 同分数）
- 方法/framework 完全不同，代码绝不混用：
  - **Pony**: Task-Grounded Uncertainty signals (Shadow series, verbalized confidence, calibration)
  - **TGL-Rec**: Temporal Graph evidence + Need-Gate + LoRA reranking
  - **TRUCE-Rec**: Title grounding + Confidence-popularity disentanglement + Exposure-counterfactual calibration

## 服务器信息

- Host: pony-rec-gpu (125.71.97.70:15302)
- User: ajifang
- GPU: RTX 4090
