---
title: "全部项目状态与优先级"
type: fact
created: 2026-05-21T22:00:00+08:00
updated: 2026-05-21T23:30:00+08:00
agent: claude
tags: [projects, priority, all-agents, critical]
related: [pony-current-status.md, truce-rec-current-status.md, tglrec-current-status.md, project-server-mapping.md, research-hard-rules.md]
---

## 项目优先级（顺序执行，但可交错）

### 执行逻辑

科研项目按优先级顺序推进，但**当一个项目在服务器跑实验时，可以切换到下一个项目做准备工作**（research-refine、experiment-plan 等不需要 GPU 的步骤）。等实验跑完再回头处理结果。这样不浪费等待时间。

**不允许的是：** 同时在两个项目上做同一类工作（比如同时写两个项目的代码）。

### 科研项目（按顺序，一个做完再做下一个）

| # | 项目 | 方向 | 状态 | 服务器 |
|---|------|------|------|--------|
| 1 | **Pony/Uncertainty (RSC)** | Ranking Stability Conformal for LLM-Rec | 🔄 experiment-bridge (M0 passed ρ=0.91) | pony-rec-gpu |
| 2 | **TGL-Rec** | Temporal Graph + LLM Rec | 🔄 Phase 10 已启动（reportable path实现，待部署服务器） | 未部署（脚本就绪） |
| 3 | **TRUCE-Rec** | Uncertainty-Aware Generative Rec (title grounding + confidence-popularity disentanglement + exposure-aware calibration) | 🔄 Gate R1: 代码完整，novelty确认，待服务器部署 | ~/projects/TRUCE-Rec (待部署) |
| 4 | **ProteinShift (DA-BCP)** | Decision-Aware Bilevel Conformal for Protein Optimization | ✅ M2 done (rank #2/10), next: stats+mechanism+paper | pony-rec-gpu |
| 5 | **CSATG-EDA** | Analog circuit design with AI | Phase 6c done, SOTA on OTA2, paper next | 服务器上有 |

### 软件/游戏项目（可与科研并行）

| 项目 | 负责 agent | 状态 |
|------|-----------|------|
| **My Terraria** | Codex (GPT-5.5) + DeepSeek (鲸鱼) | 外包，CC 不管 |

## 关键区分（不要搞混！）

- Pony、TGL-Rec、TRUCE-Rec 共享 8 个外部 baseline 和数据 setting
- 8 个共享 baseline: LLM2Rec, LLM-ESR, LLMEmb, RLMRec, IRLLRec, ELMRec, ProEx, ProMax
- 数据 setting: Amazon 四域 (Beauty/Books/Electronics/Movies), same-candidate, Qwen3-8B + LoRA
- Baseline 分数可复用（同 baseline + 同数据 = 同分数）
- 但三个项目的方法完全不同，代码绝不混用：
  - Pony: permutation instability → conformal prediction (ranking stability)
  - TGL-Rec: temporal graph evidence → need-gate → LoRA reranking
  - TRUCE-Rec: title grounding → confidence-popularity disentanglement → exposure-counterfactual calibration
- **不要把一个项目的方法/结果混到另一个项目里**

## My Terraria 外包规则

- 由 Codex (GPT-5.5) 主导，DeepSeek 辅助
- CC (Opus) 不参与日常开发，只在架构决策时被咨询
- 项目路径: D:\Terraria_doc (或相关目录)
- 定期自动迭代（如果可以配置 cron/automation）
