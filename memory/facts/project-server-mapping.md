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
| D:\research\TRUCE-Rec | ~/projects/uncertainty-llm4rec/ (旧版) | Uncertainty-Aware LLM4Rec / Storyflow |

## 关键区分

- **pony-rec-rescue-shadow-v6 ≠ TGL-Rec！** 它是 Pony/Uncertainty 项目
- 三个项目都是推荐系统, 共享外部 baseline 设定, 但各自方法完全不同
- **Pony**: Task-Grounded Uncertainty signals (Shadow series, verbalized confidence, calibration)
- **TGL-Rec**: Temporal Graph evidence + Need-Gate + LoRA reranking
- **TRUCE-Rec**: Storyflow / uncertainty-aware generative recommendation

## 服务器信息

- Host: pony-rec-gpu (125.71.97.70:15302)
- User: ajifang
- GPU: RTX 4090
