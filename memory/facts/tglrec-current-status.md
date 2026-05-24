---
title: "TGL-Rec 项目当前状态 — Phase 10 已启动"
type: fact
created: 2026-05-21T23:00:00+08:00
updated: 2026-05-21T23:00:00+08:00
agent: claude
tags: [TGL-Rec, temporal-graph, LLM4Rec, research, critical]
related: [all-projects-status.md, project-server-mapping.md, research-hard-rules.md]
---

## 项目状态

| 维度 | 值 |
|------|-----|
| 阶段 | Phase 10 — 已启动实现 |
| 方向 | Temporal Need-State Evidence for LLM Reranking |
| 服务器 | 未部署（部署脚本已就绪） |
| Baseline | 8个Pony官方baseline x 4 domains = 32个结果，全部完成 |
| 方法状态 | Reportable scoring path 已实现，待服务器训练 |
| Git commit | 7250b2e (codex/phase9e-lora-rerank-eval) |
| 下一步 | 部署到服务器 → 跑observation实验 |

## 核心创新（已通过文献压力测试 2026-05-21）

**Claim**: LLM推荐系统系统性地忽略时序转移信号；TGL-Rec通过显式时序图证据+学习的need-gate修复这一问题。

**与竞品的区别**:
- vs CETRec [2507.03047]: 我们提供外部证据，不是修改LLM内部时序敏感性
- vs G-Refer [2502.12586]: 我们用时序item-item转移图，不是静态CF图
- vs Temporal Awareness [2405.02778]: 我们有训练的gate和LoRA，不是纯prompt
- vs FlexRec [2603.11901]: 我们的need是数据驱动的temporal state，不是用户指令

**最强审稿人攻击**: "这不就是G-Refer加时间戳？"
**反驳**: G-Refer检索静态user-item CF路径；我们构建item-item时序转移图，need-gate从temporal state学习何时激活。机制完全不同。

## 技术架构（4个核心组件）

1. **TDIG** (Temporal Directed Item Graph): 从train-only交互构建时序有向item转移图
2. **Need-State Encoder**: 计算用户temporal state（drift, transition pressure, gap, entropy）
3. **Learned Need-Gate**: 26参数logistic gate，决定何时信任temporal evidence
4. **Two-Stage Scoring**: Stage 1 evidence scoring (all candidates) → Stage 2 LoRA reranking (top-K)

## 实验计划（~700 GPU小时）

| Block | 内容 | 预计时间 |
|-------|------|---------|
| 1 | Observation (base Qwen3-8B是否忽略时序) | Week 1 |
| 2 | Gate验证 (learned vs fixed) | Week 2 |
| 3 | Component ablation (7个变体) | Week 2 |
| 4 | Main comparison (20 seeds) | Week 3-4 |
| 5 | Mechanism分析 | Week 4 |
| 6 | Robustness | Week 4 |

**Stage Gate**: 如果observation显示base Qwen3-8B已经对时序敏感（shuffling显著降低性能），则STOP并reformulate。

## 已完成的代码产出（commit 7250b2e）

- `docs/technical_design.md` — 完整技术设计（13 sections，数学公式）
- `docs/EXPERIMENT_PLAN.md` — ARIS格式实验计划
- `src/llm4rec/evidence/need_state.py` — NeedStateEncoder
- `src/llm4rec/evidence/need_gate.py` — LearnedNeedGate（已通过单元测试）
- `src/llm4rec/evidence/reportable_scorer.py` — ReportableScorer
- `scripts/train_need_gate.py` — Gate训练脚本
- `scripts/prepare_lora_data.py` — LoRA数据准备
- `scripts/deploy_server.sh` — 独立部署脚本
- `scripts/run_observation.py` — Observation实验脚本

## 8个Official Baselines（全部完成）

| Baseline | Beauty | Books | Electronics | Movies |
|----------|--------|-------|-------------|--------|
| llm2rec | 0.058 | 0.198 | 0.058 | 0.132 |
| llmesr | 0.097 | 0.073 | 0.068 | 0.073 |
| llmemb | - | - | - | - |
| rlmrec | 0.125 | 0.127 | 0.081 | 0.116 |
| irllrec | 0.124 | 0.155 | 0.097 | 0.129 |
| elmrec | 0.081 | 0.058 | 0.055 | 0.068 |
| proex | 0.143 | 0.114 | 0.067 | 0.112 |
| promax | 0.122 | 0.097 | 0.066 | 0.109 |

(MRR, test split. llmemb数值待从CSV提取)

**我们需要beat的目标**: Beauty上proex(0.143), Books上llm2rec(0.198), Electronics上irllrec(0.097), Movies上llm2rec(0.132)

## 与Pony的隔离保证

- 独立目录: `~/projects/TGL-Rec/`
- 独立环境: `conda env tglrec`
- 只读引用: symlink Pony的external_tasks（不修改）
- 只复用分数: 已导入的baseline scores
- 绝不修改Pony项目的任何文件
