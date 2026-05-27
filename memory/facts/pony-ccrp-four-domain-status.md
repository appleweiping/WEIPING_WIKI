---
title: "PonyRec 项目全状态 (2026-05-25 更新)"
type: fact
created: 2026-05-24T15:20:00+08:00
updated: 2026-05-25T21:00:00+08:00
agent: claude
tags: [pony, c-crp, srpd, experiment, status, four-domain]
related: [pony-ccrp-v2-decision.md]
---

## 当前阶段: M5 四域验证 → 接近完成

### 主表方法: C-CRP v3 (pointwise relevance probability)

脚本: `experiments/rsc/run_ccrp_v3_domain.py`
模型: Qwen3-8B, vLLM batch, max_model_len=2048
数据: same-candidate protocol, 101 candidates/user (1 pos + 100 neg)

| Domain | Users | HR@5 | NDCG@5 | HR@10 | NDCG@10 | HR@20 | NDCG@20 | MRR | vs Best Baseline |
|--------|-------|------|--------|-------|---------|-------|---------|-----|-----------------|
| Books | 10,000 | 0.374 | 0.300 | 0.476 | 0.333 | 0.592 | 0.362 | 0.306 | **SOTA** (+21.5% vs LLMEmb) |
| Electronics | 10,000 | 0.218 | 0.157 | 0.299 | 0.183 | 0.418 | 0.213 | 0.168 | **SOTA** (+52.5% vs LLMEmb) |
| Movies | 10,000 | 0.145 | 0.108 | 0.208 | 0.128 | 0.331 | 0.159 | 0.127 | 排第4-6 (LLMEmb=0.169) |
| Beauty | 973 | — | — | 0.239* | 0.136* | — | — | — | 接近 ProEx (差6%) |

*Beauty 全指标正在排队跑

### 关键决策

1. **不用 formal C-CRP** — uncertainty decomposition + risk penalty 在 beauty 上反而变差 (0.131 vs 0.136)
2. **不用 temperature scaling** — post-hoc 无法创造区分力, movies 问题是 scoring 本身
3. **尝试 v4 enhanced prompt** — 提取 category, 更长 description, 更多 history。先跑 movies 验证

### 观察链

| 环节 | Beauty | Books | Electronics | Movies |
|------|--------|-------|-------------|--------|
| 1. Raw confidence 诊断 | ✅ | 🔄 跑中 | 🔄 跑中 | 🔄 跑中 |
| 2. Reliability bins | ✅ | 🔄 | 🔄 | 🔄 |
| 3. Baselines miscalibration | ✅ | ✅ | ✅ | ✅ |
| 4. C-CRP v3 主表 | 🔄 排队 | ✅ | ✅ | ✅ |
| 5. Official baselines 8个 | ✅ | ✅ | ✅ | ✅ |

### GPU 队列 (自动执行, 不需干预)

1. 三域诊断 (PID 2812434) — ~15h remaining
2. Beauty v3 全指标 (PID 2910032) — ~43min
3. Movies v4 验证 (PID 2911797) — ~7-9h

### 关键文件位置

- 总表: `outputs/ccrp_v3_formal/main_comparison_table.csv`
- Baseline 诊断: `outputs/baseline_calibration_diagnostic/{domain}/{method}/`
- C-CRP v3 结果: `outputs/ccrp_v3_formal/{domain}/report.json`
- v4 脚本: `experiments/rsc/run_ccrp_v4_enhanced.py`
- 服务器: `pony-rec-gpu:~/projects/pony-rec-rescue-shadow-v6/`
- 本地: `D:\Research\Uncertainty\`

### 下一步

- Movies v4 结果出来后决定: 有效 → 四域全跑 v4; 无效 → v3 + narrative 收工
- Beauty 全指标补完后更新总表
- 三域诊断完成后, 观察链 1/2 环节全部完成
- 之后进入论文写作阶段 (M6)

---

## 2026-05-25 更新

### C-CRP v3: 全部完成 ✅

所有四域实验已完成, 观察链 100%, Paper 初稿已写完:

| Domain | Users | HR@5 | NDCG@5 | HR@10 | NDCG@10 | HR@20 | NDCG@20 | MRR | Rank |
|--------|-------|------|--------|-------|---------|-------|---------|-----|------|
| Books | 10,000 | 0.374 | 0.300 | 0.476 | 0.333 | 0.592 | 0.362 | 0.306 | **#1 SOTA** |
| Electronics | 10,000 | 0.218 | 0.157 | 0.299 | 0.183 | 0.418 | 0.213 | 0.168 | **#1 SOTA** |
| Beauty | 973 | 0.157 | 0.111 | 0.229 | 0.134 | 0.369 | 0.169 | 0.128 | #2 (ProEx #1) |
| Movies | 10,000 | 0.145 | 0.108 | 0.208 | 0.128 | 0.331 | 0.159 | 0.127 | #5 (LLMEmb #1) |

### 已放弃的方向
- **V4 enhanced prompt**: movies 上更差, 放弃
- **Temperature scaling**: 数学上无效 (monotonic transform preserves rank order)
- **Formal C-CRP (uncertainty decomposition)**: beauty 上变差

### SRPD Pipeline: Step 5 运行中 🔄

目标: 补强 C-CRP v3 在 beauty/movies 的短板 (trainable listwise ranking + LoRA)

**完整操作手册**: `memory/workflows/srpd-pipeline-full-guide.md`

**当前进程**: PID 3762241 (GPU 33.3GB), Log: `outputs/summary/logs/srpd_steps4_6.log`

| Step | 内容 | beauty | books | electronics | movies |
|------|------|--------|-------|-------------|--------|
| 1 | Anchor rank (vLLM) | ✅ | ✅ | ✅ | ✅ |
| 2 | Teacher signal | ✅ | ✅ | ✅ | ✅ |
| 3 | Training data | ✅ | ✅ | ✅ | ✅ |
| 4 | LoRA training | ✅ | ✅ | ✅ | ✅ |
| 5 | Test inference (HF) | ✅ 973/973 | 🔄 41% | ⏳ | ⏳ |
| 6 | Evaluate | ⏳ | ⏳ | ⏳ | ⏳ |

**预计完成**: books ~26h + electronics ~40h + movies ~40h ≈ 4.4天 (2026-05-31)

关键技术决策:
- Step 1 用 vLLM + title-only prompts (~2.5K tokens) 代替 full-text (24K tokens), 避免 OOM
- 仍是全量: 10K users × 101 candidates, 非 toy
- Step 5 用 HF batch_size=1 (~15s/sample, vLLM 0.10.2 不支持 LoRA adapter loading)
- `VLLM_WORKER_MULTIPROC_METHOD=spawn` 解决 CUDA fork 问题
- `--resume_partial` 支持断点续跑

### Paper 状态

- 初稿完成: `D:\Research\Uncertainty\Paper\` (main.tex + sections/ + tables/)
- CLAIM_MAP.md 已对齐所有 claim-evidence
- 等 SRPD 结果后更新 main_results 表 + 补充 SRPD 相关 section
- 之后进入 Phase 5: internal review + auto-review-loop

### 新增关键文件
- `experiments/rsc/run_srpd_anchor_rank_vllm.py` — vLLM anchor rank 独立脚本 (Step 1)
- `experiments/rsc/run_srpd_steps2_6_formal.py` — Steps 2-6 主脚本
- `experiments/rsc/run_srpd_full_vllm.sh` — SRPD 完整 pipeline (旧, Step 1 only)
- `configs/model/qwen3_8b_vllm_rank_safe.yaml` — vLLM ranking 配置
- `configs/model/qwen3_8b_local_rank.yaml` — HF ranking 配置 (batch_size=1)
- `configs/lora/{prefix}_srpd_v6_formal.yaml` — 4 个 LoRA 训练配置
- `configs/srpd/{prefix}_srpd_v6_formal.yaml` — 4 个 SRPD 数据配置
- `src/training/lora_rank_trainer.py` — LoRA 训练核心 (已修 2 处 bug)
- `artifacts/adapters/{prefix}_srpd_v6_formal/` — 4 个 LoRA adapter
